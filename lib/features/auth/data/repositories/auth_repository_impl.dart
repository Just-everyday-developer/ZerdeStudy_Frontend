import 'package:frontend_flutter/core/network/api_exception.dart';
import 'package:frontend_flutter/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_flutter/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_flutter/features/auth/data/models/auth_tokens_dto.dart';
import 'package:frontend_flutter/features/auth/data/models/stored_auth_session_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<AuthSession?> restoreSession() async {
    final stored = _local.readSession();
    if (stored == null || !stored.hasTokens) {
      await _local.clearSession();
      return null;
    }

    try {
      final user = await _remote.me(accessToken: stored.accessToken);
      final next = stored.copyWith(user: user);
      await _local.saveSession(next);
      return next.toDomain();
    } on ApiException catch (error) {
      if (!error.isUnauthorized) {
        return stored.toDomain();
      }
    }

    try {
      final refreshed = await _remote.refresh(
        refreshToken: stored.refreshToken,
      );
      return _storeAndBuildSession(refreshed);
    } on ApiException {
      await _local.clearSession();
      return null;
    }
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    String? platform,
  }) async {
    final tokens = await _remote.register(
      email: email,
      password: password,
      platform: platform,
    );
    return _storeAndBuildSession(tokens);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _remote.login(email: email, password: password);
    return _storeAndBuildSession(tokens);
  }

  @override
  Future<AuthSession> refreshSession() async {
    final stored = _local.readSession();
    if (stored == null || stored.refreshToken.trim().isEmpty) {
      throw const ApiException(
        statusCode: 401,
        code: 'invalid_token',
        message: 'No refresh token available.',
      );
    }

    final tokens = await _remote.refresh(refreshToken: stored.refreshToken);
    return _storeAndBuildSession(tokens);
  }

  @override
  Future<void> logout() async {
    final stored = _local.readSession();
    if (stored != null && stored.refreshToken.trim().isNotEmpty) {
      try {
        await _remote.logout(refreshToken: stored.refreshToken);
      } on ApiException {
        // Even if the remote logout fails, the local session should be cleared.
      }
    }

    await _local.clearSession();
  }

  @override
  Future<void> requestPasswordReset({required String email}) {
    return _remote.forgotPassword(email: email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _remote.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? email,
    String? avatarBase64,
  }) async {
    final accessToken = _requireAccessToken();
    await _remote.updateProfile(
      accessToken: accessToken,
      name: name,
      bio: bio,
      email: email,
      avatarBase64: avatarBase64,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final accessToken = _requireAccessToken();
    await _remote.changePassword(
      accessToken: accessToken,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  String _requireAccessToken() {
    final stored = _local.readSession();
    final token = stored?.accessToken.trim() ?? '';
    if (token.isEmpty) {
      throw const ApiException(
        statusCode: 401,
        code: 'invalid_token',
        message: 'You need to be signed in to do this.',
      );
    }
    return token;
  }

  @override
  Future<String> getGoogleAuthUrl({String? redirectUri, String? platform}) =>
      _remote.getGoogleAuthUrl(redirectUri: redirectUri, platform: platform);

  @override
  Future<String> getGithubAuthUrl({String? redirectUri, String? platform}) =>
      _remote.getGithubAuthUrl(redirectUri: redirectUri, platform: platform);

  @override
  Future<AuthSession> googleCallback(
    String code, {
    String? platform,
    String? redirectUri,
  }) async {
    final tokens = await _remote.googleCallback(
      code,
      platform: platform,
      redirectUri: redirectUri,
    );
    return _storeAndBuildSession(tokens);
  }

  @override
  Future<AuthSession> githubCallback(String code, {String? redirectUri}) async {
    final tokens = await _remote.githubCallback(
      code,
      redirectUri: redirectUri,
    );
    return _storeAndBuildSession(tokens);
  }

  Future<AuthSession> _storeAndBuildSession(AuthTokensDto tokens) async {
    final user = await _remote.me(accessToken: tokens.accessToken);
    final stored = StoredAuthSessionDto(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: user,
    );

    await _local.saveSession(stored);
    final session = stored.toDomain();
    if (session == null) {
      throw const ApiException(
        statusCode: 0,
        code: 'invalid_session',
        message: 'Unable to build an authenticated session.',
      );
    }
    return session;
  }
}
