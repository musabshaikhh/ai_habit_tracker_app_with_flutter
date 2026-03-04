import 'package:ai_habit_tracker_app/core/database/database_helper.dart';
import '../../domain/models/habit.dart';
import 'package:flutter/foundation.dart';

class HabitRepositoryImpl {
  final DatabaseHelper _dbHelper;

  HabitRepositoryImpl(this._dbHelper);

  Future<int> addHabit(Habit habit) async {
    try {
      if (kDebugMode) {
        print('Repository: Adding habit ${habit.name}');
      }
      final id = await _dbHelper.insertHabit(habit);
      if (kDebugMode) {
        print('Repository: Habit added with ID $id');
      }
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Repository: Error adding habit: $e');
      }
      rethrow;
    }
  }

  Future<List<Habit>> getHabits() async {
    try {
      return await _dbHelper.getAllHabits();
    } catch (e) {
      if (kDebugMode) {
        print('Repository: Error fetching habits: $e');
      }
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _dbHelper.updateHabit(habit);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: Error updating habit: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await _dbHelper.deleteHabit(id);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: Error deleting habit: $e');
      }
      rethrow;
    }
  }

  Future<bool> isHabitCompleted(int habitId, DateTime date) async {
    try {
      final history = await _dbHelper.getHistoryForDate(date);
      return history.any((h) => h.habitId == habitId && h.completed);
    } catch (e) {
      if (kDebugMode) {
        print('Repository: Error checking habit completion: $e');
      }
      rethrow;
    }
  }

  Future<void> markHabitCompleted(int habitId, DateTime date) async {
    try {
      await _dbHelper.insertHistory(
        HabitHistory(habitId: habitId, date: date, completed: true),
      );

      // Update streak logic here
      final habits = await _dbHelper.getAllHabits();
      final habit = habits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => habits.isEmpty 
          ? Habit(
              name: '', 
              description: '', 
              icon: 'book', 
              color: 0xFF8D6E63, 
              frequency: 'daily', 
              reminderTime: '08:00', 
              startDate: DateTime.now(),
            )
          : habits.first,
      );

      // Simple streak increment
      await _dbHelper.updateHabit(
        habit.copyWith(
          currentStreak: habit.currentStreak + 1,
          totalCompletions: habit.totalCompletions + 1,
          longestStreak: (habit.currentStreak + 1) > habit.longestStreak
              ? habit.currentStreak + 1
              : habit.longestStreak,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Repository: Error marking habit completed: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteHistory(int habitId, DateTime date) async {
    try {
      await _dbHelper.deleteHistory(habitId, date);

      // Rollback streak
      final habits = await _dbHelper.getAllHabits();
      final habit = habits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => habits.isEmpty
          ? Habit(
              name: '',
              description: '',
              icon: 'book',
              color: 0xFF8D6E63,
              frequency: 'daily',
              reminderTime: '08:00',
              startDate: DateTime.now(),
            )
          : habits.first,
      );
      await _dbHelper.updateHabit(
        habit.copyWith(
          currentStreak: habit.currentStreak > 0 ? habit.currentStreak - 1 : 0,
          totalCompletions:
              habit.totalCompletions > 0 ? habit.totalCompletions - 1 : 0,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Repository: Error deleting history: $e');
      }
      rethrow;
    }
  }
}
