import '../../domain/validators/email_validator.dart';

class ValidateSignUpForm {
  ValidateSignUpForm(this._emailValidator);

  final EmailValidator _emailValidator;

  SignUpValidationResult call({
    required String name,
    required String email,
    required String password,
  }) {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty) {
      return const SignUpValidationResult.invalid('Name is required');
    }

    if (!_emailValidator.isValid(trimmedEmail)) {
      return const SignUpValidationResult.invalid('Invalid email');
    }

    if (password.length < 8) {
      return const SignUpValidationResult.invalid('Password must be at least 8 characters');
    }

    return const SignUpValidationResult.valid();
  }
}

class SignUpValidationResult {
  final bool ok;
  final String? message;

  const SignUpValidationResult._(this.ok, this.message);

  const SignUpValidationResult.valid() : this._(true, null);
  const SignUpValidationResult.invalid(String msg) : this._(false, msg);
}
