import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../services/navigation_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genderOptions = [
    'MALE',
    'FEMALE',
    'OTHER',
    'PREFER_NOT_TO_SAY',
  ];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    // Only employees can update age and gender
    int? age;
    if (_ageController.text.isNotEmpty) {
      age = int.tryParse(_ageController.text);
    }
    
    final success = await authProvider.updateProfile(
      _fullNameController.text.trim(),
      _emailController.text.trim(),
      age: user?.isEmployee == true ? age : null,
      gender: user?.isEmployee == true ? _selectedGender : null,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      NavigationService.goBack();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      // Age and Gender fields - only for employees
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          if (authProvider.currentUser?.isEmployee == true) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 20),
                                CustomTextField(
                                  controller: _ageController,
                                  label: 'Age',
                                  hint: 'Enter your age',
                                  prefixIcon: Icons.calendar_today_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final age = int.tryParse(value);
                                      if (age == null) {
                                        return 'Please enter a valid age';
                                      }
                                      if (age < 1 || age > 150) {
                                        return 'Age must be between 1 and 150';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    hintText: 'Select your gender',
                                    prefixIcon: const Icon(Icons.person_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: _genderOptions.map((String gender) {
                                    String displayText;
                                    switch (gender) {
                                      case 'MALE':
                                        displayText = 'Male';
                                        break;
                                      case 'FEMALE':
                                        displayText = 'Female';
                                        break;
                                      case 'OTHER':
                                        displayText = 'Other';
                                        break;
                                      case 'PREFER_NOT_TO_SAY':
                                        displayText = 'Prefer not to say';
                                        break;
                                      default:
                                        displayText = gender;
                                    }
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(displayText),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  },
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'Save Changes',
                        onPressed: _saveProfile,
                        isLoading: _isLoading,
                        icon: Icons.save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


