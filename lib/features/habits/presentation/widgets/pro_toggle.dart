import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import 'package:ai_habit_tracker_app/features/habits/presentation/widgets/xp_badge.dart';

final proVersionProvider = StateProvider<bool>((ref) => false);

class ProVersionToggle extends ConsumerWidget {
  const ProVersionToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proVersionProvider);

    return Container(
      decoration: BoxDecoration(
        color: isPro ? AppTheme.accentBrown : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPro ? Colors.amber.withValues(alpha: 0.2) : AppTheme.primaryBrown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPro ? Icons.star : Icons.star_border,
            color: isPro ? Colors.amber : AppTheme.primaryBrown,
          ),
        ),
        title: Text(
          'Pro Version',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPro ? Colors.white : AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          isPro ? '✨ All features unlocked' : 'Unlock AI Analysis & Premium Themes',
          style: TextStyle(
            color: isPro ? Colors.white70 : AppTheme.textDark.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: isPro,
          activeThumbColor: Colors.amber,
          activeTrackColor: Colors.white,
          inactiveThumbColor: AppTheme.pendingGray,
          inactiveTrackColor: AppTheme.pendingGray.withValues(alpha: 0.3),
          onChanged: (value) {
            ref.read(proVersionProvider.notifier).state = value;
            if (value) {
              _showProWelcome(context);
            }
          },
        ),
      ),
    );
  }

  void _showProWelcome(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text('Welcome to Pro! 🎉'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You now have access to:'),
            SizedBox(height: 12),
            _ProFeature(icon: Icons.psychology, text: 'Advanced AI Insights'),
            _ProFeature(icon: Icons.palette, text: 'Premium Themes'),
            _ProFeature(icon: Icons.analytics, text: 'Detailed Analytics'),
            _ProFeature(icon: Icons.cloud, text: 'Cloud Backup'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }
}

class _ProFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryBrown),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
