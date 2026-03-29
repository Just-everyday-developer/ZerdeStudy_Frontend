import '../../domain/repositories/auth_repository.dart';

class RequestPasswordReset {
  const RequestPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.requestPasswordReset(email: email);
  }
}
