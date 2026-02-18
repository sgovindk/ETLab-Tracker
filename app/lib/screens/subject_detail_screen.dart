import 'package:flutter/material.dart';
import '../models/subject_attendance.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';
import '../widgets/attendance_ring.dart';
import '../widgets/glass_card.dart';

/// Detailed view for a single subject with built-in calculator.
class SubjectDetailScreen extends StatefulWidget {
  final SubjectAttendance subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final _targetController = TextEditingController(text: '75');
  final _classesController = TextEditingController(text: '5');

  SubjectAttendance get s => widget.subject;

  @override
  void dispose() {
    _targetController.dispose();
    _classesController.dispose();
    super.dispose();
  }

  int get _classesNeeded {
    final target = double.tryParse(_targetController.text) ?? 75;
    return s.classesNeeded(target);
  }

  double get _projectedPct {
    final n = int.tryParse(_classesController.text) ?? 0;
    return s.projectedPercentage(n);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(s.subjectCode, style: AppTheme.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            FeedbackService.lightTap();
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Header
          Text(s.subjectName, style: AppTheme.headlineMedium),
          const SizedBox(height: 24),

          // Attendance Ring
          Center(
            child: AttendanceRing(
              percentage: s.percentage,
              size: 160,
              strokeWidth: 12,
              textStyle: AppTheme.monoLarge,
            ),
          ),
          const SizedBox(height: 24),

          // Stats Row
          Row(
            children: [
              _statBox('Attended', '${s.hoursAttended}', AppTheme.accent),
              const SizedBox(width: 12),
              _statBox('Total', '${s.totalHours}', AppTheme.textSecondary),
              const SizedBox(width: 12),
              _statBox(
                'Can Bunk',
                '${s.bunkableClasses()}',
                s.bunkableClasses() > 0 ? AppTheme.success : AppTheme.danger,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Target Calculator
          Text('TARGET CALCULATOR', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('I want to reach', style: AppTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        style: AppTheme.monoMedium.copyWith(color: AppTheme.accent),
                        decoration: const InputDecoration(
                          suffixText: '%',
                          hintText: '75',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.arrow_forward_rounded, color: AppTheme.textTertiary, size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _classesNeeded < 0 ? '∞' : '$_classesNeeded',
                              style: AppTheme.monoMedium.copyWith(color: AppTheme.accent),
                            ),
                            Text('classes needed', style: AppTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Projection Calculator
          Text('PROJECTION', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('If I attend', style: AppTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _classesController,
                        keyboardType: TextInputType.number,
                        style: AppTheme.monoMedium.copyWith(color: AppTheme.secondary),
                        decoration: const InputDecoration(
                          suffixText: 'classes',
                          hintText: '5',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.arrow_forward_rounded, color: AppTheme.textTertiary, size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_projectedPct.toStringAsFixed(1)}%',
                              style: AppTheme.monoMedium.copyWith(
                                color: _projectedPct >= 75 ? AppTheme.success : AppTheme.warning,
                              ),
                            ),
                            Text('projected', style: AppTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Visual comparison bar
                _comparisonBar(),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick projection table
          Text('QUICK LOOKUP', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tableHeader(),
                for (int i = 1; i <= 10; i++) _tableRow(i),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            Text(value, style: AppTheme.monoMedium.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _comparisonBar() {
    final n = int.tryParse(_classesController.text) ?? 0;
    final projected = s.projectedPercentage(n);

    return Column(
      children: [
        Row(
          children: [
            Text('Now', style: AppTheme.bodySmall),
            const Spacer(),
            Text('After +$n', style: AppTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            // Track
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Current
            FractionallySizedBox(
              widthFactor: (s.percentage / 100).clamp(0, 1),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            // Projected
            FractionallySizedBox(
              widthFactor: (projected / 100).clamp(0, 1),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: projected >= 75 ? AppTheme.success.withOpacity(0.5) : AppTheme.warning.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 75% marker
        Align(
          alignment: const Alignment(-0.5, 0), // ~75% position
          child: Column(
            children: [
              Container(width: 1, height: 8, color: AppTheme.danger.withOpacity(0.5)),
              Text('75%', style: AppTheme.bodySmall.copyWith(color: AppTheme.danger, fontSize: 9)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('+ Classes', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Text('New %', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Text('Change', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _tableRow(int n) {
    final projected = s.projectedPercentage(n);
    final change = projected - s.percentage;
    final color = projected >= 75 ? AppTheme.success : AppTheme.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('+$n', style: AppTheme.monoSmall)),
          Expanded(
            child: Text(
              '${projected.toStringAsFixed(1)}%',
              style: AppTheme.monoSmall.copyWith(color: color),
            ),
          ),
          Expanded(
            child: Text(
              '+${change.toStringAsFixed(1)}%',
              style: AppTheme.monoSmall.copyWith(color: AppTheme.success),
            ),
          ),
        ],
      ),
    );
  }
}
