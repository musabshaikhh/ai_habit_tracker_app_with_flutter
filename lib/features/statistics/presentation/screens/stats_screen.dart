// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/core/database/database_helper.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  Future<List<HabitHistory>> _getLast7DaysHistory() async {
    final db = DatabaseHelper.instance;
    final history = <HabitHistory>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayHistory = await db.getHistoryForDate(date);
      history.addAll(dayHistory);
    }

    return history;
  }

  Future<Map<String, dynamic>> _getWeeklyStats() async {
    final db = DatabaseHelper.instance;
    final habits = await db.getAllHabits();
    final now = DateTime.now();

    List<int> dailyCompletions = List.filled(7, 0);
    int totalPossible = habits.length * 7;
    int totalCompleted = 0;

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final history = await db.getHistoryForDate(date);
      final completed = history.where((h) => h.completed).length;
      dailyCompletions[6 - i] = completed;
      totalCompleted += completed;
    }

    final percentage =
        totalPossible > 0 ? (totalCompleted / totalPossible * 100).round() : 0;

    return {
      'dailyCompletions': dailyCompletions,
      'percentage': percentage,
      'totalCompleted': totalCompleted,
    };
  }

  Future<List<FlSpot>> _get30DayTrend() async {
    final db = DatabaseHelper.instance;
    final habits = await db.getAllHabits();
    final now = DateTime.now();
    List<FlSpot> spots = [];

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final history = await db.getHistoryForDate(date);
      final completed = history.where((h) => h.completed).length;
      final percentage = habits.isNotEmpty ? completed / habits.length : 0.0;
      spots.add(FlSpot((29 - i).toDouble(), percentage * 10));
    }

    return spots;
  }

  Future<Map<String, dynamic>> _getOverallStats() async {
    final habits = await DatabaseHelper.instance.getAllHabits();

    int totalCompletions = 0;
    int bestStreak = 0;

    for (final habit in habits) {
      totalCompletions += habit.totalCompletions;
      if (habit.longestStreak > bestStreak) {
        bestStreak = habit.longestStreak;
      }
    }

    return {
      'bestStreak': bestStreak,
      'totalCompletions': totalCompletions,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Completion Chart
            FutureBuilder<Map<String, dynamic>>(
              future: _getWeeklyStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ??
                    {
                      'dailyCompletions': [0, 0, 0, 0, 0, 0, 0],
                      'percentage': 0,
                      'totalCompleted': 0,
                    };
                final dailyCompletions = stats['dailyCompletions'] as List<int>;
                final percentage = stats['percentage'] as int;

                return _buildStatCard(
                  context,
                  'Weekly Completion',
                  habitsAsync.isEmpty
                      ? 'Create habits to see your weekly stats!'
                      : 'You completed $percentage% of your habits this week!',
                  _buildBarChart(dailyCompletions),
                );
              },
            ),
            const SizedBox(height: 24),

            // Consistency Trend Chart
            FutureBuilder<List<FlSpot>>(
              future: _get30DayTrend(),
              builder: (context, snapshot) {
                final spots = snapshot.data ?? [];
                return _buildStatCard(
                  context,
                  'Consistency Trend',
                  'Your daily completion rate over the last 30 days.',
                  _buildLineChart(spots),
                );
              },
            ),
            const SizedBox(height: 24),

            // Mini Stats
            FutureBuilder<Map<String, dynamic>>(
              future: _getOverallStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ??
                    {
                      'bestStreak': 0,
                      'totalCompletions': 0,
                    };
                final bestStreak = stats['bestStreak'] as int;
                final totalCompletions = stats['totalCompletions'] as int;

                return Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat(
                        'Best Streak',
                        '$bestStreak Days',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMiniStat(
                        'Total Completions',
                        totalCompletions.toString(),
                        AppTheme.successGreen,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
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

  Widget _buildBarChart(List<int> dailyCompletions) {
    final maxY = dailyCompletions.isEmpty
        ? 10.0
        : (dailyCompletions.reduce((a, b) => a > b ? a : b) + 1).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY : 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final index = value.toInt();
                if (index >= 0 && index < 7) {
                  return Text(
                    days[index],
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
        barGroups: dailyCompletions.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: AppTheme.primaryBrown,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> spots) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
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
      ),
    );
  }
}
