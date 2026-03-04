import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';
import 'xp_provider.dart';

final habitRepositoryProvider = Provider((ref) {
  return HabitRepositoryImpl(DatabaseHelper.instance);
});

final habitsProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return HabitNotifier(repository, ref);
});

final habitCompletionProvider = FutureProvider.family<bool, ({int habitId, DateTime date})>((ref, params) async {
  final repository = ref.watch(habitRepositoryProvider);
  return await repository.isHabitCompleted(params.habitId, params.date);
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  final HabitRepositoryImpl _repository;
  final Ref _ref;

  HabitNotifier(this._repository, this._ref) : super([]) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    state = await _repository.getHabits();
  }

  Future<int> addHabit(Habit habit) async {
    final id = await _repository.addHabit(habit);
    await loadHabits();
    return id;
  }

  Future<void> updateHabit(Habit habit) async {
    await _repository.updateHabit(habit);
    await loadHabits();
  }

  Future<void> toggleHabit(Habit habit, DateTime date) async {
    final isCompleted = await _repository.isHabitCompleted(habit.id!, date);
    
    if (isCompleted) {
      await _repository.deleteHistory(habit.id!, date);
    } else {
      await _repository.markHabitCompleted(habit.id!, date);
      // Award XP for completing the habit
      final xpAmount = GamificationService.xpForHabit(habit.frequency);
      await _ref.read(xpProvider.notifier).addXP(xpAmount);
    }

    await loadHabits();
    _ref.invalidate(habitCompletionProvider);
  }

  Future<void> deleteHabit(int id) async {
    await _repository.deleteHabit(id);
    await loadHabits();
  }

  Future<int> getCompletedCountForDate(DateTime date) async {
    int completed = 0;
    for (final habit in state) {
      final isCompleted = await _repository.isHabitCompleted(habit.id!, date);
      if (isCompleted) completed++;
    }
    return completed;
  }

  Future<Map<String, dynamic>> getTodayStats() async {
    final today = DateTime.now();
    final totalHabits = state.length;
    final completedHabits = await getCompletedCountForDate(today);
    final percentage = totalHabits > 0 ? completedHabits / totalHabits : 0.0;
    
    return {
      'total': totalHabits,
      'completed': completedHabits,
      'percentage': percentage,
    };
  }
}
