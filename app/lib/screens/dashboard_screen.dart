import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/timetable_provider.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';
import '../services/timetable_service.dart';
import '../widgets/attendance_ring.dart';
import '../widgets/next_class_card.dart';
import '../widgets/stat_tile.dart';
import '../widgets/low_attendance_banner.dart';
import 'subject_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final timetable = context.watch<TimetableProvider>();

    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      onRefresh: () async {
        FeedbackService.refreshThreshold();
        await attendance.refresh();
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            title: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: attendance.isLoggedIn ? AppTheme.success : AppTheme.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text('ETLab Tracker', style: AppTheme.headlineMedium),
              ],
            ),
            actions: [
              if (attendance.status == SyncStatus.syncing)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accent,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.sync_rounded, size: 22),
                  onPressed: () {
                    FeedbackService.mediumTap();
                    attendance.refresh();
                  },
                  tooltip: 'Sync attendance',
                ),
            ],
          ),

          // Body
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Next Class Card
                NextClassCard(
                  entry: timetable.nextClass,
                  currentEntry: timetable.currentClass,
                ),
                const SizedBox(height: 20),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: AttendanceRing(
                        percentage: attendance.overallPercentage,
                        size: 130,
                        strokeWidth: 10,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          StatTile(
                            label: 'Subjects',
                            value: '${attendance.totalSubjects}',
                            icon: Icons.menu_book_rounded,
                            accentColor: AppTheme.accent,
                          ),
                          const SizedBox(height: 10),
                          StatTile(
                            label: 'Below 75%',
                            value: '${attendance.belowThreshold.length}',
                            icon: Icons.warning_amber_rounded,
                            accentColor: attendance.belowThreshold.isNotEmpty
                                ? AppTheme.danger
                                : AppTheme.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Low Attendance Banner
                LowAttendanceBanner(
                  subjects: attendance.belowThreshold,
                  onTap: (s) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubjectDetailScreen(subject: s),
                    ),
                  ),
                ),
                if (attendance.belowThreshold.isNotEmpty)
                  const SizedBox(height: 24),

                // Today's Schedule
                _sectionHeader('TODAY\'S SCHEDULE', TimetableService.todayName()),
                const SizedBox(height: 12),
                ...timetable.todayEntries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _scheduleRow(entry, timetable),
                    )),
                if (timetable.todayEntries.isEmpty)
                  _emptyState('No classes today'),

                const SizedBox(height: 24),

                // Last Sync Info
                if (attendance.lastSync != null)
                  Center(
                    child: Text(
                      'Last synced: ${_formatTime(attendance.lastSync!)}',
                      style: AppTheme.bodySmall,
                    ),
                  ),
                if (attendance.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        attendance.error,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.danger),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Text(title, style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(subtitle, style: AppTheme.bodySmall.copyWith(color: AppTheme.accent)),
        ),
      ],
    );
  }

  Widget _scheduleRow(dynamic entry, TimetableProvider timetable) {
    final isCurrent = timetable.currentClass?.period == entry.period &&
        timetable.currentClass?.day == entry.day;
    final isPast = !entry.isFree &&
        !isCurrent &&
        (TimetableService.periodEndHour[entry.period] ?? 0) <
            DateTime.now().hour + DateTime.now().minute / 60.0 &&
        entry.day == TimetableService.todayName();

    Color dotColor = AppTheme.textTertiary;
    if (isCurrent) dotColor = AppTheme.success;
    if (isPast) dotColor = AppTheme.accent.withOpacity(0.4);
    if (entry.isFree) dotColor = AppTheme.textTertiary.withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.success.withOpacity(0.06) : AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: isCurrent ? AppTheme.success.withOpacity(0.3) : AppTheme.cardBorder,
        ),
      ),
      child: Row(
        children: [
          // Timeline dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          // Period
          SizedBox(
            width: 28,
            child: Text(entry.period, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          // Subject
          Expanded(
            child: Text(
              entry.subjectName,
              style: AppTheme.bodyLarge.copyWith(
                color: entry.isFree ? AppTheme.textTertiary : AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Time
          Text(
            entry.time.split('–').first,
            style: AppTheme.monoSmall.copyWith(fontSize: 11),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('NOW', style: AppTheme.bodySmall.copyWith(color: AppTheme.success, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ],
          if (isPast) ...[
            const SizedBox(width: 8),
            Icon(Icons.check, size: 14, color: AppTheme.accent.withOpacity(0.4)),
          ],
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Center(
        child: Text(message, style: AppTheme.bodyMedium),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
