import '../../domain/validators/password_validator.dart';

class ValidatePassword {
  const ValidatePassword(this._validator);

  final PasswordValidator _validator;

  bool call(String password) => _validator.isLengthEnough(password);
}