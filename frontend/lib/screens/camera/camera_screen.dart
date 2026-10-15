import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../providers/emotion_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  XFile? _capturedImage;
  Uint8List? _capturedImageBytes;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Use front camera if available, otherwise use first camera
        final camera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final XFile image = await _controller!.takePicture();
      
      // Convert image to base64 (works on both web and mobile)
      final List<int> imageBytes = await image.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      if (mounted) {
        setState(() {
          _capturedImage = image;
          _capturedImageBytes = Uint8List.fromList(imageBytes);
          _base64Image = base64Image;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _retakePhoto() async {
    setState(() {
      _capturedImage = null;
      _capturedImageBytes = null;
      _base64Image = null;
    });
  }

  Future<void> _sendImageToAPI() async {
    if (_capturedImage == null) {
      return;
    }

    final emotionProvider = Provider.of<EmotionProvider>(context, listen: false);
    final success = await emotionProvider.detectEmotionFromImage(_capturedImage!);

    if (success && mounted) {
      NavigationService.goBack(true); // Return true to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emotion detected and saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emotionProvider.errorMessage ?? 'Failed to detect emotion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendBase64ToAPI() async {
    if (_base64Image == null) {
      return;
    }

    final emotionProvider = Provider.of<EmotionProvider>(context, listen: false);
    final success = await emotionProvider.detectEmotionFromBase64(_base64Image!);

    if (success && mounted) {
      NavigationService.goBack(true); // Return true to indicate success
      
      // Show success message with alert notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Emotion détectée et enregistrée !',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '✅ Une alerte a été envoyée automatiquement à votre médecin',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emotionProvider.errorMessage ?? 'Failed to detect emotion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Capture Face',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (!_isInitialized) {
      return const Center(
        child: LoadingWidget(message: 'Initializing camera...'),
      );
    }

    if (_capturedImage != null) {
      return _buildPreviewScreen(colorScheme);
    }

    return _buildCameraScreen(colorScheme);
  }

  Widget _buildCameraScreen(ColorScheme colorScheme) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: LoadingWidget(message: 'Loading camera...'),
      );
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),

        // Instructions Overlay
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Position your face in the frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Face Guide Overlay (optional visual guide)
        Center(
          child: Container(
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        // Capture Button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Capture Button
              GestureDetector(
                onTap: _isCapturing ? null : _captureImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 4,
                    ),
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap to capture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewScreen(ColorScheme colorScheme) {
    return Stack(
      children: [
        // Captured Image
        Positioned.fill(
          child: Image.memory(
            _capturedImageBytes!,
            fit: BoxFit.cover,
          ),
        ),

        // Action Buttons
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Base64 Info (for debugging, can be removed)
                if (_base64Image != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Image size: ${(_base64Image!.length / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                // Send Button
                Consumer<EmotionProvider>(
                  builder: (context, emotionProvider, _) {
                    return CustomButton(
                      text: 'Send to API',
                      onPressed: emotionProvider.isLoading
                          ? null
                          : _sendBase64ToAPI,
                      isLoading: emotionProvider.isLoading,
                      icon: Icons.send_rounded,
                      backgroundColor: colorScheme.primary,
                      width: double.infinity,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Retake Button
                OutlinedButton.icon(
                  onPressed: _retakePhoto,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}