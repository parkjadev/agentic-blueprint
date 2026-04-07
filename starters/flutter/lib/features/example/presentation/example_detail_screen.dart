import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../data/example_repository.dart';
import '../providers/example_providers.dart';

class ExampleDetailScreen extends HookConsumerWidget {
  const ExampleDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(exampleDetailProvider(id));

    return detailAsync.when(
      loading: () => const AppScaffold(
        title: 'Loading...',
        body: LoadingIndicator(),
      ),
      error: (error, _) => AppScaffold(
        title: 'Error',
        body: ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(exampleDetailProvider(id)),
        ),
      ),
      data: (project) => AppScaffold(
        title: project.name,
        actions: [
          // Delete action
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete project?'),
                  content: const Text(
                    'This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                try {
                  final repository = ref.read(exampleRepositoryProvider);
                  await repository.delete(id);
                  if (context.mounted) {
                    context.showSuccess('Project deleted');
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showError(e.toString());
                  }
                }
              }
            },
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Chip(label: Text(project.status)),
              if (project.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  project.description!,
                  style: context.textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Created: ${project.createdAt.toLocal()}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colours.onSurfaceVariant,
                ),
              ),
              Text(
                'Updated: ${project.updatedAt.toLocal()}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colours.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
