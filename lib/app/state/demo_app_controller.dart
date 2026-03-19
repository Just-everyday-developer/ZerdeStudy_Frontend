import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';
import 'app_theme_mode.dart';
import 'demo_app_state.dart';
import 'demo_catalog.dart';
import 'demo_models.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider must be overridden.');
});

final demoCatalogProvider = Provider<DemoCatalog>((ref) => DemoCatalog());

final demoAppControllerProvider =
    NotifierProvider<DemoAppController, DemoAppState>(DemoAppController.new);

class DemoAppController extends Notifier<DemoAppState> {
  static const String _storageKey = 'zerdestudy_demo_state_v4';

  late final SharedPreferences _preferences;
  late final DemoCatalog _catalog;

  @override
  DemoAppState build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    _catalog = ref.watch(demoCatalogProvider);

    final savedState = _preferences.getString(_storageKey);
    if (savedState == null || savedState.isEmpty) {
      return _withDerived(_seedState());
    }

    try {
      return _withDerived(
        DemoAppState.fromJson(
          jsonDecode(savedState) as Map<String, dynamic>,
        ),
      );
    } catch (_) {
      return _withDerived(_seedState());
    }
  }

  void loginWithEmail({
    required String email,
    String? name,
  }) {
    state = _withDerived(
      state.copyWith(
        isAuthenticated: true,
        user: _createUser(
          name: name,
          email: email,
          goal: state.user?.goal ?? 'Build confidence across CS Core and IT Spheres',
        ),
      ),
    );
    _persist();
  }

  void loginWithProvider(String providerLabel) {
    final normalized = providerLabel.toLowerCase().trim();
    final providerName = providerLabel.isEmpty
        ? 'Demo'
        : providerLabel[0].toUpperCase() + providerLabel.substring(1);

    state = _withDerived(
      state.copyWith(
        isAuthenticated: true,
        user: _createUser(
          name: 'Talgat',
          email: '${normalized.isEmpty ? 'demo' : normalized}@zerdestudy.app',
          goal: 'Reach a polished presentation flow across all branches',
          role: '$providerName learner',
        ),
      ),
    );
    _persist();
  }

  void logout() {
    state = _withDerived(
      state.copyWith(
        isAuthenticated: false,
        user: null,
      ),
    );
    _persist();
  }

  void changeLocale(AppLocale locale) {
    state = _withDerived(state.copyWith(locale: locale));
    _persist();
  }

  void changeThemeMode(AppThemeMode themeMode) {
    state = _withDerived(state.copyWith(themeMode: themeMode));
    _persist();
  }

  void recordHistoryEntry(LearningHistoryEntry entry) {
    state = _withDerived(
      state.copyWith(
        learningHistory: <LearningHistoryEntry>[
          entry,
          ...state.learningHistory,
        ],
      ),
    );
    _persist();
  }

  void setCurrentTrack(String trackId) {
    state = _withDerived(
      state.copyWith(
        currentTrackId: trackId,
        focusedLessonId: null,
        focusedPracticeId: null,
      ),
    );
    _persist();
  }

  void focusLesson(String lessonId) {
    final lesson = _catalog.lessonById(lessonId);
    state = _withDerived(
      state.copyWith(
        currentTrackId: lesson.trackId,
        focusedLessonId: lessonId,
        focusedPracticeId: null,
      ),
    );
    _persist();
  }

  void focusPractice(String practiceId) {
    final practice = _catalog.practiceById(practiceId);
    state = _withDerived(
      state.copyWith(
        currentTrackId: practice.trackId,
        focusedLessonId: null,
        focusedPracticeId: practiceId,
      ),
    );
    _persist();
  }

  void completeQuiz(String quizId, {required bool isCorrect}) {
    final quizStats = Map<String, QuizAnswerStat>.from(state.quizAnswerStats);
    final previous = quizStats[quizId] ??
        const QuizAnswerStat(
          attempts: 0,
          correctAnswers: 0,
        );
    quizStats[quizId] = previous.copyWith(
      attempts: previous.attempts + 1,
      correctAnswers: previous.correctAnswers + (isCorrect ? 1 : 0),
    );

    var completedQuizIds = Set<String>.from(state.completedQuizIds);
    var xp = state.xp;
    if (isCorrect && !completedQuizIds.contains(quizId)) {
      completedQuizIds = completedQuizIds..add(quizId);
      xp += 6;
    }

    state = _withDerived(
      state.copyWith(
        completedQuizIds: completedQuizIds,
        quizAnswerStats: quizStats,
        xp: xp,
      ),
    );
    _persist();
  }

  void completeTrainer(String trainerId) {
    if (state.completedTrainerIds.contains(trainerId)) {
      return;
    }

    final completedTrainerIds = Set<String>.from(state.completedTrainerIds)
      ..add(trainerId);

    state = _withDerived(
      state.copyWith(
        completedTrainerIds: completedTrainerIds,
        xp: state.xp + 8,
      ),
    );
    _persist();
  }

  void completeLesson(String lessonId) {
    if (state.completedLessonIds.contains(lessonId)) {
      return;
    }

    final previousState = state;
    final lesson = _catalog.lessonById(lessonId);
    if (!_catalog.lessonRequirementsMet(state, lessonId)) {
      return;
    }

    final completedLessonIds = Set<String>.from(state.completedLessonIds)
      ..add(lessonId);

    final candidate = previousState.copyWith(
        currentTrackId: lesson.trackId,
        completedLessonIds: completedLessonIds,
        xp: previousState.xp + lesson.xpReward,
        streak: previousState.streak + 1,
        dailyMissionDone: true,
        focusedLessonId: lessonId,
        focusedPracticeId: null,
        weeklyActivity: _bumpToday(previousState.weeklyActivity),
      );

    state = _withDerived(
      candidate.copyWith(
        learningHistory: <LearningHistoryEntry>[
          ..._completionHistoryEntriesForLesson(previousState, candidate, lesson),
          ...previousState.learningHistory,
        ],
      ),
    );
    _persist();
  }

  void completePractice(String practiceId) {
    if (state.completedPracticeIds.contains(practiceId)) {
      return;
    }

    final previousState = state;
    final practice = _catalog.practiceById(practiceId);
    final completedPracticeIds = Set<String>.from(state.completedPracticeIds)
      ..add(practiceId);

    final candidate = previousState.copyWith(
        currentTrackId: practice.trackId,
        completedPracticeIds: completedPracticeIds,
        xp: previousState.xp + practice.xpReward,
        streak: previousState.streak + 1,
        dailyMissionDone: true,
        focusedPracticeId: practiceId,
        focusedLessonId: null,
        weeklyActivity: _bumpToday(previousState.weeklyActivity),
      );

    state = _withDerived(
      candidate.copyWith(
        learningHistory: <LearningHistoryEntry>[
          ..._completionHistoryEntriesForPractice(
            previousState,
            candidate,
            practice,
          ),
          ...previousState.learningHistory,
        ],
      ),
    );
    _persist();
  }

  void viewCommunityCourse(String courseId) {
    if (state.viewedCommunityCourseIds.contains(courseId)) {
      return;
    }

    final viewedCommunityCourseIds =
        Set<String>.from(state.viewedCommunityCourseIds)..add(courseId);

    state = _withDerived(
      state.copyWith(
        viewedCommunityCourseIds: viewedCommunityCourseIds,
        xp: state.xp + 4,
      ),
    );
    _persist();
  }

  void saveCommunityCourse(String courseId) {
    if (state.savedCommunityCourseIds.contains(courseId)) {
      return;
    }

    final savedCommunityCourseIds =
        Set<String>.from(state.savedCommunityCourseIds)..add(courseId);

    final course = _catalog.courseById(courseId);
    state = _withDerived(
      state.copyWith(
        savedCommunityCourseIds: savedCommunityCourseIds,
        xp: state.xp + 10,
        learningHistory: <LearningHistoryEntry>[
          LearningHistoryEntry(
            id: 'history-course-${DateTime.now().microsecondsSinceEpoch}',
            kind: LearningHistoryKind.courseSaved,
            title: 'Saved community course',
            subtitle: course.title.resolve(state.locale),
            createdAt: DateTime.now(),
            refId: course.id,
          ),
          ...state.learningHistory,
        ],
      ),
    );
    _persist();
  }

  TrackAssessmentResult submitTrackAssessment({
    required String trackId,
    required Map<String, String> selectedOptionIds,
  }) {
    final previousState = state;
    final assessment = _catalog.trackById(trackId).assessment!;
    final correctAnswers = assessment.questions
        .where(
          (question) => selectedOptionIds[question.id] == question.correctOptionId,
        )
        .length;
    final totalQuestions = assessment.questions.length;
    final percent = ((correctAnswers / totalQuestions) * 100).round();
    final passed = percent >= assessment.passPercent;
    final timestamp = DateTime.now();
    final attempt = AssessmentAttemptEntry(
      trackId: trackId,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      percent: percent,
      passed: passed,
      completedAt: timestamp,
    );

    final previousResult = previousState.assessmentResultsByTrackId[trackId];
    final isBest = previousResult == null || percent >= previousResult.bestPercent;
    final result = TrackAssessmentResult(
      trackId: trackId,
      bestPercent: isBest ? percent : previousResult.bestPercent,
      lastPercent: percent,
      bestCorrectAnswers:
          isBest ? correctAnswers : previousResult.bestCorrectAnswers,
      lastCorrectAnswers: correctAnswers,
      attemptCount: (previousResult?.attemptCount ?? 0) + 1,
      lastAttemptAt: timestamp,
      lastPassed: passed,
      history: <AssessmentAttemptEntry>[
        attempt,
        ...(previousResult?.history ?? const <AssessmentAttemptEntry>[]),
      ],
    );

    final updatedResults =
        Map<String, TrackAssessmentResult>.from(previousState.assessmentResultsByTrackId)
          ..[trackId] = result;
    final updatedAttemptHistory = <AssessmentAttemptEntry>[
      attempt,
      ...previousState.assessmentAttemptHistory,
    ];
    final updatedHistory = <LearningHistoryEntry>[
      LearningHistoryEntry(
        id: 'history-assessment-${timestamp.microsecondsSinceEpoch}',
        kind: LearningHistoryKind.assessmentCompleted,
        title: 'Track assessment completed',
        subtitle: _catalog.trackById(trackId).title.resolve(previousState.locale),
        scoreLabel: '$correctAnswers/$totalQuestions | $percent%',
        createdAt: timestamp,
        trackId: trackId,
        refId: assessment.id,
      ),
      ...previousState.learningHistory,
    ];

    state = _withDerived(
      previousState.copyWith(
        assessmentResultsByTrackId: updatedResults,
        assessmentAttemptHistory: updatedAttemptHistory,
        learningHistory: updatedHistory,
        xp: previousState.xp + (passed ? 24 : 10),
        dailyMissionDone: true,
        weeklyActivity: _bumpToday(previousState.weeklyActivity),
      ),
    );
    _persist();
    return result;
  }

  void sendAiMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final timestamp = DateTime.now();
    final messages = List<AiMessage>.from(state.aiMessages)
      ..add(
        AiMessage(
          id: 'user-${timestamp.microsecondsSinceEpoch}',
          author: AiAuthor.user,
          text: trimmed,
          createdAt: timestamp,
        ),
      )
      ..add(
        AiMessage(
          id: 'mentor-${timestamp.microsecondsSinceEpoch}',
          author: AiAuthor.mentor,
          text: _catalog.mentorReply(state, trimmed),
          createdAt: timestamp.add(const Duration(milliseconds: 320)),
        ),
      );

    state = _withDerived(
      state.copyWith(
        aiMessages: messages,
        xp: state.xp + 2,
      ),
    );
    _persist();
  }

  void resetDemo() {
    final locale = state.locale;
    final themeMode = state.themeMode;
    final currentUser = state.user ??
        _createUser(
          email: 'demo@zerdestudy.app',
        );
    final seeded = _seedState().copyWith(
      locale: locale,
      themeMode: themeMode,
      isAuthenticated: true,
      user: currentUser,
    );

    state = _withDerived(seeded);
    _persist();
  }

  DemoAppState _seedState() {
    return DemoAppState(
      locale: AppLocale.ru,
      themeMode: AppThemeMode.dark,
      isAuthenticated: false,
      user: null,
      currentTrackId: 'fundamentals',
      focusedLessonId: 'fundamentals_lesson_1_2',
      focusedPracticeId: null,
      completedLessonIds: <String>{
        'fundamentals_lesson_1_1',
        'frontend_lesson_1_1',
        'operating_systems_lesson_1_1',
      },
      completedPracticeIds: <String>{
        'frontend_practice_1',
      },
      completedQuizIds: <String>{
        'fundamentals_lesson_1_1_quiz_1',
        'frontend_lesson_1_1_quiz_1',
        'operating_systems_lesson_1_1_quiz_1',
      },
      completedTrainerIds: <String>{
        'fundamentals_lesson_1_1_trainer_1',
        'frontend_lesson_1_1_trainer_1',
        'operating_systems_lesson_1_1_trainer_1',
      },
      quizAnswerStats: <String, QuizAnswerStat>{
        'fundamentals_lesson_1_1_quiz_1': const QuizAnswerStat(
          attempts: 1,
          correctAnswers: 1,
        ),
        'frontend_lesson_1_1_quiz_1': const QuizAnswerStat(
          attempts: 2,
          correctAnswers: 1,
        ),
        'operating_systems_lesson_1_1_quiz_1': const QuizAnswerStat(
          attempts: 1,
          correctAnswers: 1,
        ),
      },
      assessmentResultsByTrackId: <String, TrackAssessmentResult>{
        'fundamentals': TrackAssessmentResult(
          trackId: 'fundamentals',
          bestPercent: 80,
          lastPercent: 80,
          bestCorrectAnswers: 8,
          lastCorrectAnswers: 8,
          attemptCount: 1,
          lastAttemptAt: DateTime(2026, 3, 16, 11, 20),
          lastPassed: true,
          history: <AssessmentAttemptEntry>[
            AssessmentAttemptEntry(
              trackId: 'fundamentals',
              correctAnswers: 8,
              totalQuestions: 10,
              percent: 80,
              passed: true,
              completedAt: DateTime(2026, 3, 16, 11, 20),
            ),
          ],
        ),
        'frontend': TrackAssessmentResult(
          trackId: 'frontend',
          bestPercent: 70,
          lastPercent: 70,
          bestCorrectAnswers: 7,
          lastCorrectAnswers: 7,
          attemptCount: 1,
          lastAttemptAt: DateTime(2026, 3, 17, 10, 0),
          lastPassed: true,
          history: <AssessmentAttemptEntry>[
            AssessmentAttemptEntry(
              trackId: 'frontend',
              correctAnswers: 7,
              totalQuestions: 10,
              percent: 70,
              passed: true,
              completedAt: DateTime(2026, 3, 17, 10, 0),
            ),
          ],
        ),
      },
      assessmentAttemptHistory: <AssessmentAttemptEntry>[
        AssessmentAttemptEntry(
          trackId: 'frontend',
          correctAnswers: 7,
          totalQuestions: 10,
          percent: 70,
          passed: true,
          completedAt: DateTime(2026, 3, 17, 10, 0),
        ),
        AssessmentAttemptEntry(
          trackId: 'fundamentals',
          correctAnswers: 8,
          totalQuestions: 10,
          percent: 80,
          passed: true,
          completedAt: DateTime(2026, 3, 16, 11, 20),
        ),
      ],
      learningHistory: <LearningHistoryEntry>[
        LearningHistoryEntry(
          id: 'history-seed-assessment-frontend',
          kind: LearningHistoryKind.assessmentCompleted,
          title: 'Track assessment completed',
          subtitle: 'Frontend',
          scoreLabel: '7/10 | 70%',
          createdAt: DateTime(2026, 3, 17, 10, 0),
          trackId: 'frontend',
          refId: 'frontend_assessment',
        ),
        LearningHistoryEntry(
          id: 'history-seed-lesson-front',
          kind: LearningHistoryKind.lessonCompleted,
          title: 'Lesson completed',
          subtitle: 'UI structure and semantic HTML',
          createdAt: DateTime(2026, 3, 17, 9, 20),
          trackId: 'frontend',
          refId: 'frontend_lesson_1_1',
        ),
        LearningHistoryEntry(
          id: 'history-seed-course-saved',
          kind: LearningHistoryKind.courseSaved,
          title: 'Saved community course',
          subtitle: 'ML Journal Club Lite',
          createdAt: DateTime(2026, 3, 16, 14, 15),
          refId: 'course_ml_journal_club',
        ),
      ],
      viewedCommunityCourseIds: <String>{
        'course_portfolio_engineering',
        'course_sql_for_analysts',
      },
      savedCommunityCourseIds: <String>{
        'course_ml_journal_club',
      },
      xp: 468,
      streak: 7,
      dailyMissionDone: false,
      weeklyActivity: <int>[2, 4, 3, 5, 4, 6, 2],
      aiMessages: <AiMessage>[
        AiMessage(
          id: 'mentor-seed',
          author: AiAuthor.mentor,
          text:
              'I can walk through CS Core topics, explain code output, and help you narrate the demo with clear next steps.',
          createdAt: DateTime(2026, 3, 16, 9, 0),
        ),
      ],
      unlockedAchievementIds: <String>{'first_step'},
    );
  }

  DemoAppState _withDerived(DemoAppState candidate) {
    return candidate.copyWith(
      unlockedAchievementIds: _catalog.unlockedAchievementIdsFor(candidate),
    );
  }

  DemoUser _createUser({
    String? name,
    required String email,
    String? goal,
    String? role,
  }) {
    return DemoUser(
      name: (name == null || name.trim().isEmpty) ? 'Talgat' : name.trim(),
      email: email.trim(),
      role: role ?? 'Student Explorer',
      goal: goal ?? 'Cover the full demo without dead ends',
    );
  }

  List<int> _bumpToday(List<int> values) {
    final updated = List<int>.from(values);
    if (updated.isEmpty) {
      return <int>[1];
    }
    updated[updated.length - 1] = updated.last + 1;
    return updated;
  }

  List<LearningHistoryEntry> _completionHistoryEntriesForLesson(
    DemoAppState previousState,
    DemoAppState nextState,
    LessonItem lesson,
  ) {
    final module = _catalog
        .trackById(lesson.trackId)
        .modules
        .firstWhere((item) => item.id == lesson.moduleId);
    final timestamp = DateTime.now();
    final entries = <LearningHistoryEntry>[
      LearningHistoryEntry(
        id: 'history-lesson-${timestamp.microsecondsSinceEpoch}',
        kind: LearningHistoryKind.lessonCompleted,
        title: 'Lesson completed',
        subtitle: lesson.title.resolve(previousState.locale),
        createdAt: timestamp,
        trackId: lesson.trackId,
        refId: lesson.id,
      ),
    ];

    if (!_isModuleCompleted(previousState, module) && _isModuleCompleted(nextState, module)) {
      entries.add(
        LearningHistoryEntry(
          id: 'history-module-${timestamp.microsecondsSinceEpoch}',
          kind: LearningHistoryKind.moduleCompleted,
          title: 'Module completed',
          subtitle: module.title.resolve(previousState.locale),
          createdAt: timestamp,
          trackId: lesson.trackId,
          refId: module.id,
        ),
      );
    }
    if (!_isTrackCompleted(previousState, lesson.trackId) &&
        _isTrackCompleted(nextState, lesson.trackId)) {
      entries.add(
        LearningHistoryEntry(
          id: 'history-track-${timestamp.microsecondsSinceEpoch}',
          kind: LearningHistoryKind.trackCompleted,
          title: 'Track completed',
          subtitle: _catalog.trackById(lesson.trackId).title.resolve(previousState.locale),
          createdAt: timestamp,
          trackId: lesson.trackId,
          refId: lesson.trackId,
        ),
      );
    }
    return entries;
  }

  List<LearningHistoryEntry> _completionHistoryEntriesForPractice(
    DemoAppState previousState,
    DemoAppState nextState,
    PracticeTask practice,
  ) {
    final module = _catalog
        .trackById(practice.trackId)
        .modules
        .firstWhere((item) => item.id == practice.moduleId);
    final timestamp = DateTime.now();
    final entries = <LearningHistoryEntry>[
      LearningHistoryEntry(
        id: 'history-practice-${timestamp.microsecondsSinceEpoch}',
        kind: LearningHistoryKind.practiceCompleted,
        title: 'Practice completed',
        subtitle: practice.title.resolve(previousState.locale),
        createdAt: timestamp,
        trackId: practice.trackId,
        refId: practice.id,
      ),
    ];

    if (!_isModuleCompleted(previousState, module) && _isModuleCompleted(nextState, module)) {
      entries.add(
        LearningHistoryEntry(
          id: 'history-module-${timestamp.microsecondsSinceEpoch}',
          kind: LearningHistoryKind.moduleCompleted,
          title: 'Module completed',
          subtitle: module.title.resolve(previousState.locale),
          createdAt: timestamp,
          trackId: practice.trackId,
          refId: module.id,
        ),
      );
    }
    if (!_isTrackCompleted(previousState, practice.trackId) &&
        _isTrackCompleted(nextState, practice.trackId)) {
      entries.add(
        LearningHistoryEntry(
          id: 'history-track-${timestamp.microsecondsSinceEpoch}',
          kind: LearningHistoryKind.trackCompleted,
          title: 'Track completed',
          subtitle:
              _catalog.trackById(practice.trackId).title.resolve(previousState.locale),
          createdAt: timestamp,
          trackId: practice.trackId,
          refId: practice.trackId,
        ),
      );
    }
    return entries;
  }

  bool _isModuleCompleted(DemoAppState candidate, LearningModule module) {
    final lessonsDone = module.lessons.every(
      (lesson) => candidate.completedLessonIds.contains(lesson.id),
    );
    final practiceDone = module.practice == null ||
        candidate.completedPracticeIds.contains(module.practice!.id);
    return lessonsDone && practiceDone;
  }

  bool _isTrackCompleted(DemoAppState candidate, String trackId) {
    final availability = _catalog.trackAvailabilityFor(candidate, trackId);
    return availability == TrackAvailability.completed ||
        availability == TrackAvailability.mastered;
  }

  void _persist() {
    _preferences.setString(_storageKey, jsonEncode(state.toJson()));
  }
}
