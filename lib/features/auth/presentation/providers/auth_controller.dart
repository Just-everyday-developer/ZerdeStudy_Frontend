import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/json_http_client.dart';
import '../../application/usecases/login_with_email.dart';
import '../../application/usecases/logout_current_session.dart';
import '../../application/usecases/refresh_auth_session.dart';
import '../../application/usecases/register_with_email.dart';
import '../../application/usecases/restore_auth_session.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
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
  return JsonHttpClient(
    client: client,
    uriResolver: environment.resolve,
  );
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

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

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

  Future<String?> register({
    required String email,
    required String password,
  }) {
    return _runSessionAction(
      status: AuthStatus.submitting,
      operation: () => ref.read(registerWithEmailProvider)(
            email: email,
            password: password,
          ),
    );
  }

  Future<String?> login({
    required String email,
    required String password,
  }) {
    return _runSessionAction(
      status: AuthStatus.submitting,
      operation: () => ref.read(loginWithEmailProvider)(
            email: email,
            password: password,
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
    state = state.copyWith(
      status: AuthStatus.loggingOut,
      errorMessage: null,
    );

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
          : AuthState.authenticated(
              currentSession,
              errorMessage: message,
            );
      return message;
    }
  }

  Future<void> _restoreSession() async {
    try {
      final session = await ref.read(restoreAuthSessionProvider)();
      if (session == null) {
        state = const AuthState.unauthenticated();
        return;
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
    state = state.copyWith(
      status: status,
      errorMessage: null,
    );

    try {
      final session = await operation();
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
          : AuthState.authenticated(
              previousSession,
              errorMessage: message,
            );
      return message;
    }
  }
}
