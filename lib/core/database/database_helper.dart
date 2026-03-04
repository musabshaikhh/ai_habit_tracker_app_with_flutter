// ignore_for_file: avoid_print, unused_field

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/habits/domain/models/habit.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  bool _isInitialized = false;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    _isInitialized = true;
    if (kDebugMode) {
      print('Database initialized successfully');
    }
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    if (kDebugMode) {
      print('Database path: $path');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) {
        if (kDebugMode) {
          print('Database opened successfully');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    if (kDebugMode) {
      print('Creating database tables...');
    }

    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE habits (
  id $idType,
  name $textType,
  description $textType,
  icon $textType,
  color $intType,
  frequency $textType,
  reminderTime $textType,
  startDate $textType,
  currentStreak $intType,
  longestStreak $intType,
  totalCompletions $intType,
  isPro $boolType
)
''');

    await db.execute('''
CREATE TABLE habit_history (
  id $idType,
  habitId $intType,
  date $textType,
  completed $boolType,
  FOREIGN KEY (habitId) REFERENCES habits (id) ON DELETE CASCADE
)
''');

    if (kDebugMode) {
      print('Database tables created successfully');
    }
  }

  // Habit CRUD
  Future<int> insertHabit(Habit habit) async {
    try {
      final db = await instance.database;
      final id = await db.insert('habits', habit.toMap());
      if (kDebugMode) {
        print('Habit inserted with ID: $id');
        print('Habit data: ${habit.toMap()}');
      }
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting habit: $e');
      }
      rethrow;
    }
  }

  Future<List<Habit>> getAllHabits() async {
    try {
      final db = await instance.database;
      final result = await db.query('habits');
      if (kDebugMode) {
        print('Fetched ${result.length} habits from database');
      }
      return result.map((json) => Habit.fromMap(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching habits: $e');
      }
      rethrow;
    }
  }

  Future<int> updateHabit(Habit habit) async {
    try {
      final db = await instance.database;
      final count = await db.update(
        'habits',
        habit.toMap(),
        where: 'id = ?',
        whereArgs: [habit.id],
      );
      if (kDebugMode) {
        print('Updated habit ${habit.id}, rows affected: $count');
      }
      return count;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating habit: $e');
      }
      rethrow;
    }
  }

  Future<int> deleteHabit(int id) async {
    try {
      final db = await instance.database;
      final count = await db.delete(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (kDebugMode) {
        print('Deleted habit $id, rows affected: $count');
      }
      return count;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting habit: $e');
      }
      rethrow;
    }
  }

  // History CRUD
  Future<int> insertHistory(HabitHistory history) async {
    try {
      final db = await instance.database;
      final id = await db.insert('habit_history', history.toMap());
      if (kDebugMode) {
        print('History inserted with ID: $id');
      }
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting history: $e');
      }
      rethrow;
    }
  }

  Future<List<HabitHistory>> getHistoryForHabit(int habitId) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'habit_history',
        where: 'habitId = ?',
        whereArgs: [habitId],
      );
      return result.map((json) => HabitHistory.fromMap(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching history for habit $habitId: $e');
      }
      rethrow;
    }
  }

  Future<List<HabitHistory>> getHistoryForDate(DateTime date) async {
    final dateStr =
        date.toIso8601String().split('T')[0]; // <-- Move outside try block
    try {
      final db = await instance.database;
      final result = await db.query(
        'habit_history',
        where: 'date = ?',
        whereArgs: [dateStr],
      );
      return result.map((json) => HabitHistory.fromMap(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching history for date $dateStr: $e'); // Now accessible
      }
      rethrow;
    }
  }

  Future<int> deleteHistory(int habitId, DateTime date) async {
    try {
      final db = await instance.database;
      final dateStr = date.toIso8601String().split('T')[0];
      final count = await db.delete(
        'habit_history',
        where: 'habitId = ? AND date = ?',
        whereArgs: [habitId, dateStr],
      );
      if (kDebugMode) {
        print('Deleted history for habit $habitId on $dateStr, rows: $count');
      }
      return count;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting history: $e');
      }
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await instance.database;
      await db.delete('habit_history');
      await db.delete('habits');
      if (kDebugMode) {
        print('Cleared all data from database');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing database: $e');
      }
      rethrow;
    }
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
    _isInitialized = false;
    if (kDebugMode) {
      print('Database closed');
    }
  }

  // Debug method to check database contents
  Future<void> debugPrintTables() async {
    if (!kDebugMode) return;
    final db = await instance.database;
    final habits = await db.query('habits');
    final history = await db.query('habit_history');
    print('=== DATABASE DEBUG ===');
    print('Habits: ${habits.length} rows');
    print('History: ${history.length} rows');
    print('==================');
  }
}
