import 'package:riverpod/riverpod.dart';

import '../../domain/validators/email_validator.dart';
import '../../data/validators/email_validator_impl.dart';
import '../../application/usecases/validate_email.dart';

/// 1) Domain abstraction -> Data implementation
final emailValidatorProvider = Provider<EmailValidator>((ref) {
  return EmailValidatorImpl();
});

/// 2) Usecase, который использует доменный интерфейс
final validateEmailProvider = Provider<ValidateEmail>((ref) {
  final validator = ref.watch(emailValidatorProvider);
  return ValidateEmail(validator);
});
