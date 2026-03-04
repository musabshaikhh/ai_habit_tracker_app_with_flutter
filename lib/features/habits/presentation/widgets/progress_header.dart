// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import '../providers/habit_provider.dart';

class ProgressHeader extends ConsumerWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(habitsProvider.notifier).getTodayStats(),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ?? {'total': 0, 'completed': 0, 'percentage': 0.0};
        final total = stats['total'] as int;
        final completed = stats['completed'] as int;
        final percentage = stats['percentage'] as double;
        final percentageInt = (percentage * 100).round();

        String message;
        if (total == 0) {
          message = 'No habits yet. Create one to get started!';
        } else if (percentage == 1.0) {
          message = 'Amazing! You\'ve completed all $total habits today!';
        } else if (percentage >= 0.7) {
          message =
              'Great job! You\'ve completed $completed/$total habits today.';
        } else if (percentage >= 0.3) {
          message =
              'Keep going! You\'ve completed $completed/$total habits today.';
        } else {
          message =
              'Let\'s start! You\'ve completed $completed/$total habits today.';
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryBrown,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Progress',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    '$percentageInt%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
