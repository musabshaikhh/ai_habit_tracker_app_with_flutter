// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/xp_provider.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/settings_provider.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/widgets/pro_toggle.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final totalXP = ref.watch(xpProvider);
    final settings = ref.watch(settingsProvider);
    final level = GamificationService.getLevel(totalXP);
    final progress = GamificationService.getProgressToNextLevel(totalXP);

    // Calculate stats
    int totalCompletions = habits.fold(0, (sum, h) => sum + h.totalCompletions);
    int bestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, settings.username, level, totalXP),
            const SizedBox(height: 32),

            // XP Progress
            _buildXPProgress(context, totalXP, level, progress),
            const SizedBox(height: 32),

            // Stats Grid
            _buildStatsGrid(habits.length, totalCompletions, bestStreak),
            const SizedBox(height: 32),

            // Achievements
            _buildAchievements(context, habits, totalCompletions, bestStreak),
            const SizedBox(height: 32),

            // Pro Toggle
            const ProVersionToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String username,
    int level,
    int totalXP,
  ) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryBrown, AppTheme.accentBrown],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style:
              Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          'Level $level • $totalXP XP Total',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textDark.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildXPProgress(
    BuildContext context,
    int totalXP,
    int level,
    double progress,
  ) {
    final xpToNext = (progress * 1000).round();
    final xpNeeded = 1000;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level Progress',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18),
              ),
              Text(
                '$xpToNext / $xpNeeded XP',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${((1 - progress) * 1000).round()} XP needed for Level ${level + 1}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textDark.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int habitCount, int totalCompletions, int bestStreak) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Habits',
            habitCount.toString(),
            Icons.favorite,
            AppTheme.primaryBrown,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Completed',
            totalCompletions.toString(),
            Icons.check_circle,
            AppTheme.successGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Best Streak',
            bestStreak.toString(),
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(
    BuildContext context,
    List habits,
    int totalCompletions,
    int bestStreak,
  ) {
    final achievements = [
      _Achievement(
        'First Steps',
        'Create your first habit',
        Icons.directions_walk,
        habits.isNotEmpty,
        Colors.blue,
      ),
      _Achievement(
        'Habit Master',
        'Create 5 habits',
        Icons.star,
        habits.length >= 5,
        Colors.amber,
      ),
      _Achievement(
        'Streak Keeper',
        'Achieve a 7-day streak',
        Icons.local_fire_department,
        bestStreak >= 7,
        Colors.orange,
      ),
      _Achievement(
        'Consistent',
        'Complete 50 habits total',
        Icons.check_circle,
        totalCompletions >= 50,
        AppTheme.successGreen,
      ),
      _Achievement(
        'Dedicated',
        'Achieve a 30-day streak',
        Icons.emoji_events,
        bestStreak >= 30,
        Colors.purple,
      ),
      _Achievement(
        'Centurion',
        'Complete 100 habits total',
        Icons.military_tech,
        totalCompletions >= 100,
        Colors.red,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementItem(achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementItem(_Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? achievement.color.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.unlocked
              ? achievement.color.withValues(alpha: 0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            color:
                achievement.unlocked ? achievement.color : Colors.grey.shade400,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: achievement.unlocked
                  ? AppTheme.textDark
                  : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          if (achievement.unlocked)
            Icon(Icons.check, size: 14, color: AppTheme.successGreen),
        ],
      ),
    );
  }
}

class _Achievement {
  final String name;
  final String description;
  final IconData icon;
  final bool unlocked;
  final Color color;

  _Achievement(
    this.name,
    this.description,
    this.icon,
    this.unlocked,
    this.color,
  );
}
