import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';

final xpProvider = StateProvider<int>((ref) => 1250); // Mock starting XP

class GamificationService {
  static int getLevel(int totalXP) => (totalXP / 1000).floor() + 1;
  static double getProgressToNextLevel(int totalXP) => (totalXP % 1000) / 1000;

  static int xpForHabit(String frequency) {
    return frequency == 'daily' ? 50 : 200;
  }
}

class XPBadge extends ConsumerWidget {
  const XPBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalXP = ref.watch(xpProvider);
    final level = GamificationService.getLevel(totalXP);
    final progress = GamificationService.getProgressToNextLevel(totalXP);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentBrown,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Text(
            'Lvl $level',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
