import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timetable_provider.dart';
import '../services/timetable_service.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';
import 'timetable_edit_screen.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _initialIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default to today's tab
    final today = TimetableService.todayName();
    _initialIndex = TimetableService.days.indexOf(today).clamp(0, 4);
    _tabCtrl = TabController(
      length: TimetableService.days.length,
      vsync: this,
      initialIndex: _initialIndex,
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule', style: AppTheme.headlineMedium),
        actions: [
          TextButton.icon(
            onPressed: () {
              FeedbackService.lightTap();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TimetableEditScreen()),
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit'),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textTertiary,
          indicatorColor: AppTheme.accent,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppTheme.divider,
          labelStyle: AppTheme.labelLarge,
          unselectedLabelStyle: AppTheme.bodySmall,
          tabAlignment: TabAlignment.start,
          tabs: TimetableService.days
              .map((d) => Tab(
                    text: d.substring(0, 3).toUpperCase(),
                  ))
              .toList(),
          onTap: (_) => FeedbackService.selectionClick(),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: TimetableService.days.map((day) {
          final entries = timetable.forDay(day);
          final isToday = day == TimetableService.todayName();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: entries.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Text(
                        day,
                        style: AppTheme.headlineSmall,
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'TODAY',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              final entry = entries[index - 1];
              final isCurrent = isToday &&
                  timetable.currentClass?.period == entry.period &&
                  timetable.currentClass?.day == entry.day;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _periodCard(entry, isCurrent),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _periodCard(entry, bool isCurrent) {
    Color typeColor;
    IconData typeIcon;
    switch (entry.type.toLowerCase()) {
      case 'lab':
        typeColor = AppTheme.secondary;
        typeIcon = Icons.science_rounded;
        break;
      case 'project':
        typeColor = AppTheme.warning;
        typeIcon = Icons.build_rounded;
        break;
      case 'free':
        typeColor = AppTheme.textTertiary;
        typeIcon = Icons.coffee_rounded;
        break;
      default:
        typeColor = AppTheme.accent;
        typeIcon = Icons.menu_book_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.success.withOpacity(0.06) : AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: isCurrent ? AppTheme.success.withOpacity(0.3) : AppTheme.cardBorder,
        ),
      ),
      child: Row(
        children: [
          // Time column
          SizedBox(
            width: 65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.period,
                  style: AppTheme.labelLarge.copyWith(
                    color: isCurrent ? AppTheme.success : AppTheme.textSecondary,
                  ),
                ),
                Text(
                  entry.time.split('–').first,
                  style: AppTheme.monoSmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 2,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isCurrent ? AppTheme.success : typeColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(typeIcon, size: 14, color: typeColor),
                    const SizedBox(width: 6),
                    if (entry.subjectCode.isNotEmpty && entry.subjectCode != 'FREE')
                      Text(
                        entry.subjectCode,
                        style: AppTheme.bodySmall.copyWith(color: typeColor, fontWeight: FontWeight.w600),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.type,
                        style: AppTheme.bodySmall.copyWith(color: typeColor, fontSize: 9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subjectName,
                  style: AppTheme.bodyLarge.copyWith(
                    color: entry.isFree ? AppTheme.textTertiary : AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.teacher.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(entry.teacher, style: AppTheme.bodySmall),
                ],
              ],
            ),
          ),

          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'NOW',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
