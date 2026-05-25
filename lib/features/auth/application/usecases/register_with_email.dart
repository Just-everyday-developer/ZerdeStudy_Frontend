import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class RegisterWithEmail {
  const RegisterWithEmail(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String email,
    required String password,
    String? platform,
  }) {
    return _repository.register(email: email, password: password, platform: platform);
  }
}
