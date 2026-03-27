import 'package:flutter/material.dart';

import 'demo_app_state.dart';
import 'demo_catalog_cs_data.dart';
import 'demo_catalog_course_data.dart';
import 'demo_catalog_it_data.dart';
import 'demo_catalog_support.dart';
import 'demo_models.dart';

const String courseTopicProgrammingLanguages = 'programming_languages';
const String courseTopicDataAnalytics = 'data_analytics';
const String courseTopicAi = 'ai';
const String courseTopicSqlDatabases = 'sql_databases';
const String courseTopicSoftSkills = 'soft_skills';

class DemoCatalog {
  DemoCatalog()
    : tracks = _buildTracksWithAssessments(),
      communityCourses = _buildCommunityCourses(),
      _leaderboardSeed = _buildLeaderboardSeed();

  final List<LearningTrack> tracks;
  final List<CommunityCourse> communityCourses;
  final List<LeaderboardEntry> _leaderboardSeed;

  late final Map<String, LearningTrack> _tracksById = <String, LearningTrack>{
    for (final track in tracks) track.id: track,
  };
  late final Map<String, LessonItem> _lessonsById = <String, LessonItem>{
    for (final track in tracks)
      for (final module in track.modules)
        for (final lesson in module.lessons) lesson.id: lesson,
  };
  late final Map<String, PracticeTask> _practicesById = <String, PracticeTask>{
    for (final track in tracks)
      for (final module in track.modules)
        if (module.practice != null) module.practice!.id: module.practice!,
  };
  late final Map<String, LessonQuiz> _lessonQuizzesById = <String, LessonQuiz>{
    for (final lesson in _lessonsById.values)
      for (final quiz in lesson.quizzes) quiz.id: quiz,
  };
  late final Map<String, CommunityCourse> _coursesById =
      <String, CommunityCourse>{
        for (final course in communityCourses) course.id: course,
      };
  late final Map<String, CoursePlayerLesson> _courseLessonsById =
      <String, CoursePlayerLesson>{
        for (final course in communityCourses)
          for (final module in course.coursePlayerModules)
            for (final lesson in module.lessons) lesson.id: lesson,
      };
  late final Map<String, CoursePlayerExercise> _courseExercisesById =
      <String, CoursePlayerExercise>{
        for (final lesson in _courseLessonsById.values)
          for (final exercise in lesson.exercises) exercise.id: exercise,
      };

  LearningTrack trackById(String trackId) =>
      _tracksById[trackId] ?? tracks.first;

  LessonItem lessonById(String lessonId) =>
      _lessonsById[lessonId] ?? _lessonsById.values.first;

  PracticeTask practiceById(String practiceId) =>
      _practicesById[practiceId] ?? _practicesById.values.first;

  LessonQuiz? lessonQuizById(String quizId) => _lessonQuizzesById[quizId];

  CommunityCourse courseById(String courseId) =>
      _coursesById[courseId] ?? communityCourses.first;

  CoursePlayerLesson? courseLessonById(String lessonId) =>
      _courseLessonsById[lessonId];

  CoursePlayerExercise? courseExerciseById(String exerciseId) =>
      _courseExercisesById[exerciseId];

  List<String> courseTopicKeys() => const <String>[
    courseTopicProgrammingLanguages,
    courseTopicDataAnalytics,
    courseTopicAi,
    courseTopicSqlDatabases,
    courseTopicSoftSkills,
  ];

  List<String> courseLevels() => const <String>[
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  List<CommunityCourseAuthor> courseAuthors() {
    final authors = popularAuthors().toList();
    authors.sort((left, right) => left.name.compareTo(right.name));
    return authors;
  }

  List<CourseDurationBucket> courseDurationBuckets() {
    return CourseDurationBucket.values;
  }

  List<String> frequentSearchTerms() => const <String>[
    'linux',
    'qa_testing',
    'statistics',
    'cybersecurity',
    'postgresql',
  ];

  List<CommunityCourse> coursesForTopic(String topicKey) {
    return communityCourses
        .where((course) => course.topicKeys.contains(topicKey))
        .toList(growable: false);
  }

  List<CommunityCourse> popularCourses() {
    return communityCourses
        .where((course) => course.isPopular)
        .toList(growable: false);
  }

  List<CommunityCourse> recommendedCourses(DemoAppState state) {
    final focusedTrack = trackById(state.currentTrackId);
    final related = communityCourses
        .where((course) {
          return course.isRecommended &&
              (course.searchKeywords.any(
                    (keyword) =>
                        focusedTrack.title.en.toLowerCase().contains(keyword),
                  ) ||
                  course.topicKeys.any(
                    (topic) => focusedTrack.title.en.toLowerCase().contains(
                      topic.split('_').first,
                    ),
                  ));
        })
        .toList(growable: false);
    if (related.length >= 13) {
      return related;
    }
    return <CommunityCourse>[
      ...related,
      ...communityCourses.where(
        (course) => course.isRecommended && !related.contains(course),
      ),
    ];
  }

  List<CommunityCourseAuthor> popularAuthors() {
    final authorsById = <String, CommunityCourseAuthor>{};
    for (final course in communityCourses) {
      authorsById[course.author.id] = course.author;
    }
    final authors = authorsById.values.toList(growable: false);
    authors.sort(
      (left, right) => right.followersCount.compareTo(left.followersCount),
    );
    return authors;
  }

  List<CommunityCourse> searchCourses({
    DemoAppState? state,
    String query = '',
    String? topicKey,
    String? level,
    double? minRating,
    CourseDurationBucket? durationBucket,
    bool? certificateOnly,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return communityCourses
        .where((course) {
          final topicMatch =
              topicKey == null ||
              topicKey.isEmpty ||
              course.topicKeys.contains(topicKey);
          final levelMatch =
              level == null ||
              level.isEmpty ||
              level == 'All' ||
              course.level == level;
          final ratingMatch =
              minRating == null ||
              displayCourseRatingFor(state, course.id) >= minRating;
          final durationMatch =
              durationBucket == null ||
              courseDurationBucketFor(course) == durationBucket;
          final certificateMatch =
              certificateOnly != true || course.facts.hasCertificate;
          final queryMatch =
              normalizedQuery.isEmpty ||
              course.title.en.toLowerCase().contains(normalizedQuery) ||
              course.subtitle.en.toLowerCase().contains(normalizedQuery) ||
              course.description.en.toLowerCase().contains(normalizedQuery) ||
              course.heroBadge.toLowerCase().contains(normalizedQuery) ||
              course.heroHeadline.toLowerCase().contains(normalizedQuery) ||
              course.learningOutcomes.any(
                (item) => item.toLowerCase().contains(normalizedQuery),
              ) ||
              course.moduleSections.any(
                (section) =>
                    section.title.toLowerCase().contains(normalizedQuery) ||
                    section.items.any(
                      (item) =>
                          item.title.toLowerCase().contains(normalizedQuery),
                    ),
              ) ||
              course.searchKeywords.any(
                (keyword) => keyword.toLowerCase().contains(normalizedQuery),
              ) ||
              course.tags.any(
                (tag) => tag.toLowerCase().contains(normalizedQuery),
              ) ||
              course.author.name.toLowerCase().contains(normalizedQuery) ||
              course.author.role.toLowerCase().contains(normalizedQuery) ||
              course.instructors.any(
                (instructor) =>
                    instructor.name.toLowerCase().contains(normalizedQuery) ||
                    instructor.role.toLowerCase().contains(normalizedQuery),
              );
          return topicMatch &&
              levelMatch &&
              ratingMatch &&
              durationMatch &&
              certificateMatch &&
              queryMatch;
        })
        .toList(growable: false);
  }

  CourseDurationBucket courseDurationBucketFor(CommunityCourse course) {
    return CourseDurationBucket.fromHours(course.estimatedHours);
  }

  double displayCourseRatingFor(DemoAppState? state, String courseId) {
    final course = courseById(courseId);
    final userRating = state?.courseRatingsByCourseId[courseId];
    if (userRating == null) {
      return course.reviewSummary.averageRating;
    }
    final baseCount = course.reviewSummary.reviewCount;
    final updatedAverage =
        ((course.reviewSummary.averageRating * baseCount) + userRating) /
        (baseCount + 1);
    return updatedAverage;
  }

  int displayCourseReviewCountFor(DemoAppState? state, String courseId) {
    final course = courseById(courseId);
    final userRating = state?.courseRatingsByCourseId[courseId];
    return course.reviewSummary.reviewCount + (userRating == null ? 0 : 1);
  }

  CommunityCourseReviewSummary displayCourseReviewSummaryFor(
    DemoAppState? state,
    String courseId,
  ) {
    final course = courseById(courseId);
    final userRating = state?.courseRatingsByCourseId[courseId];
    if (userRating == null) {
      return course.reviewSummary;
    }
    final distribution = Map<int, int>.from(
      course.reviewSummary.ratingDistribution,
    );
    distribution[userRating] = (distribution[userRating] ?? 0) + 1;
    return CommunityCourseReviewSummary(
      averageRating: displayCourseRatingFor(state, courseId),
      reviewCount: displayCourseReviewCountFor(state, courseId),
      ratingDistribution: distribution,
    );
  }

  bool isCourseEnrolled(DemoAppState state, String courseId) {
    return state.enrolledCommunityCourseIds.contains(courseId);
  }

  CoursePlayerProgress? coursePlayerProgressFor(
    DemoAppState state,
    String courseId,
  ) {
    return state.coursePlayerProgressByCourseId[courseId];
  }

  CoursePlayerLesson? currentCourseLessonFor(
    DemoAppState state,
    String courseId,
  ) {
    final course = courseById(courseId);
    final progress = coursePlayerProgressFor(state, courseId);
    final allLessons = <CoursePlayerLesson>[
      for (final module in course.coursePlayerModules) ...module.lessons,
    ];
    if (allLessons.isEmpty) {
      return null;
    }
    final currentLessonId = progress?.currentLessonId;
    return allLessons.firstWhere(
      (lesson) => lesson.id == currentLessonId,
      orElse: () => allLessons.first,
    );
  }

  List<CoursePlayerExercise> courseExercisesFor(String courseId) {
    final course = courseById(courseId);
    return <CoursePlayerExercise>[
      for (final module in course.coursePlayerModules)
        for (final lesson in module.lessons) ...lesson.exercises,
    ];
  }

  int totalCoursePlayerPoints(String courseId) {
    return courseExercisesFor(
      courseId,
    ).fold<int>(0, (sum, exercise) => sum + exercise.points);
  }

  int earnedCoursePlayerPoints(DemoAppState state, String courseId) {
    return state.coursePlayerProgressByCourseId[courseId]?.earnedPoints ?? 0;
  }

  int coursePlayerCompletionPercent(DemoAppState state, String courseId) {
    final total = totalCoursePlayerPoints(courseId);
    if (total == 0) {
      return 0;
    }
    return ((earnedCoursePlayerPoints(state, courseId) / total) * 100).round();
  }

  List<CoursePlayerExercise> incorrectCourseExercisesFor(DemoAppState state) {
    return state.coursePlayerProgressByCourseId.values
        .expand((progress) => progress.incorrectExerciseIds)
        .map(courseExerciseById)
        .whereType<CoursePlayerExercise>()
        .toList(growable: false);
  }

  List<LessonQuiz> incorrectTrackQuizzesFor(DemoAppState state) {
    return state.quizAnswerStats.entries
        .where((entry) => entry.value.attempts > entry.value.correctAnswers)
        .map((entry) => lessonQuizById(entry.key))
        .whereType<LessonQuiz>()
        .toList(growable: false);
  }

  List<CourseCertificate> certificatesFor(DemoAppState state) {
    return communityCourses
        .where((course) {
          final progress = state.coursePlayerProgressByCourseId[course.id];
          return progress?.completedAt != null &&
              coursePlayerCompletionPercent(state, course.id) >= 70;
        })
        .map((course) {
          final percent = coursePlayerCompletionPercent(state, course.id);
          return CourseCertificate(
            id: 'certificate_${course.id}',
            courseId: course.id,
            title: course.title.resolve(state.locale),
            recipientName: state.user?.name ?? 'Talgat',
            issuedAt:
                state.coursePlayerProgressByCourseId[course.id]!.completedAt!,
            accent: course.color,
            tier: percent >= 100
                ? CourseCertificateTier.premium
                : CourseCertificateTier.standard,
            completionPercent: percent,
          );
        })
        .toList()
      ..sort((left, right) => right.issuedAt.compareTo(left.issuedAt));
  }

  List<CommunityCourse> enrolledCoursesFor(DemoAppState state) {
    return communityCourses
        .where((course) => state.enrolledCommunityCourseIds.contains(course.id))
        .toList(growable: false);
  }

  TrackAssessment assessmentForTrack(String trackId) =>
      trackById(trackId).assessment ??
      _buildAssessmentForTrack(trackById(trackId), tracks);

  TrackAssessmentResult? assessmentResultFor(
    DemoAppState state,
    String trackId,
  ) => state.assessmentResultsByTrackId[trackId];

  int bestAssessmentPercentFor(DemoAppState state, String trackId) =>
      assessmentResultFor(state, trackId)?.bestPercent ?? 0;

  int lastAssessmentPercentFor(DemoAppState state, String trackId) =>
      assessmentResultFor(state, trackId)?.lastPercent ?? 0;

  int passedAssessments(DemoAppState state) {
    return state.assessmentResultsByTrackId.values
        .where((result) => result.lastPassed)
        .length;
  }

  int averageBestAssessmentPercent(DemoAppState state) {
    final results = state.assessmentResultsByTrackId.values.toList(
      growable: false,
    );
    if (results.isEmpty) {
      return 0;
    }
    final total = results.fold<int>(
      0,
      (sum, result) => sum + result.bestPercent,
    );
    return (total / results.length).round();
  }

  List<CommunityCourse> savedCoursesFor(DemoAppState state) {
    return communityCourses
        .where((course) => state.savedCommunityCourseIds.contains(course.id))
        .toList(growable: false);
  }

  List<LearningTrack> completedTracksFor(DemoAppState state) {
    return tracks
        .where((track) => _isTrackFinished(state, track.id))
        .toList(growable: false);
  }

  List<LearningModule> completedModulesFor(DemoAppState state) {
    return <LearningModule>[
      for (final track in tracks)
        for (final module in track.modules)
          if (_isModuleCompleted(state, module)) module,
    ];
  }

  List<LessonItem> completedLessonsFor(DemoAppState state) {
    return <LessonItem>[
      for (final lesson in _lessonsById.values)
        if (state.completedLessonIds.contains(lesson.id)) lesson,
    ];
  }

  List<PracticeTask> completedPracticesFor(DemoAppState state) {
    return <PracticeTask>[
      for (final practice in _practicesById.values)
        if (state.completedPracticeIds.contains(practice.id)) practice,
    ];
  }

  List<LearningTrack> tracksForZone(TrackZone zone) {
    return tracks.where((track) => track.zone == zone).toList(growable: false);
  }

  LocalizedText zoneTitle(TrackZone zone) {
    switch (zone) {
      case TrackZone.computerScienceCore:
        return sameText('Computer Science Core');
      case TrackZone.itSpheres:
        return sameText('Applied IT Spheres');
    }
  }

  LocalizedText zoneSummary(TrackZone zone) {
    switch (zone) {
      case TrackZone.computerScienceCore:
        return sameText(
          'Foundational topics that explain how systems, data, math, and machines behave.',
        );
      case TrackZone.itSpheres:
        return sameText(
          'Interactive applied branches built on top of the core, from frontend to machine learning.',
        );
    }
  }

  int completedUnitsForZone(DemoAppState state, TrackZone zone) {
    return tracksForZone(
      zone,
    ).fold<int>(0, (sum, track) => sum + _completedUnitsForTrack(state, track));
  }

  int totalUnitsForZone(TrackZone zone) {
    return tracksForZone(
      zone,
    ).fold<int>(0, (sum, track) => sum + track.totalUnits);
  }

  bool lessonRequirementsMet(DemoAppState state, String lessonId) {
    final lesson = lessonById(lessonId);
    return lesson.completionRequirements.every(
      (id) =>
          state.completedQuizIds.contains(id) ||
          state.completedTrainerIds.contains(id),
    );
  }

  TrackProgress progressForTrack(DemoAppState state, String trackId) {
    final track = trackById(trackId);
    var completedUnits = 0;
    LearningTarget? nextTarget;

    for (final module in track.modules) {
      for (final lesson in module.lessons) {
        if (state.completedLessonIds.contains(lesson.id)) {
          completedUnits += 1;
        } else {
          nextTarget ??= LearningTarget.lesson(lesson);
        }
      }
      final practice = module.practice;
      if (practice != null) {
        if (state.completedPracticeIds.contains(practice.id)) {
          completedUnits += 1;
        } else {
          nextTarget ??= LearningTarget.practice(practice);
        }
      }
    }

    final quizIds = <String>[
      for (final module in track.modules)
        for (final lesson in module.lessons)
          for (final quiz in lesson.quizzes) quiz.id,
    ];
    final trainerIds = <String>[
      for (final module in track.modules)
        for (final lesson in module.lessons)
          for (final trainer in lesson.codeTrainers) trainer.id,
    ];

    return TrackProgress(
      state: trackAvailabilityFor(state, track.id),
      completedUnits: completedUnits,
      totalUnits: track.totalUnits,
      completedQuizzes: quizIds.where(state.completedQuizIds.contains).length,
      totalQuizzes: quizIds.length,
      completedTrainers: trainerIds
          .where(state.completedTrainerIds.contains)
          .length,
      totalTrainers: trainerIds.length,
      nextTarget: nextTarget,
    );
  }

  TrackAvailability trackAvailabilityFor(DemoAppState state, String trackId) {
    final track = trackById(trackId);
    final progress = _completedUnitsForTrack(state, track);
    if (progress == 0) {
      return TrackAvailability.available;
    }
    if (progress < track.totalUnits) {
      return TrackAvailability.inProgress;
    }
    return _isMastered(state, track)
        ? TrackAvailability.mastered
        : TrackAvailability.completed;
  }

  int totalUnits() =>
      tracks.fold<int>(0, (sum, track) => sum + track.totalUnits);

  int totalCompletedUnits(DemoAppState state) =>
      state.completedLessonIds.length + state.completedPracticeIds.length;

  int totalQuizzes() =>
      tracks.fold<int>(0, (sum, track) => sum + track.totalQuizzes);

  int totalTrainers() =>
      tracks.fold<int>(0, (sum, track) => sum + track.totalTrainers);

  int totalAssessmentQuestions() => tracks.fold<int>(
    0,
    (sum, track) => sum + (track.assessment?.questions.length ?? 0),
  );

  int completedTracks(DemoAppState state) {
    return tracks.where((track) {
      final availability = trackAvailabilityFor(state, track.id);
      return availability == TrackAvailability.completed ||
          availability == TrackAvailability.mastered;
    }).length;
  }

  int masteredTracks(DemoAppState state) {
    return tracks
        .where(
          (track) =>
              trackAvailabilityFor(state, track.id) ==
              TrackAvailability.mastered,
        )
        .length;
  }

  List<Achievement> achievementsFor(DemoAppState state) {
    final completedLessons = state.completedLessonIds.length;
    final completedPractices = state.completedPracticeIds.length;
    final completedQuizzes = state.completedQuizIds.length;
    final completedTrainers = state.completedTrainerIds.length;
    final userMessages = state.aiMessages
        .where((message) => message.author == AiAuthor.user)
        .length;
    final assessmentPassed = passedAssessments(state);
    final strongAssessmentScores = state.assessmentResultsByTrackId.values
        .where((result) => result.bestPercent >= 80)
        .length;
    final csDone = [
      'mathematics',
      'mathematical_analysis',
      'discrete_math',
      'linear_algebra_calculus',
      'probability_statistics_analytics',
      'algorithms_data_structures',
      'databases',
      'networking_protocols',
      'ai_theory',
      'computer_architecture',
      'information_security_foundations',
      'operating_systems',
    ].where((id) => _isTrackFinished(state, id)).length;
    final itDone = [
      'fundamentals',
      'frontend',
      'backend',
      'mobile',
      'android_development',
      'ios_development',
      'crossplatform_development',
      'cybersecurity',
      'sre_devops',
      'system_administration',
      'machine_learning',
      'qa_engineering',
    ].where((id) => _isTrackFinished(state, id)).length;
    final courseSignals =
        state.viewedCommunityCourseIds.length +
        state.savedCommunityCourseIds.length;
    final frontendDone = _isTrackFinished(state, 'frontend') ? 1 : 0;
    final systemsDone = _isTrackFinished(state, 'operating_systems') ? 1 : 0;
    final dataDone =
        (_isTrackFinished(state, 'databases') ? 1 : 0) +
        (_isTrackFinished(state, 'probability_statistics_analytics') ? 1 : 0);
    final mathRootsDone =
        (_isTrackFinished(state, 'mathematics') ? 1 : 0) +
        (_isTrackFinished(state, 'mathematical_analysis') ? 1 : 0) +
        (_isTrackFinished(state, 'discrete_math') ? 1 : 0) +
        (_isTrackFinished(state, 'linear_algebra_calculus') ? 1 : 0) +
        (_isTrackFinished(state, 'probability_statistics_analytics') ? 1 : 0);
    final algorithmDone = _isTrackFinished(state, 'algorithms_data_structures')
        ? 1
        : 0;
    final networkDone = _isTrackFinished(state, 'networking_protocols') ? 1 : 0;
    final mlEngineerDone = _isTrackFinished(state, 'machine_learning') ? 1 : 0;
    final qaDone = _isTrackFinished(state, 'qa_engineering') ? 1 : 0;
    final systemAdminDone = _isTrackFinished(state, 'system_administration')
        ? 1
        : 0;
    final mobileBranchesDone = [
      'mobile',
      'android_development',
      'ios_development',
      'crossplatform_development',
    ].where((id) => _isTrackFinished(state, id)).length;
    final securityStackDone =
        (_isTrackFinished(state, 'information_security_foundations') ? 1 : 0) +
        (_isTrackFinished(state, 'cybersecurity') ? 1 : 0);

    return <Achievement>[
      _achievement(
        'first_step',
        'First step',
        'Complete the first lesson in any branch.',
        Icons.flag_rounded,
        1,
        completedLessons,
      ),
      _achievement(
        'lesson_runner',
        'Lesson runner',
        'Finish 6 lessons across the tree.',
        Icons.play_lesson_rounded,
        6,
        completedLessons,
      ),
      _achievement(
        'practice_engineer',
        'Practice engineer',
        'Close 4 hands-on tasks.',
        Icons.code_rounded,
        4,
        completedPractices,
      ),
      _achievement(
        'quiz_scout',
        'Quiz scout',
        'Solve 10 output quizzes.',
        Icons.quiz_rounded,
        10,
        completedQuizzes,
      ),
      _achievement(
        'memory_builder',
        'Memory builder',
        'Finish 10 code memory labs.',
        Icons.memory_rounded,
        10,
        completedTrainers,
      ),
      _achievement(
        'streak_7',
        'Seven day pulse',
        'Reach a 7-day streak.',
        Icons.local_fire_department_rounded,
        7,
        state.streak,
      ),
      _achievement(
        'xp_900',
        'XP 900',
        'Cross 900 XP in the demo.',
        Icons.bolt_rounded,
        900,
        state.xp,
      ),
      _achievement(
        'ai_partner',
        'AI partner',
        'Send 6 questions to the mentor.',
        Icons.smart_toy_rounded,
        6,
        userMessages,
      ),
      _achievement(
        'cs_core_explorer',
        'CS core explorer',
        'Finish 2 Computer Science Core tracks.',
        Icons.hub_rounded,
        2,
        csDone,
      ),
      _achievement(
        'sphere_builder',
        'Sphere builder',
        'Finish 2 IT sphere tracks.',
        Icons.auto_awesome_mosaic_rounded,
        2,
        itDone,
      ),
      _achievement(
        'frontend_ready',
        'Frontend ready',
        'Close the Frontend track.',
        Icons.web_rounded,
        1,
        frontendDone,
      ),
      _achievement(
        'systems_foundation',
        'Systems foundation',
        'Close the Operating Systems track.',
        Icons.developer_board_rounded,
        1,
        systemsDone,
      ),
      _achievement(
        'data_confidence',
        'Data confidence',
        'Finish Databases and Probability/Statistics.',
        Icons.insights_rounded,
        2,
        dataDone,
      ),
      _achievement(
        'math_canopy',
        'Math canopy',
        'Finish 3 mathematical foundation branches.',
        Icons.calculate_rounded,
        3,
        mathRootsDone,
      ),
      _achievement(
        'algorithmic_mindset',
        'Algorithmic mindset',
        'Close Algorithms & Data Structures.',
        Icons.account_tree_rounded,
        1,
        algorithmDone,
      ),
      _achievement(
        'network_mapper',
        'Network mapper',
        'Close Information Networks.',
        Icons.hub_rounded,
        1,
        networkDone,
      ),
      _achievement(
        'mobile_forest',
        'Mobile forest',
        'Finish 3 mobile-related branches.',
        Icons.devices_rounded,
        3,
        mobileBranchesDone,
      ),
      _achievement(
        'qa_guardian',
        'QA guardian',
        'Close the QA Engineer branch.',
        Icons.fact_check_rounded,
        1,
        qaDone,
      ),
      _achievement(
        'ops_keeper',
        'Ops keeper',
        'Close the System Administration branch.',
        Icons.admin_panel_settings_rounded,
        1,
        systemAdminDone,
      ),
      _achievement(
        'ml_pathfinder',
        'ML pathfinder',
        'Close the ML Engineer branch.',
        Icons.psychology_alt_rounded,
        1,
        mlEngineerDone,
      ),
      _achievement(
        'security_stack',
        'Security stack',
        'Finish Information Security and Cybersecurity.',
        Icons.shield_rounded,
        2,
        securityStackDone,
      ),
      _achievement(
        'community_curator',
        'Community curator',
        'View or save 4 community courses.',
        Icons.groups_rounded,
        4,
        courseSignals,
      ),
      _achievement(
        'assessment_starter',
        'Assessment starter',
        'Pass 3 branch assessments.',
        Icons.assignment_turned_in_rounded,
        3,
        assessmentPassed,
      ),
      _achievement(
        'assessment_sharp',
        'Assessment sharp',
        'Reach 80% or more on 4 assessments.',
        Icons.rule_rounded,
        4,
        strongAssessmentScores,
      ),
      _achievement(
        'mastery_badges',
        'Mastery badges',
        'Master 2 tracks with perfect quiz accuracy.',
        Icons.workspace_premium_rounded,
        2,
        masteredTracks(state),
      ),
    ];
  }

  Set<String> unlockedAchievementIdsFor(DemoAppState state) {
    return achievementsFor(state)
        .where((achievement) => achievement.unlocked)
        .map((achievement) => achievement.id)
        .toSet();
  }

  List<LeaderboardEntry> leaderboardFor(DemoAppState state) {
    final currentUser = LeaderboardEntry(
      id: 'current-user',
      name: state.user?.name ?? 'Talgat',
      xp: state.xp,
      level: state.level,
      role: state.user?.role ?? 'Student Explorer',
      focus: trackById(state.currentTrackId).title.resolve(state.locale),
      isCurrentUser: true,
    );
    final entries = <LeaderboardEntry>[
      ..._leaderboardSeed.where((entry) => entry.id != currentUser.id),
      currentUser,
    ];
    entries.sort((left, right) => right.xp.compareTo(left.xp));
    return entries;
  }

  List<LocalizedText> recentMilestonesFor(DemoAppState state) {
    final history = state.learningHistory.take(3).toList(growable: false);
    final summary = <LocalizedText>[
      sameText(
        'Completed ${totalCompletedUnits(state)} units across ${_activeTracks(state)} active branches.',
      ),
      sameText('Quiz accuracy: ${(state.quizAccuracy * 100).round()}%.'),
      sameText(
        'Assessment average: ${averageBestAssessmentPercent(state)}% across ${state.assessmentResultsByTrackId.length} branches.',
      ),
      sameText(
        'Community courses: ${state.viewedCommunityCourseIds.length} viewed, ${state.savedCommunityCourseIds.length} saved.',
      ),
    ];
    return <LocalizedText>[
      ...history.map(
        (entry) => sameText(
          '${entry.title}${entry.subtitle == null ? '' : ': ${entry.subtitle}'}${entry.scoreLabel == null ? '' : ' (${entry.scoreLabel})'}',
        ),
      ),
      ...summary,
    ].take(4).toList(growable: false);
  }

  List<String> suggestedPrompts(DemoAppState state) {
    final focus = state.focusedLessonId != null
        ? lessonById(state.focusedLessonId!).title.resolve(state.locale)
        : state.focusedPracticeId != null
        ? practiceById(state.focusedPracticeId!).title.resolve(state.locale)
        : trackById(state.currentTrackId).title.resolve(state.locale);
    final track = trackById(state.currentTrackId);
    final prompts = <String>[
      'Explain $focus in one minute.',
      'How does $focus connect to the unified tree?',
      'Give me a hint for the next output quiz.',
      'Summarize this topic in simple terms.',
      'Suggest a memory trick for the code example.',
      'Which branch connects most naturally to this one?',
      'How do operating systems, databases, and networks support product work?',
    ];

    if (track.zone == TrackZone.computerScienceCore) {
      prompts.addAll(<String>[
        'Which IT sphere grows naturally from this core topic?',
        'Why does this foundation matter for backend, security, or ML?',
      ]);
    } else {
      prompts.addAll(<String>[
        'Which Computer Science Core topic should I study to get better here?',
        'Compare this sphere with the nearest neighboring branch in the tree.',
      ]);
    }

    return prompts;
  }

  String mentorReply(DemoAppState state, String message) {
    final normalized = message.toLowerCase();
    final focus = state.focusedLessonId != null
        ? lessonById(state.focusedLessonId!).title.resolve(state.locale)
        : state.focusedPracticeId != null
        ? practiceById(state.focusedPracticeId!).title.resolve(state.locale)
        : trackById(state.currentTrackId).title.resolve(state.locale);

    final pool = _replyPool(normalized, focus, state);
    return pool[_stableHash('${state.currentTrackId}|$focus|$normalized') %
        pool.length];
  }

  List<String> _replyPool(String normalized, String focus, DemoAppState state) {
    if (_containsAny(normalized, <String>['quiz', 'output', 'вывод'])) {
      return <String>[
        'For output questions, narrate variables aloud: initial value, transformation, final print. That makes $focus much easier to present confidently.',
        'A good demo hint is to point to the last visible change. In $focus, the final output matters more than every intermediate detail.',
        'Walk the example line by line and notice where state changes. That is usually the key to the output in $focus.',
      ];
    }
    if (_containsAny(normalized, <String>['memory', 'trainer', 'запомин'])) {
      return <String>[
        'Use chunking: intent, setup, transformation, result. That pattern works well for the code memory lab in $focus.',
        'If you forget a line, rebuild from inputs and output. The trainer for $focus rewards structure, not perfect wording.',
        'Try verbal anchors: name the role of each line before trying to remember exact syntax.',
      ];
    }
    if (_containsAny(normalized, <String>[
      'tree',
      'branch',
      'ветк',
      'дерево',
    ])) {
      return <String>[
        'The tree is one shared route: Computer Science Core sets the foundation, Fundamentals bridges theory into practice, and the lower layer opens the specialized IT spheres.',
        'A strong demo order is Operating Systems -> Databases -> Fundamentals -> Backend. It shows how the product flows from foundation into applied work.',
        'Each branch stays independently available to open, so the tree feels connected without forcing one sphere to unlock another.',
      ];
    }
    if (_containsAny(normalized, <String>['stats', 'statistics', 'стат'])) {
      return <String>[
        'Use statistics to tell a story: breadth across branches, depth inside a track, then habits through streak, quizzes, and AI sessions.',
        'The improved stats page works well as proof of engagement: it combines unit completion, quiz accuracy, core-vs-sphere progress, and community exploration.',
        'When you narrate the stats screen, highlight progression from available to mastered. That ladder makes the journey easy to grasp.',
      ];
    }
    if (_containsAny(normalized, <String>[
      'course',
      'community',
      'курс',
      'user',
    ])) {
      return <String>[
        'Community courses are read-only mock data in this MVP, but they demonstrate how expert content can complement the main tree.',
        'A strong presentation line is that user-created courses add discovery without changing the core progression logic.',
        'Treat community courses as an expansion surface: curated authors, preview lessons, and save actions already feel product-ready in the mock.',
      ];
    }
    if (_containsAny(normalized, <String>['next', 'дальше', 'след'])) {
      final next = progressForTrack(state, state.currentTrackId).nextTarget;
      final nextTrack = _suggestNextTrack(state, state.currentTrackId);
      return <String>[
        next == null
            ? 'This track is fully covered. I would jump to ${nextTrack.title.resolve(state.locale)} to keep the demo moving.'
            : 'The next clean step is ${next.title.resolve(state.locale)}. It keeps the story focused and actionable.',
        'After $focus, I would open ${nextTrack.title.resolve(state.locale)} to show how independent branches still feel connected.',
        'For a smooth narrative, finish the current unit and then pivot into ${nextTrack.title.resolve(state.locale)}.',
      ];
    }
    return <String>[
      'For $focus, I would explain the idea, show the code example, let the learner predict the output, and only then move into practice.',
      'This MVP is strongest when you show live state changes. Complete one lesson in $focus and then jump straight to the tree and statistics screens.',
      'If you are presenting the demo, anchor on the journey: open branch, study lesson, solve quiz, finish trainer, and watch stats update.',
    ];
  }

  int _completedUnitsForTrack(DemoAppState state, LearningTrack track) {
    return track.modules.fold<int>(0, (sum, module) {
      final lessonsDone = module.lessons
          .where((lesson) => state.completedLessonIds.contains(lesson.id))
          .length;
      final practiceDone =
          module.practice != null &&
              state.completedPracticeIds.contains(module.practice!.id)
          ? 1
          : 0;
      return sum + lessonsDone + practiceDone;
    });
  }

  bool _isMastered(DemoAppState state, LearningTrack track) {
    if (_completedUnitsForTrack(state, track) != track.totalUnits) {
      return false;
    }
    final quizIds = <String>[
      for (final module in track.modules)
        for (final lesson in module.lessons)
          for (final quiz in lesson.quizzes) quiz.id,
    ];
    final trainerIds = <String>[
      for (final module in track.modules)
        for (final lesson in module.lessons)
          for (final trainer in lesson.codeTrainers) trainer.id,
    ];
    return quizIds.every((quizId) {
          final stat = state.quizAnswerStats[quizId];
          return state.completedQuizIds.contains(quizId) &&
              stat != null &&
              stat.attempts == 1 &&
              stat.correctAnswers >= 1;
        }) &&
        trainerIds.every(state.completedTrainerIds.contains);
  }

  bool _isTrackFinished(DemoAppState state, String trackId) {
    final availability = trackAvailabilityFor(state, trackId);
    return availability == TrackAvailability.completed ||
        availability == TrackAvailability.mastered;
  }

  int _activeTracks(DemoAppState state) =>
      tracks.where((track) => _completedUnitsForTrack(state, track) > 0).length;

  LearningTrack _suggestNextTrack(DemoAppState state, String currentTrackId) {
    return tracks.firstWhere(
      (track) =>
          track.id != currentTrackId &&
          trackAvailabilityFor(state, track.id) != TrackAvailability.mastered,
      orElse: () => tracks.first,
    );
  }

  Achievement _achievement(
    String id,
    String title,
    String description,
    IconData icon,
    int goal,
    int progress,
  ) {
    return Achievement(
      id: id,
      title: sameText(title),
      description: sameText(description),
      icon: icon,
      goal: goal,
      progress: progress.clamp(0, goal),
      unlocked: progress >= goal,
    );
  }

  static bool _containsAny(String value, List<String> patterns) =>
      patterns.any(value.contains);

  static int _stableHash(String value) {
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}

List<CommunityCourse> _buildCommunityCourses() {
  return buildDiscoveryCourses();
}

List<LeaderboardEntry> _buildLeaderboardSeed() {
  return const <LeaderboardEntry>[
    LeaderboardEntry(
      id: 'l1',
      name: 'Nursultan',
      xp: 1320,
      level: 8,
      role: 'Backend Explorer',
      focus: 'Databases',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l2',
      name: 'Mira',
      xp: 1280,
      level: 8,
      role: 'Frontend Builder',
      focus: 'Frontend',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l3',
      name: 'Dias',
      xp: 1210,
      level: 7,
      role: 'Systems Learner',
      focus: 'Operating Systems',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l4',
      name: 'Aruzhan',
      xp: 1170,
      level: 7,
      role: 'ML Apprentice',
      focus: 'Machine Learning',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l5',
      name: 'Timur',
      xp: 1115,
      level: 7,
      role: 'Reliability Learner',
      focus: 'SRE / DevOps',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l6',
      name: 'Sofia',
      xp: 1090,
      level: 7,
      role: 'Security Watcher',
      focus: 'Cybersecurity',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l7',
      name: 'Adilet',
      xp: 1035,
      level: 6,
      role: 'Math Track Learner',
      focus: 'Discrete Math',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l8',
      name: 'Zarina',
      xp: 980,
      level: 6,
      role: 'Data Storyteller',
      focus: 'Probability & Analytics',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l9',
      name: 'Bekzat',
      xp: 950,
      level: 6,
      role: 'Protocol Mapper',
      focus: 'Networks',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l10',
      name: 'Madina',
      xp: 910,
      level: 6,
      role: 'Mobile Builder',
      focus: 'Mobile',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l11',
      name: 'Ayan',
      xp: 860,
      level: 5,
      role: 'Product Analyst',
      focus: 'Databases',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l12',
      name: 'Alina',
      xp: 830,
      level: 5,
      role: 'App Generalist',
      focus: 'Fundamentals',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l13',
      name: 'Yernar',
      xp: 790,
      level: 5,
      role: 'UI Explorer',
      focus: 'Frontend',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l14',
      name: 'Tomiris',
      xp: 760,
      level: 5,
      role: 'Research Reader',
      focus: 'Machine Learning',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l15',
      name: 'Ainur',
      xp: 730,
      level: 5,
      role: 'Systems Generalist',
      focus: 'Computer Architecture',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l16',
      name: 'Nikita',
      xp: 690,
      level: 4,
      role: 'API Learner',
      focus: 'Backend',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l17',
      name: 'Asel',
      xp: 650,
      level: 4,
      role: 'Security Apprentice',
      focus: 'Cybersecurity',
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      id: 'l18',
      name: 'Ilia',
      xp: 620,
      level: 4,
      role: 'Cloud Curious',
      focus: 'SRE / DevOps',
      isCurrentUser: false,
    ),
  ];
}

List<LearningTrack> _buildTracksWithAssessments() {
  final baseTracks = <LearningTrack>[
    ...buildComputerScienceTracks(),
    ...buildItSphereTracks(),
  ];

  return baseTracks
      .map(
        (track) => track.copyWith(
          assessment: _buildAssessmentForTrack(track, baseTracks),
        ),
      )
      .toList(growable: false);
}

TrackAssessment _buildAssessmentForTrack(
  LearningTrack track,
  List<LearningTrack> allTracks,
) {
  final lessons = <LessonItem>[
    for (final module in track.modules) ...module.lessons,
  ];
  final practices = <PracticeTask>[
    for (final module in track.modules)
      if (module.practice != null) module.practice!,
  ];
  final connectionPool = allTracks
      .where((candidate) => track.connections.contains(candidate.id))
      .toList(growable: false);
  final outsidePool = allTracks
      .where(
        (candidate) =>
            candidate.id != track.id &&
            !track.connections.contains(candidate.id),
      )
      .toList(growable: false);

  final questions = <TrackAssessmentQuestion>[
    for (final lesson in lessons.take(4))
      _lessonAssessmentQuestion(track, lesson),
    _moduleLessonQuestion(
      id: '${track.id}_assessment_question_5',
      track: track,
      module: track.modules.first,
      correctLesson: track.modules.first.lessons.first,
      distractors: <String>[
        if (track.modules.first.lessons.length > 1)
          track.modules.first.lessons[1].title.en,
        if (track.modules.length > 1) track.modules[1].lessons.first.title.en,
        if (outsidePool.isNotEmpty)
          outsidePool.first.modules.first.lessons.first.title.en,
      ],
      seed: '${track.id}-module-a',
    ),
    _moduleLessonQuestion(
      id: '${track.id}_assessment_question_6',
      track: track,
      module: track.modules[1],
      correctLesson: track.modules[1].lessons.first,
      distractors: <String>[
        if (track.modules[1].lessons.length > 1)
          track.modules[1].lessons[1].title.en,
        track.modules.first.lessons.first.title.en,
        if (outsidePool.length > 1)
          outsidePool[1].modules.first.lessons.first.title.en,
      ],
      seed: '${track.id}-module-b',
    ),
    _practiceQuestion(
      id: '${track.id}_assessment_question_7',
      module: track.modules.first,
      correctPractice: practices.first,
      distractors: _practiceDistractors(
        allTracks,
        excludedPracticeIds: <String>{practices.first.id},
      ),
      seed: '${track.id}-practice-a',
    ),
    _practiceQuestion(
      id: '${track.id}_assessment_question_8',
      module: track.modules[1],
      correctPractice: practices[1],
      distractors: _practiceDistractors(
        allTracks,
        excludedPracticeIds: <String>{practices.first.id, practices[1].id},
      ),
      seed: '${track.id}-practice-b',
    ),
    _connectedTrackQuestion(
      id: '${track.id}_assessment_question_9',
      track: track,
      correctTrack: connectionPool.isNotEmpty
          ? connectionPool.first
          : outsidePool.first,
      distractorTracks: outsidePool.take(3).toList(growable: false),
      seed: '${track.id}-connections',
    ),
    _zoneQuestion(
      id: '${track.id}_assessment_question_10',
      track: track,
      seed: '${track.id}-zone',
    ),
  ];

  return TrackAssessment(
    id: '${track.id}_assessment',
    trackId: track.id,
    title: sameText('${track.title.en} assessment'),
    summary: sameText(
      'Answer 10 questions to validate your understanding of ${track.title.en}.',
    ),
    passPercent: 70,
    questions: questions,
  );
}

TrackAssessmentQuestion _lessonAssessmentQuestion(
  LearningTrack track,
  LessonItem lesson,
) {
  final quiz = lesson.quizzes.first;
  return TrackAssessmentQuestion(
    id: '${track.id}_assessment_${lesson.id}',
    prompt: sameText(
      '${lesson.title.en}: what does the code example print or return?',
    ),
    options: _rotateAssessmentOptions(
      quiz.options
          .map(
            (option) =>
                TrackAssessmentOption(id: option.id, label: option.label),
          )
          .toList(growable: false),
      lesson.id,
    ),
    correctOptionId: quiz.correctOptionId,
    explanation: quiz.explanation,
  );
}

TrackAssessmentQuestion _moduleLessonQuestion({
  required String id,
  required LearningTrack track,
  required LearningModule module,
  required LessonItem correctLesson,
  required List<String> distractors,
  required String seed,
}) {
  final options = _rotateAssessmentOptions(
    _buildStringOptions(
      correctId: 'correct',
      correctLabel: correctLesson.title.en,
      distractorLabels: distractors,
    ),
    seed,
  );

  return TrackAssessmentQuestion(
    id: id,
    prompt: sameText(
      'Which lesson belongs to the module "${module.title.en}" in ${track.title.en}?',
    ),
    options: options,
    correctOptionId: 'correct',
    explanation: sameText(
      '${correctLesson.title.en} is part of ${module.title.en}.',
    ),
  );
}

TrackAssessmentQuestion _practiceQuestion({
  required String id,
  required LearningModule module,
  required PracticeTask correctPractice,
  required List<String> distractors,
  required String seed,
}) {
  final options = _rotateAssessmentOptions(
    _buildStringOptions(
      correctId: 'correct',
      correctLabel: correctPractice.title.en,
      distractorLabels: distractors,
    ),
    seed,
  );

  return TrackAssessmentQuestion(
    id: id,
    prompt: sameText(
      'Which practice belongs to the module "${module.title.en}"?',
    ),
    options: options,
    correctOptionId: 'correct',
    explanation: sameText(
      '${correctPractice.title.en} is the hands-on task for ${module.title.en}.',
    ),
  );
}

TrackAssessmentQuestion _connectedTrackQuestion({
  required String id,
  required LearningTrack track,
  required LearningTrack correctTrack,
  required List<LearningTrack> distractorTracks,
  required String seed,
}) {
  final options = _rotateAssessmentOptions(
    _buildStringOptions(
      correctId: 'correct',
      correctLabel: correctTrack.title.en,
      distractorLabels: distractorTracks.map((item) => item.title.en).toList(),
    ),
    seed,
  );

  return TrackAssessmentQuestion(
    id: id,
    prompt: sameText(
      'Which branch is directly connected to ${track.title.en} on the knowledge tree?',
    ),
    options: options,
    correctOptionId: 'correct',
    explanation: sameText(
      '${correctTrack.title.en} is connected to ${track.title.en} in the map configuration.',
    ),
  );
}

TrackAssessmentQuestion _zoneQuestion({
  required String id,
  required LearningTrack track,
  required String seed,
}) {
  final correctLabel = track.zone == TrackZone.computerScienceCore
      ? 'Computer Science Core'
      : 'Applied IT Spheres';
  final options = _rotateAssessmentOptions(const <TrackAssessmentOption>[
    TrackAssessmentOption(
      id: 'core',
      label: LocalizedText(
        ru: 'Computer Science Core',
        en: 'Computer Science Core',
        kk: 'Computer Science Core',
      ),
    ),
    TrackAssessmentOption(
      id: 'spheres',
      label: LocalizedText(
        ru: 'Applied IT Spheres',
        en: 'Applied IT Spheres',
        kk: 'Applied IT Spheres',
      ),
    ),
    TrackAssessmentOption(
      id: 'community',
      label: LocalizedText(
        ru: 'Community Courses',
        en: 'Community Courses',
        kk: 'Community Courses',
      ),
    ),
    TrackAssessmentOption(
      id: 'mentor',
      label: LocalizedText(ru: 'AI Mentor', en: 'AI Mentor', kk: 'AI Mentor'),
    ),
  ], seed);

  return TrackAssessmentQuestion(
    id: id,
    prompt: sameText('Which zone contains the track ${track.title.en}?'),
    options: options,
    correctOptionId: correctLabel == 'Computer Science Core'
        ? 'core'
        : 'spheres',
    explanation: sameText('${track.title.en} belongs to $correctLabel.'),
  );
}

List<String> _practiceDistractors(
  List<LearningTrack> tracks, {
  required Set<String> excludedPracticeIds,
}) {
  return <String>[
    for (final track in tracks)
      for (final module in track.modules)
        if (module.practice != null &&
            !excludedPracticeIds.contains(module.practice!.id))
          module.practice!.title.en,
  ].take(3).toList(growable: false);
}

List<TrackAssessmentOption> _buildStringOptions({
  required String correctId,
  required String correctLabel,
  required List<String> distractorLabels,
}) {
  final labels = <String>[correctLabel];
  for (final label in distractorLabels) {
    if (!labels.contains(label)) {
      labels.add(label);
    }
    if (labels.length == 4) {
      break;
    }
  }

  while (labels.length < 4) {
    labels.add('Option ${labels.length + 1}');
  }

  return <TrackAssessmentOption>[
    TrackAssessmentOption(id: correctId, label: sameText(correctLabel)),
    for (var index = 1; index < labels.length; index++)
      TrackAssessmentOption(
        id: 'option_$index',
        label: sameText(labels[index]),
      ),
  ];
}

List<TrackAssessmentOption> _rotateAssessmentOptions(
  List<TrackAssessmentOption> options,
  String seed,
) {
  if (options.length < 2) {
    return options;
  }

  final rotation = _hashValue(seed) % options.length;
  return <TrackAssessmentOption>[
    ...options.skip(rotation),
    ...options.take(rotation),
  ];
}

int _hashValue(String value) {
  var hash = 0;
  for (final codeUnit in value.codeUnits) {
    hash = ((hash * 31) + codeUnit) & 0x7fffffff;
  }
  return hash;
}

bool _isModuleCompleted(DemoAppState state, LearningModule module) {
  final lessonsDone = module.lessons.every(
    (lesson) => state.completedLessonIds.contains(lesson.id),
  );
  final practiceDone =
      module.practice == null ||
      state.completedPracticeIds.contains(module.practice!.id);
  return lessonsDone && practiceDone;
}
