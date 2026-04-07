import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../data/profile_repository.dart';

/// FutureProvider for the user profile.
final profileProvider = FutureProvider.autoDispose((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile();
});

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return AppScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ref.read(authStateProvider.notifier).logout();
          },
        ),
      ],
      body: profileAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading profile...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (user) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                child: Text(
                  user.displayName[0].toUpperCase(),
                  style: context.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),
              _ProfileField(label: 'Name', value: user.displayName),
              _ProfileField(label: 'Email', value: user.email),
              _ProfileField(label: 'Role', value: user.role),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colours.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: context.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
