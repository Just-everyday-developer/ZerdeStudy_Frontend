import '../../domain/validators/name_validator.dart';

class NameValidatorImpl implements NameValidator {
  @override
  bool isEmpty(String name) => name.trim().isEmpty;
}