import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../shared/models/user.dart';

/// Profile repository provider.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});

/// Repository for profile-related API calls.
class ProfileRepository {
  const ProfileRepository({required this.apiClient});

  final ApiClient apiClient;

  /// Get the current user's profile.
  Future<User> getProfile() async {
    final response = await apiClient.get<User>(
      '/auth/me',
      fromData: (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load profile');
    }

    return response.data!;
  }

  /// Update the current user's profile.
  Future<User> updateProfile({String? name}) async {
    final response = await apiClient.put<User>(
      '/auth/me',
      data: {if (name != null) 'name': name},
      fromData: (data) => User.fromJson(data as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to update profile');
    }

    return response.data!;
  }
}
