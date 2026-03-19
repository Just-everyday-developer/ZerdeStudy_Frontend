import 'package:flutter/material.dart';

import 'demo_models.dart';

class DemoTrainerSeed {
  const DemoTrainerSeed.fillBlank({
    required this.title,
    required this.instruction,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.template,
  })  : kind = CodeTrainerKind.fillBlank,
        orderedLines = const <String>[];

  const DemoTrainerSeed.matchOutput({
    required this.title,
    required this.instruction,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  })  : kind = CodeTrainerKind.matchOutput,
        template = null,
        orderedLines = const <String>[];

  const DemoTrainerSeed.reorder({
    required this.title,
    required this.instruction,
    required this.prompt,
    required this.orderedLines,
  })  : kind = CodeTrainerKind.reorderLines,
        template = null,
        options = const <String>[],
        correctIndex = 0;

  final String title;
  final String instruction;
  final String prompt;
  final CodeTrainerKind kind;
  final List<String> options;
  final int correctIndex;
  final String? template;
  final List<String> orderedLines;
}

class DemoLessonSeed {
  const DemoLessonSeed({
    required this.id,
    required this.title,
    required this.summary,
    required this.outcome,
    required this.codeSnippet,
    required this.exampleOutput,
    required this.keyPoints,
    required this.quizPrompt,
    required this.quizOptions,
    required this.correctQuizIndex,
    required this.quizExplanation,
    required this.trainer,
    required this.promptSuggestion,
    this.durationMinutes = 12,
    this.xpReward = 55,
  });

  final String id;
  final String title;
  final String summary;
  final String outcome;
  final String codeSnippet;
  final String exampleOutput;
  final List<String> keyPoints;
  final String quizPrompt;
  final List<String> quizOptions;
  final int correctQuizIndex;
  final String quizExplanation;
  final DemoTrainerSeed trainer;
  final String promptSuggestion;
  final int durationMinutes;
  final int xpReward;
}

class DemoPracticeSeed {
  const DemoPracticeSeed({
    required this.id,
    required this.title,
    required this.summary,
    required this.brief,
    required this.starterCode,
    required this.successCriteria,
    required this.knowledgeChecks,
    required this.promptSuggestion,
    this.xpReward = 75,
  });

  final String id;
  final String title;
  final String summary;
  final String brief;
  final String starterCode;
  final List<String> successCriteria;
  final List<String> knowledgeChecks;
  final String promptSuggestion;
  final int xpReward;
}

class DemoModuleSeed {
  const DemoModuleSeed({
    required this.id,
    required this.title,
    required this.summary,
    required this.lessons,
    required this.practice,
  });

  final String id;
  final String title;
  final String summary;
  final List<DemoLessonSeed> lessons;
  final DemoPracticeSeed practice;
}

LearningTrack buildTrackFromSeed({
  required String id,
  required String title,
  required String subtitle,
  required String description,
  required String teaser,
  required String outcome,
  required String heroMetric,
  required IconData icon,
  required Color color,
  required TrackZone zone,
  required int order,
  required String nodeId,
  required List<String> connections,
  required List<DemoModuleSeed> modules,
}) {
  return LearningTrack(
    id: id,
    title: sameText(title),
    subtitle: sameText(subtitle),
    description: sameText(description),
    teaser: sameText(teaser),
    outcome: sameText(outcome),
    heroMetric: sameText(heroMetric),
    icon: icon,
    color: color,
    zone: zone,
    availability: TrackAvailability.available,
    order: order,
    nodeId: nodeId,
    connections: connections,
    modules: modules
        .map(
          (moduleSeed) => buildModuleFromSeed(
            trackId: id,
            seed: moduleSeed,
          ),
        )
        .toList(growable: false),
  );
}

LearningModule buildModuleFromSeed({
  required String trackId,
  required DemoModuleSeed seed,
}) {
  return LearningModule(
    id: seed.id,
    trackId: trackId,
    title: sameText(seed.title),
    summary: sameText(seed.summary),
    lessons: seed.lessons
        .map(
          (lessonSeed) => buildLessonFromSeed(
            trackId: trackId,
            moduleId: seed.id,
            seed: lessonSeed,
          ),
        )
        .toList(growable: false),
    practice: buildPracticeFromSeed(
      trackId: trackId,
      moduleId: seed.id,
      seed: seed.practice,
    ),
  );
}

LessonItem buildLessonFromSeed({
  required String trackId,
  required String moduleId,
  required DemoLessonSeed seed,
}) {
  final trainer = buildTrainerFromSeed(
    lessonId: seed.id,
    seed: seed.trainer,
  );
  final quiz = LessonQuiz(
    id: '${seed.id}_quiz_1',
    title: sameText('Output quiz'),
    prompt: sameText(seed.quizPrompt),
    kind: QuizKind.outputPrediction,
    options: List<QuizOption>.generate(
      seed.quizOptions.length,
      (index) => QuizOption(
        id: 'option_$index',
        label: sameText(seed.quizOptions[index]),
      ),
    ),
    correctOptionId: 'option_${seed.correctQuizIndex}',
    explanation: sameText(seed.quizExplanation),
  );

  return LessonItem(
    id: seed.id,
    trackId: trackId,
    moduleId: moduleId,
    title: sameText(seed.title),
    summary: sameText(seed.summary),
    durationMinutes: seed.durationMinutes,
    outcome: sameText(seed.outcome),
    codeSnippet: seed.codeSnippet,
    exampleOutput: seed.exampleOutput,
    keyPoints: seed.keyPoints.map(sameText).toList(growable: false),
    quizzes: <LessonQuiz>[quiz],
    codeTrainers: <CodeTrainer>[trainer],
    completionRequirements: <String>[quiz.id, trainer.id],
    promptSuggestion: sameText(seed.promptSuggestion),
    xpReward: seed.xpReward,
  );
}

PracticeTask buildPracticeFromSeed({
  required String trackId,
  required String moduleId,
  required DemoPracticeSeed seed,
}) {
  return PracticeTask(
    id: seed.id,
    trackId: trackId,
    moduleId: moduleId,
    title: sameText(seed.title),
    summary: sameText(seed.summary),
    brief: sameText(seed.brief),
    starterCode: seed.starterCode,
    successCriteria: seed.successCriteria.map(sameText).toList(growable: false),
    knowledgeChecks: seed.knowledgeChecks.map(sameText).toList(growable: false),
    promptSuggestion: sameText(seed.promptSuggestion),
    xpReward: seed.xpReward,
  );
}

CodeTrainer buildTrainerFromSeed({
  required String lessonId,
  required DemoTrainerSeed seed,
}) {
  switch (seed.kind) {
    case CodeTrainerKind.fillBlank:
      return CodeTrainer(
        id: '${lessonId}_trainer_1',
        title: sameText(seed.title),
        instruction: sameText(seed.instruction),
        kind: seed.kind,
        prompt: seed.prompt,
        template: seed.template,
        options: List<QuizOption>.generate(
          seed.options.length,
          (index) => QuizOption(
            id: 'option_$index',
            label: sameText(seed.options[index]),
          ),
        ),
        correctOptionId: 'option_${seed.correctIndex}',
      );
    case CodeTrainerKind.matchOutput:
      return CodeTrainer(
        id: '${lessonId}_trainer_1',
        title: sameText(seed.title),
        instruction: sameText(seed.instruction),
        kind: seed.kind,
        prompt: seed.prompt,
        options: List<QuizOption>.generate(
          seed.options.length,
          (index) => QuizOption(
            id: 'option_$index',
            label: sameText(seed.options[index]),
          ),
        ),
        correctOptionId: 'option_${seed.correctIndex}',
      );
    case CodeTrainerKind.reorderLines:
      final shuffled = List<String>.from(seed.orderedLines.reversed);
      return CodeTrainer(
        id: '${lessonId}_trainer_1',
        title: sameText(seed.title),
        instruction: sameText(seed.instruction),
        kind: seed.kind,
        prompt: seed.prompt,
        options: List<QuizOption>.generate(
          shuffled.length,
          (index) => QuizOption(
            id: 'line_$index',
            label: sameText(shuffled[index]),
          ),
        ),
        correctSequence: List<String>.generate(
          seed.orderedLines.length,
          (index) => shuffled.indexOf(seed.orderedLines[index]).toString(),
        ),
      );
  }
}

CommunityCourse buildCommunityCourse({
  required String id,
  required String title,
  required String subtitle,
  required String description,
  required String level,
  required double rating,
  required int enrollmentCount,
  required int estimatedHours,
  required Color color,
  required CommunityCourseAuthor author,
  required String categoryKey,
  required List<String> topicKeys,
  required List<String> searchKeywords,
  required bool isPopular,
  required bool isRecommended,
  required List<String> tags,
  required List<CommunityCourseLessonPreview> lessons,
  bool supportsCoursePlayer = false,
  List<String>? learningOutcomes,
  List<String>? audience,
  List<String>? requirements,
  List<CommunityCourseInstructor>? instructors,
  List<CommunityCourseModuleSection>? moduleSections,
  List<CoursePlayerModule>? coursePlayerModules,
  CommunityCourseReviewSummary? reviewSummary,
  List<CommunityCourseReview>? reviews,
  List<CommunityCourseUpdate>? updates,
  CommunityCourseFacts? facts,
  CommunityCourseOffer? offer,
}) {
  final resolvedInstructors =
      instructors ?? _defaultInstructors(author: author, title: title);
  final resolvedModules = moduleSections ??
      _defaultModuleSections(
        title: title,
        subtitle: subtitle,
        lessons: lessons,
      );
  final resolvedFacts = facts ??
      _defaultFacts(
        level: level,
        estimatedHours: estimatedHours,
        moduleSections: resolvedModules,
        hasCertificate: estimatedHours >= 5 || level != 'Beginner',
      );
  final resolvedReviewSummary = reviewSummary ??
      _defaultReviewSummary(
        rating: rating,
        enrollmentCount: enrollmentCount,
      );

  return CommunityCourse(
    id: id,
    title: sameText(title),
    subtitle: sameText(subtitle),
    description: sameText(description),
    level: level,
    rating: rating,
    enrollmentCount: enrollmentCount,
    estimatedHours: estimatedHours,
    color: color,
    author: author,
    categoryKey: categoryKey,
    topicKeys: topicKeys,
    searchKeywords: searchKeywords,
    isPopular: isPopular,
    isRecommended: isRecommended,
    tags: tags,
    lessons: lessons,
    heroBadge: tags.isEmpty ? level : tags.first,
    heroHeadline: 'Structured path into $title',
    learningOutcomes: learningOutcomes ??
        _defaultLearningOutcomes(
          title: title,
          subtitle: subtitle,
          tags: tags,
        ),
    audience: audience ?? _defaultAudience(title: title),
    requirements: requirements ?? _defaultRequirements(level: level),
    instructors: resolvedInstructors,
    moduleSections: resolvedModules,
    reviewSummary: resolvedReviewSummary,
    reviews: reviews ??
        _defaultReviews(
          title: title,
          author: author,
          summary: resolvedReviewSummary,
        ),
    updates: updates ?? _defaultUpdates(title: title),
    facts: resolvedFacts,
    offer: offer ??
        _defaultOffer(
          estimatedHours: estimatedHours,
          level: level,
        ),
    supportsCoursePlayer: supportsCoursePlayer,
    coursePlayerModules: coursePlayerModules ??
        _defaultCoursePlayerModules(
          id: id,
          title: title,
          subtitle: subtitle,
          tags: tags,
          lessons: lessons,
        ),
  );
}

List<String> _defaultLearningOutcomes({
  required String title,
  required String subtitle,
  required List<String> tags,
}) {
  return <String>[
    'Understand the core workflow behind $title and explain it in plain language.',
    'Apply the main patterns from "$subtitle" in small production-like scenarios.',
    'Recognize common mistakes earlier and review your own work with more confidence.',
    'Use ${tags.isEmpty ? 'course concepts' : tags.first} as a repeatable decision tool.',
    'Build a cleaner narrative for demos, interviews, and portfolio walkthroughs.',
    'Leave with a compact checklist you can reuse after the course ends.',
  ];
}

List<String> _defaultAudience({
  required String title,
}) {
  return <String>[
    'Learners who want a structured and calmer entry into $title.',
    'Students preparing portfolio demos, interviews, or a stronger first project.',
    'Engineers who want clearer mental models before going deeper into documentation.',
  ];
}

List<String> _defaultRequirements({
  required String level,
}) {
  final beginner = level == 'Beginner';
  return <String>[
    beginner
        ? 'No strict prerequisites beyond curiosity and consistency.'
        : 'Comfort with basic programming syntax and command-line navigation.',
    'A notebook or editor where you can repeat the examples and keep short notes.',
    'Readiness to move from examples into small hands-on exercises.',
  ];
}

List<CommunityCourseInstructor> _defaultInstructors({
  required CommunityCourseAuthor author,
  required String title,
}) {
  return <CommunityCourseInstructor>[
    CommunityCourseInstructor(
      id: author.id,
      name: author.name,
      role: author.role,
      bio:
          '${author.name} teaches $title with a product-minded focus on clarity, iteration, and confident delivery.',
      courseCount: author.courseCount,
      studentCount:
          author.studentCount == 0 ? author.followersCount * 8 : author.studentCount,
      rating: author.rating,
    ),
    CommunityCourseInstructor(
      id: '${author.id}_mentor_team',
      name: 'ZerdeStudy Mentor Team',
      role: 'Course Editors',
      bio:
          'The internal mentor team packages examples, reviews the explanations, and keeps each mock course presentation-ready.',
      courseCount: 12,
      studentCount: author.followersCount * 5,
      rating: 4.9,
    ),
  ];
}

List<CommunityCourseModuleSection> _defaultModuleSections({
  required String title,
  required String subtitle,
  required List<CommunityCourseLessonPreview> lessons,
}) {
  final previews = lessons.isNotEmpty
      ? lessons
      : <CommunityCourseLessonPreview>[
          buildCourseLesson(
            '$title: foundations',
            'Build the mental model and vocabulary you need before diving deeper.',
          ),
        ];

  final first = previews.first;
  final second = previews.length > 1 ? previews[1] : previews.first;
  final third = previews.length > 2 ? previews[2] : previews.last;

  return <CommunityCourseModuleSection>[
    CommunityCourseModuleSection(
      title: 'Orientation and foundations',
      description: 'Get aligned on the mental model, vocabulary, and learning flow.',
      items: <CommunityCourseModuleItem>[
        _moduleItemFromPreview(first, viewersBase: 2200, helpfulBase: 74),
        CommunityCourseModuleItem(
          title: 'Why this topic matters in real teams',
          durationLabel: '8 min',
          viewerCount: 1980,
          helpfulCount: 63,
        ),
      ],
    ),
    CommunityCourseModuleSection(
      title: 'Worked examples',
      description: 'Break down the examples and turn them into a repeatable routine.',
      items: <CommunityCourseModuleItem>[
        _moduleItemFromPreview(second, viewersBase: 1740, helpfulBase: 58),
        CommunityCourseModuleItem(
          title: 'Review checklist for $subtitle',
          durationLabel: '11 min',
          viewerCount: 1620,
          helpfulCount: 49,
        ),
      ],
    ),
    CommunityCourseModuleSection(
      title: 'Apply and extend',
      description: 'Practice the pattern, reflect on tradeoffs, and prepare a clean explanation.',
      items: <CommunityCourseModuleItem>[
        _moduleItemFromPreview(third, viewersBase: 1480, helpfulBase: 42),
        CommunityCourseModuleItem(
          title: 'Capstone walkthrough: from idea to confident delivery',
          durationLabel: '15 min',
          viewerCount: 1370,
          helpfulCount: 39,
        ),
      ],
    ),
  ];
}

CommunityCourseModuleItem _moduleItemFromPreview(
  CommunityCourseLessonPreview preview, {
  required int viewersBase,
  required int helpfulBase,
}) {
  return CommunityCourseModuleItem(
    title: preview.title.en,
    durationLabel: '${preview.durationMinutes} min',
    viewerCount: viewersBase,
    helpfulCount: helpfulBase,
  );
}

CommunityCourseReviewSummary _defaultReviewSummary({
  required double rating,
  required int enrollmentCount,
}) {
  final reviewCount = enrollmentCount > 0 ? (enrollmentCount / 3.8).round() : 120;
  final fiveStar = (reviewCount * 0.78).round();
  final fourStar = (reviewCount * 0.14).round();
  final threeStar = (reviewCount * 0.05).round();
  final twoStar = (reviewCount * 0.02).round();
  final oneStar = reviewCount - fiveStar - fourStar - threeStar - twoStar;

  return CommunityCourseReviewSummary(
    averageRating: rating,
    reviewCount: reviewCount,
    ratingDistribution: <int, int>{
      5: fiveStar,
      4: fourStar,
      3: threeStar,
      2: twoStar,
      1: oneStar,
    },
  );
}

List<CommunityCourseReview> _defaultReviews({
  required String title,
  required CommunityCourseAuthor author,
  required CommunityCourseReviewSummary summary,
}) {
  return <CommunityCourseReview>[
    CommunityCourseReview(
      id: '${author.id}_review_1',
      authorName: 'Aiman K.',
      timeLabel: '2 days ago',
      rating: 5,
      headline: 'Clear structure',
      text:
          'The $title flow feels compact but very usable. I especially liked how the examples moved into a practical checklist instead of staying abstract.',
    ),
    CommunityCourseReview(
      id: '${author.id}_review_2',
      authorName: 'Arman S.',
      timeLabel: '5 days ago',
      rating: 5,
      headline: 'Useful for demos',
      text:
          'This course helped me explain the topic aloud. The sequence from overview to examples to modules made the whole subject feel much more presentable.',
    ),
    CommunityCourseReview(
      id: '${author.id}_review_3',
      authorName: 'Dana Z.',
      timeLabel: '1 week ago',
      rating: summary.averageRating.round().clamp(4, 5),
      text:
          'I came in for quick revision and stayed because the structure was calm and focused. The review section and module list are especially helpful.',
    ),
  ];
}

List<CommunityCourseUpdate> _defaultUpdates({
  required String title,
}) {
  return <CommunityCourseUpdate>[
    CommunityCourseUpdate(
      id: '${title.hashCode}_update_1',
      title: 'Expanded examples',
      summary:
          'Added one more worked example and tightened the intro copy to make the first module easier to follow.',
      timeLabel: '3 days ago',
    ),
    CommunityCourseUpdate(
      id: '${title.hashCode}_update_2',
      title: 'Program refresh',
      summary:
          'Reordered the module sequence so the course moves from foundation into applied scenarios more smoothly.',
      timeLabel: '1 week ago',
    ),
    CommunityCourseUpdate(
      id: '${title.hashCode}_update_3',
      title: 'Review notes',
      summary:
          'Improved the lesson summaries and added stronger prompts for the final wrap-up sections.',
      timeLabel: '2 weeks ago',
    ),
  ];
}

CommunityCourseFacts _defaultFacts({
  required String level,
  required int estimatedHours,
  required List<CommunityCourseModuleSection> moduleSections,
  required bool hasCertificate,
}) {
  final lessonCount = moduleSections.fold<int>(
    0,
    (sum, section) => sum + section.items.length,
  );
  return CommunityCourseFacts(
    lessonCount: lessonCount,
    videoMinutes: estimatedHours * 52,
    assessmentCount: lessonCount + 4,
    interactiveCount: lessonCount * 3,
    languageLabel: 'English / Russian',
    hasCertificate: hasCertificate,
    certificateLabel:
        hasCertificate ? 'Certificate available' : 'No certificate in this edition',
    startModeLabel: level == 'Beginner' ? 'Start anytime' : 'Self-paced access',
  );
}

CommunityCourseOffer _defaultOffer({
  required int estimatedHours,
  required String level,
}) {
  final price = 1800 + (estimatedHours * 140) + (level == 'Advanced' ? 700 : 0);
  final split = (price / 4).round();
  return CommunityCourseOffer(
    priceLabel: '$price ₸',
    installmentLabel: '$split ₸ x 4 Split',
    secondaryInstallmentLabel: '$split ₸ x 4 Milestone',
    previewLabel: 'Open preview',
    favoriteLabel: 'Save course',
  );
}

CommunityCourseLessonPreview buildCourseLesson(
  String title,
  String summary, {
  int durationMinutes = 18,
}) {
  return CommunityCourseLessonPreview(
    title: sameText(title),
    summary: sameText(summary),
    durationMinutes: durationMinutes,
  );
}

LocalizedText sameText(String value) {
  return LocalizedText(
    ru: value,
    en: value,
    kk: value,
  );
}

LocalizedText localizedText(String ru, String en, String kk) {
  return LocalizedText(
    ru: ru,
    en: en,
    kk: kk,
  );
}

List<CoursePlayerModule> _defaultCoursePlayerModules({
  required String id,
  required String title,
  required String subtitle,
  required List<String> tags,
  required List<CommunityCourseLessonPreview> lessons,
}) {
  final topicTag = tags.isEmpty ? title : tags.first;
  final lessonSeeds = <CoursePlayerLesson>[
    CoursePlayerLesson(
      id: '${id}_player_lesson_1',
      title: sameText('Orientation'),
      annotation: sameText('We start with the key idea behind $title and the mental model you will reuse later.'),
      explanation: sameText(
        'This course treats $topicTag as a repeatable pattern: observe the problem, name the moving parts, and then apply a compact implementation.',
      ),
      codeSnippet: 'final goal = "$topicTag";\nfinal nextStep = "${subtitle.split(' ').first.toLowerCase()}";\nprint("Focus: \$goal -> \$nextStep");',
      exampleOutput: 'Focus: $topicTag -> ${subtitle.split(' ').first.toLowerCase()}',
      nextActionLabel: sameText('Continue to the first worked example'),
    ),
    CoursePlayerLesson(
      id: '${id}_player_lesson_2',
      title: sameText('Worked example'),
      annotation: sameText('A tiny example shows how the idea turns into a concrete, explainable action.'),
      explanation: sameText(
        'Notice the sequence: define a small input, transform it once, and print a result that can be checked immediately. This keeps the explanation calm and presentation-friendly.',
      ),
      codeSnippet: 'final items = ["observe", "reason", "ship"];\nfinal summary = items.join(" -> ");\nprint(summary);',
      exampleOutput: 'observe -> reason -> ship',
      nextActionLabel: sameText('Move to the practice checkpoint'),
    ),
    CoursePlayerLesson(
      id: '${id}_player_lesson_3',
      title: sameText('Practice checkpoint'),
      annotation: sameText('You now connect the concept to a real team scenario and prepare for the task view.'),
      explanation: sameText(
        'Before moving into assignments, summarize the technique in one sentence and name one place where your team could use it this week.',
      ),
      codeSnippet: 'String explainPattern(String domain) {\n  return "Use a small loop: learn, test, and refine in \$domain.";\n}\n\nprint(explainPattern("$title"));',
      exampleOutput: 'Use a small loop: learn, test, and refine in $title.',
      nextActionLabel: sameText('Open the assignment block'),
    ),
  ];

  return <CoursePlayerModule>[
    CoursePlayerModule(
      id: '${id}_player_module_1',
      title: sameText('Launch pad'),
      summary: sameText('Start with the concept, one worked example, and a practice-oriented wrap-up.'),
      lessons: lessonSeeds,
    ),
    CoursePlayerModule(
      id: '${id}_player_module_2',
      title: sameText('Task bridge'),
      summary: sameText('Use the final lesson list as a checklist for your independent task flow.'),
      lessons: List<CoursePlayerLesson>.generate(
        lessons.length,
        (index) {
          final preview = lessons[index];
          return CoursePlayerLesson(
            id: '${id}_player_bridge_${index + 1}',
            title: preview.title,
            annotation: preview.summary,
            explanation: sameText(
              'This bridge lesson keeps the authored course language intact while giving you a short explanation and a safe next step into tasks.',
            ),
            codeSnippet:
                'final topic = "${preview.title.en}";\nprint("Ready for: \$topic");',
            exampleOutput: 'Ready for: ${preview.title.en}',
            nextActionLabel: sameText('Continue to the next lesson'),
          );
        },
      ),
    ),
  ];
}
