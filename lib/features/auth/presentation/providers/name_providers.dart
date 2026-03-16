import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/validate_name.dart';
import '../../domain/validators/name_validator.dart';
import '../../data/validators/name_validator_impl.dart';

final nameValidatorProvider = Provider<NameValidator>((ref) {
  return NameValidatorImpl();
});

final validateNameProvider = Provider<ValidateName>((ref) {
  final validator = ref.watch(nameValidatorProvider);
  return ValidateName(validator);
});

