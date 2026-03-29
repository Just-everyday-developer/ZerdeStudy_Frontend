import '../../domain/validators/password_validator.dart';

class PasswordValidatorImpl implements PasswordValidator {
  @override
  bool isLengthEnough(String password) {
    if (password.length < 8) {
      return false;
    }
    return true;
  }
}
