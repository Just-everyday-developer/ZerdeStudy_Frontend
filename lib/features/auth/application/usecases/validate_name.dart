import '../../domain/validators/name_validator.dart';

class ValidateName {
  const ValidateName(this._validator);

  final NameValidator _validator;

  bool call(String name) => !_validator.isEmpty(name);
}
