import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_habit_tracker_app/core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

class ProVersionToggle extends ConsumerWidget {
  const ProVersionToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proVersionProvider);

    return ListTile(
      leading: Icon(
        isPro ? Icons.star : Icons.star_border,
        color: isPro ? Colors.amber : AppTheme.primaryBrown,
      ),
      title: const Text(
        'Pro Version',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        isPro ? 'All features unlocked' : 'Unlock AI Analysis & Themes',
      ),
      trailing: Switch(
        value: isPro,
        activeThumbColor: AppTheme.primaryBrown,
        onChanged: (value) {
          ref.read(settingsProvider.notifier).setProVersionEnabled(value);
        },
      ),
    );
  }
}
