import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';

final xpProvider = StateProvider<int>((ref) => 1250);

class GamificationService {
  static int getLevel(int totalXP) => (totalXP / 1000).floor() + 1;
  
  static double getProgressToNextLevel(int totalXP) {
    final progress = (totalXP % 1000) / 1000;
    return progress;
  }

  static int getXPForNextLevel(int totalXP) {
    return 1000 - (totalXP % 1000);
  }

  static int xpForHabit(String frequency) {
    return frequency == 'daily' ? 50 : 200;
  }

  static String getLevelTitle(int level) {
    if (level < 3) return 'Beginner';
    if (level < 5) return 'Explorer';
    if (level < 8) return 'Achiever';
    if (level < 12) return 'Master';
    return 'Legend';
  }
}

class XPBadge extends ConsumerWidget {
  const XPBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalXP = ref.watch(xpProvider);
    final level = GamificationService.getLevel(totalXP);
    final progress = GamificationService.getProgressToNextLevel(totalXP);
    final title = GamificationService.getLevelTitle(level);
    final xpToNext = GamificationService.getXPForNextLevel(totalXP);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentBrown,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBrown.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Lvl $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($title)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 4,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            '$totalXP XP',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// XP Animation overlay
class XPRewardAnimation extends StatefulWidget {
  final int xpAmount;
  final VoidCallback onComplete;

  const XPRewardAnimation({
    super.key,
    required this.xpAmount,
    required this.onComplete,
  });

  @override
  State<XPRewardAnimation> createState() => _XPRewardAnimationState();
}

class _XPRewardAnimationState extends State<XPRewardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0),
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white),
                  Text(
                    '+${widget.xpAmount} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
