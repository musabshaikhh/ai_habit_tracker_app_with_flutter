import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/core/notifications/notification_service.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _selectedIcon;
  late int _selectedColor;
  late String _frequency;
  late TimeOfDay _reminderTime;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'book', 'icon': FontAwesomeIcons.bookOpen},
    {'name': 'workout', 'icon': FontAwesomeIcons.dumbbell},
    {'name': 'meditation', 'icon': FontAwesomeIcons.spa},
    {'name': 'code', 'icon': FontAwesomeIcons.code},
    {'name': 'water', 'icon': FontAwesomeIcons.glassWater},
    {'name': 'sleep', 'icon': FontAwesomeIcons.bed},
    {'name': 'music', 'icon': FontAwesomeIcons.music},
    {'name': 'walk', 'icon': FontAwesomeIcons.personWalking},
  ];

  final List<int> _colors = [
    0xFF8D6E63, // Brown
    0xFF81C784, // Green
    0xFF64B5F6, // Blue
    0xFFFFB74D, // Orange
    0xFFBA68C8, // Purple
    0xFFE57373, // Red
    0xFF4DD0E1, // Cyan
    0xFFA1887F, // Light Brown
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _descController = TextEditingController(text: widget.habit.description);
    _selectedIcon = widget.habit.icon;
    _selectedColor = widget.habit.color;
    _frequency = widget.habit.frequency;
    
    // Parse reminder time
    final timeParts = widget.habit.reminderTime.split(':');
    _reminderTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _updateHabit() {
    if (_nameController.text.isEmpty) return;

    final updatedHabit = widget.habit.copyWith(
      name: _nameController.text,
      description: _descController.text,
      icon: _selectedIcon,
      color: _selectedColor,
      frequency: _frequency,
      reminderTime:
          '${_reminderTime.hour}:${_reminderTime.minute.toString().padLeft(2, '0')}',
    );

    ref.read(habitsProvider.notifier).updateHabit(updatedHabit);
    
    // Schedule notification with new time
    NotificationService.instance.scheduleHabitReminder(
      habitId: updatedHabit.id!,
      habitName: updatedHabit.name,
      time: _reminderTime,
      frequency: updatedHabit.frequency,
    );

    Navigator.pop(context);
  }

  void _deleteHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${widget.habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitsProvider.notifier).deleteHabit(widget.habit.id!);
              NotificationService.instance.cancelHabitReminder(widget.habit.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.missedRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Habit',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _deleteHabit,
            icon: const Icon(Icons.delete_outline, color: AppTheme.missedRed),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Stats Card
            _buildStatsCard(),
            const SizedBox(height: 24),
            
            // Habit Info
            _buildTextField(
              'Habit Name',
              _nameController,
              'e.g., Read 20 pages',
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Description',
              _descController,
              'Why is this habit important?',
            ),
            const SizedBox(height: 32),
            
            // Icon Selection
            Text('Icon', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _icons.map((item) {
                bool isSelected = _selectedIcon == item['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = item['name']),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBrown : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      item['icon'],
                      color: isSelected ? Colors.white : AppTheme.primaryBrown,
                      size: 20,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            // Color Selection
            Text('Color', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: _colors.map((color) {
                bool isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppTheme.textDark, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            // Frequency Toggle
            _buildFrequencyToggle(),
            const SizedBox(height: 32),
            
            // Reminder Time
            _buildReminderTimePicker(),
            const SizedBox(height: 40),
            
            // Update Button
            ElevatedButton(
              onPressed: _updateHabit,
              child: const Text('Update Habit'),
            ),
            const SizedBox(height: 16),
            
            // Delete Button
            OutlinedButton(
              onPressed: _deleteHabit,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.missedRed,
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: AppTheme.missedRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Delete Habit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBrown.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Current Streak', '🔥 ${widget.habit.currentStreak}'),
          _buildStatItem('Longest Streak', '⭐ ${widget.habit.longestStreak}'),
          _buildStatItem('Total Done', '✓ ${widget.habit.totalCompletions}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBrown,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textDark.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Frequency',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        Row(
          children: [
            _toggleBtn('Daily', _frequency == 'daily'),
            const SizedBox(width: 8),
            _toggleBtn('Weekly', _frequency == 'weekly'),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Reminder Time',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryBrown.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppTheme.primaryBrown,
                ),
                const SizedBox(width: 8),
                Text(
                  _reminderTime.format(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleBtn(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _frequency = label.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBrown : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
