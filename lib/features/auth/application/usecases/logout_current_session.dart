import '../../domain/repositories/auth_repository.dart';

class LogoutCurrentSession {
  const LogoutCurrentSession(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
