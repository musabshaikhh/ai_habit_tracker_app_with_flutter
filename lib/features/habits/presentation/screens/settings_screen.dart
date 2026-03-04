// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';
import 'package:ai_habit_tracker_app/core/notifications/notification_service.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/settings_provider.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/xp_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          _buildSwitchTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Enable Notifications',
            subtitle: 'Get reminders for your habits',
            value: settings.notificationsEnabled,
            onChanged: (value) async {
              if (value) {
                final granted =
                    await NotificationService.instance.requestPermissions();
                if (granted) {
                  ref
                      .read(settingsProvider.notifier)
                      .setNotificationsEnabled(true);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Please enable notifications in settings'),
                      ),
                    );
                  }
                }
              } else {
                await NotificationService.instance.cancelAllReminders();
                ref
                    .read(settingsProvider.notifier)
                    .setNotificationsEnabled(false);
              }
            },
          ),
          const SizedBox(height: 8),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildSwitchTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            value: settings.darkModeEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setDarkModeEnabled(value);
            },
          ),
          const SizedBox(height: 8),

          // User Info Section
          _buildSectionHeader(context, 'User'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_outline,
                  color: AppTheme.primaryBrown),
            ),
            title: const Text('Display Name'),
            subtitle: Text(settings.username),
            trailing: const Icon(Icons.edit, size: 18),
            onTap: () => _showEditNameDialog(context, ref, settings.username),
          ),
          const SizedBox(height: 8),

          // Data Management Section
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.refresh, color: Colors.orange),
            ),
            title: const Text('Reset All Data'),
            subtitle: const Text('Clear all habits and history'),
            onTap: () => _showResetDialog(context, ref),
          ),
          const SizedBox(height: 8),

          // About Section
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info_outline, color: Colors.blue),
            ),
            title: const Text('AI Habit Tracker'),
            subtitle: const Text('Version 1.0.0'),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite_outline, color: Colors.green),
            ),
            title: const Text('Made with ❤️ for better habits'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark.withValues(alpha: 0.5),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBrown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBrown),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textDark.withValues(alpha: 0.6),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryBrown,
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter your name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(settingsProvider.notifier)
                    .setUsername(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your habits, history, and progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Cancel all notifications
              await NotificationService.instance.cancelAllReminders();

              // Clear database tables
              await DatabaseHelper.instance.clearAll();

              // Reset providers
              ref.read(xpProvider.notifier).resetXP();
              ref.read(settingsProvider.notifier).clearAllData();
              ref.read(habitsProvider.notifier).loadHabits();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been reset'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.missedRed),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
