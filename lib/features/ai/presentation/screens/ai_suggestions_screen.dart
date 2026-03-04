import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/features/ai/services/ai_service.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:ai_habit_tracker_app/core/notifications/notification_service.dart';

final aiSuggestionsProvider = FutureProvider.family<
    List<Map<String, String>>,
    ({String goal, String lifestyle})>((ref, params) async {
  return await AIService.instance.generateHabitSuggestions(
    goal: params.goal,
    lifestyle: params.lifestyle,
  );
});

class AISuggestionsScreen extends ConsumerStatefulWidget {
  const AISuggestionsScreen({super.key});

  @override
  ConsumerState<AISuggestionsScreen> createState() => _AISuggestionsScreenState();
}

class _AISuggestionsScreenState extends ConsumerState<AISuggestionsScreen> {
  final _goalController = TextEditingController();
  String _lifestyle = 'moderate';
  bool _hasSearched = false;

  final List<Map<String, dynamic>> _lifestyleOptions = [
    {'label': 'Busy', 'value': 'busy', 'icon': Icons.work_outline},
    {'label': 'Moderate', 'value': 'moderate', 'icon': Icons.schedule},
    {'label': 'Relaxed', 'value': 'relaxed', 'icon': Icons.spa},
  ];

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _getSuggestions() {
    if (_goalController.text.isNotEmpty) {
      setState(() {
        _hasSearched = true;
      });
      ref.invalidate(aiSuggestionsProvider);
    }
  }

  void _addHabit(Map<String, String> suggestion) async {
    final habit = Habit(
      name: suggestion['name']!,
      description: suggestion['explanation']!,
      icon: _getIconForHabit(suggestion['name']!),
      color: 0xFF8D6E63,
      frequency: suggestion['frequency'] ?? 'daily',
      reminderTime: '08:00',
      startDate: DateTime.now(),
    );

    // Add habit and get the ID
    final habitId = await ref.read(habitsProvider.notifier).addHabit(habit);

    // Schedule notification with the returned ID
    NotificationService.instance.scheduleHabitReminder(
      habitId: habitId,
      habitName: habit.name,
      time: const TimeOfDay(hour: 8, minute: 0),
      frequency: habit.frequency,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${suggestion['name']} added to your habits!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  String _getIconForHabit(String habitName) {
    final name = habitName.toLowerCase();
    if (name.contains('work') || name.contains('focus')) return 'code';
    if (name.contains('phone') || name.contains('digital')) return 'code';
    if (name.contains('stretch') || name.contains('exercise')) return 'workout';
    if (name.contains('read')) return 'book';
    if (name.contains('meditate') || name.contains('mindfulness')) return 'meditation';
    if (name.contains('journal') || name.contains('write')) return 'book';
    if (name.contains('walk')) return 'walk';
    if (name.contains('water') || name.contains('hydrate')) return 'water';
    if (name.contains('sleep')) return 'sleep';
    if (name.contains('music')) return 'music';
    return 'book';
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = _hasSearched
        ? ref.watch(aiSuggestionsProvider(
            (goal: _goalController.text, lifestyle: _lifestyle)))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Habit Suggestions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBrown, AppTheme.accentBrown],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI-Powered Suggestions',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tell us your goals and lifestyle, and our AI will suggest habits tailored just for you.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Goal Input
            Text(
              'What is your main goal?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goalController,
              decoration: InputDecoration(
                hintText: 'e.g., Improve focus, get fit, read more...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.flag, color: AppTheme.primaryBrown),
              ),
            ),
            const SizedBox(height: 24),

            // Lifestyle Selection
            Text(
              'What is your lifestyle like?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Row(
              children: _lifestyleOptions.map((option) {
                final isSelected = _lifestyle == option['value'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _lifestyle = option['value']),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBrown
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryBrown
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            option['icon'],
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textDark.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option['label'],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textDark.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Get Suggestions Button
            ElevatedButton.icon(
              onPressed: _getSuggestions,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Get AI Suggestions'),
            ),
            const SizedBox(height: 32),

            // Suggestions List
            if (_hasSearched && suggestionsAsync != null)
              suggestionsAsync.when(
                data: (suggestions) => _buildSuggestionsList(suggestions),
                loading: () => const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('AI is thinking...'),
                    ],
                  ),
                ),
                error: (error, _) => Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.missedRed,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to get suggestions',
                        style: TextStyle(
                          color: AppTheme.textDark.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(List<Map<String, String>> suggestions) {
    if (suggestions.isEmpty) {
      return const Center(
        child: Text('No suggestions found. Try a different goal!'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Habits',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...suggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
      ],
    );
  }

  Widget _buildSuggestionCard(Map<String, String> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForHabit(suggestion['name']!) == 'book'
                      ? FontAwesomeIcons.bookOpen
                      : _getIconForHabit(suggestion['name']!) == 'workout'
                          ? FontAwesomeIcons.dumbbell
                          : _getIconForHabit(suggestion['name']!) == 'meditation'
                              ? FontAwesomeIcons.spa
                              : _getIconForHabit(suggestion['name']!) == 'code'
                                  ? FontAwesomeIcons.code
                                  : FontAwesomeIcons.check,
                  color: AppTheme.primaryBrown,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion['name']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion['frequency']!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBrown.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            suggestion['explanation']!,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _addHabit(suggestion),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add to My Habits'),
            ),
          ),
        ],
      ),
    );
  }
}
