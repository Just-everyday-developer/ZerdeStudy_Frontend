import 'package:flutter/widgets.dart';

import '../../../app/state/app_locale.dart';
import '../../../core/localization/app_localizations.dart';
import 'app_guide_controller.dart';

class AppGuidePanelCopy {
  const AppGuidePanelCopy({
    required this.title,
    required this.body,
    this.tips = const <String>[],
    this.hotkeys = const <String>[],
    this.actionLabel,
  });

  final String title;
  final String body;
  final List<String> tips;
  final List<String> hotkeys;
  final String? actionLabel;
}

abstract final class AppGuideCopy {
  static String loginEntryLabel(BuildContext context) {
    return switch (context.l10n.locale) {
      AppLocale.ru => 'Гайд по приложению',
      AppLocale.en => 'App guide',
      AppLocale.kk => 'Қосымша гиді',
    };
  }

  static String openSettingsLabel(BuildContext context) {
    return switch (context.l10n.locale) {
      AppLocale.ru => 'Открыть настройки',
      AppLocale.en => 'Open settings',
      AppLocale.kk => 'Баптауларды ашу',
    };
  }

  static String settingsSectionTitle(BuildContext context) {
    return switch (context.l10n.locale) {
      AppLocale.ru => 'Гайд по приложению',
      AppLocale.en => 'App guide',
      AppLocale.kk => 'Қосымша гиді',
    };
  }

  static String settingsSectionSubtitle(
    BuildContext context, {
    required bool hasCompleted,
  }) {
    return switch (context.l10n.locale) {
      AppLocale.ru =>
        hasCompleted
            ? 'Вы уже проходили тур. Его можно перезапустить в любой момент из этого блока.'
            : 'Короткий маршрут по основным экранам, кнопкам и подсказкам.',
      AppLocale.en =>
        hasCompleted
            ? 'You have already completed the tour. Restart it any time from this section.'
            : 'A short walkthrough of the main screens, actions, and tips.',
      AppLocale.kk =>
        hasCompleted
            ? 'Сіз турды өтіп шықтыңыз. Оны осы бөлімнен кез келген уақытта қайта бастауға болады.'
            : 'Негізгі экрандар, әрекеттер және кеңестер бойынша қысқа шолу.',
    };
  }

  static String settingsActionLabel(
    BuildContext context, {
    required bool hasCompleted,
  }) {
    return switch (context.l10n.locale) {
      AppLocale.ru => hasCompleted ? 'Повторить гайд' : 'Запустить гайд',
      AppLocale.en => hasCompleted ? 'Replay guide' : 'Start guide',
      AppLocale.kk => hasCompleted ? 'Гидті қайта іске қосу' : 'Гидті бастау',
    };
  }

  static String closeTooltip(BuildContext context) {
    return switch (context.l10n.locale) {
      AppLocale.ru => 'Закрыть гайд',
      AppLocale.en => 'Close guide',
      AppLocale.kk => 'Гидті жабу',
    };
  }

  static String stepCounter(
    BuildContext context, {
    required int current,
    required int total,
    required bool isCompletion,
  }) {
    return switch (context.l10n.locale) {
      AppLocale.ru => isCompletion ? 'Финиш' : 'Шаг $current из $total',
      AppLocale.en => isCompletion ? 'Finish' : 'Step $current of $total',
      AppLocale.kk =>
        isCompletion ? 'Аяқталды' : '$total ішінен $current-қадам',
    };
  }

  static String tipsTitle(BuildContext context) {
    return switch (context.l10n.locale) {
      AppLocale.ru => 'Что важно',
      AppLocale.en => 'What matters here',
      AppLocale.kk => 'Маңыздысы',
    };
  }

  static String hotkeysTitle(BuildContext context) {
    return switch (context.l10n.locale) {
      AppLocale.ru => 'Горячие клавиши',
      AppLocale.en => 'Shortcuts',
      AppLocale.kk => 'Пернелер тіркесімі',
    };
  }

  static String nextLabel(BuildContext context) {
    return switch (context.l10n.locale) {
      AppLocale.ru => 'Далее',
      AppLocale.en => 'Next',
      AppLocale.kk => 'Келесі',
    };
  }

  static AppGuidePanelCopy step(BuildContext context, AppGuideStepId stepId) {
    final locale = context.l10n.locale;
    switch (stepId) {
      case AppGuideStepId.shellNavigation:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Главная навигация',
            body:
                'Это меню быстро переключает вас между ключевыми разделами приложения на вебе, десктопе и телефоне.',
            tips: <String>[
              'Главная ведет к прогрессу и следующему шагу.',
              'Профиль хранит достижения, сертификаты и историю результатов.',
            ],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Main navigation',
            body:
                'This menu moves you across the core sections of the app on web, desktop, and mobile.',
            tips: <String>[
              'Home keeps the current progress and next action in view.',
              'Profile stores achievements, certificates, and learning history.',
            ],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Негізгі навигация',
            body:
                'Бұл мәзір вебте, десктопта және телефонда қолданбаның басты бөлімдері арасында жылдам өтуді береді.',
            tips: <String>[
              'Басты экранда прогресс пен келесі қадам көрінеді.',
              'Профильде жетістіктер, сертификаттар және оқу тарихы сақталады.',
            ],
          ),
        };
      case AppGuideStepId.homeProgress:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Главный экран',
            body:
                'Здесь видно текущий трек, прогресс и самая быстрая кнопка для продолжения обучения.',
            tips: <String>[
              'Кнопка Continue переносит в следующий урок или практику.',
              'Ниже собраны рекомендованные треки и лидерборд для ориентира.',
            ],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Home screen',
            body:
                'This area shows the active track, your progress, and the fastest way to continue learning.',
            tips: <String>[
              'Continue opens the next lesson or practice right away.',
              'Recommended tracks and the leaderboard below help with the next choice.',
            ],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Басты экран',
            body:
                'Мұнда ағымдағы трек, прогресс және оқуды жалғастырудың ең жылдам батырмасы көрінеді.',
            tips: <String>[
              'Continue келесі сабаққа не практикаға апарады.',
              'Төменде ұсынылған тректер мен лидерборд бар.',
            ],
          ),
        };
      case AppGuideStepId.treeOverview:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Дерево знаний',
            body:
                'Этот экран показывает, какие ветки уже пройдены, что в работе и куда логично двигаться дальше.',
            tips: <String>[
              'Нажимайте на узлы, чтобы открыть трек и перейти к модулям.',
            ],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Knowledge tree',
            body:
                'This screen shows what is completed, what is in progress, and where the next learning branch starts.',
            tips: <String>[
              'Tap a node to open the related track and modules.',
            ],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Білім ағашы',
            body:
                'Бұл экран қай тармақ аяқталғанын, не жүріп жатқанын және келесі қадам қайда екенін көрсетеді.',
            tips: <String>[
              'Трек пен модульдерді ашу үшін түйіндерді басыңыз.',
            ],
          ),
        };
      case AppGuideStepId.learnDiscovery:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Каталог Learn',
            body:
                'Поиск и фильтры помогают быстро найти нужный курс по теме, уровню, рейтингу и сертификату.',
            tips: <String>[
              'Если знаете тему, начинайте с поиска, а затем уточняйте фильтрами.',
              'Горизонтальные полки ниже показывают популярные и рекомендованные подборки.',
            ],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Learn catalog',
            body:
                'Search and filters help you narrow the course catalog by topic, level, rating, and certificate.',
            tips: <String>[
              'Start with search when you know the topic, then refine with filters.',
              'The rails below show popular and recommended collections.',
            ],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Learn каталогы',
            body:
                'Іздеу мен фильтрлер курстарды тақырып, деңгей, рейтинг және сертификат бойынша тарылтады.',
            tips: <String>[
              'Тақырып белгілі болса, алдымен іздеуден бастаңыз да, кейін фильтрлермен нақтылаңыз.',
              'Төмендегі жолақтарда танымал және ұсынылған жинақтар көрсетіледі.',
            ],
          ),
        };
      // communityGroups case removed — feature removed.
      case AppGuideStepId.aiMentor:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'AI-наставник',
            body:
                'Сюда удобно приносить вопросы по теме, коду и задачам, когда нужен быстрый разбор или следующий шаг.',
            tips: <String>[
              'Поле внизу отправляет ваш запрос, а блоки выше содержат быстрые вопросы и статус ключа.',
            ],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'AI mentor',
            body:
                'Bring topic, code, and task questions here when you need a quick explanation or the next step.',
            tips: <String>[
              'The composer sends prompts, while the cards above hold quick questions and key status.',
            ],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'AI-ментор',
            body:
                'Тақырып, код және тапсырма сұрақтарын жылдам түсіндіру не келесі қадам үшін осы жерге әкелуге болады.',
            tips: <String>[
              'Төмендегі өріс сұрауды жібереді, ал жоғарыдағы блоктарда дайын сұрақтар мен кілт күйі тұр.',
            ],
          ),
        };
      case AppGuideStepId.profileOverview:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Профиль и прогресс',
            body: 'Здесь собраны XP, достижения, сертификаты, прогресс.',
            tips: <String>[
              'Эта часть помогает быстро понять, как идет обучение и что уже закрыто.',
            ],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Profile and progress',
            body: 'Here you will find XP, achievements, certificates, and progress.',
            tips: <String>[
              'It gives a quick read on how learning is going and what is already completed.',
            ],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Профиль және прогресс',
            body: 'Мұнда XP, жетістіктер, сертификаттар және прогресс жиналған.',
            tips: <String>[
              'Бұл бөлім оқу қалай жүріп жатқанын және не аяқталғанын тез көруге көмектеседі.',
            ],
          ),
        };
      case AppGuideStepId.settingsAccess:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Настройки и повтор',
            body:
                'Если интерфейс подзабылся, откройте настройки: там собраны язык, тема и кнопка повторного запуска гайда.',
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Settings and replay',
            body:
                'If the interface gets fuzzy later, open Settings for language, theme, and the guide replay button.',
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Баптаулар және қайталау',
            body:
                'Интерфейс ұмытылса, баптауларды ашыңыз: онда тіл, тақырып және гидті қайта іске қосу бар.',
          ),
        };
      case AppGuideStepId.completion:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Вперед к знаниям',
            body:
                'Основные экраны уже знакомы. Можно продолжать обучение, а при необходимости снова запустить этот маршрут из настроек.',
            actionLabel: 'Вперед к знаниям',
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Onward to knowledge',
            body:
                'The main screens are now mapped out. Keep learning and relaunch the guide from Settings whenever you need a refresher.',
            actionLabel: 'Onward to knowledge',
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Білімге алға',
            body:
                'Негізгі экрандармен таныстыңыз. Енді оқуды жалғастырып, қажет болса гидті баптаулардан қайта іске қоса аласыз.',
            actionLabel: 'Білімге алға',
          ),
        };
    }
  }
}
