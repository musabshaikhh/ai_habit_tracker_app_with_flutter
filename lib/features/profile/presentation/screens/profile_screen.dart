import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/widgets/xp_badge.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/widgets/pro_toggle.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final totalCompletions = habits.fold<int>(
        0, (sum, habit) => sum + habit.totalCompletions);
    final longestStreak = habits.fold<int>(
        0, (max, habit) => habit.longestStreak > max ? habit.longestStreak : max);
    final totalXP = ref.watch(xpProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 32),
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FontAwesomeIcons.user,
                        size: 40,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Diana',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const XPBadge(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total XP',
                      totalXP.toString(),
                      FontAwesomeIcons.star,
                      Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Best Streak',
                      '$longestStreak days',
                      FontAwesomeIcons.fire,
                      AppTheme.missedRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Completed',
                      totalCompletions.toString(),
                      FontAwesomeIcons.checkCircle,
                      AppTheme.successGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Active Habits',
                      habits.length.toString(),
                      FontAwesomeIcons.clipboardList,
                      AppTheme.primaryBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Settings Section
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildSettingsTile(
                context,
                icon: FontAwesomeIcons.bell,
                title: 'Notifications',
                subtitle: 'Manage your reminders',
                onTap: () => _showNotificationSettings(context),
              ),
              _buildSettingsTile(
                context,
                icon: FontAwesomeIcons.palette,
                title: 'Appearance',
                subtitle: 'Themes and display options',
                onTap: () => _showAppearanceSettings(context),
              ),
              _buildSettingsTile(
                context,
                icon: FontAwesomeIcons.lock,
                title: 'Privacy',
                subtitle: 'Data and privacy settings',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: FontAwesomeIcons.circleQuestion,
                title: 'Help & Support',
                subtitle: 'FAQs and contact',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              const ProVersionToggle(),
              const SizedBox(height: 32),
              // App Info
              Center(
                child: Column(
                  children: [
                    Text(
                      'AI Habit Tracker',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textDark.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textDark.withValues(alpha: 0.4),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDark.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Colors.white,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBrown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryBrown, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.textDark.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.pendingGray,
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Daily Reminders'),
              subtitle: const Text('Get reminded to complete your habits'),
              value: true,
              activeColor: AppTheme.primaryBrown,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Streak Alerts'),
              subtitle: const Text('Warning when you might break a streak'),
              value: true,
              activeColor: AppTheme.primaryBrown,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Weekly Summary'),
              subtitle: const Text('Receive weekly progress reports'),
              value: false,
              activeColor: AppTheme.primaryBrown,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAppearanceSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Mode'),
              trailing: Radio<bool>(
                value: true,
                groupValue: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Radio<bool>(
                value: false,
                groupValue: true,
                onChanged: (value) {},
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
