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
  static const String _storageKey = 'zerdestudy_demo_state_v1';

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
          goal: state.user?.goal ?? 'Ship a presentation-ready MVP',
        ),
      ),
    );
    _persist();
  }

  void loginWithProvider(String providerLabel) {
    final normalized = providerLabel.toLowerCase();
    final providerName = providerLabel.isEmpty
        ? 'Demo'
        : providerLabel[0].toUpperCase() + providerLabel.substring(1);

    state = _withDerived(
      state.copyWith(
        isAuthenticated: true,
        user: _createUser(
          name: providerName == 'Apple' ? 'Aliya ❤️' : 'Aliya ❤️',
          email: '${normalized.isEmpty ? 'demo' : normalized}@zerdestudy.app',
          goal: 'Reach confident demo flow in 14 days',
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

  void completeLesson(String lessonId) {
    if (state.completedLessonIds.contains(lessonId)) {
      return;
    }

    final lesson = _catalog.lessonById(lessonId);
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

    state = _withDerived(state.copyWith(aiMessages: messages));
    _persist();
  }

  void resetDemo() {
    final locale = state.locale;
    final currentUser = state.user ?? _createUser(email: 'demo@zerdestudy.app');
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
      focusedLessonId: 'fundamentals_flow',
      focusedPracticeId: null,
      completedLessonIds: <String>{
        'fundamentals_mindset',
        'frontend_html',
      },
      completedPracticeIds: <String>{},
      xp: 240,
      streak: 4,
      dailyMissionDone: false,
      weeklyActivity: <int>[2, 3, 1, 4, 2, 5, 1],
      aiMessages: <AiMessage>[
        AiMessage(
          id: 'mentor-seed',
          author: AiAuthor.mentor,
          text: 'I can explain lessons, suggest the next step, and help you narrate the demo.',
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
  }) {
    return DemoUser(
      name: (name == null || name.trim().isEmpty) ? 'Aliya ❤️' : name.trim(),
      email: email.trim(),
      role: 'Student Explorer',
      goal: goal ?? 'Reach the Frontend track with visible progress',
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
