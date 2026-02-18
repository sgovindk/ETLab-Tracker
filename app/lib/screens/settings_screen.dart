import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/timetable_provider.dart';
import '../services/feedback_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: AppTheme.headlineMedium)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Account Section
          _sectionLabel('ACCOUNT'),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                _infoRow(
                  Icons.account_circle_outlined,
                  'Status',
                  attendance.isLoggedIn ? 'Signed in' : 'Not signed in',
                  attendance.isLoggedIn ? AppTheme.success : AppTheme.danger,
                ),
                const Divider(),
                _infoRow(
                  Icons.sync_rounded,
                  'Last sync',
                  attendance.lastSync != null
                      ? _formatDate(attendance.lastSync!)
                      : 'Never',
                  AppTheme.textSecondary,
                ),
                const Divider(),
                _infoRow(
                  Icons.school_rounded,
                  'Subjects loaded',
                  '${attendance.totalSubjects}',
                  AppTheme.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          _sectionLabel('ACTIONS'),
          const SizedBox(height: 8),
          _actionTile(
            icon: Icons.sync_rounded,
            label: 'Refresh Attendance',
            subtitle: 'Fetch latest data from ETLab',
            onTap: () {
              FeedbackService.mediumTap();
              attendance.refresh();
            },
          ),
          const SizedBox(height: 8),
          _actionTile(
            icon: Icons.restore_rounded,
            label: 'Reset Timetable',
            subtitle: 'Restore default timetable',
            onTap: () async {
              FeedbackService.mediumTap();
              final tt = context.read<TimetableProvider>();
              await tt.resetToDefault();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Timetable reset to default')),
              );
            },
          ),
          const SizedBox(height: 8),
          _actionTile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            subtitle: 'Clear credentials and cached data',
            color: AppTheme.danger,
            onTap: () async {
              FeedbackService.heavyTap();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  title: Text('Sign Out', style: AppTheme.titleMedium),
                  content: Text(
                    'This will clear all your data and credentials.',
                    style: AppTheme.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancel',
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Sign Out',
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await attendance.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
          const SizedBox(height: 32),

          // About
          Center(
            child: Column(
              children: [
                Text('ETLab Tracker v1.0.0', style: AppTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  'ETLab Attendance Tracker v1.0.0',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                ),
                const SizedBox(height: 16),
                // "Created by GK" engraving
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Text(
                    'Created by GK',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: AppTheme.labelLarge.copyWith(color: AppTheme.textTertiary));
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textTertiary),
          const SizedBox(width: 12),
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
          Text(value, style: AppTheme.bodyMedium.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color color = AppTheme.textPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.titleMedium.copyWith(color: color)),
                  Text(subtitle, style: AppTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
