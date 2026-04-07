import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_response.dart';
import '../data/example_model.dart';
import '../data/example_repository.dart';

/// Provider for the paginated example list.
final exampleListProvider =
    FutureProvider.autoDispose.family<PaginatedResponse<ExampleProject>, int>(
  (ref, page) {
    final repository = ref.watch(exampleRepositoryProvider);
    return repository.list(page: page);
  },
);

/// Provider for a single example by ID.
final exampleDetailProvider =
    FutureProvider.autoDispose.family<ExampleProject, String>(
  (ref, id) {
    final repository = ref.watch(exampleRepositoryProvider);
    return repository.getById(id);
  },
);
