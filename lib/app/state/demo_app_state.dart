import 'app_locale.dart';
import 'demo_models.dart';

class DemoAppState {
  const DemoAppState({
    required this.locale,
    required this.isAuthenticated,
    required this.user,
    required this.currentTrackId,
    required this.focusedLessonId,
    required this.focusedPracticeId,
    required this.completedLessonIds,
    required this.completedPracticeIds,
    required this.xp,
    required this.streak,
    required this.dailyMissionDone,
    required this.weeklyActivity,
    required this.aiMessages,
    required this.unlockedAchievementIds,
  });

  static const Object _sentinel = Object();
  static const int xpPerLevel = 180;

  final AppLocale locale;
  final bool isAuthenticated;
  final DemoUser? user;
  final String currentTrackId;
  final String? focusedLessonId;
  final String? focusedPracticeId;
  final Set<String> completedLessonIds;
  final Set<String> completedPracticeIds;
  final int xp;
  final int streak;
  final bool dailyMissionDone;
  final List<int> weeklyActivity;
  final List<AiMessage> aiMessages;
  final Set<String> unlockedAchievementIds;

  int get level => 1 + (xp ~/ xpPerLevel);

  int get xpIntoLevel => xp % xpPerLevel;

  int get xpToNextLevel {
    final remaining = xpPerLevel - xpIntoLevel;
    return remaining == 0 ? xpPerLevel : remaining;
  }

  DemoAppState copyWith({
    AppLocale? locale,
    bool? isAuthenticated,
    Object? user = _sentinel,
    String? currentTrackId,
    Object? focusedLessonId = _sentinel,
    Object? focusedPracticeId = _sentinel,
    Set<String>? completedLessonIds,
    Set<String>? completedPracticeIds,
    int? xp,
    int? streak,
    bool? dailyMissionDone,
    List<int>? weeklyActivity,
    List<AiMessage>? aiMessages,
    Set<String>? unlockedAchievementIds,
  }) {
    return DemoAppState(
      locale: locale ?? this.locale,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: identical(user, _sentinel) ? this.user : user as DemoUser?,
      currentTrackId: currentTrackId ?? this.currentTrackId,
      focusedLessonId: identical(focusedLessonId, _sentinel)
          ? this.focusedLessonId
          : focusedLessonId as String?,
      focusedPracticeId: identical(focusedPracticeId, _sentinel)
          ? this.focusedPracticeId
          : focusedPracticeId as String?,
      completedLessonIds:
          completedLessonIds ?? Set<String>.from(this.completedLessonIds),
      completedPracticeIds:
          completedPracticeIds ?? Set<String>.from(this.completedPracticeIds),
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      dailyMissionDone: dailyMissionDone ?? this.dailyMissionDone,
      weeklyActivity: weeklyActivity ?? List<int>.from(this.weeklyActivity),
      aiMessages: aiMessages ?? List<AiMessage>.from(this.aiMessages),
      unlockedAchievementIds:
          unlockedAchievementIds ?? Set<String>.from(this.unlockedAchievementIds),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'locale': locale.code,
      'isAuthenticated': isAuthenticated,
      'user': user?.toJson(),
      'currentTrackId': currentTrackId,
      'focusedLessonId': focusedLessonId,
      'focusedPracticeId': focusedPracticeId,
      'completedLessonIds': completedLessonIds.toList(),
      'completedPracticeIds': completedPracticeIds.toList(),
      'xp': xp,
      'streak': streak,
      'dailyMissionDone': dailyMissionDone,
      'weeklyActivity': weeklyActivity,
      'aiMessages': aiMessages.map((message) => message.toJson()).toList(),
      'unlockedAchievementIds': unlockedAchievementIds.toList(),
    };
  }

  factory DemoAppState.fromJson(Map<String, dynamic> json) {
    return DemoAppState(
      locale: AppLocale.fromCode(json['locale'] as String?),
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
      user: json['user'] is Map<String, dynamic>
          ? DemoUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      currentTrackId: json['currentTrackId'] as String? ?? 'fundamentals',
      focusedLessonId: json['focusedLessonId'] as String?,
      focusedPracticeId: json['focusedPracticeId'] as String?,
      completedLessonIds: Set<String>.from(
        (json['completedLessonIds'] as List<dynamic>? ?? <dynamic>[])
            .cast<String>(),
      ),
      completedPracticeIds: Set<String>.from(
        (json['completedPracticeIds'] as List<dynamic>? ?? <dynamic>[])
            .cast<String>(),
      ),
      xp: json['xp'] as int? ?? 240,
      streak: json['streak'] as int? ?? 4,
      dailyMissionDone: json['dailyMissionDone'] as bool? ?? false,
      weeklyActivity: List<int>.from(
        (json['weeklyActivity'] as List<dynamic>? ??
                <dynamic>[2, 3, 1, 4, 2, 5, 1])
            .cast<int>(),
      ),
      aiMessages: (json['aiMessages'] as List<dynamic>? ?? <dynamic>[])
          .map((message) => AiMessage.fromJson(message as Map<String, dynamic>))
          .toList(),
      unlockedAchievementIds: Set<String>.from(
        (json['unlockedAchievementIds'] as List<dynamic>? ?? <dynamic>[])
            .cast<String>(),
      ),
    );
  }
}
