import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final ButtonStyle? style;
  final bool isFilled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.style,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Widget button;
    
    if (isFilled) {
      button = FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: textColor ?? colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(
            vertical: height ?? 16,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: width != null ? Size(width!, height ?? 48) : null,
        ),
        child: _buildChild(context, colorScheme),
      );
    } else {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? OutlinedButton.styleFrom(
          foregroundColor: textColor ?? colorScheme.primary,
          padding: EdgeInsets.symmetric(
            vertical: height ?? 16,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: backgroundColor ?? colorScheme.primary,
            width: 2,
          ),
          minimumSize: width != null ? Size(width!, height ?? 48) : null,
        ),
        child: _buildChild(context, colorScheme),
      );
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
  
  Widget _buildChild(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? (isFilled ? colorScheme.onPrimary : colorScheme.primary),
          ),
        ),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: textColor ?? (isFilled ? colorScheme.onPrimary : colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

