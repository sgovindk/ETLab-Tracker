import 'package:flutter/material.dart';
import '../models/subject_attendance.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';

/// Card showing a single subject's attendance with a progress bar.
class SubjectCard extends StatelessWidget {
  final SubjectAttendance subject;
  final VoidCallback? onTap;

  const SubjectCard({super.key, required this.subject, this.onTap});

  Color get _barColor {
    if (subject.percentage >= 85) return AppTheme.success;
    if (subject.percentage >= 75) return AppTheme.accent;
    if (subject.percentage >= 65) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FeedbackService.lightTap();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: subject.isBelowThreshold
            ? AppTheme.glowDecoration(AppTheme.danger)
            : AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Subject code badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _barColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    subject.subjectCode,
                    style: AppTheme.bodySmall.copyWith(
                      color: _barColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${subject.percentage.toStringAsFixed(1)}%',
                  style: AppTheme.monoSmall.copyWith(color: _barColor),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textTertiary),
              ],
            ),
            const SizedBox(height: 10),

            // Subject name
            Text(
              subject.subjectName,
              style: AppTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Hours info
            Text(
              '${subject.hoursAttended} / ${subject.totalHours} hours',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: subject.percentage.clamp(0, 100) / 100),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  backgroundColor: AppTheme.cardBorder,
                  valueColor: AlwaysStoppedAnimation(_barColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
