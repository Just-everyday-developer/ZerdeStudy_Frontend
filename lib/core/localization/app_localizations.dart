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

  static final Map<String, Map<AppLocale, String>> _localizedValues =
      <String, Map<AppLocale, String>>{
    'app_name': {
      AppLocale.ru: 'ZerdeStudy',
      AppLocale.en: 'ZerdeStudy',
      AppLocale.kk: 'ZerdeStudy',
    },
    'tagline': {
      AppLocale.ru: 'Персональная траектория в IT с деревом знаний и AI-наставником',
      AppLocale.en: 'A personal path into IT with a knowledge tree and AI mentor',
      AppLocale.kk: 'Білім ағашы мен AI-менторы бар IT-ке жеке траектория',
    },
    'presentation_ready': {
      AppLocale.ru: 'MVP для презентации готов к кликабельному демо',
      AppLocale.en: 'Presentation-ready MVP with clickable demo flow',
      AppLocale.kk: 'Презентацияға дайын, шертуге болатын MVP',
    },
    'continue_learning': {
      AppLocale.ru: 'Продолжить обучение',
      AppLocale.en: 'Continue learning',
      AppLocale.kk: 'Оқуды жалғастыру',
    },
    'start_demo': {
      AppLocale.ru: 'Войти в демо',
      AppLocale.en: 'Enter demo',
      AppLocale.kk: 'Демоға кіру',
    },
    'login': {
      AppLocale.ru: 'Войти',
      AppLocale.en: 'Log in',
      AppLocale.kk: 'Кіру',
    },
    'signup': {
      AppLocale.ru: 'Создать аккаунт',
      AppLocale.en: 'Create account',
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
      AppLocale.kk: 'Жеке траекторияны іске қосу',
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
    'tab_ai': {
      AppLocale.ru: 'AI',
      AppLocale.en: 'AI',
      AppLocale.kk: 'AI',
    },
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
      AppLocale.ru: 'Закройте один урок или практику сегодня',
      AppLocale.en: 'Complete one lesson or practice today',
      AppLocale.kk: 'Бүгін бір сабақ не практиканы аяқтаңыз',
    },
    'daily_mission_done': {
      AppLocale.ru: 'Миссия на сегодня закрыта',
      AppLocale.en: 'Today\'s mission is complete',
      AppLocale.kk: 'Бүгінгі миссия орындалды',
    },
    'knowledge_tree': {
      AppLocale.ru: 'Дерево знаний',
      AppLocale.en: 'Knowledge Tree',
      AppLocale.kk: 'Білім ағашы',
    },
    'recommended_tracks': {
      AppLocale.ru: 'Рекомендованные ветки',
      AppLocale.en: 'Recommended tracks',
      AppLocale.kk: 'Ұсынылған тармақтар',
    },
    'active_roadmap': {
      AppLocale.ru: 'Активная траектория',
      AppLocale.en: 'Active roadmap',
      AppLocale.kk: 'Белсенді траектория',
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
    'xp_breakdown': {
      AppLocale.ru: 'XP breakdown',
      AppLocale.en: 'XP breakdown',
      AppLocale.kk: 'XP breakdown',
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
    'reset_demo': {
      AppLocale.ru: 'Сбросить демо',
      AppLocale.en: 'Reset demo',
      AppLocale.kk: 'Демоны қалпына келтіру',
    },
    'track_overview': {
      AppLocale.ru: 'Обзор ветки',
      AppLocale.en: 'Track overview',
      AppLocale.kk: 'Тармаққа шолу',
    },
    'modules': {
      AppLocale.ru: 'Модули',
      AppLocale.en: 'Modules',
      AppLocale.kk: 'Модульдер',
    },
    'lesson': {
      AppLocale.ru: 'Урок',
      AppLocale.en: 'Lesson',
      AppLocale.kk: 'Сабақ',
    },
    'practice': {
      AppLocale.ru: 'Практика',
      AppLocale.en: 'Practice',
      AppLocale.kk: 'Практика',
    },
    'duration': {
      AppLocale.ru: 'Длительность',
      AppLocale.en: 'Duration',
      AppLocale.kk: 'Ұзақтығы',
    },
    'minutes': {
      AppLocale.ru: 'мин',
      AppLocale.en: 'min',
      AppLocale.kk: 'мин',
    },
    'start_track': {
      AppLocale.ru: 'Открыть ветку',
      AppLocale.en: 'Open track',
      AppLocale.kk: 'Тармақты ашу',
    },
    'unlock_later': {
      AppLocale.ru: 'Откроется после Frontend',
      AppLocale.en: 'Unlocks after Frontend',
      AppLocale.kk: 'Frontend-тен кейін ашылады',
    },
    'status_locked': {
      AppLocale.ru: 'Locked',
      AppLocale.en: 'Locked',
      AppLocale.kk: 'Locked',
    },
    'status_in_progress': {
      AppLocale.ru: 'In progress',
      AppLocale.en: 'In progress',
      AppLocale.kk: 'In progress',
    },
    'status_completed': {
      AppLocale.ru: 'Completed',
      AppLocale.en: 'Completed',
      AppLocale.kk: 'Completed',
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
      AppLocale.ru: 'Напишите вопрос по уроку или практике',
      AppLocale.en: 'Ask about the lesson or practice',
      AppLocale.kk: 'Сабақ не практика туралы сұрақ жазыңыз',
    },
    'tree_intro': {
      AppLocale.ru: 'Все IT-направления видны сразу, но глубоко проработаны две ветки для демо.',
      AppLocale.en: 'All IT directions are visible, while two branches are fully playable for the demo.',
      AppLocale.kk: 'Барлық IT бағыттары көрінеді, бірақ демо үшін екі тармақ тереңірек жасалған.',
    },
    'leaderboard_hint': {
      AppLocale.ru: 'Локальный рейтинг для демонстрации вовлечённости',
      AppLocale.en: 'Local leaderboard to showcase engagement',
      AppLocale.kk: 'Қызығушылықты көрсетуге арналған жергілікті рейтинг',
    },
    'profile_goal': {
      AppLocale.ru: 'Цель',
      AppLocale.en: 'Goal',
      AppLocale.kk: 'Мақсат',
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
    'lessons_done': {
      AppLocale.ru: 'Закрыто шагов',
      AppLocale.en: 'Completed steps',
      AppLocale.kk: 'Аяқталған қадамдар',
    },
    'xp_to_next': {
      AppLocale.ru: 'до следующего уровня',
      AppLocale.en: 'to next level',
      AppLocale.kk: 'келесі деңгейге дейін',
    },
    'empty_chat': {
      AppLocale.ru: 'Начните диалог: AI объяснит тему, предложит план и поможет оформить демо-нарратив.',
      AppLocale.en: 'Start the conversation: AI can explain, plan, and help narrate the demo.',
      AppLocale.kk: 'Диалогты бастаңыз: AI түсіндіреді, жоспар құрады және демо-нарративке көмектеседі.',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
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
