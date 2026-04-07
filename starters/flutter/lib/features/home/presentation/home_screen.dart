import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/router/routes.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_scaffold.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Home',
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.push(Routes.profile),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ref.read(authStateProvider.notifier).logout();
          },
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your app content goes here.',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colours.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Example navigation
            FilledButton.tonal(
              onPressed: () => context.push(Routes.examples),
              child: const Text('View Examples'),
            ),
          ],
        ),
      ),
    );
  }
}
