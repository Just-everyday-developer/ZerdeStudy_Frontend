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
      final seeded = _seedState();
      final restored = DemoAppState.fromJson(
        jsonDecode(savedState) as Map<String, dynamic>,
      );
      return _withDerived(
        restored.copyWith(
          courseRatingsByCourseId: restored.courseRatingsByCourseId.isEmpty
              ? seeded.courseRatingsByCourseId
              : restored.courseRatingsByCourseId,
          enrolledCommunityCourseIds: restored.enrolledCommunityCourseIds.isEmpty
              ? seeded.enrolledCommunityCourseIds
              : restored.enrolledCommunityCourseIds,
          coursePlayerProgressByCourseId:
              restored.coursePlayerProgressByCourseId.isEmpty
                  ? seeded.coursePlayerProgressByCourseId
                  : restored.coursePlayerProgressByCourseId,
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

  void loginAsModerator() {
    state = _withDerived(state.copyWith(
      isAuthenticated: true,
      isModerator: true,
    ));
  }

  void logoutModerator() {
    state = _withDerived(state.copyWith(
      isAuthenticated: false,
      isModerator: false,
    ));
  }

  void syncExternalAuth({
    required bool isAuthenticated,
    required bool isModerator,
    DemoUser? user,
  }) {
    final sameUser = _sameUser(state.user, user);
    if (state.isAuthenticated == isAuthenticated &&
        state.isModerator == isModerator &&
        sameUser) {
      return;
    }

    state = _withDerived(
      state.copyWith(
        isAuthenticated: isAuthenticated,
        isModerator: isModerator,
        user: user,
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

  void toggleSavedCommunityCourse(String courseId) {
    if (!state.savedCommunityCourseIds.contains(courseId)) {
      saveCommunityCourse(courseId);
      return;
    }

    final updatedSavedIds = Set<String>.from(state.savedCommunityCourseIds)
      ..remove(courseId);

    state = _withDerived(
      state.copyWith(
        savedCommunityCourseIds: updatedSavedIds,
      ),
    );
    _persist();
  }

  void rateCommunityCourse(String courseId, int stars) {
    final normalized = stars.clamp(1, 5);
    final updatedRatings = Map<String, int>.from(state.courseRatingsByCourseId)
      ..[courseId] = normalized;
    final firstRating = !state.courseRatingsByCourseId.containsKey(courseId);
    final course = _catalog.courseById(courseId);
    final timestamp = DateTime.now();

    state = _withDerived(
      state.copyWith(
        courseRatingsByCourseId: updatedRatings,
        xp: state.xp + (firstRating ? 5 : 1),
        learningHistory: <LearningHistoryEntry>[
          LearningHistoryEntry(
            id: 'history-course-rating-${timestamp.microsecondsSinceEpoch}',
            kind: LearningHistoryKind.courseSaved,
            title: 'Course rating updated',
            subtitle: '${course.title.resolve(state.locale)} • $normalized/5',
            createdAt: timestamp,
            refId: courseId,
          ),
          ...state.learningHistory,
        ],
      ),
    );
    _persist();
  }

  void enrollCommunityCourse(String courseId) {
    if (state.enrolledCommunityCourseIds.contains(courseId)) {
      return;
    }

    final course = _catalog.courseById(courseId);
    final allLessons = <CoursePlayerLesson>[
      for (final module in course.coursePlayerModules) ...module.lessons,
    ];
    final timestamp = DateTime.now();
    final updatedEnrollments = Set<String>.from(state.enrolledCommunityCourseIds)
      ..add(courseId);
    final updatedProgress =
        Map<String, CoursePlayerProgress>.from(state.coursePlayerProgressByCourseId)
          ..[courseId] = CoursePlayerProgress(
            courseId: courseId,
            completedLessonIds: const <String>{},
            attemptedExerciseIds: const <String>{},
            correctExerciseIds: const <String>{},
            incorrectExerciseIds: const <String>{},
            earnedPoints: 0,
            enrolledAt: timestamp,
            currentLessonId: allLessons.isEmpty ? null : allLessons.first.id,
            lastOpenedAt: timestamp,
          );

    state = _withDerived(
      state.copyWith(
        enrolledCommunityCourseIds: updatedEnrollments,
        coursePlayerProgressByCourseId: updatedProgress,
        xp: state.xp + 14,
        learningHistory: <LearningHistoryEntry>[
          LearningHistoryEntry(
            id: 'history-course-enrolled-${timestamp.microsecondsSinceEpoch}',
            kind: LearningHistoryKind.courseEnrolled,
            title: 'Course enrolled',
            subtitle: course.title.resolve(state.locale),
            createdAt: timestamp,
            refId: course.id,
          ),
          ...state.learningHistory,
        ],
      ),
    );
    _persist();
  }

  CoursePlayerProgress advanceCoursePlayer({
    required String courseId,
    required String lessonId,
    Set<String> attemptedExerciseIds = const <String>{},
    Set<String> correctExerciseIds = const <String>{},
    Set<String> incorrectExerciseIds = const <String>{},
    int earnedPointsDelta = 0,
  }) {
    final course = _catalog.courseById(courseId);
    final allLessons = <CoursePlayerLesson>[
      for (final module in course.coursePlayerModules) ...module.lessons,
    ];
    final currentProgress = state.coursePlayerProgressByCourseId[courseId] ??
        CoursePlayerProgress(
          courseId: courseId,
          completedLessonIds: const <String>{},
          attemptedExerciseIds: const <String>{},
          correctExerciseIds: const <String>{},
          incorrectExerciseIds: const <String>{},
          earnedPoints: 0,
          enrolledAt: DateTime.now(),
          currentLessonId: allLessons.isEmpty ? null : allLessons.first.id,
        );
    final updatedCompletedIds = Set<String>.from(currentProgress.completedLessonIds)
      ..add(lessonId);
    final currentIndex = allLessons.indexWhere((lesson) => lesson.id == lessonId);
    final nextLessonId =
        currentIndex >= 0 && currentIndex < allLessons.length - 1 ? allLessons[currentIndex + 1].id : null;
    final finishedCourse = updatedCompletedIds.length >= allLessons.length &&
        allLessons.isNotEmpty;
    final timestamp = DateTime.now();
    final updatedProgress = currentProgress.copyWith(
      completedLessonIds: updatedCompletedIds,
      attemptedExerciseIds:
          Set<String>.from(currentProgress.attemptedExerciseIds)
            ..addAll(attemptedExerciseIds),
      correctExerciseIds: Set<String>.from(currentProgress.correctExerciseIds)
        ..addAll(correctExerciseIds),
      incorrectExerciseIds:
          Set<String>.from(currentProgress.incorrectExerciseIds)
            ..addAll(incorrectExerciseIds),
      earnedPoints: currentProgress.earnedPoints + earnedPointsDelta,
      currentLessonId: finishedCourse ? null : nextLessonId,
      lastOpenedAt: timestamp,
      completedAt: finishedCourse ? timestamp : currentProgress.completedAt,
    );

    final progressMap =
        Map<String, CoursePlayerProgress>.from(state.coursePlayerProgressByCourseId)
          ..[courseId] = updatedProgress;

    final historyEntries = <LearningHistoryEntry>[
      LearningHistoryEntry(
        id: 'history-course-lesson-${timestamp.microsecondsSinceEpoch}',
        kind: LearningHistoryKind.lessonCompleted,
        title: 'Course lesson completed',
        subtitle: allLessons
            .firstWhere((lesson) => lesson.id == lessonId)
            .title
            .resolve(state.locale),
        createdAt: timestamp,
        refId: lessonId,
      ),
    ];
    if (finishedCourse) {
      final percent = _catalog.coursePlayerCompletionPercent(
        state.copyWith(
          coursePlayerProgressByCourseId: progressMap,
        ),
        courseId,
      );
      historyEntries.addAll(<LearningHistoryEntry>[
        LearningHistoryEntry(
          id: 'history-course-completed-${timestamp.microsecondsSinceEpoch}',
          kind: LearningHistoryKind.courseCompleted,
          title: 'Course completed',
          subtitle: course.title.resolve(state.locale),
          scoreLabel: '$percent%',
          createdAt: timestamp,
          refId: courseId,
        ),
        LearningHistoryEntry(
          id: 'history-certificate-${timestamp.microsecondsSinceEpoch}',
          kind: LearningHistoryKind.certificateEarned,
          title: 'Certificate earned',
          subtitle: '${course.title.resolve(state.locale)} • $percent%',
          createdAt: timestamp,
          refId: 'certificate_$courseId',
        ),
      ]);
    }

    state = _withDerived(
      state.copyWith(
        coursePlayerProgressByCourseId: progressMap,
        enrolledCommunityCourseIds:
            Set<String>.from(state.enrolledCommunityCourseIds)..add(courseId),
        xp: state.xp + (finishedCourse ? 26 : 12),
        dailyMissionDone: true,
        weeklyActivity: _bumpToday(state.weeklyActivity),
        learningHistory: <LearningHistoryEntry>[
          ...historyEntries,
          ...state.learningHistory,
        ],
      ),
    );
    _persist();
    return updatedProgress;
  }

  String askInlineCourseAi({
    required String courseId,
    required String prompt,
  }) {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final course = _catalog.courseById(courseId);
    final progress = state.coursePlayerProgressByCourseId[courseId];
    final currentLesson = progress?.currentLessonId == null
        ? null
        : _catalog.currentCourseLessonFor(state, courseId);
    final reply = _courseAiReply(
      course: course,
      currentLesson: currentLesson,
      prompt: trimmed,
    );
    final timestamp = DateTime.now();
    state = _withDerived(
      state.copyWith(
        aiMessages: <AiMessage>[
          ...state.aiMessages,
          AiMessage(
            id: 'inline-user-${timestamp.microsecondsSinceEpoch}',
            author: AiAuthor.user,
            text: trimmed,
            createdAt: timestamp,
          ),
          AiMessage(
            id: 'inline-mentor-${timestamp.microsecondsSinceEpoch}',
            author: AiAuthor.mentor,
            text: reply,
            createdAt: timestamp.add(const Duration(milliseconds: 180)),
          ),
        ],
        xp: state.xp + 3,
      ),
    );
    _persist();
    return reply;
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
          email: 'tomyrkanov@gmail.com',
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
      isModerator: false,
      user: const DemoUser(
        name: 'Talgat O.',
        email: 'tomyrkanov@gmail.com',
        role: 'Student Explorer',
        goal: 'Cover the full demo without dead ends',
      ),
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
      courseRatingsByCourseId: <String, int>{
        'course_dart_first_widget': 5,
        'course_sql_for_analysts': 4,
      },
      enrolledCommunityCourseIds: <String>{
        'course_dart_first_widget',
        'course_portfolio_engineering',
      },
      coursePlayerProgressByCourseId: <String, CoursePlayerProgress>{
        'course_dart_first_widget': CoursePlayerProgress(
          courseId: 'course_dart_first_widget',
          completedLessonIds: <String>{
            'course_dart_first_widget_player_lesson_1',
            'course_dart_first_widget_player_lesson_2',
            'course_dart_first_widget_player_lesson_3',
          },
          attemptedExerciseIds: <String>{
            'course_dart_first_widget_exercise_1',
            'course_dart_first_widget_exercise_2',
            'course_dart_first_widget_exercise_3',
            'course_dart_first_widget_exercise_4',
            'course_dart_first_widget_exercise_5',
            'course_dart_first_widget_exercise_6',
          },
          correctExerciseIds: <String>{
            'course_dart_first_widget_exercise_1',
            'course_dart_first_widget_exercise_2',
            'course_dart_first_widget_exercise_3',
            'course_dart_first_widget_exercise_5',
          },
          incorrectExerciseIds: <String>{
            'course_dart_first_widget_exercise_4',
            'course_dart_first_widget_exercise_6',
          },
          earnedPoints: 44,
          enrolledAt: DateTime(2026, 3, 14, 9, 0),
          lastOpenedAt: DateTime(2026, 3, 15, 10, 10),
          completedAt: DateTime(2026, 3, 15, 10, 10),
        ),
        'course_portfolio_engineering': CoursePlayerProgress(
          courseId: 'course_portfolio_engineering',
          completedLessonIds: <String>{
            'course_portfolio_engineering_player_lesson_1',
          },
          attemptedExerciseIds: <String>{
            'course_portfolio_engineering_exercise_1',
            'course_portfolio_engineering_exercise_2',
          },
          correctExerciseIds: <String>{
            'course_portfolio_engineering_exercise_1',
          },
          incorrectExerciseIds: <String>{
            'course_portfolio_engineering_exercise_2',
          },
          earnedPoints: 10,
          enrolledAt: DateTime(2026, 3, 18, 16, 0),
          currentLessonId: 'course_portfolio_engineering_player_lesson_2',
          lastOpenedAt: DateTime(2026, 3, 18, 16, 20),
        ),
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
      name: (name == null || name.trim().isEmpty) ? 'Talgat O.' : name.trim(),
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

  bool _sameUser(DemoUser? left, DemoUser? right) {
    if (identical(left, right)) {
      return true;
    }
    if (left == null || right == null) {
      return left == right;
    }

    return left.name == right.name &&
        left.email == right.email &&
        left.role == right.role &&
        left.goal == right.goal;
  }

  String _courseAiReply({
    required CommunityCourse course,
    required CoursePlayerLesson? currentLesson,
    required String prompt,
  }) {
    final normalized = prompt.toLowerCase();
    final lessonTitle = currentLesson?.title.resolve(state.locale) ?? course.title.resolve(state.locale);

    if (normalized.contains('code') || normalized.contains('пример') || normalized.contains('example')) {
      return 'Start from the smallest moving part in $lessonTitle, then point to the final print. In ${course.title.resolve(state.locale)}, that usually makes the code explanation feel much calmer.';
    }
    if (normalized.contains('next') || normalized.contains('дальше') || normalized.contains('step')) {
      return 'The clean next step is to finish $lessonTitle, then open the task block and explain the pattern in one sentence before solving it.';
    }
    if (normalized.contains('why') || normalized.contains('зачем') || normalized.contains('why this')) {
      return '${course.title.resolve(state.locale)} is useful because it turns a broad topic into one repeatable workflow you can explain, demonstrate, and then reuse in practice.';
    }
    return 'For $lessonTitle, focus on three beats: the idea, one small code example, and the practical takeaway. If you want, ask me about the output or the next task.';
  }
}
