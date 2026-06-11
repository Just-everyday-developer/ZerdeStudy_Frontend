import '../../../../core/network/json_http_client.dart';
import '../models/admin_role_dto.dart';
import '../models/admin_user_dto.dart';
import '../models/course_review_dto.dart';

/// Talks to the auth-service RBAC endpoints through the gateway.
///
/// Path notes (gin RedirectTrailingSlash): the auth-service registers the
/// collection routes with a trailing slash (`/users/`, `/roles/`, `/user_roles/`),
/// so we call those with a trailing slash to avoid a redirect that would drop
/// the body/method on PATCH. `/users/status` and `/user_roles/revoke` are exact.
class AdminRemoteDataSource {
  AdminRemoteDataSource(this._client);

  final JsonHttpClient _client;

  Future<List<AdminUserDto>> fetchUsers({required String accessToken}) async {
    final json = await _client.getJsonList(
      '/api/v1/users/',
      headers: _authHeaders(accessToken),
    );
    return json.map(AdminUserDto.fromJson).toList(growable: false);
  }

  Future<List<AdminRoleDto>> fetchRoles({required String accessToken}) async {
    final json = await _client.getJsonList(
      '/api/v1/roles/',
      headers: _authHeaders(accessToken),
    );
    return json.map(AdminRoleDto.fromJson).toList(growable: false);
  }

  /// PATCH /api/v1/users/status — activate or deactivate a user.
  Future<AdminUserDto> fetchUserProfile({
    required String accessToken,
    required String userId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/profiles/${userId.trim()}',
      headers: _authHeaders(accessToken),
    );
    return AdminUserDto.fromJson(json);
  }

  Future<List<AdminRoleDto>> fetchUserRoles({
    required String accessToken,
    required String userId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/user_roles/${userId.trim()}',
      headers: _authHeaders(accessToken),
    );
    return _rolesFromUserRolesResponse(json);
  }

  Future<AdminUserDto> updateUserStatus({
    required String accessToken,
    required String userId,
    required bool isActive,
  }) async {
    final json = await _client.patchJson(
      '/api/v1/users/status',
      headers: _authHeaders(accessToken),
      body: <String, dynamic>{'user_id': userId, 'is_active': isActive},
    );
    return AdminUserDto.fromJson(json);
  }

  /// PATCH /api/v1/user_roles/ — replace the full role set for a user.
  /// Returns the user's updated roles.
  Future<List<AdminRoleDto>> replaceUserRoles({
    required String accessToken,
    required String userId,
    required List<String> roleIds,
  }) async {
    final json = await _client.patchJson(
      '/api/v1/user_roles/',
      headers: _authHeaders(accessToken),
      body: <String, dynamic>{'user_id': userId, 'role_ids': roleIds},
    );
    return _rolesFromUserRolesResponse(json);
  }

  /// POST /api/v1/user_roles/revoke — remove a single role from a user.
  /// Returns the user's remaining roles.
  Future<List<AdminRoleDto>> revokeUserRole({
    required String accessToken,
    required String userId,
    required String roleId,
  }) async {
    final json = await _client.postJson(
      '/api/v1/user_roles/revoke',
      headers: _authHeaders(accessToken),
      body: <String, dynamic>{'user_id': userId, 'role_id': roleId},
    );
    return _rolesFromUserRolesResponse(json);
  }

  Future<List<PendingCourseDto>> fetchPendingCourses({
    required String accessToken,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/admin/courses/pending-check',
      headers: _authHeaders(accessToken),
    );
    return json.map(PendingCourseDto.fromJson).toList(growable: false);
  }

  Future<CourseReviewResultDto> reviewCourse({
    required String accessToken,
    required String courseId,
    required String adminId,
    required bool isApproved,
    required String comment,
  }) async {
    final json = await _client.patchJson(
      '/api/v1/admin/courses/$courseId/review',
      headers: _authHeaders(accessToken),
      body: <String, dynamic>{
        'is_approved': isApproved,
        'admin_id': adminId,
        'comment': comment,
      },
    );
    return CourseReviewResultDto.fromJson(json);
  }

  Future<CourseReviewResultDto> getCourseReview({
    required String accessToken,
    required String courseId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/admin/courses/$courseId/review',
      headers: _authHeaders(accessToken),
    );
    return CourseReviewResultDto.fromJson(json);
  }

  List<AdminRoleDto> _rolesFromUserRolesResponse(JsonMap json) {
    final rawRoles = json['roles'] as List<dynamic>? ?? const <dynamic>[];
    return rawRoles
        .whereType<Map<String, dynamic>>()
        .map(AdminRoleDto.fromJson)
        .toList(growable: false);
  }

  Map<String, String> _authHeaders(String accessToken) {
    return <String, String>{'Authorization': 'Bearer ${accessToken.trim()}'};
  }
}
