import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject_attendance.dart';
import '../providers/attendance_provider.dart';
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
  final _attendController = TextEditingController(text: '0');
  final _bunkController = TextEditingController(text: '0');

  SubjectAttendance get s => widget.subject;

  @override
  void dispose() {
    _targetController.dispose();
    _attendController.dispose();
    _bunkController.dispose();
    super.dispose();
  }

  int get _classesNeeded {
    final target = double.tryParse(_targetController.text) ?? 75;
    return s.classesNeeded(target);
  }

  int get _attendCount => int.tryParse(_attendController.text) ?? 0;
  int get _bunkCount => int.tryParse(_bunkController.text) ?? 0;

  double get _projectedPct => s.predictedPercentage(_attendCount, _bunkCount);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 20),
            onPressed: () => _showEditDialog(context),
            tooltip: 'Edit subject name',
          ),
        ],
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

          // Prediction Calculator
          Text('PREDICT YOUR ATTENDANCE', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attend row
                _stepperRow(
                  label: 'Classes to attend',
                  icon: Icons.add_circle_outline_rounded,
                  color: AppTheme.success,
                  value: _attendCount,
                  onChanged: (v) => setState(() => _attendController.text = '$v'),
                ),
                const SizedBox(height: 16),
                // Bunk row
                _stepperRow(
                  label: 'Classes to bunk',
                  icon: Icons.remove_circle_outline_rounded,
                  color: AppTheme.danger,
                  value: _bunkCount,
                  onChanged: (v) => setState(() => _bunkController.text = '$v'),
                ),
                const SizedBox(height: 20),
                // Result
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: _projectedPct >= 75
                          ? AppTheme.success.withOpacity(0.3)
                          : AppTheme.danger.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_projectedPct.toStringAsFixed(1)}%',
                        style: AppTheme.monoLarge.copyWith(
                          color: _projectedPct >= 75 ? AppTheme.success : AppTheme.danger,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _predictionSummary(),
                        style: AppTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
          const SizedBox(height: 16),

          // Bunk scenarios table
          Text('BUNK SCENARIOS', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _bunkTableHeader(),
                for (int i = 1; i <= 10; i++) _bunkTableRow(i),
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
    final projected = _projectedPct;
    final totalClasses = _attendCount + _bunkCount;
    final label = totalClasses > 0
        ? 'After +$_attendCount / -$_bunkCount'
        : 'Current';

    return Column(
      children: [
        Row(
          children: [
            Text('Now: ${s.percentage.toStringAsFixed(1)}%', style: AppTheme.bodySmall),
            const Spacer(),
            Text(label, style: AppTheme.bodySmall),
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

  Widget _bunkTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Bunked', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Text('New %', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Text('Drop', style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _bunkTableRow(int n) {
    final projected = s.predictedPercentage(0, n);
    final change = projected - s.percentage;
    final color = projected >= 75 ? AppTheme.success : AppTheme.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('-$n', style: AppTheme.monoSmall.copyWith(color: AppTheme.danger))),
          Expanded(
            child: Text(
              '${projected.toStringAsFixed(1)}%',
              style: AppTheme.monoSmall.copyWith(color: color),
            ),
          ),
          Expanded(
            child: Text(
              '${change.toStringAsFixed(1)}%',
              style: AppTheme.monoSmall.copyWith(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperRow({
    required String label,
    required IconData icon,
    required Color color,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTheme.bodyMedium)),
        // Minus button
        GestureDetector(
          onTap: () {
            if (value > 0) {
              FeedbackService.lightTap();
              onChanged(value - 1);
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: value > 0 ? color.withOpacity(0.1) : AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value > 0 ? color.withOpacity(0.3) : AppTheme.cardBorder,
              ),
            ),
            child: Icon(Icons.remove, size: 18,
              color: value > 0 ? color : AppTheme.textTertiary,
            ),
          ),
        ),
        // Value display
        SizedBox(
          width: 48,
          child: Center(
            child: Text(
              '$value',
              style: AppTheme.monoMedium.copyWith(color: color),
            ),
          ),
        ),
        // Plus button
        GestureDetector(
          onTap: () {
            FeedbackService.lightTap();
            onChanged(value + 1);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(Icons.add, size: 18, color: color),
          ),
        ),
      ],
    );
  }

  String _predictionSummary() {
    final total = _attendCount + _bunkCount;
    if (total == 0) return 'Tap + or - to predict';
    final change = _projectedPct - s.percentage;
    final sign = change >= 0 ? '+' : '';
    final parts = <String>[];
    if (_attendCount > 0) parts.add('attend $_attendCount');
    if (_bunkCount > 0) parts.add('bunk $_bunkCount');
    return 'If you ${parts.join(' & ')}: $sign${change.toStringAsFixed(1)}%';
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: s.subjectName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('Edit Subject Name', style: AppTheme.headlineSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: 'Subject Name',
            hintText: s.subjectName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                context.read<AttendanceProvider>().updateSubjectName(
                      s.subjectCode,
                      newName,
                    );
                FeedbackService.success();
                Navigator.pop(context);
              }
            },
            child: Text('Save', style: AppTheme.bodyMedium.copyWith(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}
