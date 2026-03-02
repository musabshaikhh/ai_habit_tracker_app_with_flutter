import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';

final habitRepositoryProvider = Provider((ref) {
  return HabitRepositoryImpl(DatabaseHelper.instance);
});

final habitsProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return HabitNotifier(repository);
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  final HabitRepositoryImpl _repository;

  HabitNotifier(this._repository) : super([]) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    state = await _repository.getHabits();
  }

  Future<void> addHabit(Habit habit) async {
    await _repository.addHabit(habit);
    await loadHabits();
  }

  Future<void> toggleHabit(Habit habit, DateTime date) async {
    // Logic to toggle completion and update streaks
    final isCompleted = await _repository.isHabitCompleted(habit.id!, date);
    if (isCompleted) {
      await _repository.deleteHistory(habit.id!, date);
    } else {
      await _repository.markHabitCompleted(habit.id!, date);
    }

    // Refresh streaks (Simplified for now)
    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    await _repository.deleteHabit(id);
    await loadHabits();
  }
}
