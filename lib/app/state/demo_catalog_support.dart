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
  required List<String> tags,
  required List<CommunityCourseLessonPreview> lessons,
}) {
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
    tags: tags,
    lessons: lessons,
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
