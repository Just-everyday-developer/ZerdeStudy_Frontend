import 'dart:ui';

enum AppLocale {
  ru(code: 'ru', label: 'RU', locale: Locale('ru')),
  en(code: 'en', label: 'EN', locale: Locale('en')),
  kk(code: 'kk', label: 'KZ', locale: Locale('kk'));

  const AppLocale({
    required this.code,
    required this.label,
    required this.locale,
  });

  final String code;
  final String label;
  final Locale locale;

  static AppLocale fromCode(String? code) {
    return AppLocale.values.firstWhere(
      (locale) => locale.code == code,
      orElse: () => AppLocale.ru,
    );
  }
}
