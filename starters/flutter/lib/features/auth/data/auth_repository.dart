import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../shared/models/user.dart';

/// Auth repository provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient: apiClient);
});

/// Repository for auth-related API calls.
class AuthRepository {
  const AuthRepository({required this.apiClient});

  final ApiClient apiClient;

  /// Get the current authenticated user's profile.
  Future<User> getCurrentUser() async {
    final response = await apiClient.get<User>(
      '/auth/me',
      fromData: (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to get user');
    }

    return response.data!;
  }
}
