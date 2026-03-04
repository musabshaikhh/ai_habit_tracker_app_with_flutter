import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/habit_provider.dart';
import '../screens/habit_detail_screen.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final completionAsync = ref.watch(
      habitCompletionProvider((habitId: habit.id!, date: today)),
    );

    return completionAsync.when(
      data: (isCompleted) => GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(habit: habit),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.successGreen.withValues(alpha: 0.1)
                : Color(habit.color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isCompleted
                  ? AppTheme.successGreen.withValues(alpha: 0.3)
                  : Color(habit.color).withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successGreen.withValues(alpha: 0.2)
                      : Color(habit.color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIconData(habit.icon),
                  color: isCompleted ? AppTheme.successGreen : Color(habit.color),
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
                            color: isCompleted ? AppTheme.successGreen : AppTheme.textDark,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    Text(
                      habit.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textDark.withValues(alpha: 0.6),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.frequency == 'daily' ? 'Daily' : 'Weekly',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '🔥 ${habit.currentStreak}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      ref.read(habitsProvider.notifier).toggleHabit(habit, today);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppTheme.successGreen : Colors.transparent,
                        border: Border.all(
                          color: isCompleted ? AppTheme.successGreen : AppTheme.primaryBrown,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : null,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      loading: () => _buildLoadingCard(),
      error: (_, __) => _buildErrorCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(habit.color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(habit.color).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(habit.color).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIconData(habit.icon),
              color: Color(habit.color),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  habit.description,
                  style: TextStyle(
                    color: AppTheme.textDark.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.missedRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.missedRed.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: AppTheme.missedRed),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              habit.name,
              style: const TextStyle(color: AppTheme.textDark),
            ),
          ),
        ],
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
      case 'music':
        return FontAwesomeIcons.music;
      case 'walk':
        return FontAwesomeIcons.personWalking;
      default:
        return FontAwesomeIcons.check;
    }
  }
}
