import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<DateTime, List<HabitHistory>> _historyMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final habits = ref.read(habitsProvider);
      final historyMap = <DateTime, List<HabitHistory>>{};

      for (final habit in habits) {
        if (habit.id != null) {
          final history = await DatabaseHelper.instance.getHistoryForHabit(habit.id!);
          for (final h in history) {
            final dateKey = DateTime(h.date.year, h.date.month, h.date.day);
            historyMap[dateKey] = [...(historyMap[dateKey] ?? []), h];
          }
        }
      }

      setState(() {
        _historyMap = historyMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildMonthSelector(),
                    const SizedBox(height: 24),
                    _buildWeekdayHeaders(),
                    const SizedBox(height: 16),
                    _buildCalendarGrid(habits.length),
                    const SizedBox(height: 24),
                    _buildLegend(),
                    const SizedBox(height: 24),
                    _buildMonthlyStats(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMonthSelector() {
    final monthFormat = DateFormat('MMMM yyyy');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              );
            });
            _loadHistory();
          },
          icon: const Icon(Icons.chevron_left, color: AppTheme.primaryBrown),
        ),
        Text(
          monthFormat.format(_selectedMonth),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month + 1,
              );
            });
            _loadHistory();
          },
          icon: const Icon(Icons.chevron_right, color: AppTheme.primaryBrown),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((day) => SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark.withValues(alpha: 0.5),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(int totalHabits) {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    final today = DateTime.now();
    final isCurrentMonth = today.year == _selectedMonth.year &&
        today.month == _selectedMonth.month;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: daysInMonth + firstWeekday - 1,
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) {
          return const SizedBox.shrink();
        }

        final day = index - firstWeekday + 2;
        final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
        final isToday = isCurrentMonth && day == today.day;
        final isFuture = date.isAfter(today);

        final history = _historyMap[date] ?? [];
        final completedCount = history.where((h) => h.completed).length;

        Color? cellColor;
        if (!isFuture) {
          if (totalHabits == 0) {
            cellColor = Colors.white;
          } else if (completedCount == totalHabits) {
            cellColor = AppTheme.successGreen;
          } else if (completedCount > 0) {
            cellColor = AppTheme.primaryBrown.withValues(alpha: 0.5);
          } else if (isToday) {
            cellColor = AppTheme.primaryBrown.withValues(alpha: 0.2);
          } else {
            cellColor = Colors.white;
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(color: AppTheme.primaryBrown, width: 2)
                : Border.all(
                    color: cellColor == Colors.white || cellColor == null
                        ? Colors.black12
                        : Colors.transparent,
                  ),
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                color: isFuture
                    ? AppTheme.textDark.withValues(alpha: 0.2)
                    : (cellColor == Colors.white || cellColor == null
                        ? AppTheme.textDark
                        : Colors.white),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Completed', AppTheme.successGreen),
        const SizedBox(width: 20),
        _legendItem('Partial', AppTheme.primaryBrown),
        const SizedBox(width: 20),
        _legendItem('Missed', Colors.white),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: color == Colors.white
                ? Border.all(color: Colors.black12)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMonthlyStats() {
    return Container(
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
          Text(
            'Monthly Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: FontAwesomeIcons.checkCircle,
                  value: _getCompletedDays().toString(),
                  label: 'Days Completed',
                  color: AppTheme.successGreen,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: FontAwesomeIcons.fire,
                  value: _getCurrentMonthStreak().toString(),
                  label: 'Best Streak',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textDark.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _getCompletedDays() {
    int count = 0;
    final today = DateTime.now();
    
    for (int day = 1; day <= today.day; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      if (date.isAfter(today)) break;
      
      final history = _historyMap[date] ?? [];
      if (history.any((h) => h.completed)) {
        count++;
      }
    }
    
    return count;
  }

  int _getCurrentMonthStreak() {
    int maxStreak = 0;
    int currentStreak = 0;
    final today = DateTime.now();
    
    for (int day = 1; day <= today.day; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final history = _historyMap[date] ?? [];
      
      if (history.any((h) => h.completed)) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }
    
    return maxStreak;
  }
}
