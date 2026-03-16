import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/validators/email_validator.dart';
import '../../data/validators/email_validator_impl.dart';
import '../../application/usecases/validate_email.dart';

/// 1) С Domain простого интерфейса который проверяет валиден ли, мы создаем Data конкретную реализацию EmailValidatorImpl
/// но он подходит и к EmailValidator потому что использовали implement
final emailValidatorProvider = Provider<EmailValidator>((ref) {  // EmailValidator это интерфейс
  return EmailValidatorImpl();  // возвращает конкретную реализацию
});  // Domain

/// 2) Usecase, который использует доменный интерфейс
final validateEmailProvider = Provider<ValidateEmail>((ref) {
  final validator = ref.watch(emailValidatorProvider);
  return ValidateEmail(validator);
});  // Application


