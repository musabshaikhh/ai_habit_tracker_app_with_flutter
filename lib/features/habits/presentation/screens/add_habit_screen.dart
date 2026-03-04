import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/core/notifications/notification_service.dart';
import 'package:ai_habit_tracker_app/features/habits/domain/models/habit.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/habit_provider.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedIcon = 'book';
  int _selectedColor = 0xFF8D6E63;
  String _frequency = 'daily';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSaving = false;

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

  void _saveHabit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (kDebugMode) {
        print('AddHabitScreen: Saving habit ${_nameController.text}');
      }

      final habit = Habit(
        name: _nameController.text,
        description: _descController.text,
        icon: _selectedIcon,
        color: _selectedColor,
        frequency: _frequency,
        reminderTime:
            '${_reminderTime.hour}:${_reminderTime.minute.toString().padLeft(2, '0')}',
        startDate: DateTime.now(),
      );

      final habitId = await ref.read(habitsProvider.notifier).addHabit(habit);
      
      if (kDebugMode) {
        print('AddHabitScreen: Habit saved with ID $habitId');
      }

      // Schedule notification if enabled
      final settings = ref.read(settingsProvider);
      if (settings.notificationsEnabled) {
        try {
          await NotificationService.instance.scheduleHabitReminder(
            habitId: habitId,
            habitName: habit.name,
            time: _reminderTime,
            frequency: habit.frequency,
          );
          if (kDebugMode) {
            print('AddHabitScreen: Notification scheduled for habit $habitId');
          }
        } catch (e) {
          if (kDebugMode) {
            print('AddHabitScreen: Error scheduling notification: $e');
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit created successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print('AddHabitScreen: Error saving habit: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving habit: $e'),
            backgroundColor: AppTheme.missedRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Habit',
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
            Text('Icon & Color', style: Theme.of(context).textTheme.titleLarge),
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
                      color:
                          isSelected ? AppTheme.primaryBrown : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      item['icon'],
                      color:
                          isSelected ? Colors.white : AppTheme.primaryBrown,
                      size: 20,
                    ),
                  ),
                );
              }).toList(),
            ),
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
            _buildFrequencyToggle(),
            const SizedBox(height: 32),
            _buildReminderTimePicker(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveHabit,
              child: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Habit'),
            ),
          ],
        ),
      ),
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
