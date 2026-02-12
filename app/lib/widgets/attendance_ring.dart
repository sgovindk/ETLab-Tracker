import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated circular attendance ring with percentage in the centre.
class AttendanceRing extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final Color? color;
  final TextStyle? textStyle;

  const AttendanceRing({
    super.key,
    required this.percentage,
    this.size = 120,
    this.strokeWidth = 8,
    this.color,
    this.textStyle,
  });

  Color get _ringColor {
    if (color != null) return color!;
    if (percentage >= 85) return AppTheme.success;
    if (percentage >= 75) return AppTheme.accent;
    if (percentage >= 65) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: percentage.clamp(0, 100)),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _RingPainter(
              progress: value / 100,
              color: _ringColor,
              trackColor: AppTheme.cardBorder,
              strokeWidth: strokeWidth,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${value.toStringAsFixed(1)}%',
                    style: textStyle ?? AppTheme.monoMedium.copyWith(color: _ringColor),
                  ),
                  Text('overall', style: AppTheme.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
