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

  String format(String key, Map<String, Object> values) {
    var template = text(key);
    for (final entry in values.entries) {
      template = template.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return template;
  }

  String courseTopicLabel(String topicKey) {
    switch (topicKey) {
      case 'programming_languages':
        return text('section_programming_languages');
      case 'data_analytics':
        return text('section_data_analytics');
      case 'ai':
        return text('section_ai');
      case 'sql_databases':
        return text('section_sql_databases');
      case 'soft_skills':
        return text('section_soft_skills');
      default:
        return topicKey;
    }
  }

  String courseLevelLabel(String level) {
    switch (level) {
      case 'All':
        return text('all_levels');
      case 'Beginner':
        return text('level_beginner');
      case 'Intermediate':
        return text('level_intermediate');
      case 'Advanced':
        return text('level_advanced');
      default:
        return level;
    }
  }

  String frequentSearchLabel(String termKey) {
    switch (termKey) {
      case 'linux':
        return 'Linux';
      case 'qa_testing':
        return text('frequent_qa_testing');
      case 'statistics':
        return text('frequent_statistics');
      case 'cybersecurity':
        return 'Cybersecurity';
      case 'postgresql':
        return 'PostgreSQL';
      default:
        return termKey;
    }
  }

  static final Map<String, Map<AppLocale, String>> _localizedValues =
      <String, Map<AppLocale, String>>{
        'app_name': {
          AppLocale.ru: 'ZerdeStudy',
          AppLocale.en: 'ZerdeStudy',
          AppLocale.kk: 'ZerdeStudy',
        },
        'tagline': {
          AppLocale.ru:
              'Изучайте IT шаг за шагом: ясно, последовательно и уверенно.',
          AppLocale.en:
              'Learn IT step by step with clarity, structure, and confidence.',
          AppLocale.kk:
              'IT-ді қадам-қадаммен анық, жүйелі және сенімді түрде үйреніңіз.',
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
          AppLocale.kk: 'Тіркелу',
        },
        'login_title': {
          AppLocale.ru: 'Вход в учебный поток',
          AppLocale.en: 'Sign in to your learning flow',
          AppLocale.kk: 'Оқу ағынына кіру',
        },
        'signup_title': {
          AppLocale.ru: 'Запустить личную траекторию',
          AppLocale.en: 'Start your personal track',
          AppLocale.kk: 'Жеке траекторияңызды бастау',
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
        'login_with': {
          AppLocale.ru: 'Войти через',
          AppLocale.en: 'Continue with',
          AppLocale.kk: 'Мына арқылы кіру',
        },
        'invalid_email': {
          AppLocale.ru: 'Введите корректный email',
          AppLocale.en: 'Enter a valid email',
          AppLocale.kk: 'Дұрыс email енгізіңіз',
        },
        'invalid_password': {
          AppLocale.ru: 'Пароль должен быть не короче 8 символов',
          AppLocale.en: 'Password must be at least 8 characters',
          AppLocale.kk: 'Құпиясөз кемінде 8 таңбадан тұруы керек',
        },
        'empty_name': {
          AppLocale.ru: 'Введите имя',
          AppLocale.en: 'Enter your name',
          AppLocale.kk: 'Атыңызды енгізіңіз',
        },
        'tab_home': {
          AppLocale.ru: 'Главная',
          AppLocale.en: 'Home',
          AppLocale.kk: 'Басты бет',
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
          AppLocale.ru: 'Профиль',
          AppLocale.en: 'Profile',
          AppLocale.kk: 'Профиль',
        },
        'daily_mission': {
          AppLocale.ru: 'Задание дня',
          AppLocale.en: 'Daily mission',
          AppLocale.kk: 'Күн тапсырмасы',
        },
        'daily_mission_pending': {
          AppLocale.ru: 'Завершите сегодня один урок, практику или memory lab.',
          AppLocale.en:
              'Complete one lesson, practice, or memory lab today.',
          AppLocale.kk:
              'Бүгін бір сабақ, практика немесе memory lab аяқтаңыз.',
        },
        'daily_mission_done': {
          AppLocale.ru: 'Сегодняшнее задание уже выполнено.',
          AppLocale.en: 'Today’s mission is already complete.',
          AppLocale.kk: 'Бүгінгі тапсырма орындалды.',
        },
        'knowledge_tree': {
          AppLocale.ru: 'Дерево знаний',
          AppLocale.en: 'Knowledge tree',
          AppLocale.kk: 'Білім ағашы',
        },
        'recommended_tracks': {
          AppLocale.ru: 'Рекомендуемые ветки',
          AppLocale.en: 'Recommended tracks',
          AppLocale.kk: 'Ұсынылатын бағыттар',
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
          AppLocale.ru: 'Очистить историю',
          AppLocale.en: 'Clear history',
          AppLocale.kk: 'Тарихты тазалау',
        },
        'reset_demo': {
          AppLocale.ru: 'Демо-состояние сброшено',
          AppLocale.en: 'Demo state was reset',
          AppLocale.kk: 'Демо күйі қалпына келтірілді',
        },
        'track_overview': {
          AppLocale.ru: 'Обзор ветки',
          AppLocale.en: 'Track overview',
          AppLocale.kk: 'Бағыт шолуы',
        },
        'modules': {
          AppLocale.ru: 'Модули',
          AppLocale.en: 'Modules',
          AppLocale.kk: 'Модульдер',
        },
        'minutes': {
          AppLocale.ru: 'мин',
          AppLocale.en: 'min',
          AppLocale.kk: 'мин',
        },
        'start_track': {
          AppLocale.ru: 'Открыть ветку',
          AppLocale.en: 'Open track',
          AppLocale.kk: 'Бағытты ашу',
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
          AppLocale.ru: 'Завершить практику',
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
          AppLocale.ru: 'Готовые запросы',
          AppLocale.en: 'Suggested prompts',
          AppLocale.kk: 'Дайын сұрақтар',
        },
        'prepared_questions': {
          AppLocale.ru: 'Готовые вопросы',
          AppLocale.en: 'Prepared questions',
          AppLocale.kk: 'Дайын сұрақтар',
        },
        'prepared_questions_hint': {
          AppLocale.ru: 'Выберите вопрос и сразу отправьте его в чат.',
          AppLocale.en: 'Pick a prepared question and send it to the chat.',
          AppLocale.kk: 'Дайын сұрақты таңдап, чатқа бірден жіберіңіз.',
        },
        'ask_now': {
          AppLocale.ru: 'Задать вопрос',
          AppLocale.en: 'Ask now',
          AppLocale.kk: 'Қазір сұрау',
        },
        'send_message': {
          AppLocale.ru: 'Отправить',
          AppLocale.en: 'Send',
          AppLocale.kk: 'Жіберу',
        },
        'message_hint': {
          AppLocale.ru:
              'Спросите про урок, практику, дерево знаний или статистику',
          AppLocale.en:
              'Ask about the lesson, practice, knowledge tree, or statistics',
          AppLocale.kk:
              'Сабақ, практика, білім ағашы немесе статистика туралы сұраңыз',
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
              'Начните диалог: AI объяснит тему, подскажет следующий шаг и поможет структурировать материал.',
          AppLocale.en:
              'Start the conversation: AI can explain the topic, suggest the next step, and structure the material.',
          AppLocale.kk:
              'Диалогты бастаңыз: AI тақырыпты түсіндіреді, келесі қадамды ұсынады және материалды құрылымдауға көмектеседі.',
        },
        'profile_goal': {
          AppLocale.ru: 'Цель',
          AppLocale.en: 'Goal',
          AppLocale.kk: 'Мақсат',
        },
        'default_goal': {
          AppLocale.ru: 'Уверенно пройти основной учебный сценарий за 14 дней',
          AppLocale.en: 'Reach a confident learning flow in 14 days',
          AppLocale.kk: '14 күнде сенімді оқу траекториясына жету',
        },
        'settings': {
          AppLocale.ru: 'Настройки',
          AppLocale.en: 'Settings',
          AppLocale.kk: 'Баптаулар',
        },
        'theme': {
          AppLocale.ru: 'Тема',
          AppLocale.en: 'Theme',
          AppLocale.kk: 'Тақырып',
        },
        'theme_dark': {
          AppLocale.ru: 'Тёмная',
          AppLocale.en: 'Dark',
          AppLocale.kk: 'Қараңғы',
        },
        'theme_light': {
          AppLocale.ru: 'Светлая',
          AppLocale.en: 'Light',
          AppLocale.kk: 'Жарық',
        },
        'level': {
          AppLocale.ru: 'Уровень',
          AppLocale.en: 'Level',
          AppLocale.kk: 'Деңгей',
        },
        'streak': {
          AppLocale.ru: 'Серия',
          AppLocale.en: 'Streak',
          AppLocale.kk: 'Серия',
        },
        'favorites': {
          AppLocale.ru: 'Избранное',
          AppLocale.en: 'Favorites',
          AppLocale.kk: 'Таңдаулылар',
        },
        'favorites_empty': {
          AppLocale.ru:
              'Сохраняйте курсы из каталога, чтобы быстро возвращаться к ним отсюда.',
          AppLocale.en:
              'Save courses from the catalog to keep them here for quick access.',
          AppLocale.kk:
              'Каталогтағы курстарды сақтап, осында жылдам қайта оралыңыз.',
        },
        'completed': {
          AppLocale.ru: 'Завершено',
          AppLocale.en: 'Completed',
          AppLocale.kk: 'Аяқталғандар',
        },
        'completed_empty': {
          AppLocale.ru:
              'Завершённые ветки, модули, уроки и практики появятся здесь.',
          AppLocale.en:
              'Completed tracks, modules, lessons, and practices will appear here.',
          AppLocale.kk:
              'Аяқталған бағыттар, модульдер, сабақтар және практикалар осында көрінеді.',
        },
        'result_history': {
          AppLocale.ru: 'История результатов',
          AppLocale.en: 'Result history',
          AppLocale.kk: 'Нәтижелер тарихы',
        },
        'result_history_empty': {
          AppLocale.ru:
              'Попытки тестов и ключевые события обучения появятся здесь.',
          AppLocale.en:
              'Assessment attempts and key learning events will appear here.',
          AppLocale.kk:
              'Тест нәтижелері мен негізгі оқу оқиғалары осында көрінеді.',
        },
        'saved': {
          AppLocale.ru: 'Сохранено',
          AppLocale.en: 'Saved',
          AppLocale.kk: 'Сақталған',
        },
        'save_course': {
          AppLocale.ru: 'Сохранить курс',
          AppLocale.en: 'Save course',
          AppLocale.kk: 'Курсты сақтау',
        },
        'saved_to_profile': {
          AppLocale.ru: 'Сохранено в профиле',
          AppLocale.en: 'Saved to profile',
          AppLocale.kk: 'Профильге сақталды',
        },
        'tracks': {
          AppLocale.ru: 'Ветки',
          AppLocale.en: 'Tracks',
          AppLocale.kk: 'Бағыттар',
        },
        'lessons': {
          AppLocale.ru: 'Уроки',
          AppLocale.en: 'Lessons',
          AppLocale.kk: 'Сабақтар',
        },
        'practices': {
          AppLocale.ru: 'Практики',
          AppLocale.en: 'Practices',
          AppLocale.kk: 'Практикалар',
        },
        'followers': {
          AppLocale.ru: 'Подписчики',
          AppLocale.en: 'Followers',
          AppLocale.kk: 'Жазылушылар',
        },
        'courses_label': {
          AppLocale.ru: 'Курсы',
          AppLocale.en: 'Courses',
          AppLocale.kk: 'Курстар',
        },
        'rating': {
          AppLocale.ru: 'рейтинг',
          AppLocale.en: 'rating',
          AppLocale.kk: 'рейтинг',
        },
        'enrolled': {
          AppLocale.ru: 'обучаются',
          AppLocale.en: 'enrolled',
          AppLocale.kk: 'оқуда',
        },
        'preview_minutes': {
          AppLocale.ru: '{minutes} мин превью',
          AppLocale.en: '{minutes} min preview',
          AppLocale.kk: '{minutes} мин preview',
        },
        'show_all': {
          AppLocale.ru: 'Открыть',
          AppLocale.en: 'Open',
          AppLocale.kk: 'Ашу',
        },
        'unlocked': {
          AppLocale.ru: 'Открытые',
          AppLocale.en: 'Unlocked',
          AppLocale.kk: 'Ашылған',
        },
        'locked': {
          AppLocale.ru: 'Закрытые',
          AppLocale.en: 'Locked',
          AppLocale.kk: 'Жабық',
        },
        'no_items_yet': {
          AppLocale.ru: 'Пока здесь пусто.',
          AppLocale.en: 'No items here yet.',
          AppLocale.kk: 'Әзірге мұнда бос.',
        },
        'search_courses': {
          AppLocale.ru: 'Искать курсы',
          AppLocale.en: 'Search courses',
          AppLocale.kk: 'Курстарды іздеу',
        },
        'filters': {
          AppLocale.ru: 'Фильтры',
          AppLocale.en: 'Filters',
          AppLocale.kk: 'Сүзгілер',
        },
        'filter_topic': {
          AppLocale.ru: 'Тема',
          AppLocale.en: 'Topic',
          AppLocale.kk: 'Тақырып',
        },
        'filter_level': {
          AppLocale.ru: 'Уровень',
          AppLocale.en: 'Level',
          AppLocale.kk: 'Деңгей',
        },
        'clear_filters': {
          AppLocale.ru: 'Сбросить фильтры',
          AppLocale.en: 'Clear filters',
          AppLocale.kk: 'Сүзгілерді тазалау',
        },
        'all_topics': {
          AppLocale.ru: 'Все темы',
          AppLocale.en: 'All topics',
          AppLocale.kk: 'Барлық тақырыптар',
        },
        'all_levels': {
          AppLocale.ru: 'Все уровни',
          AppLocale.en: 'All levels',
          AppLocale.kk: 'Барлық деңгейлер',
        },
        'level_beginner': {
          AppLocale.ru: 'Начальный',
          AppLocale.en: 'Beginner',
          AppLocale.kk: 'Бастапқы',
        },
        'level_intermediate': {
          AppLocale.ru: 'Средний',
          AppLocale.en: 'Intermediate',
          AppLocale.kk: 'Орташа',
        },
        'level_advanced': {
          AppLocale.ru: 'Продвинутый',
          AppLocale.en: 'Advanced',
          AppLocale.kk: 'Жетілдірілген',
        },
        'section_programming_languages': {
          AppLocale.ru: 'Изучение языков программирования',
          AppLocale.en: 'Programming languages',
          AppLocale.kk: 'Бағдарламалау тілдерін оқу',
        },
        'section_data_analytics': {
          AppLocale.ru: 'Data Analytics',
          AppLocale.en: 'Data analytics',
          AppLocale.kk: 'Data analytics',
        },
        'section_ai': {
          AppLocale.ru: 'AI',
          AppLocale.en: 'AI',
          AppLocale.kk: 'AI',
        },
        'section_sql_databases': {
          AppLocale.ru: 'SQL и базы данных',
          AppLocale.en: 'SQL and databases',
          AppLocale.kk: 'SQL және деректер базалары',
        },
        'section_soft_skills': {
          AppLocale.ru: 'Soft Skills',
          AppLocale.en: 'Soft skills',
          AppLocale.kk: 'Soft skills',
        },
        'section_popular_courses': {
          AppLocale.ru: 'Популярные курсы',
          AppLocale.en: 'Popular courses',
          AppLocale.kk: 'Танымал курстар',
        },
        'section_recommended_courses': {
          AppLocale.ru: 'Рекомендуемые курсы',
          AppLocale.en: 'Recommended courses',
          AppLocale.kk: 'Ұсынылатын курстар',
        },
        'section_popular_authors': {
          AppLocale.ru: 'Популярные авторы курсов',
          AppLocale.en: 'Popular course authors',
          AppLocale.kk: 'Танымал курс авторлары',
        },
        'section_frequent_searches': {
          AppLocale.ru: 'Часто ищут',
          AppLocale.en: 'Frequent searches',
          AppLocale.kk: 'Жиі іздейді',
        },
        'view_all_courses': {
          AppLocale.ru: 'Посмотреть все ->',
          AppLocale.en: 'View all ->',
          AppLocale.kk: 'Барлығын көру ->',
        },
        'catalog_title': {
          AppLocale.ru: 'Каталог',
          AppLocale.en: 'Catalog',
          AppLocale.kk: 'Каталог',
        },
        'catalog_subtitle': {
          AppLocale.ru: 'Курсы по темам, авторам и уровням сложности',
          AppLocale.en: 'Browse courses by topic, author, and level',
          AppLocale.kk: 'Курстарды тақырып, автор және деңгей бойынша шолыңыз',
        },
        'catalog_results': {
          AppLocale.ru: 'Найдено: {count}',
          AppLocale.en: 'Results: {count}',
          AppLocale.kk: 'Нәтижелер: {count}',
        },
        'catalog_empty_title': {
          AppLocale.ru: 'Подходящие курсы не найдены',
          AppLocale.en: 'No matching courses found',
          AppLocale.kk: 'Сәйкес курстар табылмады',
        },
        'catalog_empty_subtitle': {
          AppLocale.ru: 'Попробуйте изменить поисковый запрос или фильтры.',
          AppLocale.en:
              'Try adjusting your search query or the selected filters.',
          AppLocale.kk:
              'Іздеу сұрауын немесе таңдалған сүзгілерді өзгертіп көріңіз.',
        },
        'tree_summary': {
          AppLocale.ru:
              'Единое дерево знаний связывает фундаментальные темы computer science и прикладные инженерные направления.',
          AppLocale.en:
              'A single knowledge tree connects computer science foundations with applied engineering paths.',
          AppLocale.kk:
              'Біртұтас білім ағашы computer science негіздерін қолданбалы инженерлік бағыттармен байланыстырады.',
        },
        'tree_visible_branches': {
          AppLocale.ru: 'Видимые ветви',
          AppLocale.en: 'Visible branches',
          AppLocale.kk: 'Көрінетін тармақтар',
        },
        'tree_completed': {
          AppLocale.ru: 'Завершено',
          AppLocale.en: 'Completed',
          AppLocale.kk: 'Аяқталған',
        },
        'tree_assessments': {
          AppLocale.ru: 'Оценивания',
          AppLocale.en: 'Assessments',
          AppLocale.kk: 'Бағалаулар',
        },
        'tree_available': {
          AppLocale.ru: 'Доступно',
          AppLocale.en: 'Available',
          AppLocale.kk: 'Қолжетімді',
        },
        'tree_in_progress': {
          AppLocale.ru: 'В процессе',
          AppLocale.en: 'In progress',
          AppLocale.kk: 'Орындалып жатыр',
        },
        'tree_mastered': {
          AppLocale.ru: 'Освоено',
          AppLocale.en: 'Mastered',
          AppLocale.kk: 'Толық меңгерілген',
        },
        'tree_units': {
          AppLocale.ru: 'юнитов',
          AppLocale.en: 'units',
          AppLocale.kk: 'юнит',
        },
        'mentor_label': {
          AppLocale.ru: 'Ментор',
          AppLocale.en: 'Mentor',
          AppLocale.kk: 'Ментор',
        },
        'you_label': {
          AppLocale.ru: 'Вы',
          AppLocale.en: 'You',
          AppLocale.kk: 'Сіз',
        },
        'frequent_qa_testing': {
          AppLocale.ru: 'QA и тестирование ПО',
          AppLocale.en: 'QA and software testing',
          AppLocale.kk: 'QA және БҚ тестілеу',
        },
        'frequent_statistics': {
          AppLocale.ru: 'Статистика',
          AppLocale.en: 'Statistics',
          AppLocale.kk: 'Статистика',
        },
        'history_lesson_completed': {
          AppLocale.ru: 'Урок завершён',
          AppLocale.en: 'Lesson completed',
          AppLocale.kk: 'Сабақ аяқталды',
        },
        'history_practice_completed': {
          AppLocale.ru: 'Практика завершена',
          AppLocale.en: 'Practice completed',
          AppLocale.kk: 'Практика аяқталды',
        },
        'history_module_completed': {
          AppLocale.ru: 'Модуль завершён',
          AppLocale.en: 'Module completed',
          AppLocale.kk: 'Модуль аяқталды',
        },
        'history_track_completed': {
          AppLocale.ru: 'Ветка завершена',
          AppLocale.en: 'Track completed',
          AppLocale.kk: 'Бағыт аяқталды',
        },
        'history_assessment_completed': {
          AppLocale.ru: 'Тест по ветке завершён',
          AppLocale.en: 'Track assessment completed',
          AppLocale.kk: 'Бағыттық тест аяқталды',
        },
        'history_course_saved': {
          AppLocale.ru: 'Курс сохранён',
          AppLocale.en: 'Course saved',
          AppLocale.kk: 'Курс сақталды',
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
