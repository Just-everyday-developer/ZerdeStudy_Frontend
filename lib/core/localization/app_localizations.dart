import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../app/state/app_locale.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final AppLocale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String text(String key) {
    final localized = _localizedValues[key];
    if (localized == null) {
      return key;
    }
    return localized[locale] ?? localized[AppLocale.en] ?? key;
  }

  static final Map<String, Map<AppLocale, String>>
  _localizedValues = <String, Map<AppLocale, String>>{
    'app_name': {
      AppLocale.ru: 'ZerdeStudy',
      AppLocale.en: 'ZerdeStudy',
      AppLocale.kk: 'ZerdeStudy',
    },
    'tagline': {
      AppLocale.ru:
          'Начните изучать IT шаг за шагом - понятно и уверенно',
      AppLocale.en:
          'Start learning IT step by step with clarity and confidence',
      AppLocale.kk:
          'IT-ті қадам-қадаммен анық әрі сенімді үйренуді бастаңыз',
    },
    'presentation_ready': {
      AppLocale.ru: 'Кликабельный MVP для презентации',
      AppLocale.en: 'Presentation-ready clickable MVP',
      AppLocale.kk: 'Презентацияға дайын кликабельді MVP',
    },
    'continue_learning': {
      AppLocale.ru: 'Продолжить обучение',
      AppLocale.en: 'Continue learning',
      AppLocale.kk: 'Оқуды жалғастыру',
    },
    'login': {
      AppLocale.ru: 'Войти',
      AppLocale.en: 'Log in',
      AppLocale.kk: 'Кіру',
    },
    'signup': {
      AppLocale.ru: 'Создать аккаунт',
      AppLocale.en: 'Sign up',
      AppLocale.kk: 'Аккаунт ашу',
    },
    'login_title': {
      AppLocale.ru: 'Вход в учебный поток',
      AppLocale.en: 'Sign in to your learning flow',
      AppLocale.kk: 'Оқу ағынына кіру',
    },
    'signup_title': {
      AppLocale.ru: 'Запустить личную траекторию',
      AppLocale.en: 'Start your personal track',
      AppLocale.kk: 'Жеке траекторияны бастау',
    },
    'email': {
      AppLocale.ru: 'Email',
      AppLocale.en: 'Email',
      AppLocale.kk: 'Email',
    },
    'password': {
      AppLocale.ru: 'Пароль',
      AppLocale.en: 'Password',
      AppLocale.kk: 'Құпиясөз',
    },
    'full_name': {
      AppLocale.ru: 'Имя',
      AppLocale.en: 'Full name',
      AppLocale.kk: 'Аты-жөні',
    },
    'google': {
      AppLocale.ru: 'Google',
      AppLocale.en: 'Google',
      AppLocale.kk: 'Google',
    },
    'github': {
      AppLocale.ru: 'GitHub',
      AppLocale.en: 'GitHub',
      AppLocale.kk: 'GitHub',
    },
    'apple': {
      AppLocale.ru: 'Apple ID',
      AppLocale.en: 'Apple ID',
      AppLocale.kk: 'Apple ID',
    },
    'invalid_email': {
      AppLocale.ru: 'Введите корректный email',
      AppLocale.en: 'Enter a valid email',
      AppLocale.kk: 'Дұрыс email енгізіңіз',
    },
    'invalid_password': {
      AppLocale.ru: 'Пароль должен быть не короче 8 символов',
      AppLocale.en: 'Password must be at least 8 characters',
      AppLocale.kk: 'Құпиясөз кемінде 8 таңба болуы керек',
    },
    'empty_name': {
      AppLocale.ru: 'Введите имя',
      AppLocale.en: 'Enter your name',
      AppLocale.kk: 'Атыңызды енгізіңіз',
    },
    'tab_home': {
      AppLocale.ru: 'Home',
      AppLocale.en: 'Home',
      AppLocale.kk: 'Home',
    },
    'tab_tree': {
      AppLocale.ru: 'Tree',
      AppLocale.en: 'Tree',
      AppLocale.kk: 'Tree',
    },
    'tab_learn': {
      AppLocale.ru: 'Learn',
      AppLocale.en: 'Learn',
      AppLocale.kk: 'Learn',
    },
    'tab_ai': {AppLocale.ru: 'AI', AppLocale.en: 'AI', AppLocale.kk: 'AI'},
    'tab_profile': {
      AppLocale.ru: 'Profile',
      AppLocale.en: 'Profile',
      AppLocale.kk: 'Profile',
    },
    'dashboard': {
      AppLocale.ru: 'Дашборд',
      AppLocale.en: 'Dashboard',
      AppLocale.kk: 'Дашборд',
    },
    'daily_mission': {
      AppLocale.ru: 'Daily mission',
      AppLocale.en: 'Daily mission',
      AppLocale.kk: 'Daily mission',
    },
    'daily_mission_pending': {
      AppLocale.ru: 'Закройте один урок, практику или memory lab сегодня',
      AppLocale.en: 'Complete one lesson, practice, or memory lab today',
      AppLocale.kk: 'Бүгін бір сабақ, практика немесе memory lab аяқтаңыз',
    },
    'daily_mission_done': {
      AppLocale.ru: 'Сегодняшняя миссия закрыта',
      AppLocale.en: 'Today’s mission is complete',
      AppLocale.kk: 'Бүгінгі миссия орындалды',
    },
    'knowledge_tree': {
      AppLocale.ru: 'Дерево знаний',
      AppLocale.en: 'Knowledge Tree',
      AppLocale.kk: 'Білім ағашы',
    },
    'recommended_tracks': {
      AppLocale.ru: 'Рекомендуемые ветки',
      AppLocale.en: 'Recommended tracks',
      AppLocale.kk: 'Ұсынылған тармақтар',
    },
    'achievements': {
      AppLocale.ru: 'Достижения',
      AppLocale.en: 'Achievements',
      AppLocale.kk: 'Жетістіктер',
    },
    'leaderboard': {
      AppLocale.ru: 'Лидерборд',
      AppLocale.en: 'Leaderboard',
      AppLocale.kk: 'Лидерборд',
    },
    'stats': {
      AppLocale.ru: 'Статистика',
      AppLocale.en: 'Statistics',
      AppLocale.kk: 'Статистика',
    },
    'weekly_activity': {
      AppLocale.ru: 'Активность за неделю',
      AppLocale.en: 'Weekly activity',
      AppLocale.kk: 'Апталық белсенділік',
    },
    'profile': {
      AppLocale.ru: 'Профиль',
      AppLocale.en: 'Profile',
      AppLocale.kk: 'Профиль',
    },
    'locale': {
      AppLocale.ru: 'Язык',
      AppLocale.en: 'Language',
      AppLocale.kk: 'Тіл',
    },
    'logout': {
      AppLocale.ru: 'Выйти',
      AppLocale.en: 'Log out',
      AppLocale.kk: 'Шығу',
    },
    'delete_history': {
      AppLocale.ru: 'Удалить историю',
      AppLocale.en: 'Delete history',
      AppLocale.kk: 'Тарихты жою',
    },
    'track_overview': {
      AppLocale.ru: 'Обзор ветки',
      AppLocale.en: 'Track overview',
      AppLocale.kk: 'Тармақ шолуы',
    },
    'modules': {
      AppLocale.ru: 'Модули',
      AppLocale.en: 'Modules',
      AppLocale.kk: 'Модульдер',
    },
    'minutes': {AppLocale.ru: 'мин', AppLocale.en: 'min', AppLocale.kk: 'мин'},
    'start_track': {
      AppLocale.ru: 'Открыть ветку',
      AppLocale.en: 'Open track',
      AppLocale.kk: 'Тармақты ашу',
    },
    'status_completed': {
      AppLocale.ru: 'Завершено',
      AppLocale.en: 'Completed',
      AppLocale.kk: 'Аяқталды',
    },
    'current_focus': {
      AppLocale.ru: 'Текущий фокус',
      AppLocale.en: 'Current focus',
      AppLocale.kk: 'Қазіргі фокус',
    },
    'complete_lesson': {
      AppLocale.ru: 'Завершить урок',
      AppLocale.en: 'Complete lesson',
      AppLocale.kk: 'Сабақты аяқтау',
    },
    'complete_practice': {
      AppLocale.ru: 'Закрыть практику',
      AppLocale.en: 'Complete practice',
      AppLocale.kk: 'Практиканы аяқтау',
    },
    'ai_mentor': {
      AppLocale.ru: 'AI Mentor',
      AppLocale.en: 'AI Mentor',
      AppLocale.kk: 'AI Mentor',
    },
    'ask_ai': {
      AppLocale.ru: 'Спросить AI',
      AppLocale.en: 'Ask AI',
      AppLocale.kk: 'AI-дан сұрау',
    },
    'suggested_prompts': {
      AppLocale.ru: 'Suggested prompts',
      AppLocale.en: 'Suggested prompts',
      AppLocale.kk: 'Suggested prompts',
    },
    'send_message': {
      AppLocale.ru: 'Отправить',
      AppLocale.en: 'Send',
      AppLocale.kk: 'Жіберу',
    },
    'message_hint': {
      AppLocale.ru: 'Напишите вопрос по уроку, практике, дереву или статистике',
      AppLocale.en: 'Ask about the lesson, practice, tree, or statistics',
      AppLocale.kk:
          'Сабақ, практика, ағаш немесе статистика туралы сұрақ жазыңыз',
    },
    'view_stats': {
      AppLocale.ru: 'Открыть статистику',
      AppLocale.en: 'Open statistics',
      AppLocale.kk: 'Статистиканы ашу',
    },
    'view_leaderboard': {
      AppLocale.ru: 'Открыть лидерборд',
      AppLocale.en: 'Open leaderboard',
      AppLocale.kk: 'Лидербордты ашу',
    },
    'empty_chat': {
      AppLocale.ru:
          'Начните диалог: AI объяснит тему, подскажет следующий шаг и поможет озвучить демо.',
      AppLocale.en:
          'Start the conversation: AI can explain the topic, suggest the next step, and help you understand the material.',
      AppLocale.kk:
          'Диалогты бастаңыз: AI тақырыпты түсіндіреді, келесі қадамды ұсынады және демоны баяндауға көмектеседі.',
    },
    'profile_goal': {
      AppLocale.ru: 'Цель',
      AppLocale.en: 'Goal',
      AppLocale.kk: 'Мақсат',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return <String>{'ru', 'en', 'kk'}.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(AppLocale.fromCode(locale.languageCode));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
