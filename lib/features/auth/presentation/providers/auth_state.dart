import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  initializing,
  unauthenticated,
  authenticated,
  submitting,
  refreshing,
  loggingOut,
}

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.errorMessage,
  });

  const AuthState.initializing()
      : status = AuthStatus.initializing,
        session = null,
        errorMessage = null;

  const AuthState.unauthenticated({
    this.errorMessage,
  })  : status = AuthStatus.unauthenticated,
        session = null;

  const AuthState.authenticated(
    this.session, {
    this.errorMessage,
  }) : status = AuthStatus.authenticated;

  static const Object _sentinel = Object();

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  bool get isReady => status != AuthStatus.initializing;
  bool get isAuthenticated => session != null;
  bool get isBusy =>
      status == AuthStatus.submitting ||
      status == AuthStatus.refreshing ||
      status == AuthStatus.loggingOut;
  bool get isModerator => session?.isModerator ?? false;
  AuthUser? get user => session?.user;

  AuthState copyWith({
    AuthStatus? status,
    Object? session = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return AuthState(
      status: status ?? this.status,
      session:
          identical(session, _sentinel) ? this.session : session as AuthSession?,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
