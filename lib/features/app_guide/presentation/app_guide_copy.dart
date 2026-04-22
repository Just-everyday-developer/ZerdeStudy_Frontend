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
            : 'Короткий маршрут по основным экранам, кнопкам, подсказкам и горячим клавишам.',
      AppLocale.en =>
        hasCompleted
            ? 'You have already completed the tour. Restart it any time from this section.'
            : 'A short walkthrough of the main screens, actions, tips, and keyboard shortcuts.',
      AppLocale.kk =>
        hasCompleted
            ? 'Сіз турды өтіп шықтыңыз. Оны осы бөлімнен кез келген уақытта қайта бастауға болады.'
            : 'Негізгі экрандар, әрекеттер, кеңестер және пернелер тіркесімі бойынша қысқа шолу.',
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
            hotkeys: <String>['Alt + 1..5', 'Ctrl + Tab', 'Left / Right'],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Main navigation',
            body:
                'This menu moves you across the core sections of the app on web, desktop, and mobile.',
            tips: <String>[
              'Home keeps the current progress and next action in view.',
              'Profile stores achievements, certificates, and learning history.',
            ],
            hotkeys: <String>['Alt + 1..5', 'Ctrl + Tab', 'Left / Right'],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Негізгі навигация',
            body:
                'Бұл мәзір вебте, десктопта және телефонда қолданбаның басты бөлімдері арасында жылдам өтуді береді.',
            tips: <String>[
              'Басты экранда прогресс пен келесі қадам көрінеді.',
              'Профильде жетістіктер, сертификаттар және оқу тарихы сақталады.',
            ],
            hotkeys: <String>['Alt + 1..5', 'Ctrl + Tab', 'Left / Right'],
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
              'На больших экранах легенда справа помогает быстро читать статусы.',
            ],
            hotkeys: <String>['Ctrl + T', 'Wheel / pinch'],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Knowledge tree',
            body:
                'This screen shows what is completed, what is in progress, and where the next learning branch starts.',
            tips: <String>[
              'Tap a node to open the related track and modules.',
              'On larger screens the legend on the right helps decode statuses faster.',
            ],
            hotkeys: <String>['Ctrl + T', 'Wheel / pinch'],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Білім ағашы',
            body:
                'Бұл экран қай тармақ аяқталғанын, не жүріп жатқанын және келесі қадам қайда екенін көрсетеді.',
            tips: <String>[
              'Трек пен модульдерді ашу үшін түйіндерді басыңыз.',
              'Үлкен экрандарда оң жақтағы легенда мәртебелерді тез оқуға көмектеседі.',
            ],
            hotkeys: <String>['Ctrl + T', 'Wheel / pinch'],
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
            hotkeys: <String>['Ctrl + K', 'Ctrl + L'],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Learn catalog',
            body:
                'Search and filters help you narrow the course catalog by topic, level, rating, and certificate.',
            tips: <String>[
              'Start with search when you know the topic, then refine with filters.',
              'The rails below show popular and recommended collections.',
            ],
            hotkeys: <String>['Ctrl + K', 'Ctrl + L'],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Learn каталогы',
            body:
                'Іздеу мен фильтрлер курстарды тақырып, деңгей, рейтинг және сертификат бойынша тарылтады.',
            tips: <String>[
              'Тақырып белгілі болса, алдымен іздеуден бастаңыз да, кейін фильтрлермен нақтылаңыз.',
              'Төмендегі жолақтарда танымал және ұсынылған жинақтар көрсетіледі.',
            ],
            hotkeys: <String>['Ctrl + K', 'Ctrl + L'],
          ),
        };
      case AppGuideStepId.communityGroups:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Сообщество',
            body:
                'В этом разделе создаются учебные группы, собираются ссылки, материалы и люди по интересам.',
            tips: <String>[
              'Создайте свою группу, если хотите собрать cohort, клуб или проектную команду.',
              'Поиск и фильтры помогают быстро находить нужные сообщества.',
            ],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Community',
            body:
                'This section is for learning groups, shared links, media, and people around the same topic.',
            tips: <String>[
              'Create a group when you want a cohort, club, or project team.',
              'Search and filters help you find the right communities faster.',
            ],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Қауымдастық',
            body:
                'Бұл бөлімде оқу топтары, сілтемелер, материалдар және ортақ қызығушылығы бар адамдар жиналады.',
            tips: <String>[
              'Cohort, клуб не жоба командасын жинағыңыз келсе, өз тобыңызды құрыңыз.',
              'Іздеу мен фильтрлер керек қауымдастықты тез табуға көмектеседі.',
            ],
          ),
        };
      case AppGuideStepId.aiMentor:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'AI-наставник',
            body:
                'Сюда удобно приносить вопросы по теме, коду и задачам, когда нужен быстрый разбор или следующий шаг.',
            tips: <String>[
              'Поле внизу отправляет ваш запрос, а блоки выше содержат быстрые вопросы и статус ключа.',
              'Личный API-ключ хранится локально на устройстве.',
            ],
            hotkeys: <String>['Enter'],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'AI mentor',
            body:
                'Bring topic, code, and task questions here when you need a quick explanation or the next step.',
            tips: <String>[
              'The composer sends prompts, while the cards above hold quick questions and key status.',
              'Your personal API key is stored locally on the device.',
            ],
            hotkeys: <String>['Enter'],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'AI-ментор',
            body:
                'Тақырып, код және тапсырма сұрақтарын жылдам түсіндіру не келесі қадам үшін осы жерге әкелуге болады.',
            tips: <String>[
              'Төмендегі өріс сұрауды жібереді, ал жоғарыдағы блоктарда дайын сұрақтар мен кілт күйі тұр.',
              'Жеке API-кілті құрылғыда жергілікті түрде сақталады.',
            ],
            hotkeys: <String>['Enter'],
          ),
        };
      case AppGuideStepId.profileOverview:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Профиль и прогресс',
            body:
                'Здесь собраны XP, достижения, сертификаты, избранное и история ваших результатов.',
            tips: <String>[
              'Эта часть помогает быстро понять, как идет обучение и что уже закрыто.',
              'Кнопки ниже ведут к статистике, лидерборду и сервисным действиям.',
            ],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Profile and progress',
            body:
                'This area keeps XP, achievements, certificates, favorites, and your result history together.',
            tips: <String>[
              'It gives a quick read on how learning is going and what is already completed.',
              'The buttons below open stats, leaderboard, and maintenance actions.',
            ],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Профиль және прогресс',
            body:
                'Мұнда XP, жетістіктер, сертификаттар, таңдаулылар және нәтиже тарихы жиналған.',
            tips: <String>[
              'Бұл бөлім оқу қалай жүріп жатқанын және не аяқталғанын тез көруге көмектеседі.',
              'Төмендегі батырмалар статистика, лидерборд және сервистік әрекеттерді ашады.',
            ],
          ),
        };
      case AppGuideStepId.settingsAccess:
        return switch (locale) {
          AppLocale.ru => const AppGuidePanelCopy(
            title: 'Настройки и повтор',
            body:
                'Если интерфейс подзабылся, откройте настройки: там собраны язык, тема, хоткеи и кнопка повторного запуска гайда.',
            tips: <String>[
              'Этот вход в настройки одинаково полезен на телефоне, десктопе и в вебе.',
              'После реального первого входа сюда легко добавить автозапуск тура для новых пользователей.',
            ],
          ),
          AppLocale.en => const AppGuidePanelCopy(
            title: 'Settings and replay',
            body:
                'If the interface gets fuzzy later, open Settings for language, theme, shortcuts, and the guide replay button.',
            tips: <String>[
              'This settings entry is useful on phone, desktop, and web.',
              'Later it will be easy to connect this flow to first-login onboarding.',
            ],
          ),
          AppLocale.kk => const AppGuidePanelCopy(
            title: 'Баптаулар және қайталау',
            body:
                'Интерфейс ұмытылса, баптауларды ашыңыз: онда тіл, тақырып, пернелер тіркесімі және гидті қайта іске қосу бар.',
            tips: <String>[
              'Бұл кіру нүктесі телефонда, десктопта және вебте бірдей ыңғайлы.',
              'Кейін осы жерге алғашқы кірудегі автоматты онбордингті қосу оңай болады.',
            ],
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
