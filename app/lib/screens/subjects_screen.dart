import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/subject_card.dart';
import 'subject_detail_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _filter = 'all'; // all, low, safe

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final subjects = switch (_filter) {
      'low' => attendance.subjects.where((s) => s.isBelowThreshold).toList(),
      'safe' => attendance.subjects.where((s) => !s.isBelowThreshold).toList(),
      _ => attendance.subjects,
    };

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          title: Text('Subjects', style: AppTheme.headlineMedium),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _filterChip('All', 'all', attendance.subjects.length),
                  const SizedBox(width: 8),
                  _filterChip('Below 75%', 'low', attendance.belowThreshold.length),
                  const SizedBox(width: 8),
                  _filterChip(
                    'Safe',
                    'safe',
                    attendance.subjects.length - attendance.belowThreshold.length,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (subjects.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_outlined, size: 48, color: AppTheme.textTertiary),
                  const SizedBox(height: 12),
                  Text(
                    attendance.subjects.isEmpty
                        ? 'No attendance data yet.\nSync from the dashboard.'
                        : 'No subjects match this filter.',
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final s = subjects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SubjectCard(
                      subject: s,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectDetailScreen(subject: s),
                        ),
                      ),
                    ),
                  );
                },
                childCount: subjects.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _filterChip(String label, String value, int count) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withOpacity(0.12) : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.accent.withOpacity(0.4) : AppTheme.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: selected ? AppTheme.accent : AppTheme.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? AppTheme.accent.withOpacity(0.2) : AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: AppTheme.bodySmall.copyWith(
                  color: selected ? AppTheme.accent : AppTheme.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
