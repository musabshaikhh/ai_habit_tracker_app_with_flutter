import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class XPNotifier extends StateNotifier<int> {
  XPNotifier() : super(0) {
    _loadXP();
  }

  static const String _xpKey = 'total_xp';

  Future<void> _loadXP() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_xpKey) ?? 0;
  }

  Future<void> _saveXP() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, state);
  }

  Future<void> addXP(int amount) async {
    state += amount;
    await _saveXP();
  }

  Future<void> setXP(int amount) async {
    state = amount;
    await _saveXP();
  }

  Future<void> resetXP() async {
    state = 0;
    await _saveXP();
  }

  int get level => (state / 1000).floor() + 1;
  double get progressToNextLevel => (state % 1000) / 1000;
}

final xpProvider = StateNotifierProvider<XPNotifier, int>((ref) {
  return XPNotifier();
});

class GamificationService {
  static int getLevel(int totalXP) => (totalXP / 1000).floor() + 1;
  static double getProgressToNextLevel(int totalXP) => (totalXP % 1000) / 1000;

  static int xpForHabit(String frequency) {
    return frequency == 'daily' ? 50 : 200;
  }
}
