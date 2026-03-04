import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';
import 'xp_provider.dart';
import 'package:flutter/foundation.dart';

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
    if (kDebugMode) {
      print('HabitNotifier: Initializing');
    }
    loadHabits();
  }

  Future<void> loadHabits() async {
    try {
      if (kDebugMode) {
        print('HabitNotifier: Loading habits...');
      }
      state = await _repository.getHabits();
      if (kDebugMode) {
        print('HabitNotifier: Loaded ${state.length} habits');
      }
    } catch (e) {
      if (kDebugMode) {
        print('HabitNotifier: Error loading habits: $e');
      }
      state = [];
    }
  }

  Future<int> addHabit(Habit habit) async {
    try {
      if (kDebugMode) {
        print('HabitNotifier: Adding habit ${habit.name}');
      }
      final id = await _repository.addHabit(habit);
      if (kDebugMode) {
        print('HabitNotifier: Habit added with ID $id, reloading...');
      }
      await loadHabits();
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('HabitNotifier: Error adding habit: $e');
      }
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _repository.updateHabit(habit);
      await loadHabits();
    } catch (e) {
      if (kDebugMode) {
        print('HabitNotifier: Error updating habit: $e');
      }
      rethrow;
    }
  }

  Future<void> toggleHabit(Habit habit, DateTime date) async {
    try {
      final isCompleted = await _repository.isHabitCompleted(habit.id!, date);
      
      if (isCompleted) {
        await _repository.deleteHistory(habit.id!, date);
      } else {
        await _repository.markHabitCompleted(habit.id!, date);
        // Award XP for completing the habit
        final xpAmount = GamificationService.xpForHabit(habit.frequency);
        await _ref.read(xpProvider.notifier).addXP(xpAmount);
        if (kDebugMode) {
          print('HabitNotifier: Awarded $xpAmount XP for ${habit.name}');
        }
      }

      await loadHabits();
      _ref.invalidate(habitCompletionProvider);
    } catch (e) {
      if (kDebugMode) {
        print('HabitNotifier: Error toggling habit: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await _repository.deleteHabit(id);
      await loadHabits();
    } catch (e) {
      if (kDebugMode) {
        print('HabitNotifier: Error deleting habit: $e');
      }
      rethrow;
    }
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
