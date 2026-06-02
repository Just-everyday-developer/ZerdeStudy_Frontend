import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_flutter/core/auth/oauth_redirect.dart';
import 'package:frontend_flutter/core/config/app_environment.dart';
import 'package:frontend_flutter/core/network/api_exception.dart';
import 'package:frontend_flutter/core/network/json_http_client.dart';
import 'package:frontend_flutter/app/state/app_experience.dart';
import 'package:frontend_flutter/app/state/demo_app_controller.dart';
import 'package:frontend_flutter/features/auth/application/usecases/request_password_reset.dart';
import 'package:frontend_flutter/features/auth/application/usecases/login_with_email.dart';
import 'package:frontend_flutter/features/auth/application/usecases/logout_current_session.dart';
import 'package:frontend_flutter/features/auth/application/usecases/refresh_auth_session.dart';
import 'package:frontend_flutter/features/auth/application/usecases/register_with_email.dart';
import 'package:frontend_flutter/features/auth/application/usecases/reset_password.dart';
import 'package:frontend_flutter/features/auth/application/usecases/restore_auth_session.dart';
import 'package:frontend_flutter/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend_flutter/features/auth/domain/entities/auth_role.dart';
import 'package:frontend_flutter/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_flutter/features/auth/domain/entities/auth_user.dart';
import 'package:frontend_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Auth SharedPreferences must be overridden.');
});

final authHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final authJsonHttpClientProvider = Provider<JsonHttpClient>((ref) {
  final client = ref.watch(authHttpClientProvider);
  final environment = ref.watch(appEnvironmentProvider);
  return JsonHttpClient(client: client, uriResolver: environment.resolve);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final preferences = ref.watch(authSharedPreferencesProvider);
  return AuthLocalDataSource(preferences);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(authJsonHttpClientProvider);
  return AuthRemoteDataSource(client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final local = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remote: remote, local: local);
});

final loginWithEmailProvider = Provider<LoginWithEmail>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithEmail(repository);
});

final registerWithEmailProvider = Provider<RegisterWithEmail>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterWithEmail(repository);
});

final restoreAuthSessionProvider = Provider<RestoreAuthSession>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RestoreAuthSession(repository);
});

final refreshAuthSessionProvider = Provider<RefreshAuthSession>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshAuthSession(repository);
});

final logoutCurrentSessionProvider = Provider<LogoutCurrentSession>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutCurrentSession(repository);
});

final requestPasswordResetProvider = Provider<RequestPasswordReset>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RequestPasswordReset(repository);
});

final resetPasswordProvider = Provider<ResetPassword>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPassword(repository);
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  bool _bootstrapStarted = false;

  @override
  AuthState build() {
    if (!_bootstrapStarted) {
      _bootstrapStarted = true;
      Future<void>.microtask(_restoreSession);
    }
    return const AuthState.initializing();
  }

  Future<String?> register({required String email, required String password}) {
    return _runSessionAction(
      status: AuthStatus.submitting,
      operation: () => ref.read(registerWithEmailProvider)(
        email: email,
        password: password,
        platform: _getPlatform(),
      ),
    );
  }

  Future<String?> login({required String email, required String password}) {
    return _runSessionAction(
      status: AuthStatus.submitting,
      operation: () =>
          ref.read(loginWithEmailProvider)(email: email, password: password),
    );
  }

  Future<void> signInWithMockProvider({
    required String provider,
    required String roleCode,
  }) async {
    final normalizedProvider = provider.trim().toLowerCase();
    final providerId = normalizedProvider.isEmpty ? 'mock' : normalizedProvider;
    final timestamp = DateTime.now();
    final session = AuthSession(
      accessToken: 'mock-$providerId-access',
      refreshToken: 'mock-$providerId-refresh',
      user: AuthUser(
        id: 'mock-$providerId-user',
        email: '$providerId@zerdestudy.app',
        roles: <AuthRole>[
          AuthRole(
            id: 'mock-$roleCode-role',
            code: roleCode,
            name: roleCode,
            description: 'Mock social login role',
            isDefault: roleCode == 'student',
            isPrivileged: roleCode == 'admin',
            isSupport: roleCode == 'manager',
            createdAt: timestamp,
          ),
        ],
        isActive: true,
        createdAt: timestamp,
      ),
    );

    state = AuthState.authenticated(session);
  }

  Future<String?> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.submitting, errorMessage: null);
    try {
      final platform = _getPlatform();
      final redirectUri = OAuthRedirectConfig.google();
      final url = await ref.read(authRepositoryProvider).getGoogleAuthUrl(
            redirectUri: redirectUri,
            platform: platform,
          );
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // User continues in the system browser; keep UI usable until deep link / web callback.
        state = const AuthState.unauthenticated();
        return null;
      } else {
        throw Exception('Could not launch Google Auth URL');
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return e.toString();
    }
  }

  Future<String?> signInWithGithub() async {
    state = state.copyWith(status: AuthStatus.submitting, errorMessage: null);
    try {
      final redirectUri = OAuthRedirectConfig.github();
      final url = await ref.read(authRepositoryProvider).getGithubAuthUrl(redirectUri: redirectUri);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        state = const AuthState.unauthenticated();
        return null;
      } else {
        throw Exception('Could not launch Github Auth URL');
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return e.toString();
    }
  }

  Future<String?> handleGoogleCallback(String code) {
    return _runSessionAction(
      status: AuthStatus.submitting,
      operation: () => ref.read(authRepositoryProvider).googleCallback(
            code,
            platform: _getPlatform(),
            redirectUri: OAuthRedirectConfig.google(),
          ),
    );
  }

  Future<String?> handleGithubCallback(String code) {
    return _runSessionAction(
      status: AuthStatus.submitting,
      operation: () => ref.read(authRepositoryProvider).githubCallback(
            code,
            redirectUri: OAuthRedirectConfig.github(),
          ),
    );
  }

  Future<String?> refreshSession() {
    return _runSessionAction(
      status: AuthStatus.refreshing,
      operation: () => ref.read(refreshAuthSessionProvider)(),
    );
  }

  Future<String?> logout() async {
    final currentSession = state.session;
    state = state.copyWith(status: AuthStatus.loggingOut, errorMessage: null);

    try {
      await ref.read(logoutCurrentSessionProvider)();
      state = const AuthState.unauthenticated();
      return null;
    } on ApiException catch (error) {
      state = currentSession == null
          ? AuthState.unauthenticated(errorMessage: error.message)
          : AuthState.authenticated(
              currentSession,
              errorMessage: error.message,
            );
      return error.message;
    } catch (_) {
      const message = 'Unable to log out right now.';
      state = currentSession == null
          ? const AuthState.unauthenticated(errorMessage: message)
          : AuthState.authenticated(currentSession, errorMessage: message);
      return message;
    }
  }

  Future<String?> requestPasswordReset({required String email}) {
    return _runStatelessAction(
      status: AuthStatus.submitting,
      operation: () => ref.read(requestPasswordResetProvider)(email: email),
    );
  }

  Future<String?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _runStatelessAction(
      status: AuthStatus.submitting,
      operation: () => ref.read(resetPasswordProvider)(
        email: email,
        code: code,
        newPassword: newPassword,
      ),
    );
  }

  /// Updates the signed-in user's profile on the backend.
  /// Returns null on success, or an error message on failure.
  Future<String?> updateProfile({
    String? name,
    String? bio,
    String? email,
    String? avatarBase64,
  }) async {
    try {
      await ref.read(authRepositoryProvider).updateProfile(
            name: name,
            bio: bio,
            email: email,
            avatarBase64: avatarBase64,
          );
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Unable to update your profile right now.';
    }
  }

  /// Changes the signed-in user's password on the backend.
  /// Returns null on success, or an error message on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Unable to change your password right now.';
    }
  }

  Future<void> _restoreSession() async {
    try {
      final session = await ref.read(restoreAuthSessionProvider)();
      if (session == null) {
        state = const AuthState.unauthenticated();
        return;
      }

      // Update active experience based on user's primary role
      final role = session.user.roles.firstOrNull?.code;
      if (role != null) {
        final experience = switch (role) {
          'teacher' => AppExperience.teacher,
          'manager' => AppExperience.moderator,
          'admin' => AppExperience.admin,
          _ => AppExperience.student,
        };
        ref.read(demoAppControllerProvider.notifier).setActiveExperience(experience);
      }

      state = AuthState.authenticated(session);
    } on ApiException catch (error) {
      state = AuthState.unauthenticated(errorMessage: error.message);
    } catch (_) {
      state = const AuthState.unauthenticated(
        errorMessage: 'Unable to restore your session.',
      );
    }
  }

  Future<String?> _runSessionAction({
    required AuthStatus status,
    required Future<AuthSession> Function() operation,
  }) async {
    final previousSession = state.session;
    state = state.copyWith(status: status, errorMessage: null);

    try {
      final session = await operation();
      
      // Update active experience based on user's primary role
      final role = session.user.roles.firstOrNull?.code;
      if (role != null) {
        final experience = switch (role) {
          'teacher' => AppExperience.teacher,
          'manager' => AppExperience.moderator,
          'admin' => AppExperience.admin,
          _ => AppExperience.student,
        };
        ref.read(demoAppControllerProvider.notifier).setActiveExperience(experience);
      }

      state = AuthState.authenticated(session);
      return null;
    } on ApiException catch (error) {
      state = previousSession == null
          ? AuthState.unauthenticated(errorMessage: error.message)
          : AuthState.authenticated(
              previousSession,
              errorMessage: error.message,
            );
      return error.message;
    } catch (_) {
      const message = 'Unable to complete the request right now.';
      state = previousSession == null
          ? const AuthState.unauthenticated(errorMessage: message)
          : AuthState.authenticated(previousSession, errorMessage: message);
      return message;
    }
  }

  Future<String?> _runStatelessAction({
    required AuthStatus status,
    required Future<void> Function() operation,
  }) async {
    final previousSession = state.session;
    state = state.copyWith(status: status, errorMessage: null);

    try {
      await operation();
      state = previousSession == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(previousSession);
      return null;
    } on ApiException catch (error) {
      state = previousSession == null
          ? AuthState.unauthenticated(errorMessage: error.message)
          : AuthState.authenticated(
              previousSession,
              errorMessage: error.message,
            );
      return error.message;
    } catch (_) {
      const message = 'Unable to complete the request right now.';
      state = previousSession == null
          ? const AuthState.unauthenticated(errorMessage: message)
          : AuthState.authenticated(previousSession, errorMessage: message);
      return message;
    }
  }
  String _getPlatform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'desktop';
      default:
        return 'web';
    }
  }
}
