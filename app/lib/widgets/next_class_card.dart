import 'package:flutter/material.dart';
import '../models/timetable_entry.dart';
import '../services/timetable_service.dart';
import '../theme/app_theme.dart';

/// Shows the next upcoming class with countdown.
class NextClassCard extends StatelessWidget {
  final TimetableEntry? entry;
  final TimetableEntry? currentEntry;

  const NextClassCard({super.key, this.entry, this.currentEntry});

  @override
  Widget build(BuildContext context) {
    if (entry == null && currentEntry == null) {
      return _buildNoClass();
    }

    final isOngoing = currentEntry != null;
    final display = isOngoing ? currentEntry! : entry!;
    final minutes = TimetableService.minutesUntil(display.period);
    final statusText = isOngoing ? 'ONGOING' : _formatCountdown(minutes);
    final statusColor = isOngoing ? AppTheme.success : AppTheme.accent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowDecoration(statusColor),
      child: Row(
        children: [
          // Left icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOngoing ? Icons.play_circle_outline_rounded : Icons.schedule_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isOngoing ? 'NOW' : 'NEXT',
                      style: AppTheme.labelLarge.copyWith(color: statusColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${display.period}  ·  ${display.time}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  display.subjectName,
                  style: AppTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (display.teacher.isNotEmpty)
                  Text(display.teacher, style: AppTheme.bodyMedium),
              ],
            ),
          ),

          // Countdown badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.25)),
            ),
            child: Text(
              statusText,
              style: AppTheme.bodySmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoClass() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppTheme.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ALL DONE', style: AppTheme.labelLarge.copyWith(color: AppTheme.textTertiary)),
                const SizedBox(height: 2),
                Text('No more classes today', style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCountdown(int minutes) {
    if (minutes <= 0) return 'NOW';
    if (minutes < 60) return 'in ${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? 'in ${h}h ${m}m' : 'in ${h}h';
  }
}
