import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/widgets/xp_badge.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final isCompletedToday = ref.watch(habitCompletionProvider(habit.id!));

    return Dismissible(
      key: Key('habit_${habit.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Habit'),
            content: Text('Are you sure you want to delete "${habit.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.missedRed),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        if (habit.id != null) {
          ref.read(habitsProvider.notifier).deleteHabit(habit.id!);
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.missedRed,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          ref.read(habitsProvider.notifier).toggleHabit(habit, DateTime.now());
          // Award XP for completion
          if (!isCompletedToday) {
            final xp = habit.frequency == 'daily' ? 50 : 200;
            ref.read(xpProvider.notifier).state += xp;
            _showXPReward(context, xp);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCompletedToday
                ? AppTheme.successGreen.withValues(alpha: 0.1)
                : Color(habit.color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isCompletedToday
                  ? AppTheme.successGreen
                  : Color(habit.color).withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: isCompletedToday
                ? [
                    BoxShadow(
                      color: AppTheme.successGreen.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompletedToday
                      ? AppTheme.successGreen.withValues(alpha: 0.2)
                      : Color(habit.color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIconData(habit.icon),
                  color: isCompletedToday
                      ? AppTheme.successGreen
                      : Color(habit.color),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            color: AppTheme.textDark,
                            decoration: isCompletedToday
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textDark.withValues(alpha: 0.6),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.fire,
                          size: 14,
                          color: AppTheme.primaryBrown,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak} day streak',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryBrown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          FontAwesomeIcons.clock,
                          size: 12,
                          color: AppTheme.textDark.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          habit.reminderTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textDark.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompletedToday
                      ? AppTheme.successGreen
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompletedToday
                        ? AppTheme.successGreen
                        : AppTheme.primaryBrown,
                    width: 2,
                  ),
                ),
                child: isCompletedToday
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showXPReward(BuildContext context, int xp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text('+$xp XP earned!'),
          ],
        ),
        backgroundColor: AppTheme.accentBrown,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'book':
        return FontAwesomeIcons.bookOpen;
      case 'workout':
        return FontAwesomeIcons.dumbbell;
      case 'meditation':
        return FontAwesomeIcons.spa;
      case 'code':
        return FontAwesomeIcons.code;
      case 'water':
        return FontAwesomeIcons.glassWater;
      case 'sleep':
        return FontAwesomeIcons.bed;
      case 'walk':
        return FontAwesomeIcons.personWalking;
      case 'food':
        return FontAwesomeIcons.utensils;
      default:
        return FontAwesomeIcons.check;
    }
  }
}

// Provider to check if a habit is completed today
final habitCompletionProvider =
    FutureProvider.family<bool, int>((ref, int habitId) async {
  if (habitId == 0 || habitId == null) return false;
  
  try {
    final history = await DatabaseHelper.instance.getHistoryForDate(DateTime.now());
    return history.any((h) => h.habitId == habitId && h.completed);
  } catch (e) {
    return false;
  }
});
