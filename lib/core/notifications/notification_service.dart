import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }

    // Android 13+ requires runtime permission
    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final notificationEnabled = await androidPlugin.areNotificationsEnabled();
        return notificationEnabled ?? false;
      }
    }

    return true;
  }

  Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitName,
    required TimeOfDay time,
    required String frequency,
  }) async {
    await cancelHabitReminder(habitId);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Reminders for your daily habits',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      habitId,
      'Time for $habitName!',
      'Stay consistent and complete your habit today.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: frequency == 'daily'
          ? DateTimeComponents.time
          : DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelHabitReminder(int habitId) async {
    await _flutterLocalNotificationsPlugin.cancel(habitId);
  }

  Future<void> cancelAllReminders() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'immediate_notifications',
      'Immediate Notifications',
      channelDescription: 'Immediate app notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
