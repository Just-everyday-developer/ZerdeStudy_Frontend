import '../../domain/repositories/auth_repository.dart';

class ResetPassword {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _repository.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }
}
