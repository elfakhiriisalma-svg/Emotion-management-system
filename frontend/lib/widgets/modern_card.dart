import 'package:flutter/material.dart';

/// Minimalist card widget with soft design
/// 24px rounded corners, no shadows, clean spacing
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const ModernCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(24),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: borderRadius ?? BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE5E5E5),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
