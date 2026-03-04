import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/habits/domain/models/habit.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
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
  }

  // Habit CRUD
  Future<int> insertHabit(Habit habit) async {
    final db = await instance.database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await instance.database;
    final result = await db.query('habits');
    return result.map((json) => Habit.fromMap(json)).toList();
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await instance.database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await instance.database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // History CRUD
  Future<int> insertHistory(HabitHistory history) async {
    final db = await instance.database;
    return await db.insert('habit_history', history.toMap());
  }

  Future<List<HabitHistory>> getHistoryForHabit(int habitId) async {
    final db = await instance.database;
    final result = await db.query(
      'habit_history',
      where: 'habitId = ?',
      whereArgs: [habitId],
    );
    return result.map((json) => HabitHistory.fromMap(json)).toList();
  }

  Future<List<HabitHistory>> getHistoryForDate(DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'habit_history',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    return result.map((json) => HabitHistory.fromMap(json)).toList();
  }

  Future<int> deleteHistory(int habitId, DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().split('T')[0];
    return await db.delete(
      'habit_history',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, dateStr],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
