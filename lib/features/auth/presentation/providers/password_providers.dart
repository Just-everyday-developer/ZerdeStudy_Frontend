import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/validate_password.dart';
import '../../domain/validators/password_validator.dart';
import '../../data/validators/password_validator_impl.dart';

final passwordValidatorProvider = Provider<PasswordValidator>((ref) {
  return PasswordValidatorImpl();
});

final validatePasswordProvider = Provider<ValidatePassword>((ref) {
  final validator = ref.watch(passwordValidatorProvider);

  return ValidatePassword(validator);
});
