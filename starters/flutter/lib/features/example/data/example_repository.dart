import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import 'example_model.dart';

/// Example repository provider.
final exampleRepositoryProvider = Provider<ExampleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExampleRepository(apiClient: apiClient);
});

/// Repository for the example CRUD resource.
/// Demonstrates the full Riverpod + repository + API client pattern.
class ExampleRepository {
  const ExampleRepository({required this.apiClient});

  final ApiClient apiClient;

  /// List projects (paginated).
  Future<PaginatedResponse<ExampleProject>> list({
    int page = 1,
    int pageSize = 20,
  }) async {
    return apiClient.getList<ExampleProject>(
      '/example',
      page: page,
      pageSize: pageSize,
      fromItem: ExampleProject.fromJson,
    );
  }

  /// Get a single project by ID.
  Future<ExampleProject> getById(String id) async {
    final response = await apiClient.get<ExampleProject>(
      '/example/$id',
      fromData: (data) =>
          ExampleProject.fromJson(data as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Project not found');
    }

    return response.data!;
  }

  /// Create a new project.
  Future<ExampleProject> create({
    required String name,
    String? description,
  }) async {
    final response = await apiClient.post<ExampleProject>(
      '/example',
      data: {
        'name': name,
        if (description != null) 'description': description,
      },
      fromData: (data) =>
          ExampleProject.fromJson(data as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to create project');
    }

    return response.data!;
  }

  /// Update a project.
  Future<ExampleProject> update(
    String id, {
    String? name,
    String? description,
  }) async {
    final response = await apiClient.put<ExampleProject>(
      '/example/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      },
      fromData: (data) =>
          ExampleProject.fromJson(data as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to update project');
    }

    return response.data!;
  }

  /// Delete a project (soft delete).
  Future<void> delete(String id) async {
    await apiClient.delete('/example/$id');
  }
}
