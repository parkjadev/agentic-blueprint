import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/router/routes.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/example_providers.dart';

class ExampleListScreen extends HookConsumerWidget {
  const ExampleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(exampleListProvider(1));

    return AppScaffold(
      title: 'Examples',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create screen or show create dialog
          context.showSnackBar('Create flow — implement per your needs');
        },
        child: const Icon(Icons.add),
      ),
      body: listAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading examples...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(exampleListProvider(1)),
        ),
        data: (response) {
          if (!response.success || response.data == null) {
            return ErrorView(
              message: response.error?.message ?? 'Failed to load examples',
              onRetry: () => ref.invalidate(exampleListProvider(1)),
            );
          }

          final items = response.data!;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: context.colours.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No examples yet',
                    style: context.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first one',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colours.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(exampleListProvider(1));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: item.description != null
                        ? Text(
                            item.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.exampleDetail(item.id)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
