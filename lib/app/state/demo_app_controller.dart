import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';
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
  static const String _storageKey = 'zerdestudy_demo_state_v2';

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

    final lesson = _catalog.lessonById(lessonId);
    if (!_catalog.lessonRequirementsMet(state, lessonId)) {
      return;
    }

    final completedLessonIds = Set<String>.from(state.completedLessonIds)
      ..add(lessonId);

    state = _withDerived(
      state.copyWith(
        currentTrackId: lesson.trackId,
        completedLessonIds: completedLessonIds,
        xp: state.xp + lesson.xpReward,
        streak: state.streak + 1,
        dailyMissionDone: true,
        focusedLessonId: lessonId,
        focusedPracticeId: null,
        weeklyActivity: _bumpToday(state.weeklyActivity),
      ),
    );
    _persist();
  }

  void completePractice(String practiceId) {
    if (state.completedPracticeIds.contains(practiceId)) {
      return;
    }

    final practice = _catalog.practiceById(practiceId);
    final completedPracticeIds = Set<String>.from(state.completedPracticeIds)
      ..add(practiceId);

    state = _withDerived(
      state.copyWith(
        currentTrackId: practice.trackId,
        completedPracticeIds: completedPracticeIds,
        xp: state.xp + practice.xpReward,
        streak: state.streak + 1,
        dailyMissionDone: true,
        focusedPracticeId: practiceId,
        focusedLessonId: null,
        weeklyActivity: _bumpToday(state.weeklyActivity),
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

    state = _withDerived(
      state.copyWith(
        savedCommunityCourseIds: savedCommunityCourseIds,
        xp: state.xp + 10,
      ),
    );
    _persist();
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
    final currentUser = state.user ??
        _createUser(
          email: 'demo@zerdestudy.app',
        );
    final seeded = _seedState().copyWith(
      locale: locale,
      isAuthenticated: true,
      user: currentUser,
    );

    state = _withDerived(seeded);
    _persist();
  }

  DemoAppState _seedState() {
    return DemoAppState(
      locale: AppLocale.ru,
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

  void _persist() {
    _preferences.setString(_storageKey, jsonEncode(state.toJson()));
  }
}
