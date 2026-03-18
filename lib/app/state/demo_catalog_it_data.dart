import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'demo_catalog_support.dart';
import 'demo_models.dart';

List<LearningTrack> buildItSphereTracks() {
  return <LearningTrack>[
    _track(
      id: 'fundamentals',
      title: 'Fundamentals',
      subtitle: 'Mindset, tooling, debugging, HTTP, and workflow habits',
      description:
          'A practical start for navigating software work with calmer structure.',
      teaser: 'A hidden support branch that still powers the wider MVP flow.',
      outcome:
          'You can move through an IT task with clearer steps and feedback loops.',
      icon: Icons.school_rounded,
      color: AppColors.primary,
      order: 0,
      nodeId: 'it-fundamentals',
      connections: <String>[
        'frontend',
        'backend',
        'mobile',
        'cybersecurity',
        'sre_devops',
        'machine_learning',
      ],
    ),
    _track(
      id: 'frontend',
      title: 'Frontend',
      subtitle: 'Semantics, layout, component state, and interactive UI',
      description:
          'Build intuitive interfaces with structure, styling, state, and feedback.',
      teaser: 'A product-facing branch that turns logic into usable experience.',
      outcome:
          'You can explain how UI structure and state create responsive product experience.',
      icon: Icons.web_asset_rounded,
      color: const Color(0xFFFF7A59),
      order: 1,
      nodeId: 'it-frontend',
      connections: <String>[
        'algorithms_data_structures',
        'backend',
        'mobile',
        'qa_engineering',
      ],
    ),
    _track(
      id: 'backend',
      title: 'Backend',
      subtitle: 'Handlers, APIs, validation, jobs, and service design',
      description:
          'Build the server-side logic that receives requests and coordinates work.',
      teaser: 'A strong branch for showing practical system thinking.',
      outcome:
          'You can explain how a service receives, validates, and processes work.',
      icon: Icons.dns_rounded,
      color: const Color(0xFF8BCBFF),
      order: 2,
      nodeId: 'it-backend',
      connections: <String>[
        'algorithms_data_structures',
        'databases',
        'networking_protocols',
        'operating_systems',
        'qa_engineering',
        'sre_devops',
        'cybersecurity',
      ],
    ),
    _track(
      id: 'mobile',
      title: 'Mobile',
      subtitle: 'Mobile product development across platforms and runtime environments',
      description:
          'Design mobile flows that respect device constraints and app lifecycle.',
      teaser: 'The parent branch for platform-specific mobile directions.',
      outcome:
          'You can explain how mobile apps structure screens, state, and storage.',
      icon: Icons.phone_android_rounded,
      color: const Color(0xFFFF9F68),
      order: 3,
      nodeId: 'it-mobile',
      connections: <String>[
        'frontend',
        'operating_systems',
        'android_development',
        'ios_development',
        'crossplatform_development',
      ],
    ),
    _track(
      id: 'android_development',
      title: 'Android',
      subtitle: 'Android UI, lifecycle, state, and native delivery workflows',
      description:
          'Build Android product flows with lifecycle awareness and native patterns.',
      teaser: 'A focused mobile branch for platform-specific behavior.',
      outcome:
          'You can explain how Android apps handle lifecycle, UI, and release flow.',
      icon: Icons.android_rounded,
      color: const Color(0xFF9EE16D),
      order: 4,
      nodeId: 'it-android',
      connections: <String>['mobile', 'operating_systems'],
    ),
    _track(
      id: 'ios_development',
      title: 'iOS',
      subtitle: 'Apple platform lifecycle, interface patterns, and native app structure',
      description:
          'Understand iOS app behavior, navigation, and platform expectations.',
      teaser: 'Shows how one product branch adapts to a specific ecosystem.',
      outcome:
          'You can explain how iOS apps structure state, navigation, and platform behavior.',
      icon: Icons.phone_iphone_rounded,
      color: const Color(0xFF9BC5FF),
      order: 5,
      nodeId: 'it-ios',
      connections: <String>['mobile', 'operating_systems'],
    ),
    _track(
      id: 'crossplatform_development',
      title: 'Crossplatform',
      subtitle: 'Shared UI, state, and platform adaptation across app targets',
      description:
          'Learn how a single codebase can serve multiple mobile platforms well.',
      teaser: 'Useful for presenting shared delivery across devices.',
      outcome:
          'You can explain the tradeoffs between shared logic and platform-specific behavior.',
      icon: Icons.devices_rounded,
      color: const Color(0xFFFFC36B),
      order: 6,
      nodeId: 'it-crossplatform',
      connections: <String>['mobile', 'frontend'],
    ),
    _track(
      id: 'sre_devops',
      title: 'DevOps / SRE',
      subtitle: 'Pipelines, containers, observability, SLOs, and operations',
      description:
          'Learn how software gets delivered, observed, and kept reliable.',
      teaser: 'Connect code, infrastructure, and service reliability.',
      outcome:
          'You can explain how systems are shipped and kept dependable over time.',
      icon: Icons.settings_suggest_rounded,
      color: AppColors.success,
      order: 7,
      nodeId: 'it-sre',
      connections: <String>[
        'backend',
        'networking_protocols',
        'operating_systems',
        'computer_architecture',
        'system_administration',
        'cybersecurity',
      ],
    ),
    _track(
      id: 'system_administration',
      title: 'System Administration',
      subtitle: 'Servers, services, users, environments, and host-level operations',
      description:
          'Maintain hosts, environments, and runtime services with operational clarity.',
      teaser: 'A practical branch for host operations and environment control.',
      outcome:
          'You can explain how systems are configured, maintained, and kept available.',
      icon: Icons.admin_panel_settings_rounded,
      color: const Color(0xFF73E2C3),
      order: 8,
      nodeId: 'it-sysadmin',
      connections: <String>[
        'computer_architecture',
        'networking_protocols',
        'information_security_foundations',
        'operating_systems',
        'sre_devops',
      ],
    ),
    _track(
      id: 'machine_learning',
      title: 'ML Engineer',
      subtitle: 'Model pipelines, features, evaluation, and product-facing ML systems',
      description:
          'Learn the flow from structured data to model evaluation and product use.',
      teaser: 'Connect AI theory, data, math, and engineering delivery.',
      outcome:
          'You can explain how data becomes a model and how the model earns trust.',
      icon: Icons.psychology_alt_rounded,
      color: const Color(0xFFA78BFA),
      order: 9,
      nodeId: 'it-ml',
      connections: <String>[
        'ai_theory',
        'algorithms_data_structures',
        'linear_algebra_calculus',
        'probability_statistics_analytics',
        'databases',
      ],
    ),
    _track(
      id: 'qa_engineering',
      title: 'QA Engineer',
      subtitle: 'Quality strategy, test design, regression control, and release confidence',
      description:
          'Build confidence in product behavior through testing and quality thinking.',
      teaser: 'A strong branch for showing reliability from the product side.',
      outcome:
          'You can explain how tests, scenarios, and checks protect product quality.',
      icon: Icons.fact_check_rounded,
      color: const Color(0xFFF6D365),
      order: 10,
      nodeId: 'it-qa',
      connections: <String>[
        'algorithms_data_structures',
        'frontend',
        'backend',
      ],
    ),
    _track(
      id: 'cybersecurity',
      title: 'Cybersecurity',
      subtitle: 'Threat models, auth, secrets, vulnerabilities, and monitoring',
      description:
          'Think defensively about systems, identities, and attack surfaces.',
      teaser: 'A trust-focused branch built on networks, OS, and security foundations.',
      outcome:
          'You can explain how software protects identity, data, and availability.',
      icon: Icons.security_rounded,
      color: AppColors.danger,
      order: 11,
      nodeId: 'it-security',
      connections: <String>[
        'information_security_foundations',
        'backend',
        'networking_protocols',
        'operating_systems',
        'sre_devops',
      ],
    ),
  ];
}

LearningTrack _track({
  required String id,
  required String title,
  required String subtitle,
  required String description,
  required String teaser,
  required String outcome,
  required IconData icon,
  required Color color,
  required int order,
  required String nodeId,
  required List<String> connections,
}) {
  return buildTrackFromSeed(
    id: id,
    title: title,
    subtitle: subtitle,
    description: description,
    teaser: teaser,
    outcome: outcome,
    heroMetric: '2 modules • 4 lessons • 2 practices',
    icon: icon,
    color: color,
    zone: TrackZone.itSpheres,
    order: order,
    nodeId: nodeId,
    connections: connections,
    modules: _modulesForTrack(id, title),
  );
}

List<DemoModuleSeed> _modulesForTrack(String trackId, String trackTitle) {
  final titles = _trackTitles[trackId]!;
  return <DemoModuleSeed>[
    _module(
      id: '${trackId}_module_1',
      title: titles[0],
      summary: 'Build a clear mental model for the first half of $trackTitle.',
      lessons: <DemoLessonSeed>[
        _lesson(trackId, trackTitle, 1, 1, titles[2], _codeSetA),
        _lesson(trackId, trackTitle, 1, 2, titles[3], _codeSetB),
      ],
      practice: _practice(
        id: '${trackId}_practice_1',
        title: titles[6],
        starterCode: _practiceStarterA,
      ),
    ),
    _module(
      id: '${trackId}_module_2',
      title: titles[1],
      summary: 'Turn the second half of $trackTitle into a live flow.',
      lessons: <DemoLessonSeed>[
        _lesson(trackId, trackTitle, 2, 1, titles[4], _codeSetC),
        _lesson(trackId, trackTitle, 2, 2, titles[5], _codeSetD),
      ],
      practice: _practice(
        id: '${trackId}_practice_2',
        title: titles[7],
        starterCode: _practiceStarterB,
      ),
    ),
  ];
}

DemoLessonSeed _lesson(
  String trackId,
  String trackTitle,
  int moduleIndex,
  int lessonIndex,
  String title,
  _CodeBlueprint blueprint,
) {
  return DemoLessonSeed(
    id: '${trackId}_lesson_${moduleIndex}_$lessonIndex',
    title: title,
    summary: 'Core idea in $trackTitle: $title.',
    outcome: 'You can explain $title using code and a short narrative.',
    codeSnippet: blueprint.codeSnippet,
    exampleOutput: blueprint.output,
    keyPoints: const <String>[
      'Follow the data transformation step by step.',
      'Connect the example to a real engineering situation.',
      'Use the output to verify your mental model.',
    ],
    quizPrompt: 'What does this example print or return?',
    quizOptions: blueprint.quizOptions,
    correctQuizIndex: blueprint.correctQuizIndex,
    quizExplanation:
        'The correct answer follows from the final value computed in the example.',
    trainer: blueprint.trainer,
    promptSuggestion: 'Explain $title as if I am presenting $trackTitle on stage.',
  );
}

DemoModuleSeed _module({
  required String id,
  required String title,
  required String summary,
  required List<DemoLessonSeed> lessons,
  required DemoPracticeSeed practice,
}) {
  return DemoModuleSeed(
    id: id,
    title: title,
    summary: summary,
    lessons: lessons,
    practice: practice,
  );
}

DemoPracticeSeed _practice({
  required String id,
  required String title,
  required String starterCode,
}) {
  return DemoPracticeSeed(
    id: id,
    title: title,
    summary: 'Use a small example to practice the idea and narrate the result.',
    brief:
        'Complete the starter code, print one meaningful result, and explain what the learner should notice.',
    starterCode: starterCode,
    successCriteria: const <String>[
      'Keep the example short and readable.',
      'Print one meaningful result.',
      'Explain why the result matters.',
    ],
    knowledgeChecks: const <String>[
      'What is the key idea behind the example?',
      'How would you explain the result to a teammate?',
    ],
    promptSuggestion:
        'Help me turn this practice into a presenter-friendly walkthrough.',
  );
}

class _CodeBlueprint {
  const _CodeBlueprint({
    required this.codeSnippet,
    required this.output,
    required this.quizOptions,
    required this.correctQuizIndex,
    required this.trainer,
  });

  final String codeSnippet;
  final String output;
  final List<String> quizOptions;
  final int correctQuizIndex;
  final DemoTrainerSeed trainer;
}

const _CodeBlueprint _codeSetA = _CodeBlueprint(
  codeSnippet: '''final plan = ['input', 'plan', 'review'];
print(plan.join(' -> '));''',
  output: 'input -> plan -> review',
  quizOptions: <String>[
    'input -> review -> plan',
    'input -> plan -> review',
    'plan -> input -> review',
  ],
  correctQuizIndex: 1,
  trainer: DemoTrainerSeed.fillBlank(
    title: 'Fill the workflow join',
    instruction:
        'Choose the method that combines list items into one string.',
    prompt: 'Which method turns the list into a readable workflow?',
    options: <String>['join', 'split', 'map'],
    correctIndex: 0,
    template: "print(plan.____(' -> '));",
  ),
);

const _CodeBlueprint _codeSetB = _CodeBlueprint(
  codeSnippet: '''final items = ['init', 'layout', 'fix'];
print(items.last);''',
  output: 'fix',
  quizOptions: <String>['init', 'layout', 'fix'],
  correctQuizIndex: 2,
  trainer: DemoTrainerSeed.reorder(
    title: 'Rebuild the sequence',
    instruction: 'Arrange the lines in the intended order.',
    prompt: 'Put the short sequence example back in order.',
    orderedLines: <String>[
      "final items = ['first', 'second', 'third'];",
      'final latest = items.last;',
      'print(latest);',
    ],
  ),
);

const _CodeBlueprint _codeSetC = _CodeBlueprint(
  codeSnippet: '''var current = 'home';
current = 'tree';
print(current);''',
  output: 'tree',
  quizOptions: <String>['home', 'tree', 'profile'],
  correctQuizIndex: 1,
  trainer: DemoTrainerSeed.matchOutput(
    title: 'Choose the final value',
    instruction: 'Pick the output that matches the last update.',
    prompt: '''var state = 'learn';
state = 'ai';
print(state);''',
    options: <String>['learn', 'ai', 'state'],
    correctIndex: 1,
  ),
);

const _CodeBlueprint _codeSetD = _CodeBlueprint(
  codeSnippet: '''final cards = ['os', 'db', 'ml'];
print(cards.length);''',
  output: '3',
  quizOptions: <String>['2', '3', '4'],
  correctQuizIndex: 1,
  trainer: DemoTrainerSeed.fillBlank(
    title: 'Complete the list metric',
    instruction:
        'Choose the property that returns the number of items.',
    prompt: 'Which property returns the number of list elements?',
    options: <String>['length', 'size', 'last'],
    correctIndex: 0,
    template: 'print(cards.____);',
  ),
);

const String _practiceStarterA = '''final steps = ['understand', 'build', 'verify'];

// print a useful result''';

const String _practiceStarterB = '''var screenState = 'loading';

// update the state and print it''';

const Map<String, List<String>> _trackTitles = <String, List<String>>{
  'fundamentals': <String>[
    'Mindset and tooling',
    'Requests and debugging',
    'Break problems into steps',
    'Git snapshots and iteration',
    'HTTP and JSON basics',
    'Debugging with logs',
    'Build a tiny workflow',
    'Trace a request',
  ],
  'frontend': <String>[
    'Structure and layout',
    'State and interaction',
    'Semantic structure',
    'Layout systems',
    'State-driven UI',
    'Rendering lists and async data',
    'Describe a page frame',
    'Simulate a UI state change',
  ],
  'backend': <String>[
    'Handlers and validation',
    'APIs, jobs, and service flow',
    'Routes and handlers',
    'Validation and trust boundaries',
    'RESTful responses',
    'Background jobs',
    'Describe one API boundary',
    'Model a request and follow-up job',
  ],
  'mobile': <String>[
    'Mobile architecture and lifecycle',
    'Navigation and device storage',
    'Screen trees',
    'Lifecycle awareness',
    'Navigation flows',
    'Local persistence',
    'Map a mobile screen',
    'Model a mobile app flow',
  ],
  'android_development': <String>[
    'Activities and fragments',
    'Android state and delivery',
    'Activity lifecycle',
    'Platform navigation',
    'Background work',
    'Release channels',
    'Describe an Android screen',
    'Model one Android user flow',
  ],
  'ios_development': <String>[
    'View hierarchy and lifecycle',
    'iOS navigation and storage',
    'View controller flow',
    'App lifecycle states',
    'Navigation stacks',
    'Local persistence',
    'Describe one iOS screen',
    'Model one iOS interaction',
  ],
  'crossplatform_development': <String>[
    'Shared UI and state',
    'Platform adaptation',
    'Reusable widget systems',
    'State synchronization',
    'Platform conditionals',
    'Deployment targets',
    'Design one shared screen',
    'Explain one crossplatform tradeoff',
  ],
  'sre_devops': <String>[
    'Delivery systems',
    'Observability and reliability',
    'CI/CD pipelines',
    'Containers and environments',
    'Observability signals',
    'SLOs and incident response',
    'Model a deployment flow',
    'Describe a reliability signal',
  ],
  'system_administration': <String>[
    'Hosts and services',
    'Users, permissions, and operations',
    'Server roles',
    'Service management',
    'Users and groups',
    'Environment maintenance',
    'Describe a host setup',
    'Model one admin operation',
  ],
  'machine_learning': <String>[
    'Data and training flow',
    'Evaluation and serving',
    'Features and labels',
    'Train and validation split',
    'Evaluation metrics',
    'Serving predictions',
    'Describe a tiny learning dataset',
    'Describe one model decision',
  ],
  'qa_engineering': <String>[
    'Test strategy and coverage',
    'Regression and release confidence',
    'Test scenarios',
    'Coverage thinking',
    'Regression suites',
    'Release quality checks',
    'Describe one test matrix',
    'Model a regression pass',
  ],
  'cybersecurity': <String>[
    'Threat models and identity',
    'Vulnerabilities and response',
    'Threat modeling',
    'Authentication and secrets',
    'Common web vulnerabilities',
    'Monitoring and incident response',
    'Model one identity boundary',
    'Describe a security signal',
  ],
};
