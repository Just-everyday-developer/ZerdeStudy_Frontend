import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/data/models/backend_achievement_dto.dart';
import '../../../courses_backend/data/models/backend_progress_dto.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
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

class AdminUserDetails {
  const AdminUserDetails({
    required this.profile,
    required this.roles,
    required this.achievements,
    required this.progress,
    required this.courseProgress,
    required this.courseNames,
  });

  final AdminUserDto profile;
  final List<AdminRoleDto> roles;
  final List<BackendAchievementDto> achievements;
  final List<BackendCourseProgressDto> progress;
  final List<BackendCourseProgressDto> courseProgress;
  /// courseId → course title (best-effort; falls back to courseId if not found)
  final Map<String, String> courseNames;

  int get completedLessons =>
      courseProgress.fold(0, (sum, item) => sum + item.completedLessons);

  int get totalLessons =>
      courseProgress.fold(0, (sum, item) => sum + item.totalLessons);

  int get unlockedAchievements =>
      achievements.where((item) => item.unlocked).length;

  String courseTitle(String courseId) =>
      courseNames[courseId]?.trim().isNotEmpty == true
          ? courseNames[courseId]!
          : courseId;
}

final adminUserDetailsProvider =
    FutureProvider.family<AdminUserDetails?, String>((ref, userId) async {
      final normalizedUserId = userId.trim();
      if (normalizedUserId.isEmpty) {
        return null;
      }

      final accessToken = ref.watch(adminAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        return null;
      }

      final adminRemote = ref.watch(adminRemoteDataSourceProvider);
      final courseRemote = ref.watch(backendCourseRemoteDataSourceProvider);

      final profileFuture = adminRemote.fetchUserProfile(
        accessToken: accessToken,
        userId: normalizedUserId,
      );
      final rolesFuture = adminRemote.fetchUserRoles(
        accessToken: accessToken,
        userId: normalizedUserId,
      );
      final achievementsFuture = courseRemote.fetchAchievementsForUser(
        accessToken: accessToken,
        userId: normalizedUserId,
      );
      final progress = await courseRemote.fetchAllProgressForUser(
        accessToken: accessToken,
        userId: normalizedUserId,
      );

      final courseProgressFuture = Future.wait(
        progress.map((item) async {
          try {
            return await courseRemote.fetchCourseProgressForUser(
              accessToken: accessToken,
              courseId: item.courseId,
              userId: normalizedUserId,
            );
          } catch (_) {
            return item;
          }
        }),
      );

      // Fetch course titles for all courses the user has progress in.
      final courseNamesFuture = Future.wait(
        progress.map((item) async {
          try {
            final course = await courseRemote.fetchCourseById(
              accessToken: accessToken,
              courseId: item.courseId,
            );
            return MapEntry(item.courseId, course.title);
          } catch (_) {
            return MapEntry(item.courseId, '');
          }
        }),
      ).then((entries) => Map.fromEntries(entries));

      final courseProgress = await courseProgressFuture;
      final courseNames = await courseNamesFuture;

      return AdminUserDetails(
        profile: await profileFuture,
        roles: await rolesFuture,
        achievements: await achievementsFuture,
        progress: progress,
        courseProgress: courseProgress,
        courseNames: courseNames,
      );
    });
