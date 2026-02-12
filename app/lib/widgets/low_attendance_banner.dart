import 'package:flutter/material.dart';
import '../models/subject_attendance.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';

/// Horizontal scrollable banner for subjects below 75%.
class LowAttendanceBanner extends StatelessWidget {
  final List<SubjectAttendance> subjects;
  final void Function(SubjectAttendance)? onTap;

  const LowAttendanceBanner({super.key, required this.subjects, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.warning),
            const SizedBox(width: 6),
            Text(
              'LOW ATTENDANCE',
              style: AppTheme.labelLarge.copyWith(color: AppTheme.warning),
            ),
            const Spacer(),
            Text(
              '${subjects.length} subject${subjects.length > 1 ? 's' : ''}',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _chip(subjects[i]),
          ),
        ),
      ],
    );
  }

  Widget _chip(SubjectAttendance s) {
    final color = s.isCritical ? AppTheme.danger : AppTheme.warning;
    return GestureDetector(
      onTap: () {
        FeedbackService.lightTap();
        onTap?.call(s);
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.subjectCode,
              style: AppTheme.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
            Text(
              s.subjectName,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Text(
                  '${s.percentage.toStringAsFixed(1)}%',
                  style: AppTheme.monoSmall.copyWith(color: color),
                ),
                const Spacer(),
                Text(
                  'need ${s.classesNeeded(75)} cls',
                  style: AppTheme.bodySmall.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
