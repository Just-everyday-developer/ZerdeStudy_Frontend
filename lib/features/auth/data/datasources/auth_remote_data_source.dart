import 'package:flutter/foundation.dart';

import '../../../../core/network/json_http_client.dart';
import '../models/auth_tokens_dto.dart';
import '../models/auth_user_dto.dart';
import '../models/backend_profile_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final JsonHttpClient _client;

  Future<AuthTokensDto> register({
    required String email,
    required String password,
    String? platform,
  }) async {
    final json = await _client.postJson(
      '/api/v1/auth/register',
      body: <String, dynamic>{
        'email': email,
        'password': password,
        if (platform != null) 'platform': platform,
      },
    );
    return AuthTokensDto.fromJson(json);
  }

  Future<AuthTokensDto> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.postJson(
      '/api/v1/auth/login',
      body: <String, dynamic>{'email': email, 'password': password},
    );
    return AuthTokensDto.fromJson(json);
  }

  Future<AuthTokensDto> refresh({required String refreshToken}) async {
    final json = await _client.postJson(
      '/api/v1/auth/refresh',
      body: <String, dynamic>{'refresh_token': refreshToken},
    );
    return AuthTokensDto.fromJson(json);
  }

  Future<void> logout({required String refreshToken}) {
    return _client.postEmpty(
      '/api/v1/auth/logout',
      body: <String, dynamic>{'refresh_token': refreshToken},
    );
  }

  Future<void> forgotPassword({required String email}) {
    return _client.postEmpty(
      '/api/v1/auth/forgot-password',
      body: <String, dynamic>{'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _client.postEmpty(
      '/api/v1/auth/reset-password',
      body: <String, dynamic>{
        'email': email,
        'code': code,
        'new_password': newPassword,
      },
    );
  }

  Future<AuthUserDto> me({required String accessToken}) async {
    final json = await _client.getJson(
      '/api/v1/auth/me',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
    return AuthUserDto.fromJson(json);
  }

  /// Fetches the signed-in user's full profile including server-computed
  /// XP, level, streak and max_streak via GET /profiles/me.
  Future<BackendProfileDto> fetchProfile({required String accessToken}) async {
    final json = await _client.getJson(
      '/api/v1/profiles/me',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
    return BackendProfileDto.fromJson(json);
  }

  /// Updates the current user's own profile via PATCH /profiles/me.
  /// The backend maps [name] to the user `login`, and [avatarBase64]/photoUrl
  /// to `photo_url`. Only non-null fields are sent.
  Future<void> updateProfile({
    required String accessToken,
    String? name,
    String? bio,
    String? email,
    String? avatarBase64,
  }) {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (bio != null) 'bio': bio,
      if (email != null) 'email': email,
      if (avatarBase64 != null) 'avatarBase64': avatarBase64,
    };

    return _client.patchEmpty(
      '/api/v1/profiles/me',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      body: body,
    );
  }

  /// Changes the current user's password via POST /auth/change-password.
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) {
    return _client.postEmpty(
      '/api/v1/auth/change-password',
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
      body: <String, dynamic>{
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<String> getGoogleAuthUrl({
    String? redirectUri,
    String? platform,
  }) async {
    final queryParameters = <String, String>{};
    if (redirectUri != null) queryParameters['redirect_uri'] = redirectUri;
    if (platform != null) queryParameters['platform'] = platform;

    final json = await _client.getJson(
      '/api/v1/auth/oauth/google/url',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    return json['auth_url'] as String;
  }

  Future<String> getGithubAuthUrl({String? redirectUri, String? platform}) async {
    final queryParameters = <String, String>{};
    if (redirectUri != null) queryParameters['redirect_uri'] = redirectUri;
    if (platform != null) queryParameters['platform'] = platform;

    final json = await _client.getJson(
      '/api/v1/auth/oauth/github/url',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    return json['auth_url'] as String;
  }

  Future<AuthTokensDto> googleCallback(
    String code, {
    String? platform,
    String? redirectUri,
  }) async {
    debugPrint('[RemoteDataSource] POST /oauth/google/callback  platform=$platform  redirect_uri=$redirectUri  code_len=${code.length}');
    final json = await _client.postJson(
      '/api/v1/auth/oauth/google/callback',
      body: <String, dynamic>{
        'code': code,
        if (platform != null) 'platform': platform,
        if (redirectUri != null) 'redirect_uri': redirectUri,
      },
    );
    debugPrint('[RemoteDataSource] POST /oauth/google/callback response: $json');
    return AuthTokensDto.fromJson(json);
  }

  Future<AuthTokensDto> githubCallback(
    String code, {
    String? redirectUri,
  }) async {
    final json = await _client.postJson(
      '/api/v1/auth/oauth/github/callback',
      body: <String, dynamic>{
        'code': code,
        if (redirectUri != null) 'redirect_uri': redirectUri,
      },
    );
    return AuthTokensDto.fromJson(json);
  }
}
