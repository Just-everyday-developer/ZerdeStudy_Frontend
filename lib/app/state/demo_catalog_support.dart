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
  final previewLessons = lessons.isEmpty
      ? <CommunityCourseLessonPreview>[
          buildCourseLesson(
            '$title foundations',
            'Build the core model before going deeper.',
          ),
          buildCourseLesson(
            '$title worked example',
            'Walk through one practical example and narrate it clearly.',
          ),
          buildCourseLesson(
            '$title practice bridge',
            'Move into exercises, feedback, and repetition.',
          ),
        ]
      : lessons;

  CoursePlayerLesson buildLesson({
    required String lessonId,
    required String lessonTitle,
    required String annotation,
    required String explanation,
    required String objective,
    required String videoLabel,
    required String imageCaption,
    required String codeSnippet,
    required String exampleOutput,
    required String nextAction,
    required List<CoursePlayerExercise> exercises,
  }) {
    return CoursePlayerLesson(
      id: lessonId,
      title: sameText(lessonTitle),
      annotation: sameText(annotation),
      explanation: sameText(explanation),
      objective: sameText(objective),
      videoLabel: videoLabel,
      imageCaption: imageCaption,
      codeSnippet: codeSnippet,
      exampleOutput: exampleOutput,
      comments: _defaultCourseComments(title, lessonTitle),
      exercises: exercises,
      nextActionLabel: sameText(nextAction),
    );
  }

  return <CoursePlayerModule>[
    CoursePlayerModule(
      id: '${id}_player_module_1',
      title: sameText('Concept and examples'),
      summary: sameText(
        'Start with a mental model, watch one walkthrough, and then validate the core idea with interactive checks.',
      ),
      lessons: <CoursePlayerLesson>[
        buildLesson(
          lessonId: '${id}_player_lesson_1',
          lessonTitle: previewLessons[0].title.en,
          annotation:
              'Start with the foundation behind $title and turn it into a reusable explanation.',
          explanation:
              'Treat $topicTag as a small repeatable loop: understand the input, apply one transformation, and explain the visible result in plain language.',
          objective:
              'By the end of this step, you should be able to explain the purpose of $title in one clear sentence.',
          videoLabel: 'Intro walkthrough • 06:24',
          imageCaption: 'A concept map showing how $topicTag moves from idea to implementation.',
          codeSnippet:
              'final topic = "$topicTag";\nconst stage = "foundation";\nprint("\$topic -> \$stage");',
          exampleOutput: '$topicTag -> foundation',
          nextAction: 'Move into the first worked example.',
          exercises: <CoursePlayerExercise>[
            CoursePlayerExercise(
              id: '${id}_exercise_1',
              kind: CourseExerciseKind.singleChoice,
              title: sameText('Core idea'),
              prompt: sameText('What is the main goal of the first lesson?'),
              description: 'Choose the explanation that best matches the lesson objective.',
              points: 10,
              choices: const <CourseExerciseChoice>[
                CourseExerciseChoice(id: 'a', label: 'Memorize every line without understanding the flow'),
                CourseExerciseChoice(id: 'b', label: 'Build a small mental model and explain the pattern clearly'),
                CourseExerciseChoice(id: 'c', label: 'Skip the concept and jump directly into advanced optimization'),
              ],
              correctChoiceIds: const <String>['b'],
            ),
            CoursePlayerExercise(
              id: '${id}_exercise_2',
              kind: CourseExerciseKind.fillBlank,
              title: sameText('Fill the blank'),
              prompt: sameText('Complete the output label used in the code example.'),
              description: 'Type the missing word exactly as it should appear.',
              points: 8,
              blankTemplate: 'print("$topicTag -> ____");',
              correctText: 'foundation',
            ),
          ],
        ),
        buildLesson(
          lessonId: '${id}_player_lesson_2',
          lessonTitle: previewLessons.length > 1
              ? previewLessons[1].title.en
              : 'Worked example',
          annotation:
              'Walk through one example and connect the explanation to visible state changes.',
          explanation:
              'A reliable explanation starts with the initial value, continues with the transformation, and ends by reading the final output aloud.',
          objective:
              'You should be able to read the example from top to bottom and predict the final result.',
          videoLabel: 'Example breakdown • 08:10',
          imageCaption: 'A layered diagram where input, transformation, and output are grouped into a clean flow.',
          codeSnippet:
              'final items = ["observe", "reason", "ship"];\nfinal summary = items.join(" -> ");\nprint(summary);',
          exampleOutput: 'observe -> reason -> ship',
          nextAction: 'Check how the sequence changes and then continue into practice.',
          exercises: <CoursePlayerExercise>[
            CoursePlayerExercise(
              id: '${id}_exercise_3',
              kind: CourseExerciseKind.matching,
              title: sameText('Match the flow'),
              prompt: sameText('Match each code part with its role.'),
              description: 'Pick the correct pair for every step in the example.',
              points: 12,
              leftItems: const <String>['items', 'join(" -> ")', 'print(summary)'],
              rightItems: const <String>['shows the final string', 'holds the starting values', 'combines the list into one line'],
              correctMatches: const <String, String>{
                'items': 'holds the starting values',
                'join(" -> ")': 'combines the list into one line',
                'print(summary)': 'shows the final string',
              },
            ),
            CoursePlayerExercise(
              id: '${id}_exercise_4',
              kind: CourseExerciseKind.dragDrop,
              title: sameText('Build the order'),
              prompt: sameText('Arrange the explanation in the correct order.'),
              description: 'Place the steps from first to last.',
              points: 10,
              draggableItems: const <String>[
                'Read the final output',
                'Notice the starting values',
                'Explain the transformation',
              ],
              correctOrder: const <String>[
                'Notice the starting values',
                'Explain the transformation',
                'Read the final output',
              ],
            ),
          ],
        ),
        buildLesson(
          lessonId: '${id}_player_lesson_3',
          lessonTitle: previewLessons.length > 2
              ? previewLessons[2].title.en
              : 'Practice bridge',
          annotation:
              'Turn the concept into a task-ready habit and prepare for repetition.',
          explanation:
              'Before leaving the lesson, describe the pattern in one sentence and fill in the missing code so the output still matches your explanation.',
          objective:
              'You should be ready to move into exercises, comments, and repeat only the parts that were incorrect.',
          videoLabel: 'Practice bridge • 07:42',
          imageCaption: 'A compact checklist showing explanation, implementation, and review.',
          codeSnippet:
              'String explainPattern(String domain) {\n  return "Use a small loop: learn, test, and refine in \$domain.";\n}\n\nprint(explainPattern("$title"));',
          exampleOutput: 'Use a small loop: learn, test, and refine in $title.',
          nextAction: 'Complete the final code checks and open the next module.',
          exercises: <CoursePlayerExercise>[
            CoursePlayerExercise(
              id: '${id}_exercise_5',
              kind: CourseExerciseKind.codeInput,
              title: sameText('Complete the code'),
              prompt: sameText('Type the missing method name so the code prints the expected output.'),
              description: 'Enter only the missing token.',
              points: 14,
              codeTemplate:
                  'String explainPattern(String domain) {\n  return "Use a small loop: learn, test, and refine in \$domain.";\n}\n\nprint(________("$title"));',
              correctCodeToken: 'explainPattern',
            ),
            CoursePlayerExercise(
              id: '${id}_exercise_6',
              kind: CourseExerciseKind.multipleChoice,
              title: sameText('Review the lesson'),
              prompt: sameText('Which habits make the walkthrough easier to present?'),
              description: 'Choose all correct options.',
              points: 12,
              choices: const <CourseExerciseChoice>[
                CourseExerciseChoice(id: 'a', label: 'Read the input, transformation, and output in order'),
                CourseExerciseChoice(id: 'b', label: 'Skip the visible result and focus only on syntax'),
                CourseExerciseChoice(id: 'c', label: 'Use one clear sentence to summarize the pattern'),
                CourseExerciseChoice(id: 'd', label: 'Ignore mistakes instead of revisiting them'),
              ],
              correctChoiceIds: const <String>['a', 'c'],
            ),
          ],
        ),
      ],
    ),
    CoursePlayerModule(
      id: '${id}_player_module_2',
      title: sameText('Assignments and reflection'),
      summary: sameText(
        'Use the same rhythm again with authored lesson names, then reflect on mistakes and finish the course with a stronger narrative.',
      ),
      lessons: List<CoursePlayerLesson>.generate(
        previewLessons.length,
        (index) {
          final preview = previewLessons[index];
          return buildLesson(
            lessonId: '${id}_player_bridge_${index + 1}',
            lessonTitle: preview.title.en,
            annotation: preview.summary.en,
            explanation:
                'This bridge lesson keeps the authored course voice but adds one more explanation, one more visual cue, and a final exercise that checks transfer.',
            objective:
                'Connect the authored topic to a practical task you can explain without switching screens.',
            videoLabel: 'Module preview • 05:${index + 3}0',
            imageCaption: 'A visual note for ${preview.title.en} showing how the topic maps into a repeatable task.',
            codeSnippet:
                'final topic = "${preview.title.en}";\nfinal checkpoint = ${index + 1};\nprint("Ready for \$topic #\$checkpoint");',
            exampleOutput: 'Ready for ${preview.title.en} #${index + 1}',
            nextAction: 'Continue to the next lesson and keep the same explanation loop.',
            exercises: <CoursePlayerExercise>[
              CoursePlayerExercise(
                id: '${id}_bridge_exercise_${index + 1}_a',
                kind: CourseExerciseKind.singleChoice,
                title: sameText('Transfer check'),
                prompt: sameText('What is the best way to approach ${preview.title.en}?'),
                description: 'Choose the option that preserves the same rhythm from earlier lessons.',
                points: 8,
                choices: <CourseExerciseChoice>[
                  CourseExerciseChoice(id: 'a', label: 'Jump into the deepest edge case first'),
                  CourseExerciseChoice(id: 'b', label: 'Start with one example, explain the output, then move into practice'),
                  CourseExerciseChoice(id: 'c', label: 'Avoid reviewing the result after running the code'),
                ],
                correctChoiceIds: const <String>['b'],
              ),
              CoursePlayerExercise(
                id: '${id}_bridge_exercise_${index + 1}_b',
                kind: CourseExerciseKind.fillBlank,
                title: sameText('Output phrase'),
                prompt: sameText('Fill the final number used in the output.'),
                description: 'Type the checkpoint number from the code block.',
                points: 6,
                blankTemplate:
                    'print("Ready for ${preview.title.en} #__");',
                correctText: '${index + 1}',
              ),
            ],
          );
        },
      ),
    ),
  ];
}

List<CoursePlayerComment> _defaultCourseComments(String courseTitle, String lessonTitle) {
  return <CoursePlayerComment>[
    CoursePlayerComment(
      id: '${courseTitle.hashCode}_${lessonTitle.hashCode}_1',
      authorName: 'Aruzhan B.',
      role: 'Frontend learner',
      message:
          'I remembered this lesson faster when I said the input and output out loud before looking at the code.',
    ),
    CoursePlayerComment(
      id: '${courseTitle.hashCode}_${lessonTitle.hashCode}_2',
      authorName: 'Nursultan K.',
      role: 'Backend student',
      message:
          'The visual block helped me connect the concept to the code example. I would revisit the matching exercise once after finishing.',
    ),
    CoursePlayerComment(
      id: '${courseTitle.hashCode}_${lessonTitle.hashCode}_3',
      authorName: 'Dana S.',
      role: 'Mentor note',
      message:
          'If the output feels confusing, trace only one change at a time and keep the explanation short.',
    ),
  ];
}
