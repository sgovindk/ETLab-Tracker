import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.glowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = glowColor != null
        ? AppTheme.glowDecoration(glowColor!)
        : AppTheme.cardDecoration;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: decoration,
        child: child,
      ),
    );
  }
}
