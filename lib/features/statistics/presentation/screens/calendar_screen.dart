import 'package:flutter/material.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History', style: Theme.of(context).textTheme.titleLarge),
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
            Expanded(child: _buildCalendarGrid()),
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
        const Text(
          'February 2026',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 31,
      itemBuilder: (context, index) {
        int day = index + 1;
        // Mock data for colors
        Color color = index % 3 == 0
            ? AppTheme.successGreen
            : (index % 5 == 0 ? AppTheme.missedRed : Colors.white);
        bool isFuture = day > 28; // Simple mock for "today"
        if (isFuture) color = Colors.transparent;

        return Container(
          decoration: BoxDecoration(
            color: isFuture ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(12),
            border: !isFuture && color == Colors.white
                ? Border.all(color: Colors.black12)
                : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                color: color == Colors.white || isFuture
                    ? AppTheme.textDark
                    : Colors.white,
                fontWeight: FontWeight.bold,
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
        _legendItem('Missed', AppTheme.missedRed),
        const SizedBox(width: 20),
        _legendItem('Pending', Colors.white),
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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
