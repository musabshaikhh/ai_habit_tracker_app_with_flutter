import 'dart:async';

class AIService {
  static final AIService instance = AIService._init();
  AIService._init();

  // Mock implementation for MVP
  Future<List<Map<String, String>>> generateHabitSuggestions({
    required String goal,
    required String lifestyle,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    if (goal.toLowerCase().contains('focus') ||
        goal.toLowerCase().contains('work')) {
      return [
        {
          'name': '25 min deep work',
          'frequency': 'daily',
          'explanation':
              'Uses Pomodoro technique to maintain high focus levels.',
        },
        {
          'name': 'No phone 1st hour',
          'frequency': 'daily',
          'explanation': 'Prevents reactive dopamine spikes early in the day.',
        },
        {
          'name': 'Write daily goal',
          'frequency': 'daily',
          'explanation': 'Clarifies intent and reduces decision fatigue.',
        },
      ];
    }

    return [
      {
        'name': 'Morning stretch',
        'frequency': 'daily',
        'explanation': 'Boosts circulation and wakes up the nervous system.',
      },
      {
        'name': 'Read 10 pages',
        'frequency': 'daily',
        'explanation':
            'Compound learning leads to exponential knowledge growth.',
      },
      {
        'name': 'Gratitude journal',
        'frequency': 'daily',
        'explanation': 'Rewires the brain to focus on positive outcomes.',
      },
    ];
  }

  Future<String> generateDailyMotivation({
    required int streak,
    required int completionPercentage,
  }) async {
    if (streak > 0) {
      return "You're on a $streak-day streak! Don't let the chain break today. Consistency is your superpower.";
    } else if (completionPercentage > 80) {
      return "Almost perfect! You're crushing your goals. Keep that momentum going!";
    } else {
      return "Every day is a fresh start. Focus on just one small win today.";
    }
  }

  Future<Map<String, dynamic>> analyzeWeeklyProgress({
    required int totalHabits,
    required int completedHabits,
    required int streaksMaintained,
  }) async {
    double rate = completedHabits / totalHabits;
    String insight = rate > 0.7
        ? "Excellent consistency! You are forming strong neurological pathways."
        : "You had a few dips this week. Try scheduling your hardest habits for the morning.";

    return {
      'performanceScore': (rate * 100).toInt(),
      'insight': insight,
      'recommendation':
          "Start with 5 minutes of meditation to reset your focus for next week.",
    };
  }
}
