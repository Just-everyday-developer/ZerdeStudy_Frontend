import 'package:flutter/material.dart';

import 'demo_app_state.dart';
import 'demo_models.dart';

class DemoCatalog {
  DemoCatalog() : tracks = _buildTracks();

  final List<LearningTrack> tracks;

  static const List<Achievement> _achievementBlueprints = <Achievement>[
    Achievement(
      id: 'first_step',
      title: LocalizedText(
        ru: 'Первый шаг',
        en: 'First Step',
        kk: 'Алғашқы қадам',
      ),
      description: LocalizedText(
        ru: 'Завершите первый урок.',
        en: 'Complete your first lesson.',
        kk: 'Алғашқы сабақты аяқтаңыз.',
      ),
      icon: Icons.bolt_rounded,
      goal: 1,
      progress: 0,
      unlocked: false,
    ),
    Achievement(
      id: 'focus_mode',
      title: LocalizedText(
        ru: 'Фокус-режим',
        en: 'Focus Mode',
        kk: 'Фокус режимі',
      ),
      description: LocalizedText(
        ru: 'Доведите streak до 5 дней.',
        en: 'Reach a 5-day streak.',
        kk: '5 күндік streak жинаңыз.',
      ),
      icon: Icons.local_fire_department_rounded,
      goal: 5,
      progress: 0,
      unlocked: false,
    ),
    Achievement(
      id: 'frontend_ready',
      title: LocalizedText(
        ru: 'Frontend Ready',
        en: 'Frontend Ready',
        kk: 'Frontend Ready',
      ),
      description: LocalizedText(
        ru: 'Закройте ветку Frontend.',
        en: 'Finish the Frontend track.',
        kk: 'Frontend тармағын жабыңыз.',
      ),
      icon: Icons.web_asset_rounded,
      goal: 1,
      progress: 0,
      unlocked: false,
    ),
    Achievement(
      id: 'xp_360',
      title: LocalizedText(
        ru: 'Ритм роста',
        en: 'Growth Rhythm',
        kk: 'Өсу ырғағы',
      ),
      description: LocalizedText(
        ru: 'Наберите 360 XP.',
        en: 'Reach 360 XP.',
        kk: '360 XP жинаңыз.',
      ),
      icon: Icons.stars_rounded,
      goal: 360,
      progress: 0,
      unlocked: false,
    ),
  ];

  LearningTrack trackById(String trackId) {
    return tracks.firstWhere((track) => track.id == trackId);
  }

  LessonItem lessonById(String lessonId) {
    for (final track in tracks) {
      for (final module in track.modules) {
        for (final lesson in module.lessons) {
          if (lesson.id == lessonId) {
            return lesson;
          }
        }
      }
    }
    throw StateError('Unknown lesson id: $lessonId');
  }

  PracticeTask practiceById(String practiceId) {
    for (final track in tracks) {
      for (final module in track.modules) {
        if (module.practice?.id == practiceId) {
          return module.practice!;
        }
      }
    }
    throw StateError('Unknown practice id: $practiceId');
  }

  TrackProgress progressForTrack(DemoAppState state, String trackId) {
    final track = trackById(trackId);
    final completedUnits = _completedUnitsForTrack(state, track);

    return TrackProgress(
      state: visualStateFor(state, track),
      completedUnits: completedUnits,
      totalUnits: track.totalUnits,
      nextTarget: nextTargetForTrack(state, trackId),
    );
  }

  TrackVisualState visualStateFor(DemoAppState state, LearningTrack track) {
    if (!track.isPlayable) {
      return TrackVisualState.locked;
    }
    if (_completedUnitsForTrack(state, track) >= track.totalUnits) {
      return TrackVisualState.completed;
    }
    return TrackVisualState.inProgress;
  }

  LearningTarget? nextTargetForTrack(DemoAppState state, String trackId) {
    final track = trackById(trackId);
    if (!track.isPlayable) {
      return null;
    }

    for (final module in track.modules) {
      for (final lesson in module.lessons) {
        if (!state.completedLessonIds.contains(lesson.id)) {
          return LearningTarget.lesson(lesson);
        }
      }

      final practice = module.practice;
      if (practice != null &&
          !state.completedPracticeIds.contains(practice.id)) {
        return LearningTarget.practice(practice);
      }
    }
    return null;
  }

  List<Achievement> achievementsFor(DemoAppState state) {
    final completedLessons = state.completedLessonIds.length;
    final frontendComplete =
        progressForTrack(state, 'frontend').state == TrackVisualState.completed;

    return _achievementBlueprints.map((blueprint) {
      switch (blueprint.id) {
        case 'first_step':
          return blueprint.copyWith(
            progress: completedLessons,
            unlocked: completedLessons >= blueprint.goal,
          );
        case 'focus_mode':
          return blueprint.copyWith(
            progress: state.streak,
            unlocked: state.streak >= blueprint.goal,
          );
        case 'frontend_ready':
          return blueprint.copyWith(
            progress: frontendComplete ? 1 : 0,
            unlocked: frontendComplete,
          );
        case 'xp_360':
          return blueprint.copyWith(
            progress: state.xp,
            unlocked: state.xp >= blueprint.goal,
          );
        default:
          return blueprint;
      }
    }).toList(growable: false);
  }

  Set<String> unlockedAchievementIdsFor(DemoAppState state) {
    return achievementsFor(state)
        .where((achievement) => achievement.unlocked)
        .map((achievement) => achievement.id)
        .toSet();
  }

  List<LeaderboardEntry> leaderboardFor(DemoAppState state) {
    final entries = <LeaderboardEntry>[
      const LeaderboardEntry(
        id: 'alex',
        name: 'Alex R.',
        xp: 540,
        level: 4,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        id: 'nurai',
        name: 'Nurai T.',
        xp: 480,
        level: 3,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        id: 'amira',
        name: 'Amira K.',
        xp: 430,
        level: 3,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        id: 'current-user',
        name: state.user?.name ?? 'Demo User',
        xp: state.xp,
        level: state.level,
        isCurrentUser: true,
      ),
      const LeaderboardEntry(
        id: 'timur',
        name: 'Timur S.',
        xp: 320,
        level: 2,
        isCurrentUser: false,
      ),
    ];

    entries.sort((left, right) => right.xp.compareTo(left.xp));
    return entries;
  }

  String mentorReply(DemoAppState state, String prompt) {
    final normalized = prompt.toLowerCase();
    final locale = state.locale;
    final lessonTitle = state.focusedLessonId == null
        ? null
        : lessonById(state.focusedLessonId!).title.resolve(locale);

    if (normalized.contains('error') || normalized.contains('ошиб')) {
      return LocalizedText(
        ru: 'Сначала проверь входные данные и ожидаемый результат. Затем сузим проблему: что именно не совпало в ${lessonTitle ?? 'текущем задании'}?',
        en: 'Start by comparing input and expected output. Then narrow the issue down: what exactly mismatched in ${lessonTitle ?? 'the current task'}?',
        kk: 'Алдымен кіріс пен күтілетін нәтижені салыстырыңыз. Содан кейін мәселені тарылтайық: ${lessonTitle ?? 'ағымдағы тапсырмада'} нақты не сәйкес келмеді?',
      ).resolve(locale);
    }

    if (normalized.contains('plan') ||
        normalized.contains('траект') ||
        normalized.contains('roadmap')) {
      return LocalizedText(
        ru: 'Для презентационного темпа держим маршрут таким: Fundamentals -> Frontend -> teaser по остальным веткам. Это показывает и глубину, и ширину MVP.',
        en: 'For a presentation-friendly pace, keep the route as Fundamentals -> Frontend -> teaser overviews for the rest. That shows both depth and breadth.',
        kk: 'Презентацияға ыңғайлы маршрут: Fundamentals -> Frontend -> қалған тармақтарға teaser overview. Осылай MVP-дің тереңдігі де, кеңдігі де көрінеді.',
      ).resolve(locale);
    }

    if (state.currentTrackId == 'frontend') {
      return LocalizedText(
        ru: 'Во Frontend сейчас важно не только собрать UI, но и связать состояние с действиями пользователя. Покажи progress, CTA и итоговую пользу экрана.',
        en: 'In Frontend, focus not only on the UI but on wiring state to user actions. Show progress, CTAs, and the screen outcome.',
        kk: 'Frontend-та тек UI емес, қолданушы әрекеттеріне байланған күй де маңызды. Progress, CTA және экран нәтижесін көрсетіңіз.',
      ).resolve(locale);
    }

    return LocalizedText(
      ru: 'Разбей тему на маленькие шаги: цель, теория, пример, практика, рефлексия. Именно такой ритм лучше всего смотрится в демо-обучении.',
      en: 'Break the topic into small steps: goal, theory, example, practice, reflection. That rhythm works best in a demo learning flow.',
      kk: 'Тақырыпты шағын қадамдарға бөліңіз: мақсат, теория, мысал, практика, рефлексия. Демо-оқытуда осы ырғақ ең жақсы көрінеді.',
    ).resolve(locale);
  }

  List<String> suggestedPrompts(DemoAppState state) {
    return <LocalizedText>[
      const LocalizedText(
        ru: 'Объясни тему простыми словами',
        en: 'Explain this topic in simple words',
        kk: 'Тақырыпты қарапайым тілмен түсіндір',
      ),
      const LocalizedText(
        ru: 'С чего начать практику?',
        en: 'How should I start the practice?',
        kk: 'Практиканы неден бастаймын?',
      ),
      const LocalizedText(
        ru: 'Построй мне план на 20 минут',
        en: 'Build me a 20-minute study plan',
        kk: 'Маған 20 минуттық жоспар құрып бер',
      ),
    ].map((prompt) => prompt.resolve(state.locale)).toList(growable: false);
  }

  int totalCompletedUnits(DemoAppState state) {
    return state.completedLessonIds.length + state.completedPracticeIds.length;
  }

  int totalPlayableUnits() {
    return tracks
        .where((track) => track.isPlayable)
        .fold<int>(0, (sum, track) => sum + track.totalUnits);
  }

  int _completedUnitsForTrack(DemoAppState state, LearningTrack track) {
    var total = 0;
    for (final module in track.modules) {
      for (final lesson in module.lessons) {
        if (state.completedLessonIds.contains(lesson.id)) {
          total += 1;
        }
      }

      final practice = module.practice;
      if (practice != null && state.completedPracticeIds.contains(practice.id)) {
        total += 1;
      }
    }
    return total;
  }
}

LocalizedText t(String ru, String en, String kk) {
  return LocalizedText(ru: ru, en: en, kk: kk);
}

List<LearningTrack> _buildTracks() {
  return <LearningTrack>[
    _fundamentalsTrack(),
    _frontendTrack(),
    _lockedTrack(
      id: 'backend',
      icon: Icons.storage_rounded,
      color: const Color(0xFF70D49A),
      title: t('Backend', 'Backend', 'Backend'),
      subtitle: t('API, базы данных и архитектура', 'APIs, databases, and architecture', 'API, дерекқор және архитектура'),
      description: t(
        'Следующая большая ветка после интерфейсов: как данные живут на сервере.',
        'The next big branch after interfaces: how data lives on the server.',
        'Интерфейстен кейінгі келесі үлкен тармақ: деректердің серверде өмір сүруі.',
      ),
      teaser: t('Preview: REST, CRUD, auth flow и сервисы.', 'Preview: REST, CRUD, auth flow, and services.', 'Preview: REST, CRUD, auth flow және сервистер.'),
      outcome: t('Откроется после завершения основного frontend-ритма.', 'Unlocks after the core frontend rhythm is complete.', 'Негізгі frontend ырғағы аяқталғаннан кейін ашылады.'),
    ),
    _lockedTrack(
      id: 'mobile',
      icon: Icons.phone_android_rounded,
      color: const Color(0xFF8F93FF),
      title: t('Mobile Development', 'Mobile Development', 'Mobile Development'),
      subtitle: t('Нативные паттерны и UX на ходу', 'Native patterns and mobile UX', 'Натив паттерндер мен mobile UX'),
      description: t('Touch-first сценарии и мобильная навигация.', 'Touch-first flows and mobile navigation.', 'Touch-first сценарий және mobile навигация.'),
      teaser: t('Preview: gestures, adaptive layouts, offline thinking.', 'Preview: gestures, adaptive layouts, offline thinking.', 'Preview: gestures, adaptive layouts, offline thinking.'),
      outcome: t('Ветка для расширения продукта за пределы web-демо.', 'A branch for expanding the product beyond the web demo.', 'Өнімді web-демодан ары кеңейтуге арналған тармақ.'),
    ),
    _lockedTrack(
      id: 'devops',
      icon: Icons.settings_suggest_rounded,
      color: const Color(0xFF4BE0C6),
      title: t('DevOps / SRE', 'DevOps / SRE', 'DevOps / SRE'),
      subtitle: t('Доставка, наблюдаемость и надёжность', 'Delivery, observability, reliability', 'Жеткізу, бақылау және сенімділік'),
      description: t('Релизы, пайплайны и стабильность продукта.', 'Releases, pipelines, and product stability.', 'Релиздер, pipeline және өнім тұрақтылығы.'),
      teaser: t('Preview: CI/CD, metrics, logs, rollback mindset.', 'Preview: CI/CD, metrics, logs, rollback mindset.', 'Preview: CI/CD, metrics, logs, rollback mindset.'),
      outcome: t('Покажет, как проект выходит в production.', 'Shows how a project reaches production.', 'Жобаның production-ға қалай шығатынын көрсетеді.'),
    ),
    _lockedTrack(
      id: 'cyber_security',
      icon: Icons.shield_rounded,
      color: const Color(0xFFFF6A7A),
      title: t('Cyber Security', 'Cyber Security', 'Cyber Security'),
      subtitle: t('Безопасность как часть инженерного мышления', 'Security as part of engineering', 'Қауіпсіздік инженерлік ойлаудың бөлігі ретінде'),
      description: t('Secure-by-default подход и работа с рисками.', 'Secure-by-default thinking and risk handling.', 'Secure-by-default тәсілі және тәуекелмен жұмыс.'),
      teaser: t('Preview: auth, secrets, threat mindset, secure reviews.', 'Preview: auth, secrets, threat mindset, secure reviews.', 'Preview: auth, secrets, threat mindset, secure reviews.'),
      outcome: t('Подскажет, как расти не только быстро, но и безопасно.', 'Shows how to grow not only fast but safely.', 'Тек тез емес, қауіпсіз өсуді де көрсетеді.'),
    ),
    _lockedTrack(
      id: 'machine_learning',
      icon: Icons.psychology_alt_rounded,
      color: const Color(0xFFFFD166),
      title: t('Machine Learning', 'Machine Learning', 'Machine Learning'),
      subtitle: t('Данные, модели и практический AI', 'Data, models, and practical AI', 'Дерек, модель және практикалық AI'),
      description: t('Путь от использования ИИ к пониманию его устройства.', 'A path from using AI to understanding it.', 'AI-ды қолданудан оны түсінуге апаратын жол.'),
      teaser: t('Preview: features, evaluation, prompt systems.', 'Preview: features, evaluation, prompt systems.', 'Preview: features, evaluation, prompt systems.'),
      outcome: t('Покажет путь к более продвинутой AI-специализации.', 'Shows the path toward deeper AI specialization.', 'Тереңірек AI мамандануына жол көрсетеді.'),
    ),
  ];
}

LearningTrack _lockedTrack({
  required String id,
  required IconData icon,
  required Color color,
  required LocalizedText title,
  required LocalizedText subtitle,
  required LocalizedText description,
  required LocalizedText teaser,
  required LocalizedText outcome,
}) {
  return LearningTrack(
    id: id,
    title: title,
    subtitle: subtitle,
    description: description,
    teaser: teaser,
    outcome: outcome,
    heroMetric: t('Preview branch', 'Preview branch', 'Preview branch'),
    icon: icon,
    color: color,
    isPlayable: false,
    modules: <LearningModule>[
      LearningModule(
        id: '${id}_preview',
        trackId: id,
        title: t('Preview module', 'Preview module', 'Preview module'),
        summary: teaser,
        lessons: const <LessonItem>[],
        practice: null,
      ),
    ],
  );
}

LearningTrack _fundamentalsTrack() {
  return LearningTrack(
    id: 'fundamentals',
    title: t('Fundamentals', 'Fundamentals', 'Fundamentals'),
    subtitle: t(
      'База мышления разработчика',
      'Developer thinking foundation',
      'Әзірлеуші ойлауының негізі',
    ),
    description: t(
      'Стартовая ветка для логики, структуры кода, отладки и ритма обучения.',
      'Starter branch for logic, code structure, debugging, and learning rhythm.',
      'Логика, код құрылымы, debug және оқу ырғағына арналған бастапқы тармақ.',
    ),
    teaser: t(
      'Закрываем основу, чтобы дальше двигаться по любому IT-направлению без хаоса.',
      'Close the basics first so every next IT path feels structured, not chaotic.',
      'Алдымен негізді жабамыз, сонда келесі IT бағыты реттелген көрінеді.',
    ),
    outcome: t(
      'После ветки студент уверенно читает простые программы и умеет разложить задачу на шаги.',
      'After this branch, the learner can read simple programs and break tasks into steps.',
      'Осы тармақтан кейін студент қарапайым бағдарламаларды оқып, тапсырманы қадамдарға бөле алады.',
    ),
    heroMetric: t('2 модуля · 6 шагов', '2 modules · 6 steps', '2 модуль · 6 қадам'),
    icon: Icons.account_tree_rounded,
    color: const Color(0xFF59E3FF),
    isPlayable: true,
    modules: <LearningModule>[
      LearningModule(
        id: 'fundamentals_core',
        trackId: 'fundamentals',
        title: t('Core Logic', 'Core Logic', 'Core Logic'),
        summary: t(
          'Как мыслить как разработчик и видеть алгоритм до кода.',
          'How to think like a developer and see the algorithm before the code.',
          'Кодқа дейін алгоритмді көріп, әзірлеушіше ойлау.',
        ),
        lessons: <LessonItem>[
          LessonItem(
            id: 'fundamentals_mindset',
            trackId: 'fundamentals',
            moduleId: 'fundamentals_core',
            title: t('Programming Mindset', 'Programming Mindset', 'Programming Mindset'),
            summary: t(
              'Учимся превращать большую цель в короткую последовательность действий.',
              'Turn a big goal into a short sequence of actions.',
              'Үлкен мақсатты қысқа әрекеттер тізбегіне айналдыру.',
            ),
            durationMinutes: 12,
            outcome: t(
              'Определите вход, действие и ожидаемый результат задачи.',
              'Identify the input, action, and expected outcome of a task.',
              'Тапсырманың кірісі, әрекеті және күтілетін нәтижесін анықтаңыз.',
            ),
            codeSnippet: '''// Pseudocode mindset
goal = "show study progress"
input = completedLessons
action = calculatePercentage(input)
output = "62% completed"''',
            keyPoints: <LocalizedText>[
              t('Сначала цель, потом инструменты.', 'Goal first, tools second.', 'Алдымен мақсат, содан кейін құрал.'),
              t('Разбивайте задачу на маленькие блоки.', 'Break problems into small blocks.', 'Тапсырманы шағын блоктарға бөліңіз.'),
              t('Проверяйте результат после каждого шага.', 'Validate after every step.', 'Әр қадамнан кейін нәтижені тексеріңіз.'),
            ],
            promptSuggestion: t(
              'Объясни, как декомпозировать задачу',
              'Explain how to decompose a task',
              'Тапсырманы қалай бөлуге болатынын түсіндір',
            ),
            xpReward: 50,
          ),
          LessonItem(
            id: 'fundamentals_flow',
            trackId: 'fundamentals',
            moduleId: 'fundamentals_core',
            title: t('Conditions and Flow', 'Conditions and Flow', 'Conditions and Flow'),
            summary: t(
              'Используем if/else и порядок действий для управляемого поведения программы.',
              'Use if/else and execution order to control program behavior.',
              'Бағдарлама жүрісін басқару үшін if/else және орындалу ретін қолдану.',
            ),
            durationMinutes: 14,
            outcome: t(
              'Научитесь описывать простую логику выбора.',
              'Describe simple branching logic.',
              'Қарапайым тармақталу логикасын сипаттау.',
            ),
            codeSnippet: '''if (progress >= 0.7) {
  showBadge("Almost there");
} else {
  showHint("Finish the current lesson");
}''',
            keyPoints: <LocalizedText>[
              t('Условия помогают управлять сценарием.', 'Conditions shape the scenario.', 'Шарттар сценарийді басқарады.'),
              t('Порядок веток влияет на результат.', 'Branch order affects the outcome.', 'Тармақ реті нәтижеге әсер етеді.'),
              t('Показывайте пользователю понятный next step.', 'Always reveal the next step.', 'Қолданушыға келесі қадамды анық көрсетіңіз.'),
            ],
            promptSuggestion: t(
              'Разбери пример с условиями',
              'Break down an if/else example',
              'if/else мысалын талдап бер',
            ),
            xpReward: 55,
          ),
        ],
        practice: PracticeTask(
          id: 'fundamentals_logic_lab',
          trackId: 'fundamentals',
          moduleId: 'fundamentals_core',
          title: t('Logic Lab', 'Logic Lab', 'Logic Lab'),
          summary: t(
            'Соберите мини-сценарий выбора следующего шага для студента.',
            'Build a mini flow that chooses the next step for the learner.',
            'Студент үшін келесі қадамды таңдайтын шағын flow құрыңыз.',
          ),
          brief: t(
            'Нужно показать подсказку для студента в зависимости от прогресса и streak.',
            'Show a hint based on progress and streak.',
            'Прогресс пен streak-ке қарап hint көрсету керек.',
          ),
          starterCode: '''String nextHint(double progress, int streak) {
  if (progress >= 0.8) {
    return "Finish practice";
  }
  return "Review lesson";
}''',
          successCriteria: <LocalizedText>[
            t('Есть минимум две ветки поведения.', 'At least two behavior branches exist.', 'Кемінде екі тармақ болуы керек.'),
            t('Подсказка понятна пользователю.', 'The hint is clear to the learner.', 'Hint қолданушыға түсінікті болуы тиіс.'),
            t('Логика зависит от данных, а не от хардкода.', 'Logic depends on data, not static text.', 'Логика дерекке сүйенуі керек.'),
          ],
          promptSuggestion: t(
            'Подскажи, как улучшить мою функцию',
            'Help me improve this function',
            'Функциямды қалай жақсартуға болады?',
          ),
          xpReward: 70,
        ),
      ),
      LearningModule(
        id: 'fundamentals_debug',
        trackId: 'fundamentals',
        title: t('Debug and Structure', 'Debug and Structure', 'Debug and Structure'),
        summary: t(
          'Закрепляем функции, списки и отладочный ритм.',
          'Reinforce functions, lists, and a debugging rhythm.',
          'Функциялар, тізімдер және debug ырғағын бекіту.',
        ),
        lessons: <LessonItem>[
          LessonItem(
            id: 'fundamentals_functions',
            trackId: 'fundamentals',
            moduleId: 'fundamentals_debug',
            title: t('Functions and Reuse', 'Functions and Reuse', 'Functions and Reuse'),
            summary: t(
              'Убираем дублирование и выносим шаги в повторно используемые блоки.',
              'Reduce duplication and move repeated steps into reusable blocks.',
              'Қайталанатын бөліктерді қайта қолданылатын блоктарға шығару.',
            ),
            durationMinutes: 11,
            outcome: t(
              'Научитесь выделять повторяющееся поведение.',
              'Spot and extract repeated behavior.',
              'Қайталанатын әрекеттерді бөліп көрсету.',
            ),
            codeSnippet: '''Widget buildMetric(String title, String value) {
  return MetricCard(title: title, value: value);
}''',
            keyPoints: <LocalizedText>[
              t('Функция отвечает за один смысл.', 'One function, one intent.', 'Бір функция, бір мағына.'),
              t('Повторяющийся UI тоже стоит выносить.', 'Repeated UI should be extracted too.', 'Қайталанатын UI-ды да бөлу керек.'),
              t('Названия должны объяснять действие.', 'Names should explain the action.', 'Атаулар әрекетті түсіндіруі керек.'),
            ],
            promptSuggestion: t(
              'Помоги выделить функцию из кода',
              'Help me extract a function',
              'Кодтан функция бөліп бер',
            ),
            xpReward: 50,
          ),
          LessonItem(
            id: 'fundamentals_debugging',
            trackId: 'fundamentals',
            moduleId: 'fundamentals_debug',
            title: t('Debugging Basics', 'Debugging Basics', 'Debugging Basics'),
            summary: t(
              'Понимаем, как быстро локализовать ошибку и проверить гипотезу.',
              'Learn to localize an error quickly and test a hypothesis.',
              'Қатені тез локалдап, гипотезаны тексеру тәсілі.',
            ),
            durationMinutes: 13,
            outcome: t(
              'Опишите простой цикл: наблюдение -> гипотеза -> проверка.',
              'Describe the cycle: observe -> hypothesize -> verify.',
              'Бақылау -> гипотеза -> тексеру циклін сипаттау.',
            ),
            codeSnippet: '''print("progress: \$progress");
assert(progress >= 0 && progress <= 1);''',
            keyPoints: <LocalizedText>[
              t('Сначала воспроизведите проблему.', 'Reproduce the issue first.', 'Алдымен қателікті қайталаңыз.'),
              t('Проверяйте одно предположение за раз.', 'Test one assumption at a time.', 'Бір уақытта бір болжамды тексеріңіз.'),
              t('Фиксируйте, что именно изменилось.', 'Note what exactly changed.', 'Нақты не өзгергенін белгілеңіз.'),
            ],
            promptSuggestion: t(
              'Помоги составить план отладки',
              'Help me build a debug plan',
              'Debug жоспарын құрып бер',
            ),
            xpReward: 55,
          ),
        ],
        practice: PracticeTask(
          id: 'fundamentals_debug_lab',
          trackId: 'fundamentals',
          moduleId: 'fundamentals_debug',
          title: t('Debug Flow Lab', 'Debug Flow Lab', 'Debug Flow Lab'),
          summary: t(
            'Находите ошибку в мини-виджете аналитики и чините сценарий.',
            'Find the issue in a mini analytics widget and fix the flow.',
            'Аналитика виджетіндегі қатені тауып, flow-ды түзету.',
          ),
          brief: t(
            'В прогресс-бар попадает число больше 1. Нужно объяснить причину и предложить фиксацию.',
            'A progress bar receives a value greater than 1. Explain the cause and propose a fix.',
            'Progress bar-ға 1-ден үлкен мән беріліп жатыр. Себебін түсіндіріп, fix ұсыныңыз.',
          ),
          starterCode: '''final progress = completedLessons / 2;
LinearProgressIndicator(value: progress);''',
          successCriteria: <LocalizedText>[
            t('Найдена причина проблемы.', 'The root cause is identified.', 'Мәселенің себебі табылды.'),
            t('Предложено безопасное ограничение значения.', 'A safe value clamp is proposed.', 'Қауіпсіз шектеу ұсынылды.'),
            t('Пояснение можно озвучить на презентации.', 'The explanation is presentation-ready.', 'Түсіндіруді презентацияда айтуға болады.'),
          ],
          promptSuggestion: t(
            'Помоги проверить гипотезу по багу',
            'Help me verify the bug hypothesis',
            'Баг гипотезасын тексеруге көмектес',
          ),
          xpReward: 75,
        ),
      ),
    ],
  );
}

LearningTrack _frontendTrack() {
  return LearningTrack(
    id: 'frontend',
    title: t('Frontend', 'Frontend', 'Frontend'),
    subtitle: t(
      'Интерфейсы, адаптивность и состояние',
      'Interfaces, responsiveness, and state',
      'Интерфейс, адаптивтілік және күй',
    ),
    description: t(
      'Ветка про визуальный слой продукта: структура экрана, композиция, интерактивность.',
      'The visual layer of a product: screen structure, composition, and interactivity.',
      'Өнімнің визуал қабаты: экран құрылымы, композиция және интерактивтілік.',
    ),
    teaser: t(
      'Собираем интерфейс, который не просто красивый, а объясняет следующий шаг пользователю.',
      'Build interfaces that not only look good but also clarify the next user action.',
      'Тек әдемі емес, келесі қадамды түсіндіретін интерфейс жасаймыз.',
    ),
    outcome: t(
      'После ветки студент умеет проектировать карточки, CTA и адаптивные блоки под реальный user flow.',
      'After this branch, the learner can design cards, CTAs, and adaptive blocks for a real user flow.',
      'Осы тармақтан кейін студент нақты user flow үшін карточка, CTA және адаптив блоктарды жасай алады.',
    ),
    heroMetric: t('2 модуля · 6 шагов', '2 modules · 6 steps', '2 модуль · 6 қадам'),
    icon: Icons.web_rounded,
    color: const Color(0xFFFFB158),
    isPlayable: true,
    modules: <LearningModule>[
      LearningModule(
        id: 'frontend_layout',
        trackId: 'frontend',
        title: t('UI Structure', 'UI Structure', 'UI Structure'),
        summary: t(
          'Каркас интерфейса, hierarchy и понятные точки фокуса.',
          'Interface skeleton, hierarchy, and clear focal points.',
          'Интерфейс қаңқасы, hierarchy және анық фокус нүктелері.',
        ),
        lessons: <LessonItem>[
          LessonItem(
            id: 'frontend_html',
            trackId: 'frontend',
            moduleId: 'frontend_layout',
            title: t('Screen Hierarchy', 'Screen Hierarchy', 'Screen Hierarchy'),
            summary: t(
              'Понимаем, как расставить акценты, чтобы экран быстро считывался на защите.',
              'Learn how to place emphasis so the screen reads fast during a presentation.',
              'Экран презентацияда тез оқылуы үшін акценттерді дұрыс қою.',
            ),
            durationMinutes: 10,
            outcome: t(
              'Выберите один главный CTA и одну supporting-механику.',
              'Choose one primary CTA and one supporting mechanic.',
              'Бір негізгі CTA және бір supporting механиканы таңдаңыз.',
            ),
            codeSnippet: '''Column(
  children: [
    HeroCard(),
    ProgressStrip(),
    ActionButton(label: "Continue learning"),
  ],
)''',
            keyPoints: <LocalizedText>[
              t('Иерархия экономит время пользователя.', 'Hierarchy saves user time.', 'Hierarchy қолданушы уақытын үнемдейді.'),
              t('Первый экран должен продавать следующий шаг.', 'The first screen should sell the next action.', 'Бірінші экран келесі қадамды сатуы керек.'),
              t('Повторяйте мотивы и отступы.', 'Repeat patterns and spacing.', 'Мотивтер мен аралықтарды қайталаңыз.'),
            ],
            promptSuggestion: t(
              'Оцени структуру моего экрана',
              'Review my screen structure',
              'Экранымның құрылымын бағала',
            ),
            xpReward: 50,
          ),
          LessonItem(
            id: 'frontend_responsive',
            trackId: 'frontend',
            moduleId: 'frontend_layout',
            title: t('Responsive Decisions', 'Responsive Decisions', 'Responsive Decisions'),
            summary: t(
              'Готовим layout, который выглядит уверенно и на телефоне, и в браузере.',
              'Prepare a layout that feels strong on both phone and browser.',
              'Телефонда да, браузерде де сенімді көрінетін layout дайындау.',
            ),
            durationMinutes: 13,
            outcome: t(
              'Научитесь ограничивать ширину и перестраивать сетку под размер экрана.',
              'Learn to constrain width and adapt the grid to screen size.',
              'Контейнер енін шектеп, торды экран өлшеміне бейімдеңіз.',
            ),
            codeSnippet: '''Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 520),
    child: child,
  ),
)''',
            keyPoints: <LocalizedText>[
              t('Phone-first не означает browser-last.', 'Phone-first is not browser-last.', 'Phone-first browser-last деген емес.'),
              t('Ширина контейнера формирует ритм чтения.', 'Container width shapes reading rhythm.', 'Контейнер ені оқу ырғағын қалыптастырады.'),
              t('Сетки должны быть предсказуемыми.', 'Grids should stay predictable.', 'Торлар болжамды болуы керек.'),
            ],
            promptSuggestion: t(
              'Сделай мне план адаптации экрана',
              'Give me a responsive plan for this screen',
              'Экранды бейімдеу жоспарын бер',
            ),
            xpReward: 55,
          ),
        ],
        practice: PracticeTask(
          id: 'frontend_ui_lab',
          trackId: 'frontend',
          moduleId: 'frontend_layout',
          title: t('Landing UI Lab', 'Landing UI Lab', 'Landing UI Lab'),
          summary: t(
            'Соберите hero-блок для образовательного продукта.',
            'Build a hero block for an educational product.',
            'Білім беру өніміне hero-блок жинаңыз.',
          ),
          brief: t(
            'Нужны заголовок, короткий value proposition, CTA и 2 supporting-метрики.',
            'Include a headline, short value proposition, CTA, and 2 support metrics.',
            'Тақырып, қысқа value proposition, CTA және 2 supporting метрика керек.',
          ),
          starterCode: '''HeroCard(
  title: "ZerdeStudy",
  subtitle: "Personal path into IT",
)''',
          successCriteria: <LocalizedText>[
            t('Есть один сильный CTA.', 'There is one strong CTA.', 'Бір күшті CTA бар.'),
            t('Метрики усиливают доверие.', 'Metrics strengthen trust.', 'Метрикалар сенімді күшейтеді.'),
            t('Блок читается за 3-5 секунд.', 'The block is readable in 3-5 seconds.', 'Блок 3-5 секундта оқылады.'),
          ],
          promptSuggestion: t(
            'Дай фидбек по hero-блоку',
            'Give feedback on my hero block',
            'Hero-блокқа фидбек бер',
          ),
          xpReward: 70,
        ),
      ),
      LearningModule(
        id: 'frontend_state',
        trackId: 'frontend',
        title: t('Stateful UI', 'Stateful UI', 'Stateful UI'),
        summary: t(
          'Связываем действия пользователя с прогрессом, табами и micro-feedback.',
          'Connect user actions to progress, tabs, and micro-feedback.',
          'Қолданушы әрекеттерін progress, tab және micro-feedback-пен байланыстыру.',
        ),
        lessons: <LessonItem>[
          LessonItem(
            id: 'frontend_components',
            trackId: 'frontend',
            moduleId: 'frontend_state',
            title: t('Reusable Components', 'Reusable Components', 'Reusable Components'),
            summary: t(
              'Собираем повторяемые карточки и action-блоки из одной дизайн-системы.',
              'Build repeatable cards and action blocks from one design system.',
              'Бір дизайн жүйесінен қайталанатын карточка мен action-блок құру.',
            ),
            durationMinutes: 12,
            outcome: t(
              'Научитесь выносить повторяющийся UI в переиспользуемые виджеты.',
              'Extract repeating UI into reusable widgets.',
              'Қайталанатын UI-ды қайта қолданылатын виджеттерге шығару.',
            ),
            codeSnippet: '''class GlowCard extends StatelessWidget {
  const GlowCard({required this.child});
}''',
            keyPoints: <LocalizedText>[
              t('Одна стилистика на всём пути делает MVP цельным.', 'One styling language keeps the MVP coherent.', 'Бір стилистика MVP-ді тұтас етеді.'),
              t('Компонент должен прятать визуальную сложность.', 'A component should hide visual complexity.', 'Компонент визуал күрделілікті жасыруы керек.'),
              t('Простой API ускоряет сборку экранов.', 'A simple API speeds up screens.', 'Қарапайым API экран жинауды тездетеді.'),
            ],
            promptSuggestion: t(
              'Помоги выделить общий компонент',
              'Help me extract a shared component',
              'Ортақ компонентті бөліп бер',
            ),
            xpReward: 50,
          ),
          LessonItem(
            id: 'frontend_state_link',
            trackId: 'frontend',
            moduleId: 'frontend_state',
            title: t('State and Feedback', 'State and Feedback', 'State and Feedback'),
            summary: t(
              'Показываем, как действия влияют на XP, streak и доступность следующего шага.',
              'Show how actions affect XP, streak, and the next available step.',
              'Әрекеттердің XP, streak және келесі қадамға әсерін көрсету.',
            ),
            durationMinutes: 15,
            outcome: t(
              'Свяжите одно действие с несколькими UI-изменениями.',
              'Connect one action to multiple UI updates.',
              'Бір әрекетті бірнеше UI жаңаруымен байланыстырыңыз.',
            ),
            codeSnippet: '''ref.read(demoAppControllerProvider.notifier)
  .completeLesson(lessonId);''',
            keyPoints: <LocalizedText>[
              t('Действие должно иметь видимый эффект.', 'Actions should have visible effects.', 'Әрекет көрінетін әсер беруі керек.'),
              t('Стейт нужен ради пользовательской пользы.', 'State exists to help the learner.', 'State қолданушыға пайда беру үшін керек.'),
              t('Feedback укрепляет мотивацию.', 'Feedback reinforces motivation.', 'Feedback мотивацияны күшейтеді.'),
            ],
            promptSuggestion: t(
              'Как связать действие и прогресс?',
              'How do I connect an action to progress?',
              'Әрекетті progress-пен қалай байланыстырамын?',
            ),
            xpReward: 55,
          ),
        ],
        practice: PracticeTask(
          id: 'frontend_state_lab',
          trackId: 'frontend',
          moduleId: 'frontend_state',
          title: t('Responsive Dashboard Lab', 'Responsive Dashboard Lab', 'Responsive Dashboard Lab'),
          summary: t(
            'Подключите кнопку завершения к локальному прогрессу и метрикам.',
            'Connect a completion button to local progress and metrics.',
            'Аяқтау батырмасын локал прогресс пен метрикаларға қосыңыз.',
          ),
          brief: t(
            'После нажатия должны измениться XP, streak, блок continue learning и карточка достижений.',
            'After tapping, XP, streak, the continue card, and achievements should all update.',
            'Басқаннан кейін XP, streak, continue learning және achievement карточкасы жаңаруы керек.',
          ),
          starterCode: '''FilledButton(
  onPressed: () {
    // TODO: update state
  },
  child: Text("Complete practice"),
)''',
          successCriteria: <LocalizedText>[
            t('Меняется минимум три UI-состояния.', 'At least three UI states change.', 'Кемінде үш UI күйі өзгереді.'),
            t('Изменения понятны без объяснения кода.', 'Changes are obvious without code explanation.', 'Өзгерістер кодсыз да түсінікті.'),
            t('Экран остаётся чистым и презентабельным.', 'The screen stays clean and presentation-ready.', 'Экран таза әрі презентацияға дайын қалады.'),
          ],
          promptSuggestion: t(
            'Предложи лучший feedback после действия',
            'Suggest better feedback after this action',
            'Әрекеттен кейінгі жақсы feedback ұсын',
          ),
          xpReward: 75,
        ),
      ),
    ],
  );
}
