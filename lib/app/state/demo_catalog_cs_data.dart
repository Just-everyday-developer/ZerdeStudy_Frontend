import 'package:flutter/material.dart';

import 'demo_catalog_support.dart';
import 'demo_models.dart';

List<LearningTrack> buildComputerScienceTracks() {
  return <LearningTrack>[
    _track(
      id: 'mathematics',
      title: 'Mathematics',
      subtitle: 'The common mathematical foundation for computing and engineering',
      description:
          'Build the broad mathematical base that supports algorithms, AI, analytics, and systems thinking.',
      teaser:
          'Acts as the parent branch for analysis, discrete math, linear algebra, and probability/statistics.',
      outcome:
          'You can explain why different math branches support different computing tasks.',
      icon: Icons.calculate_rounded,
      color: const Color(0xFF8DD8FF),
      order: 0,
      nodeId: 'cs-math-root',
      connections: <String>[
        'mathematical_analysis',
        'discrete_math',
        'linear_algebra_calculus',
        'probability_statistics_analytics',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'mathematical_analysis',
      title: 'Mathematical Analysis',
      subtitle: 'Limits, derivatives, continuity, and change over time',
      description:
          'Understand how continuous change, rates, and accumulation support technical reasoning.',
      teaser: 'Useful for optimization, modeling, and dynamic system intuition.',
      outcome:
          'You can explain how change over time appears in technical systems and models.',
      icon: Icons.functions_rounded,
      color: const Color(0xFF7CB8FF),
      order: 1,
      nodeId: 'cs-math-analysis',
      connections: <String>[
        'mathematics',
        'linear_algebra_calculus',
        'probability_statistics_analytics',
        'ai_theory',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'discrete_math',
      title: 'Discrete Math',
      subtitle: 'Logic, sets, graphs, and counting techniques',
      description: 'Learn the language behind algorithms and structured reasoning.',
      teaser: 'Strong for algorithms, backend reasoning, and state modeling.',
      outcome: 'You can reason about structure, conditions, and combinations clearly.',
      icon: Icons.route_rounded,
      color: const Color(0xFF7CE7FF),
      order: 2,
      nodeId: 'cs-discrete',
      connections: <String>[
        'linear_algebra_calculus',
        'probability_statistics_analytics',
      ],
      modules: <DemoModuleSeed>[
        _module(
          id: 'discrete_math_module_1',
          title: 'Logic and sets',
          summary: 'Truth, conditions, sets, and intersections.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_1_1',
              title: 'Propositions and truth tables',
              trackTitle: 'Discrete Math',
              codeSnippet: '''final a = true;
final b = false;
print((a && !b) || false);''',
              output: 'true',
              quizOptions: <String>['true', 'false', 'null'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Fill the missing operator',
                instruction: 'Choose the operator for “both must be true”.',
                prompt: 'Select the operator that keeps both conditions required.',
                options: <String>['&&', '||', '??'],
                correctIndex: 0,
                template: 'final canDeploy = testsPassed ____ reviewPassed;',
              ),
            ),
            _lesson(
              id: 'discrete_math_lesson_1_2',
              title: 'Sets and relations',
              trackTitle: 'Discrete Math',
              codeSnippet: '''final frontend = {'html', 'css', 'js'};
print(frontend.intersection({'css', 'dart'}).length);''',
              output: '1',
              quizOptions: <String>['0', '1', '2'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the set workflow',
                instruction: 'Tap lines in the order that creates and queries a set.',
                prompt: 'Arrange the code from set creation to the final print.',
                orderedLines: <String>[
                  "final skills = {'api', 'db', 'cache'};",
                  "final shared = skills.intersection({'db', 'ui'});",
                  'print(shared.length);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_1',
            title: 'Map a feature into sets',
            starterCode: '''final platform = {'api', 'infra', 'auth'};
final product = {'ui', 'analytics', 'auth'};

// print the overlap''',
          ),
        ),
        _module(
          id: 'discrete_math_module_2',
          title: 'Graphs and counting',
          summary: 'Connections, nodes, and combinations.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_2_1',
              title: 'Graphs as system maps',
              trackTitle: 'Discrete Math',
              codeSnippet: '''final graph = {'home': ['tree', 'learn']};
print(graph['home']!.length);''',
              output: '2',
              quizOptions: <String>['1', '2', '3'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Match the graph result',
                instruction: 'Pick the output that matches the edge count.',
                prompt: '''final graph = {'api': ['db', 'cache', 'queue']};
print(graph['api']!.length);''',
                options: <String>['2', '3', '4'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: 'discrete_math_lesson_2_2',
              title: 'Counting choices',
              trackTitle: 'Discrete Math',
              codeSnippet: '''final shirts = 3;
final pants = 2;
print(shirts * pants);''',
              output: '6',
              quizOptions: <String>['5', '6', '8'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the counting rule',
                instruction: 'Choose the operation used for independent choices.',
                prompt: 'Which symbol counts combinations?',
                options: <String>['*', '+', '-'],
                correctIndex: 0,
                template: 'final total = services ____ environments;',
              ),
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_2',
            title: 'Design a mini dependency graph',
            starterCode: '''final appGraph = {
  'welcome': ['login', 'signup'],
  'home': ['tree', 'ai'],
};

// print one edge count''',
          ),
        ),
      ],
    ),
    _track(
      id: 'linear_algebra_calculus',
      title: 'Linear Algebra',
      subtitle: 'Vectors, matrices, transformations, and feature spaces',
      description: 'Build intuition for transformations and optimization.',
      teaser: 'Strong for ML, graphics, and representing structured data.',
      outcome: 'You can describe how values move through vector and matrix transforms.',
      icon: Icons.stacked_line_chart_rounded,
      color: const Color(0xFF62B5FF),
      order: 3,
      nodeId: 'cs-linear',
      connections: <String>[
        'discrete_math',
        'probability_statistics_analytics',
        'machine_learning',
      ],
      modules: <DemoModuleSeed>[
        _module(
          id: 'linear_algebra_calculus_module_1',
          title: 'Vectors and matrices',
          summary: 'Represent inputs as vectors and transform them consistently.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'linear_algebra_calculus_lesson_1_1',
              title: 'Vectors as features',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''final vector = [2, 4, 6];
final doubled = vector.map((value) => value * 2).toList();
print(doubled[1]);''',
              output: '8',
              quizOptions: <String>['4', '8', '12'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the transform',
                instruction: 'Choose the operator that scales a value.',
                prompt: 'How do you scale a value by a constant?',
                options: <String>['*', '+', '/'],
                correctIndex: 0,
                template: 'final scaled = value ____ 3;',
              ),
            ),
            _lesson(
              id: 'linear_algebra_calculus_lesson_1_2',
              title: 'Matrices as transformations',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''final x = 2;
final y = 1;
print((2 * x) + y);''',
              output: '5',
              quizOptions: <String>['3', '4', '5'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Order the transform',
                instruction: 'Arrange the lines from input to output.',
                prompt: 'Rebuild the short matrix-style transform.',
                orderedLines: <String>[
                  'final x = 3;',
                  'final projected = (4 * x) + 2;',
                  'print(projected);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'linear_algebra_calculus_practice_1',
            title: 'Transform a feature vector',
            starterCode: '''final features = [1, 3, 5];

// create a transformed list''',
          ),
        ),
        _module(
          id: 'linear_algebra_calculus_module_2',
          title: 'Derivatives and optimization',
          summary: 'Understand change, slope, and iterative improvement.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'linear_algebra_calculus_lesson_2_1',
              title: 'Slope as change',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''final x1 = 2;
final x2 = 3;
print((x2 * x2) - (x1 * x1));''',
              output: '5',
              quizOptions: <String>['1', '4', '5'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Spot the slope output',
                instruction: 'Choose the correct difference.',
                prompt: '''final a = 4;
final b = 5;
print((b * b) - (a * a));''',
                options: <String>['7', '9', '11'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: 'linear_algebra_calculus_lesson_2_2',
              title: 'Optimization loops',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''var loss = 10;
loss -= 3;
loss -= 2;
print(loss);''',
              output: '5',
              quizOptions: <String>['4', '5', '6'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the update step',
                instruction: 'Choose the operation used to reduce loss.',
                prompt: 'Which update symbol moves the loss downward?',
                options: <String>['-=', '+=', '=='],
                correctIndex: 0,
                template: 'loss ____ step;',
              ),
            ),
          ],
          practice: _practice(
            id: 'linear_algebra_calculus_practice_2',
            title: 'Simulate an optimization cycle',
            starterCode: '''var loss = 18;

// apply several update steps''',
          ),
        ),
      ],
    ),
    _track(
      id: 'probability_statistics_analytics',
      title: 'Probability & Statistics',
      subtitle: 'Randomness, sampling, uncertainty, and evidence-based decisions',
      description: 'Use uncertainty and measurement to guide decisions.',
      teaser: 'Strong for analytics, experiments, forecasting, QA, and ML.',
      outcome: 'You can reason about uncertainty and explain evidence clearly.',
      icon: Icons.query_stats_rounded,
      color: const Color(0xFF5CE6FF),
      order: 4,
      nodeId: 'cs-probability',
      connections: <String>[
        'linear_algebra_calculus',
        'databases',
        'fundamentals',
        'machine_learning',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'algorithms_data_structures',
      title: 'Algorithms & Data Structures',
      subtitle: 'Complexity, arrays, maps, trees, queues, and problem-solving patterns',
      description:
          'Learn how information is organized and how efficient procedures act on it.',
      teaser: 'A central branch for backend, frontend state, QA thinking, and ML pipelines.',
      outcome:
          'You can explain how data structures and algorithms shape runtime behavior.',
      icon: Icons.account_tree_rounded,
      color: const Color(0xFF89E8C4),
      order: 5,
      nodeId: 'cs-algorithms',
      connections: <String>[
        'discrete_math',
        'frontend',
        'backend',
        'mobile',
        'qa_engineering',
        'machine_learning',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'computer_architecture',
      title: 'Computer Architecture',
      subtitle: 'CPU, memory hierarchy, binary, and execution',
      description: 'Connect code behavior to the machine beneath it.',
      teaser: 'Strong for performance intuition and systems reasoning.',
      outcome: 'You can explain how instructions, memory, and hardware affect software.',
      icon: Icons.memory_rounded,
      color: const Color(0xFFB2F27A),
      order: 9,
      nodeId: 'cs-architecture',
      connections: <String>['operating_systems'],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'operating_systems',
      title: 'Operating Systems',
      subtitle: 'Processes, memory, scheduling, and system calls',
      description: 'Understand the runtime environment beneath an application.',
      teaser: 'Strong for backend performance, mobile behavior, and systems debugging.',
      outcome: 'You can explain how the OS shapes runtime behavior.',
      icon: Icons.settings_applications_rounded,
      color: const Color(0xFF7AE582),
      order: 11,
      nodeId: 'cs-os',
      connections: <String>[
        'computer_architecture',
        'networking_protocols',
        'fundamentals',
        'sre_devops',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'networking_protocols',
      title: 'Information Networks',
      subtitle: 'Layers, routing, DNS, protocols, transport, and latency',
      description: 'Learn how data moves through layers and protocols.',
      teaser: 'Strong for backend APIs, mobile latency, and security.',
      outcome: 'You can explain where packets, protocols, and delays enter the story.',
      icon: Icons.wifi_tethering_rounded,
      color: const Color(0xFFFFB86B),
      order: 7,
      nodeId: 'cs-networks',
      connections: <String>[
        'operating_systems',
        'databases',
        'fundamentals',
        'backend',
        'cybersecurity',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'databases',
      title: 'Databases',
      subtitle: 'Schemas, SQL, indexes, transactions, and replication',
      description: 'Store, query, and protect data with structured systems.',
      teaser: 'Strong for backend design, analytics, and product reliability.',
      outcome: 'You can explain how data is stored, queried, and kept consistent.',
      icon: Icons.storage_rounded,
      color: const Color(0xFFFFD166),
      order: 6,
      nodeId: 'cs-databases',
      connections: <String>[
        'networking_protocols',
        'probability_statistics_analytics',
        'fundamentals',
        'backend',
        'machine_learning',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'ai_theory',
      title: 'AI Theory',
      subtitle: 'Search, reasoning, learning paradigms, and intelligent systems',
      description:
          'Study the conceptual foundations behind intelligent behavior and machine reasoning.',
      teaser: 'Connects mathematics, algorithms, and ML engineering.',
      outcome:
          'You can explain how core AI ideas translate into model-driven systems.',
      icon: Icons.psychology_rounded,
      color: const Color(0xFFA991FF),
      order: 8,
      nodeId: 'cs-ai-theory',
      connections: <String>[
        'mathematical_analysis',
        'linear_algebra_calculus',
        'probability_statistics_analytics',
        'algorithms_data_structures',
        'machine_learning',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'information_security_foundations',
      title: 'Information Security',
      subtitle: 'Confidentiality, integrity, access control, and secure system design',
      description:
          'Learn the foundational ideas that protect systems, users, and information.',
      teaser:
          'A core security branch that leads naturally into cybersecurity and system administration.',
      outcome:
          'You can explain the key security principles that shape technical decisions.',
      icon: Icons.verified_user_rounded,
      color: const Color(0xFFFF8D8D),
      order: 10,
      nodeId: 'cs-info-security',
      connections: <String>[
        'networking_protocols',
        'operating_systems',
        'system_administration',
        'cybersecurity',
      ],
      modules: const <DemoModuleSeed>[],
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
  required List<DemoModuleSeed> modules,
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
    zone: TrackZone.computerScienceCore,
    order: order,
    nodeId: nodeId,
    connections: connections,
    modules: modules.isEmpty ? _fallbackModules(id, title) : modules,
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

DemoLessonSeed _lesson({
  required String id,
  required String title,
  required String trackTitle,
  required String codeSnippet,
  required String output,
  required List<String> quizOptions,
  required int correctQuizIndex,
  required DemoTrainerSeed trainer,
}) {
  return DemoLessonSeed(
    id: id,
    title: title,
    summary: 'Core idea in $trackTitle: $title.',
    outcome: 'You can explain $title using code and a short narrative.',
    codeSnippet: codeSnippet,
    exampleOutput: output,
    keyPoints: <String>[
      'Follow the data transformation step by step.',
      'Connect the code example to a real engineering situation.',
      'Use the output to verify your mental model.',
    ],
    quizPrompt: 'What does this example print or return?',
    quizOptions: quizOptions,
    correctQuizIndex: correctQuizIndex,
    quizExplanation: 'The correct answer follows from the final value computed in the example.',
    trainer: trainer,
    promptSuggestion: 'Explain $title as if I am presenting $trackTitle on stage.',
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
    brief: 'Complete the starter code, print one meaningful result, and explain what the learner should notice.',
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
    promptSuggestion: 'Help me turn this practice into a presenter-friendly walkthrough.',
  );
}

List<DemoModuleSeed> _fallbackModules(String trackId, String title) {
  switch (trackId) {
    case 'probability_statistics_analytics':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Probability intuition',
          summary: 'Events, ratios, and expected value.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Events and simple probabilities',
              trackTitle: title,
              codeSnippet: '''final success = 2;
final total = 5;
print(success / total);''',
              output: '0.4',
              quizOptions: <String>['0.2', '0.4', '2.5'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Fill the probability formula',
                instruction: 'Choose the operator that creates the ratio.',
                prompt: 'Which operator gives probability as a ratio?',
                options: <String>['/', '*', '+'],
                correctIndex: 0,
                template: 'final p = favorable ____ total;',
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Expected value',
              trackTitle: title,
              codeSnippet: '''final reward = 5;
final probability = 0.3;
print(reward * probability);''',
              output: '1.5',
              quizOptions: <String>['1.5', '2.0', '3.0'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Order the expected value formula',
                instruction: 'Arrange the lines so the payoff prints correctly.',
                prompt: 'Rebuild the expected value example.',
                orderedLines: <String>[
                  'final reward = 8;',
                  'final probability = 0.25;',
                  'print(reward * probability);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Estimate a product event',
            starterCode: '''final converted = 18;
final visitors = 60;

// compute the conversion probability''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Statistics and analytics',
          summary: 'Sampling, averages, and experiments.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Sampling and averages',
              trackTitle: title,
              codeSnippet: '''final sample = [4, 6, 8];
print(sample.reduce((a, b) => a + b) / sample.length);''',
              output: '6.0',
              quizOptions: <String>['5.0', '6.0', '7.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Choose the average',
                instruction: 'Match the sample to its printed mean.',
                prompt: '''final sample = [2, 4, 10];
print(sample.reduce((a, b) => a + b) / sample.length);''',
                options: <String>['4.0', '5.33', '6.0'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Experiments and decisions',
              trackTitle: title,
              codeSnippet: '''final control = 0.14;
final variant = 0.18;
print(variant - control);''',
              output: '0.04',
              quizOptions: <String>['0.02', '0.04', '0.32'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the lift formula',
                instruction: 'Choose the operator that compares variant against control.',
                prompt: 'Which operator gives the change over baseline?',
                options: <String>['-', '+', '*'],
                correctIndex: 0,
                template: 'final lift = variant ____ control;',
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Analyze a tiny experiment',
            starterCode: '''final control = 0.21;
final variant = 0.25;

// print the lift''',
          ),
        ),
      ];
    case 'computer_architecture':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'CPU and memory',
          summary: 'Registers, cycles, caches, and latency.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'CPU work cycle',
              trackTitle: title,
              codeSnippet: '''var register = 1;
register = register + 2;
print(register);''',
              output: '3',
              quizOptions: <String>['1', '2', '3'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the arithmetic instruction',
                instruction: 'Choose the operator used in the register update.',
                prompt: 'Which operator adds to the register?',
                options: <String>['+', '-', '='],
                correctIndex: 0,
                template: 'register = register ____ 2;',
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Caches and latency',
              trackTitle: title,
              codeSnippet: '''final cacheHit = 1;
final memoryHit = 6;
print(memoryHit - cacheHit);''',
              output: '5',
              quizOptions: <String>['4', '5', '6'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the latency example',
                instruction: 'Arrange the lines that compare cache and memory.',
                prompt: 'Order the statements from setup to difference.',
                orderedLines: <String>[
                  'final cache = 2;',
                  'final memory = 8;',
                  'print(memory - cache);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Explain a performance gap',
            starterCode: '''final cacheHit = 2;
final slowAccess = 11;

// print the gap''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Representation and execution',
          summary: 'Binary data and parallel work.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Binary representation',
              trackTitle: title,
              codeSnippet: '''final bitA = 1;
final bitB = 0;
print('\$bitA\$bitB\$bitA');''',
              output: '101',
              quizOptions: <String>['011', '101', '110'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Match the printed bit pattern',
                instruction: 'Choose the output that matches the print.',
                prompt: '''final left = 1;
final right = 1;
print('\$left\$right\$left');''',
                options: <String>['101', '111', '110'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Parallel execution intuition',
              trackTitle: title,
              codeSnippet: '''final tasks = 4;
final workers = 2;
print(tasks / workers);''',
              output: '2.0',
              quizOptions: <String>['1.0', '2.0', '4.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the parallel split',
                instruction: 'Choose the operator that divides work across workers.',
                prompt: 'Which operator shares the load evenly?',
                options: <String>['/', '*', '+'],
                correctIndex: 0,
                template: 'final load = tasks ____ workers;',
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Model a tiny performance scenario',
            starterCode: '''final tasks = 12;
final workers = 3;

// print the distribution''',
          ),
        ),
      ];
    case 'operating_systems':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Processes and memory',
          summary: 'Isolation, sharing, and memory boundaries.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Processes vs threads',
              trackTitle: title,
              codeSnippet: '''final processName = 'api';
final threads = ['io', 'worker'];
print('\$processName:\${threads.length}');''',
              output: 'api:2',
              quizOptions: <String>['api:1', 'api:2', 'worker:2'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the process label',
                instruction: 'Select the value that identifies the outer runtime container.',
                prompt: 'Which term owns the resources?',
                options: <String>['process', 'thread', 'queue'],
                correctIndex: 0,
                template: "final owner = '____';",
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Memory layout',
              trackTitle: title,
              codeSnippet: '''final stackFrames = 3;
final heapObjects = 5;
print(stackFrames + heapObjects);''',
              output: '8',
              quizOptions: <String>['6', '7', '8'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the memory summary',
                instruction: 'Arrange the memory counters before the print.',
                prompt: 'Put the simple memory example back in order.',
                orderedLines: <String>[
                  'final stackFrames = 2;',
                  'final heapObjects = 4;',
                  'print(stackFrames + heapObjects);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Describe a runtime container',
            starterCode: '''final process = 'upload-service';
final threads = ['reader', 'writer', 'retry'];

// print the process summary''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Scheduling and IO',
          summary: 'Schedulers, files, and system calls.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Scheduling work',
              trackTitle: title,
              codeSnippet: '''final queue = ['api', 'worker', 'sync'];
print(queue.removeAt(0));''',
              output: 'api',
              quizOptions: <String>['api', 'worker', 'sync'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Match the scheduler output',
                instruction: 'Choose the process that leaves the queue first.',
                prompt: '''final queue = ['cache', 'db'];
print(queue.removeAt(0));''',
                options: <String>['db', 'cache', 'queue'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Files and system calls',
              trackTitle: title,
              codeSnippet: '''final fileReads = 2;
final socketReads = 1;
print(fileReads + socketReads);''',
              output: '3',
              quizOptions: <String>['2', '3', '4'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the IO count',
                instruction: 'Pick the operator that totals two IO sources.',
                prompt: 'Which symbol combines the IO counts?',
                options: <String>['+', '-', '/'],
                correctIndex: 0,
                template: 'print(fileReads ____ socketReads);',
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Model a scheduler snapshot',
            starterCode: '''final jobs = ['index', 'compress', 'backup'];

// remove the next job and print it''',
          ),
        ),
      ];
    case 'networking_protocols':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Layers and routing',
          summary: 'Understand how data crosses abstractions.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Layers of a request',
              trackTitle: title,
              codeSnippet: '''final layers = ['link', 'ip', 'tcp', 'http'];
print(layers.last);''',
              output: 'http',
              quizOptions: <String>['ip', 'tcp', 'http'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the top layer',
                instruction: 'Choose the protocol that usually sits at the application level.',
                prompt: 'Which item belongs to the application layer here?',
                options: <String>['http', 'ethernet', 'arp'],
                correctIndex: 0,
                template: "final appLayer = '____';",
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Routing and latency',
              trackTitle: title,
              codeSnippet: '''final hop1 = 12;
final hop2 = 18;
print(hop1 + hop2);''',
              output: '30',
              quizOptions: <String>['24', '30', '36'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the hop calculation',
                instruction: 'Arrange the lines from hop values to total latency.',
                prompt: 'Put the route latency example in order.',
                orderedLines: <String>[
                  'final hopA = 9;',
                  'final hopB = 21;',
                  'print(hopA + hopB);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Describe a request path',
            starterCode: '''final hops = [10, 14, 19];

// total the route latency''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Protocols in practice',
          summary: 'HTTP, TLS, DNS, and sockets as real building blocks.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'HTTP and TLS',
              trackTitle: title,
              codeSnippet: '''final scheme = 'https';
final host = 'zerdestudy.app';
print('\$scheme://\$host');''',
              output: 'https://zerdestudy.app',
              quizOptions: <String>['http://zerdestudy.app', 'https://zerdestudy.app', 'tls://zerdestudy.app'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Choose the secure URL',
                instruction: 'Pick the output that matches the secure scheme.',
                prompt: '''final scheme = 'https';
print('\$scheme://demo.local');''',
                options: <String>['http://demo.local', 'https://demo.local', 'tls://demo.local'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'DNS and sockets',
              trackTitle: title,
              codeSnippet: '''final host = 'api.zerdestudy.app';
final port = 443;
print('\$host:\$port');''',
              output: 'api.zerdestudy.app:443',
              quizOptions: <String>['api.zerdestudy.app:80', 'api.zerdestudy.app:443', 'zerdestudy.app:443'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the socket endpoint',
                instruction: 'Choose the standard HTTPS port.',
                prompt: 'Which port is standard for HTTPS?',
                options: <String>['80', '443', '53'],
                correctIndex: 1,
                template: "final endpoint = 'api.demo.local:____';",
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Assemble a request endpoint',
            starterCode: '''final scheme = 'https';
final host = 'api.demo.local';
final port = 443;

// print the full endpoint''',
          ),
        ),
      ];
    case 'databases':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Schemas and queries',
          summary: 'Organize tables and retrieve meaningful data.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Schemas, keys, and rows',
              trackTitle: title,
              codeSnippet: '''final rows = 3;
final primaryKey = 'id';
print('\$primaryKey:\$rows');''',
              output: 'id:3',
              quizOptions: <String>['row:3', 'id:3', 'id:4'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the primary key label',
                instruction: 'Select the column typically used as a table identifier.',
                prompt: 'Which label is commonly used as the primary key?',
                options: <String>['id', 'count', 'name'],
                correctIndex: 0,
                template: "final primaryKey = '____';",
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Reading data with SQL',
              trackTitle: title,
              codeSnippet: '''SELECT COUNT(*)
FROM lessons
WHERE status = 'done';''',
              output: 'Returns the number of completed lessons.',
              quizOptions: <String>['All lesson rows', 'The number of completed lessons', 'The latest lesson title'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the SQL query',
                instruction: 'Arrange the lines from selection to filter.',
                prompt: 'Put the small SQL query back in the correct order.',
                orderedLines: <String>[
                  'SELECT COUNT(*)',
                  'FROM users',
                  'WHERE active = true;',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Model a tiny table question',
            starterCode: '''SELECT COUNT(*)
FROM users
WHERE plan = 'pro';

-- explain what this answers''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Indexes and transactions',
          summary: 'Speed up reads and protect correctness.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Indexes reduce search cost',
              trackTitle: title,
              codeSnippet: '''final fullScanCost = 12;
final indexedCost = 3;
print(fullScanCost - indexedCost);''',
              output: '9',
              quizOptions: <String>['6', '9', '15'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Choose the indexed savings',
                instruction: 'Pick the printed difference between scan and index.',
                prompt: '''final scan = 20;
final index = 5;
print(scan - index);''',
                options: <String>['10', '15', '25'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Transactions and consistency',
              trackTitle: title,
              codeSnippet: '''var inventory = 4;
inventory -= 1;
print(inventory);''',
              output: '3',
              quizOptions: <String>['2', '3', '4'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the update',
                instruction: 'Choose the operator used to decrement inventory.',
                prompt: 'Which operator reduces the inventory by one?',
                options: <String>['-=', '+=', '*='],
                correctIndex: 0,
                template: 'inventory ____ 1;',
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Explain a safe update',
            starterCode: '''var seats = 10;

// reserve one seat and print the new value''',
          ),
        ),
      ];
    default:
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Core concepts',
          summary: 'Build a clean mental model for the main ideas in $title.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Key building blocks',
              trackTitle: title,
              codeSnippet: '''final ideas = ['model', 'reason', 'apply'];
print(ideas.length);''',
              output: '3',
              quizOptions: <String>['2', '3', '4'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the concept metric',
                instruction: 'Choose the property that counts the listed building blocks.',
                prompt: 'Which property returns the number of items in the list?',
                options: <String>['length', 'last', 'first'],
                correctIndex: 0,
                template: 'print(ideas.____);',
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Patterns and structure',
              trackTitle: title,
              codeSnippet: '''final first = 2;
final second = 5;
print(first + second);''',
              output: '7',
              quizOptions: <String>['5', '7', '10'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the pattern',
                instruction: 'Arrange the setup and final print in order.',
                prompt: 'Put the short structure example back together.',
                orderedLines: <String>[
                  'final left = 4;',
                  'final right = 3;',
                  'print(left + right);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Map one core idea',
            starterCode: '''final terms = ['signal', 'state', 'result'];

// print one useful summary''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Applied reasoning',
          summary: 'Connect $title to concrete engineering decisions.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Reasoning through tradeoffs',
              trackTitle: title,
              codeSnippet: '''final fast = 8;
final safe = 5;
print(fast - safe);''',
              output: '3',
              quizOptions: <String>['2', '3', '13'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Choose the tradeoff result',
                instruction: 'Pick the printed difference.',
                prompt: '''final stable = 9;
final risky = 4;
print(stable - risky);''',
                options: <String>['4', '5', '6'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Explaining an engineering scenario',
              trackTitle: title,
              codeSnippet: '''final steps = ['observe', 'decide', 'verify'];
print(steps.first);''',
              output: 'observe',
              quizOptions: <String>['observe', 'decide', 'verify'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the first step',
                instruction: 'Choose the property that returns the starting item.',
                prompt: 'Which property returns the first element?',
                options: <String>['first', 'last', 'length'],
                correctIndex: 0,
                template: 'print(steps.____);',
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Explain one technical decision',
            starterCode: '''final options = ['simple', 'scalable', 'secure'];

// print the option you want to defend''',
          ),
        ),
      ];
  }
}
