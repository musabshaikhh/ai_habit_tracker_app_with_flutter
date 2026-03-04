import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/features/ai/presentation/widgets/ai_insight_card.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/widgets/habit_card.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/widgets/progress_header.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/widgets/xp_badge.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/screens/add_habit_screen.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final todayCompleted = ref.watch(todayCompletedProvider);
    final todayTotal = habits.length;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textDark
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                            Text(
                              'Diana',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(height: 8),
                            const XPBadge(),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to notifications - could open notification settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notifications settings coming soon!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              FontAwesomeIcons.bell,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const AIInsightCard(),
                    const SizedBox(height: 16),
                    ProgressHeader(
                      completed: todayCompleted,
                      total: todayTotal,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Habits',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (habits.isNotEmpty)
                          Text(
                            '${todayCompleted}/${todayTotal} done',
                            style: TextStyle(
                              color: AppTheme.textDark.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            habits.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.clipboardList,
                            size: 64,
                            color: AppTheme.primaryBrown.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No habits yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.textDark.withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to start your journey!',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textDark.withValues(alpha: 0.4),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: HabitCard(habit: habits[index]),
                        );
                      }, childCount: habits.length),
                    ),
                  ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddHabitScreen()),
          );
        },
        backgroundColor: AppTheme.primaryBrown,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }
}

// Provider for today's completed habits
final todayCompletedProvider = FutureProvider<int>((ref) async {
  final habits = ref.watch(habitsProvider);
  
  if (habits.isEmpty) return 0;
  
  int count = 0;
  final today = DateTime.now();
  
  for (final habit in habits) {
    if (habit.id != null) {
      final history = await DatabaseHelper.instance.getHistoryForHabit(habit.id!);
      final hasCompletedToday = history.any((h) =>
          h.date.year == today.year &&
          h.date.month == today.month &&
          h.date.day == today.day &&
          h.completed);
      if (hasCompletedToday) {
        count++;
      }
    }
  }
  
  return count;
});
