class BackendStreakDto {
  const BackendStreakDto({
    required this.streak,
    required this.lastLogin,
    required this.activeDates,
  });

  final int streak;
  final DateTime? lastLogin;
  final List<DateTime> activeDates;

  factory BackendStreakDto.fromJson(Map<String, dynamic> json) {
    final streak = (json['streak'] as num?)?.round() ?? 0;
    final lastLogin = _parseDateTime(json['last_login']);
    final activeDates = _parseActiveDates(json['active_dates']);

    return BackendStreakDto(
      streak: streak,
      lastLogin: lastLogin,
      activeDates: activeDates.isNotEmpty
          ? activeDates
          : deriveActiveDates(streak: streak, lastLogin: lastLogin),
    );
  }

  static List<DateTime> deriveActiveDates({
    required int streak,
    required DateTime? lastLogin,
  }) {
    if (streak <= 0 || lastLogin == null) {
      return const <DateTime>[];
    }

    final lastDate = _dateOnly(lastLogin.toLocal());
    return List<DateTime>.generate(
      streak,
      (index) => lastDate.subtract(Duration(days: streak - index - 1)),
      growable: false,
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }

  static List<DateTime> _parseActiveDates(Object? value) {
    if (value is! List) {
      return const <DateTime>[];
    }

    return value
        .whereType<String>()
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .map((date) => _dateOnly(date.toLocal()))
        .toList(growable: false);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
