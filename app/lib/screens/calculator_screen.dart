import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject_attendance.dart';
import '../providers/attendance_provider.dart';
import '../theme/app_theme.dart';
import '../services/feedback_service.dart';
import '../widgets/glass_card.dart';

/// Global attendance calculator for any subject.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  SubjectAttendance? _selected;
  final _targetCtrl = TextEditingController(text: '75');
  final _classesCtrl = TextEditingController(text: '5');
  int _mode = 0; // 0 = target → classes, 1 = classes → percentage

  @override
  void dispose() {
    _targetCtrl.dispose();
    _classesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<AttendanceProvider>().subjects;

    return Scaffold(
      appBar: AppBar(title: Text('Calculator', style: AppTheme.headlineMedium)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Subject selector ──
          Text('SELECT SUBJECT', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          if (subjects.isEmpty)
            GlassCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Sync attendance from the dashboard first.',
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subjects.map((s) {
                final isSelected = _selected?.subjectCode == s.subjectCode;
                return GestureDetector(
                  onTap: () {
                    FeedbackService.selectionClick();
                    setState(() => _selected = s);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accent.withOpacity(0.12) : AppTheme.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.subjectCode,
                          style: AppTheme.bodySmall.copyWith(
                            color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${s.percentage.toStringAsFixed(1)}%',
                          style: AppTheme.monoSmall.copyWith(
                            color: isSelected ? AppTheme.accent : AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 28),

          if (_selected != null) ...[
            // ── Selected info bar ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.glowDecoration(AppTheme.accent),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selected!.subjectName, style: AppTheme.titleMedium),
                        Text(
                          '${_selected!.hoursAttended}/${_selected!.totalHours} hours · ${_selected!.percentage.toStringAsFixed(1)}%',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selected!.isBelowThreshold
                          ? AppTheme.danger.withOpacity(0.12)
                          : AppTheme.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_selected!.percentage.toStringAsFixed(1)}%',
                      style: AppTheme.monoMedium.copyWith(
                        color: _selected!.isBelowThreshold ? AppTheme.danger : AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Mode switcher ──
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  _modeTab('Target → Classes', 0),
                  _modeTab('Classes → Percentage', 1),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Calculator based on mode ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _mode == 0 ? _targetMode() : _classesMode(),
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _modeTab(String label, int index) {
    final selected = _mode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          FeedbackService.selectionClick();
          setState(() => _mode = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.accent.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: selected ? AppTheme.accent : AppTheme.textTertiary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _targetMode() {
    final target = double.tryParse(_targetCtrl.text) ?? 75;
    final needed = _selected!.classesNeeded(target);
    final isImpossible = needed < 0;
    final alreadyMet = needed == 0 && _selected!.percentage >= target;

    return GlassCard(
      key: const ValueKey('target'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What percentage do you want to reach?', style: AppTheme.bodyLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _targetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTheme.monoLarge.copyWith(color: AppTheme.accent),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: '%',
              suffixStyle: AppTheme.monoMedium.copyWith(color: AppTheme.textTertiary),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          // Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: isImpossible
                    ? AppTheme.danger.withOpacity(0.3)
                    : alreadyMet
                        ? AppTheme.success.withOpacity(0.3)
                        : AppTheme.accent.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                if (isImpossible) ...[
                  Icon(Icons.block_rounded, size: 32, color: AppTheme.danger),
                  const SizedBox(height: 8),
                  Text('Not achievable', style: AppTheme.titleMedium.copyWith(color: AppTheme.danger)),
                  Text('Target percentage is too high', style: AppTheme.bodySmall),
                ] else if (alreadyMet) ...[
                  Icon(Icons.check_circle_rounded, size: 32, color: AppTheme.success),
                  const SizedBox(height: 8),
                  Text('Already there!', style: AppTheme.titleMedium.copyWith(color: AppTheme.success)),
                  Text('You\'ve met your target', style: AppTheme.bodySmall),
                ] else ...[
                  Text(
                    '$needed',
                    style: AppTheme.monoLarge.copyWith(color: AppTheme.accent, fontSize: 48),
                  ),
                  Text(
                    'consecutive classes to attend',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From ${_selected!.percentage.toStringAsFixed(1)}% → ${target.toStringAsFixed(1)}%',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.accent),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _classesMode() {
    final n = int.tryParse(_classesCtrl.text) ?? 0;
    final projected = _selected!.projectedPercentage(n);
    final change = projected - _selected!.percentage;

    return GlassCard(
      key: const ValueKey('classes'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How many classes will you attend?', style: AppTheme.bodyLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _classesCtrl,
            keyboardType: TextInputType.number,
            style: AppTheme.monoLarge.copyWith(color: AppTheme.secondary),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: 'classes',
              suffixStyle: AppTheme.monoSmall.copyWith(color: AppTheme.textTertiary),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          // Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: projected >= 75
                    ? AppTheme.success.withOpacity(0.3)
                    : AppTheme.warning.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${projected.toStringAsFixed(1)}%',
                  style: AppTheme.monoLarge.copyWith(
                    color: projected >= 75 ? AppTheme.success : AppTheme.warning,
                    fontSize: 48,
                  ),
                ),
                Text('projected attendance', style: AppTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 16,
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${change.toStringAsFixed(1)}% increase',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.success),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selected!.hoursAttended + n}/${_selected!.totalHours + n} hours',
                  style: AppTheme.monoSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
