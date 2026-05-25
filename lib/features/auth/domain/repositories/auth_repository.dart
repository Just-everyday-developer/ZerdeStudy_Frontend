import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> restoreSession();

  Future<AuthSession> register({
    required String email,
    required String password,
    String? platform,
  });

  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> refreshSession();

  Future<void> logout();

  Future<void> requestPasswordReset({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<String> getGoogleAuthUrl({String? redirectUri, String? platform});
  Future<String> getGithubAuthUrl({String? redirectUri});
  Future<AuthSession> googleCallback(
    String code, {
    String? platform,
    String? redirectUri,
  });
  Future<AuthSession> githubCallback(String code, {String? redirectUri});
}
