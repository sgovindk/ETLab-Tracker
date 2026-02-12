import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small statistic tile (e.g., "Total Subjects: 6").
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.accent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTheme.monoMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
