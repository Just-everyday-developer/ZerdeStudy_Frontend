import 'package:email_validator/email_validator.dart' as ev;
import '../../domain/validators/email_validator.dart';

class EmailValidatorImpl implements EmailValidator {
  @override
  bool isValid(String email) => ev.EmailValidator.validate(email.trim());
}
