import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/datasources/admin_remote_data_source.dart';
import '../../data/models/admin_role_dto.dart';
import '../../data/models/admin_user_dto.dart';

/// Access token of the signed-in (admin) user.
final adminAccessTokenProvider = Provider<String?>((ref) {
  return ref.watch(
    authControllerProvider.select((state) => state.session?.accessToken),
  );
});

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final client = ref.watch(authJsonHttpClientProvider);
  return AdminRemoteDataSource(client);
});

/// All registered users (admin/manager only). Empty when unauthenticated.
final adminUsersProvider = FutureProvider<List<AdminUserDto>>((ref) async {
  final accessToken = ref.watch(adminAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return const <AdminUserDto>[];
  }

  final remote = ref.watch(adminRemoteDataSourceProvider);
  return remote.fetchUsers(accessToken: accessToken);
});

/// All roles defined in the system (admin only). Empty when unauthenticated.
final adminRolesProvider = FutureProvider<List<AdminRoleDto>>((ref) async {
  final accessToken = ref.watch(adminAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return const <AdminRoleDto>[];
  }

  final remote = ref.watch(adminRemoteDataSourceProvider);
  return remote.fetchRoles(accessToken: accessToken);
});
