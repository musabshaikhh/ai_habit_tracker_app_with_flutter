class Habit {
  final int? id;
  final String name;
  final String description;
  final String icon; // Icon name as string
  final int color; // Hex color value
  final String frequency; // 'daily', 'weekly'
  final String reminderTime; // 'HH:mm'
  final DateTime startDate;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final bool isPro;

  Habit({
    this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.reminderTime,
    required this.startDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.isPro = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'frequency': frequency,
      'reminderTime': reminderTime,
      'startDate': startDate.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalCompletions': totalCompletions,
      'isPro': isPro ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      color: map['color'],
      frequency: map['frequency'],
      reminderTime: map['reminderTime'],
      startDate: DateTime.parse(map['startDate']),
      currentStreak: map['currentStreak'],
      longestStreak: map['longestStreak'],
      totalCompletions: map['totalCompletions'],
      isPro: map['isPro'] == 1,
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    int? color,
    String? frequency,
    String? reminderTime,
    DateTime? startDate,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    bool? isPro,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      startDate: startDate ?? this.startDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      isPro: isPro ?? this.isPro,
    );
  }
}

class HabitHistory {
  final int? id;
  final int habitId;
  final DateTime date;
  final bool completed;

  HabitHistory({
    this.id,
    required this.habitId,
    required this.date,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'completed': completed ? 1 : 0,
    };
  }

  factory HabitHistory.fromMap(Map<String, dynamic> map) {
    return HabitHistory(
      id: map['id'],
      habitId: map['habitId'],
      date: DateTime.parse(map['date']),
      completed: map['completed'] == 1,
    );
  }
}
