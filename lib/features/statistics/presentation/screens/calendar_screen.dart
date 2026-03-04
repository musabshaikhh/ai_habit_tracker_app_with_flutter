// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  Future<Map<String, int>> _getMonthHistory(DateTime month) async {
    final db = DatabaseHelper.instance;
    final habits = await db.getAllHabits();
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    Map<String, int> completionStatus = {};

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      if (date.isAfter(DateTime.now())) {
        completionStatus[day.toString()] = 2; // Future
        continue;
      }

      final history = await db.getHistoryForDate(date);
      final completedCount = history.where((h) => h.completed).length;
      final totalHabits = habits.length;

      if (totalHabits == 0) {
        completionStatus[day.toString()] = 2; // No habits
      } else if (completedCount == 0) {
        completionStatus[day.toString()] = 0; // Missed
      } else if (completedCount == totalHabits) {
        completionStatus[day.toString()] = 1; // Completed all
      } else {
        completionStatus[day.toString()] = 3; // Partial
      }
    }

    return completionStatus;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final firstWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    ).weekday;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCalendarHeader(),
            const SizedBox(height: 24),
            _buildWeekdayLabels(),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<Map<String, int>>(
                future: _getMonthHistory(_currentMonth),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final completionStatus = snapshot.data ?? {};

                  return _buildCalendarGrid(
                    daysInMonth,
                    firstWeekday,
                    completionStatus,
                    habits.length,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(
    int daysInMonth,
    int firstWeekday,
    Map<String, int> completionStatus,
    int totalHabits,
  ) {
    // Adjust for Monday start (weekday 1 = Monday in DateTime)
    final startOffset = firstWeekday - 1;
    final totalCells = ((daysInMonth + startOffset) / 7).ceil() * 7;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final adjustedIndex = index - startOffset;

        if (adjustedIndex < 0 || adjustedIndex >= daysInMonth) {
          return const SizedBox.shrink();
        }

        final day = adjustedIndex + 1;
        final status = completionStatus[day.toString()] ?? 0;

        // 0 = missed, 1 = completed all, 2 = future/no habits, 3 = partial
        Color color;
        bool hasBorder = false;

        switch (status) {
          case 1:
            color = AppTheme.successGreen;
            break;
          case 0:
            color = AppTheme.missedRed;
            break;
          case 3:
            color = AppTheme.pendingGray;
            hasBorder = true;
            break;
          case 2:
          default:
            color = Colors.transparent;
            hasBorder = true;
            break;
        }

        final isToday = day == DateTime.now().day &&
            _currentMonth.month == DateTime.now().month &&
            _currentMonth.year == DateTime.now().year;

        return Container(
          decoration: BoxDecoration(
            color: color == Colors.transparent
                ? null
                : color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(color: AppTheme.primaryBrown, width: 2)
                : (hasBorder || color != Colors.transparent)
                    ? Border.all(
                        color: color == Colors.transparent
                            ? Colors.grey.shade300
                            : color.withValues(alpha: 0.3),
                      )
                    : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                color: status == 1 || status == 0
                    ? color
                    : AppTheme.textDark
                        .withValues(alpha: status == 2 ? 0.4 : 0.8),
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem('Completed', AppTheme.successGreen),
          const SizedBox(width: 16),
          _legendItem('Partial', AppTheme.pendingGray),
          const SizedBox(width: 16),
          _legendItem('Missed', AppTheme.missedRed),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textDark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
