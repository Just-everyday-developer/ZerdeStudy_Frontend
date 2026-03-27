import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class RefreshAuthSession {
  const RefreshAuthSession(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call() {
    return _repository.refreshSession();
  }
}
