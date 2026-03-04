import 'package:ai_habit_tracker_app/core/database/database_helper.dart';
import '../../domain/models/habit.dart';

class HabitRepositoryImpl {
  final DatabaseHelper _dbHelper;

  HabitRepositoryImpl(this._dbHelper);

  Future<List<Habit>> getHabits() async {
    return await _dbHelper.getAllHabits();
  }

  Future<void> addHabit(Habit habit) async {
    await _dbHelper.insertHabit(habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _dbHelper.updateHabit(habit);
  }

  Future<void> deleteHabit(int id) async {
    await _dbHelper.deleteHabit(id);
  }

  Future<bool> isHabitCompleted(int habitId, DateTime date) async {
    final history = await _dbHelper.getHistoryForDate(date);
    return history.any((h) => h.habitId == habitId && h.completed);
  }

  Future<void> markHabitCompleted(int habitId, DateTime date) async {
    await _dbHelper.insertHistory(
      HabitHistory(habitId: habitId, date: date, completed: true),
    );

    // Update streak logic here
    final habits = await _dbHelper.getAllHabits();
    final habit = habits.firstWhere((h) => h.id == habitId);

    // Simple streak increment for demo
    await _dbHelper.updateHabit(
      habit.copyWith(
        currentStreak: habit.currentStreak + 1,
        totalCompletions: habit.totalCompletions + 1,
        longestStreak: (habit.currentStreak + 1) > habit.longestStreak
            ? habit.currentStreak + 1
            : habit.longestStreak,
      ),
    );
  }

  Future<void> deleteHistory(int habitId, DateTime date) async {
    await _dbHelper.deleteHistory(habitId, date);

    // Rollback streak
    final habits = await _dbHelper.getAllHabits();
    final habit = habits.firstWhere((h) => h.id == habitId);
    await _dbHelper.updateHabit(
      habit.copyWith(
        currentStreak: habit.currentStreak > 0 ? habit.currentStreak - 1 : 0,
        totalCompletions:
            habit.totalCompletions > 0 ? habit.totalCompletions - 1 : 0,
      ),
    );
  }
}
