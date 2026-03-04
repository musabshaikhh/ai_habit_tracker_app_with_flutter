import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  Map<int, int> _weeklyData = {};
  List<double> _monthlyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      await _loadWeeklyData();
      await _loadMonthlyData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWeeklyData() async {
    final habits = ref.read(habitsProvider);
    final weekData = <int, int>{};

    for (int i = 0; i < 7; i++) {
      weekData[i] = 0;
    }

    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: 6 - i));
      final dateStr = date.toIso8601String().split('T')[0];

      for (final habit in habits) {
        if (habit.id != null) {
          final history = await DatabaseHelper.instance.getHistoryForHabit(habit.id!);
          final completed = history.any((h) =>
              h.date.toIso8601String().split('T')[0] == dateStr && h.completed);
          if (completed) {
            weekData[i] = (weekData[i] ?? 0) + 1;
          }
        }
      }
    }

    setState(() => _weeklyData = weekData);
  }

  Future<void> _loadMonthlyData() async {
    final habits = ref.read(habitsProvider);
    final monthData = <double>[];

    final today = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      int completedCount = 0;

      for (final habit in habits) {
        if (habit.id != null) {
          final history = await DatabaseHelper.instance.getHistoryForHabit(habit.id!);
          final completed = history.any((h) =>
              h.date.year == date.year &&
              h.date.month == date.month &&
              h.date.day == date.day &&
              h.completed);
          if (completed) completedCount++;
        }
      }

      final rate = habits.isEmpty ? 0.0 : completedCount / habits.length;
      monthData.add(rate * 10);
    }

    setState(() => _monthlyData = monthData);
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCard(
                      context,
                      'Weekly Completion',
                      'You completed ${_calculateWeeklyPercentage(habits.length)}% of your habits this week!',
                      _buildBarChart(habits.length),
                    ),
                    const SizedBox(height: 24),
                    _buildStatCard(
                      context,
                      'Consistency Trend',
                      'Your daily completion rate over the last 30 days.',
                      _buildLineChart(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniStat(
                            _getBestStreak(habits),
                            'Best Streak',
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMiniStat(
                            _getTotalCompletions(habits).toString(),
                            'Finished',
                            AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Weekly Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
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
                            'Weekly Summary',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            Icons.check_circle,
                            'Habits Completed',
                            _getTotalThisWeek().toString(),
                            AppTheme.successGreen,
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            Icons.local_fire_department,
                            'Streaks Maintained',
                            _getActiveStreaks(habits).toString(),
                            Colors.orange,
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            Icons.trending_up,
                            'Completion Rate',
                            '${_calculateWeeklyPercentage(habits.length)}%',
                            AppTheme.primaryBrown,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  int _getTotalThisWeek() {
    return _weeklyData.values.fold(0, (sum, val) => sum + val);
  }

  int _getActiveStreaks(List<Habit> habits) {
    return habits.where((h) => h.currentStreak > 0).length;
  }

  int _calculateWeeklyPercentage(int totalHabits) {
    if (totalHabits == 0) return 0;
    final totalCompleted = _getTotalThisWeek();
    final maxPossible = totalHabits * 7;
    if (maxPossible == 0) return 0;
    return ((totalCompleted / maxPossible) * 100).round();
  }

  int _getBestStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    return habits.fold(0, (max, h) => h.longestStreak > max ? h.longestStreak : max);
  }

  int _getTotalCompletions(List<Habit> habits) {
    return habits.fold(0, (sum, h) => sum + h.totalCompletions);
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String subtitle,
    Widget chart,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
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
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(int totalHabits) {
    final maxY = (totalHabits > 0 ? totalHabits : 10).toDouble();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < weekdays.length) {
                  return Text(
                    weekdays[index],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          final value = (_weeklyData[index] ?? 0).toDouble();
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: AppTheme.primaryBrown,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _monthlyData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: AppTheme.primaryBrown,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryBrown.withValues(alpha: 0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 10,
      ),
    );
  }
}
