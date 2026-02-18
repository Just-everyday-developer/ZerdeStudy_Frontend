import '../../domain/validators/email_validator.dart';

class ValidateEmail {
  ValidateEmail(this._validator);

  final EmailValidator _validator;

  bool call(String email) => _validator.isValid(email);
}
