import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timetable_entry.dart';
import '../providers/timetable_provider.dart';
import '../services/timetable_service.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';

/// Screen for editing individual timetable entries.
class TimetableEditScreen extends StatelessWidget {
  const TimetableEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Schedule', style: AppTheme.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            FeedbackService.lightTap();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              FeedbackService.mediumTap();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  title: Text('Reset Timetable', style: AppTheme.titleMedium),
                  content: Text(
                    'This will revert all changes to the default timetable.',
                    style: AppTheme.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancel', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Reset', style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await timetable.resetToDefault();
                FeedbackService.success();
              }
            },
            child: Text('Reset', style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: TimetableService.days.length,
        itemBuilder: (context, dayIndex) {
          final day = TimetableService.days[dayIndex];
          final entries = timetable.forDay(day);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(day, style: AppTheme.headlineSmall),
              ),
              ...entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _editableEntry(context, entry, timetable),
                  )),
              if (dayIndex < TimetableService.days.length - 1)
                const Divider(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _editableEntry(BuildContext context, TimetableEntry entry, TimetableProvider provider) {
    return GestureDetector(
      onTap: () {
        FeedbackService.lightTap();
        _showEditDialog(context, entry, provider);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                entry.period,
                style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(entry.time, style: AppTheme.monoSmall.copyWith(fontSize: 11)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.subjectName,
                    style: AppTheme.bodyLarge.copyWith(
                      color: entry.isFree ? AppTheme.textTertiary : AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.teacher.isNotEmpty)
                    Text(entry.teacher, style: AppTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 16, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TimetableEntry entry, TimetableProvider provider) {
    final codeCtrl = TextEditingController(text: entry.subjectCode);
    final nameCtrl = TextEditingController(text: entry.subjectName);
    final teacherCtrl = TextEditingController(text: entry.teacher);
    String selectedType = entry.type;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Edit ${entry.period} · ${entry.day}',
                    style: AppTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: codeCtrl,
                    style: AppTheme.bodyLarge,
                    decoration: const InputDecoration(labelText: 'Subject Code'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    style: AppTheme.bodyLarge,
                    decoration: const InputDecoration(labelText: 'Subject Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: teacherCtrl,
                    style: AppTheme.bodyLarge,
                    decoration: const InputDecoration(labelText: 'Teacher'),
                  ),
                  const SizedBox(height: 16),

                  // Type selector
                  Text('TYPE', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Theory', 'Lab', 'Project', 'Free'].map((t) {
                      final isSelected = selectedType == t;
                      return GestureDetector(
                        onTap: () {
                          FeedbackService.selectionClick();
                          setModalState(() => selectedType = t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accent.withOpacity(0.12) : AppTheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
                            ),
                          ),
                          child: Text(
                            t,
                            style: AppTheme.bodySmall.copyWith(
                              color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        FeedbackService.success();
                        final newEntry = entry.copyWith(
                          subjectCode: codeCtrl.text.trim(),
                          subjectName: nameCtrl.text.trim(),
                          teacher: teacherCtrl.text.trim(),
                          type: selectedType,
                        );
                        await provider.replaceEntry(entry.day, entry.period, newEntry);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
