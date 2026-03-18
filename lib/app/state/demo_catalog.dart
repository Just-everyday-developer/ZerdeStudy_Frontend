import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'demo_app_state.dart';
import 'demo_catalog_cs_data.dart';
import 'demo_catalog_it_data.dart';
import 'demo_catalog_support.dart';
import 'demo_models.dart';

class DemoCatalog {
  DemoCatalog()
      : tracks = <LearningTrack>[
          ...buildComputerScienceTracks(),
          ...buildItSphereTracks(),
        ],
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
  late final Map<String, CommunityCourse> _coursesById =
      <String, CommunityCourse>{
    for (final course in communityCourses) course.id: course,
  };

  LearningTrack trackById(String trackId) => _tracksById[trackId] ?? tracks.first;

  LessonItem lessonById(String lessonId) =>
      _lessonsById[lessonId] ?? _lessonsById.values.first;

  PracticeTask practiceById(String practiceId) =>
      _practicesById[practiceId] ?? _practicesById.values.first;

  CommunityCourse courseById(String courseId) =>
      _coursesById[courseId] ?? communityCourses.first;

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
    return tracksForZone(zone)
        .fold<int>(0, (sum, track) => sum + _completedUnitsForTrack(state, track));
  }

  int totalUnitsForZone(TrackZone zone) {
    return tracksForZone(zone).fold<int>(0, (sum, track) => sum + track.totalUnits);
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
      completedTrainers: trainerIds.where(state.completedTrainerIds.contains).length,
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

  int totalUnits() => tracks.fold<int>(0, (sum, track) => sum + track.totalUnits);

  int totalCompletedUnits(DemoAppState state) =>
      state.completedLessonIds.length + state.completedPracticeIds.length;

  int totalQuizzes() =>
      tracks.fold<int>(0, (sum, track) => sum + track.totalQuizzes);

  int totalTrainers() =>
      tracks.fold<int>(0, (sum, track) => sum + track.totalTrainers);

  int completedTracks(DemoAppState state) {
    return tracks
        .where((track) {
          final availability = trackAvailabilityFor(state, track.id);
          return availability == TrackAvailability.completed ||
              availability == TrackAvailability.mastered;
        })
        .length;
  }

  int masteredTracks(DemoAppState state) {
    return tracks
        .where((track) => trackAvailabilityFor(state, track.id) == TrackAvailability.mastered)
        .length;
  }

  List<Achievement> achievementsFor(DemoAppState state) {
    final completedLessons = state.completedLessonIds.length;
    final completedPractices = state.completedPracticeIds.length;
    final completedQuizzes = state.completedQuizIds.length;
    final completedTrainers = state.completedTrainerIds.length;
    final userMessages =
        state.aiMessages.where((message) => message.author == AiAuthor.user).length;
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
    ]
        .where((id) => _isTrackFinished(state, id)).length;
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
    ]
        .where((id) => _isTrackFinished(state, id)).length;
    final courseSignals =
        state.viewedCommunityCourseIds.length + state.savedCommunityCourseIds.length;
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
    final algorithmDone =
        _isTrackFinished(state, 'algorithms_data_structures') ? 1 : 0;
    final networkDone =
        _isTrackFinished(state, 'networking_protocols') ? 1 : 0;
    final mlEngineerDone =
        _isTrackFinished(state, 'machine_learning') ? 1 : 0;
    final qaDone = _isTrackFinished(state, 'qa_engineering') ? 1 : 0;
    final systemAdminDone =
        _isTrackFinished(state, 'system_administration') ? 1 : 0;
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
      _achievement('first_step', 'First step', 'Complete the first lesson in any branch.', Icons.flag_rounded, 1, completedLessons),
      _achievement('lesson_runner', 'Lesson runner', 'Finish 6 lessons across the tree.', Icons.play_lesson_rounded, 6, completedLessons),
      _achievement('practice_engineer', 'Practice engineer', 'Close 4 hands-on tasks.', Icons.code_rounded, 4, completedPractices),
      _achievement('quiz_scout', 'Quiz scout', 'Solve 10 output quizzes.', Icons.quiz_rounded, 10, completedQuizzes),
      _achievement('memory_builder', 'Memory builder', 'Finish 10 code memory labs.', Icons.memory_rounded, 10, completedTrainers),
      _achievement('streak_7', 'Seven day pulse', 'Reach a 7-day streak.', Icons.local_fire_department_rounded, 7, state.streak),
      _achievement('xp_900', 'XP 900', 'Cross 900 XP in the demo.', Icons.bolt_rounded, 900, state.xp),
      _achievement('ai_partner', 'AI partner', 'Send 6 questions to the mentor.', Icons.smart_toy_rounded, 6, userMessages),
      _achievement('cs_core_explorer', 'CS core explorer', 'Finish 2 Computer Science Core tracks.', Icons.hub_rounded, 2, csDone),
      _achievement('sphere_builder', 'Sphere builder', 'Finish 2 IT sphere tracks.', Icons.auto_awesome_mosaic_rounded, 2, itDone),
      _achievement('frontend_ready', 'Frontend ready', 'Close the Frontend track.', Icons.web_rounded, 1, frontendDone),
      _achievement('systems_foundation', 'Systems foundation', 'Close the Operating Systems track.', Icons.developer_board_rounded, 1, systemsDone),
      _achievement('data_confidence', 'Data confidence', 'Finish Databases and Probability/Statistics.', Icons.insights_rounded, 2, dataDone),
      _achievement('math_canopy', 'Math canopy', 'Finish 3 mathematical foundation branches.', Icons.calculate_rounded, 3, mathRootsDone),
      _achievement('algorithmic_mindset', 'Algorithmic mindset', 'Close Algorithms & Data Structures.', Icons.account_tree_rounded, 1, algorithmDone),
      _achievement('network_mapper', 'Network mapper', 'Close Information Networks.', Icons.hub_rounded, 1, networkDone),
      _achievement('mobile_forest', 'Mobile forest', 'Finish 3 mobile-related branches.', Icons.devices_rounded, 3, mobileBranchesDone),
      _achievement('qa_guardian', 'QA guardian', 'Close the QA Engineer branch.', Icons.fact_check_rounded, 1, qaDone),
      _achievement('ops_keeper', 'Ops keeper', 'Close the System Administration branch.', Icons.admin_panel_settings_rounded, 1, systemAdminDone),
      _achievement('ml_pathfinder', 'ML pathfinder', 'Close the ML Engineer branch.', Icons.psychology_alt_rounded, 1, mlEngineerDone),
      _achievement('security_stack', 'Security stack', 'Finish Information Security and Cybersecurity.', Icons.shield_rounded, 2, securityStackDone),
      _achievement('community_curator', 'Community curator', 'View or save 4 community courses.', Icons.groups_rounded, 4, courseSignals),
      _achievement('mastery_badges', 'Mastery badges', 'Master 2 tracks with perfect quiz accuracy.', Icons.workspace_premium_rounded, 2, masteredTracks(state)),
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
    return <LocalizedText>[
      sameText('Completed ${totalCompletedUnits(state)} units across ${_activeTracks(state)} active branches.'),
      sameText('Quiz accuracy: ${(state.quizAccuracy * 100).round()}%.'),
      sameText('Community courses: ${state.viewedCommunityCourseIds.length} viewed, ${state.savedCommunityCourseIds.length} saved.'),
      sameText('Mastered tracks: ${masteredTracks(state)}.'),
    ];
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
    return pool[_stableHash('${state.currentTrackId}|$focus|$normalized') % pool.length];
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
    if (_containsAny(normalized, <String>['tree', 'branch', 'ветк', 'дерево'])) {
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
    if (_containsAny(normalized, <String>['course', 'community', 'курс', 'user'])) {
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
      final lessonsDone =
          module.lessons.where((lesson) => state.completedLessonIds.contains(lesson.id)).length;
      final practiceDone =
          module.practice != null && state.completedPracticeIds.contains(module.practice!.id)
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
  return <CommunityCourse>[
    buildCommunityCourse(
      id: 'course_portfolio_engineering',
      title: 'Portfolio Engineering for Students',
      subtitle: 'Turn side projects into convincing product stories',
      description: 'A mock course on structuring projects, demos, and README narratives for internships.',
      level: 'Beginner',
      rating: 4.8,
      enrollmentCount: 1240,
      estimatedHours: 5,
      color: AppColors.primary,
      author: const CommunityCourseAuthor(name: 'Aruzhan Bek', role: 'Product Engineer', accentLabel: 'Demo design'),
      tags: <String>['portfolio', 'frontend', 'career'],
      lessons: <CommunityCourseLessonPreview>[
        buildCourseLesson('Tell the project story', 'Frame the problem, the user, and the outcome.'),
        buildCourseLesson('Show technical depth', 'Pick 2-3 implementation decisions worth discussing.'),
        buildCourseLesson('Present without dead ends', 'Design a demo flow that feels alive and intentional.'),
      ],
    ),
    buildCommunityCourse(
      id: 'course_sql_for_analysts',
      title: 'SQL for Product Analysts',
      subtitle: 'Queries, cohorts, funnels, and experiment reads',
      description: 'A mock community course that packages practical SQL patterns around product questions.',
      level: 'Intermediate',
      rating: 4.7,
      enrollmentCount: 980,
      estimatedHours: 7,
      color: const Color(0xFFFFD166),
      author: const CommunityCourseAuthor(name: 'Maksat Y.', role: 'Analytics Lead', accentLabel: 'SQL coaching'),
      tags: <String>['sql', 'analytics', 'experiments'],
      lessons: <CommunityCourseLessonPreview>[
        buildCourseLesson('Count, filter, compare', 'Write readable queries for product metrics.'),
        buildCourseLesson('Funnel reasoning', 'Translate behavior into stage-based analysis.'),
        buildCourseLesson('Experiment snapshots', 'Read lift without overstating certainty.'),
      ],
    ),
    buildCommunityCourse(
      id: 'course_ml_journal_club',
      title: 'ML Journal Club Lite',
      subtitle: 'Read one paper idea and map it into product language',
      description: 'A mock club-style course that connects research ideas to product intuition.',
      level: 'Intermediate',
      rating: 4.9,
      enrollmentCount: 560,
      estimatedHours: 4,
      color: const Color(0xFFA78BFA),
      author: const CommunityCourseAuthor(name: 'Dana S.', role: 'ML Engineer', accentLabel: 'Research to product'),
      tags: <String>['ml', 'reading', 'research'],
      lessons: <CommunityCourseLessonPreview>[
        buildCourseLesson('Read the abstract for product meaning', 'Extract the real-world problem quickly.'),
        buildCourseLesson('Map methods to intuition', 'Explain the method without dense notation.'),
        buildCourseLesson('Find deployment relevance', 'Identify where the idea fits in a product.'),
      ],
    ),
    buildCommunityCourse(
      id: 'course_secure_api_clinic',
      title: 'Secure API Clinic',
      subtitle: 'A guided walkthrough of auth, validation, and incident hints',
      description: 'A mock course from a staff backend engineer focused on defensive API design.',
      level: 'Advanced',
      rating: 4.6,
      enrollmentCount: 430,
      estimatedHours: 6,
      color: AppColors.danger,
      author: const CommunityCourseAuthor(name: 'Rustem K.', role: 'Staff Backend Engineer', accentLabel: 'Security review'),
      tags: <String>['security', 'backend', 'api'],
      lessons: <CommunityCourseLessonPreview>[
        buildCourseLesson('Threat model the endpoint', 'Identify assets, actors, and misuse paths early.'),
        buildCourseLesson('Validate at the edge', 'Reduce trust assumptions before deeper logic.'),
        buildCourseLesson('Observe and respond', 'Connect signals to an action plan.'),
      ],
    ),
    buildCommunityCourse(
      id: 'course_design_systems_from_scratch',
      title: 'Design Systems from Scratch',
      subtitle: 'Tokens, hierarchy, reusable components, and product coherence',
      description: 'A mock course that frames design systems as a language for teams.',
      level: 'Intermediate',
      rating: 4.8,
      enrollmentCount: 760,
      estimatedHours: 5,
      color: const Color(0xFFFF9F68),
      author: const CommunityCourseAuthor(name: 'Aigerim N.', role: 'Design Systems Lead', accentLabel: 'UI systems'),
      tags: <String>['design-system', 'frontend', 'mobile'],
      lessons: <CommunityCourseLessonPreview>[
        buildCourseLesson('Name your primitives', 'Create a vocabulary for surfaces and emphasis.'),
        buildCourseLesson('Design for states', 'Component systems are strongest when states are first-class.'),
        buildCourseLesson('Teach the system', 'Adoption depends on examples and narrative, not only tokens.'),
      ],
    ),
  ];
}

List<LeaderboardEntry> _buildLeaderboardSeed() {
  return const <LeaderboardEntry>[
    LeaderboardEntry(id: 'l1', name: 'Nursultan', xp: 1320, level: 8, role: 'Backend Explorer', focus: 'Databases', isCurrentUser: false),
    LeaderboardEntry(id: 'l2', name: 'Mira', xp: 1280, level: 8, role: 'Frontend Builder', focus: 'Frontend', isCurrentUser: false),
    LeaderboardEntry(id: 'l3', name: 'Dias', xp: 1210, level: 7, role: 'Systems Learner', focus: 'Operating Systems', isCurrentUser: false),
    LeaderboardEntry(id: 'l4', name: 'Aruzhan', xp: 1170, level: 7, role: 'ML Apprentice', focus: 'Machine Learning', isCurrentUser: false),
    LeaderboardEntry(id: 'l5', name: 'Talgat', xp: 1115, level: 7, role: 'Reliability Learner', focus: 'SRE / DevOps', isCurrentUser: false),
    LeaderboardEntry(id: 'l6', name: 'Sofia', xp: 1090, level: 7, role: 'Security Watcher', focus: 'Cybersecurity', isCurrentUser: false),
    LeaderboardEntry(id: 'l7', name: 'Adilet', xp: 1035, level: 6, role: 'Math Track Learner', focus: 'Discrete Math', isCurrentUser: false),
    LeaderboardEntry(id: 'l8', name: 'Zarina', xp: 980, level: 6, role: 'Data Storyteller', focus: 'Probability & Analytics', isCurrentUser: false),
    LeaderboardEntry(id: 'l9', name: 'Bekzat', xp: 950, level: 6, role: 'Protocol Mapper', focus: 'Networks', isCurrentUser: false),
    LeaderboardEntry(id: 'l10', name: 'Madina', xp: 910, level: 6, role: 'Mobile Builder', focus: 'Mobile', isCurrentUser: false),
    LeaderboardEntry(id: 'l11', name: 'Ayan', xp: 860, level: 5, role: 'Product Analyst', focus: 'Databases', isCurrentUser: false),
    LeaderboardEntry(id: 'l12', name: 'Alina', xp: 830, level: 5, role: 'App Generalist', focus: 'Fundamentals', isCurrentUser: false),
    LeaderboardEntry(id: 'l13', name: 'Yernar', xp: 790, level: 5, role: 'UI Explorer', focus: 'Frontend', isCurrentUser: false),
    LeaderboardEntry(id: 'l14', name: 'Tomiris', xp: 760, level: 5, role: 'Research Reader', focus: 'Machine Learning', isCurrentUser: false),
    LeaderboardEntry(id: 'l15', name: 'Ainur', xp: 730, level: 5, role: 'Systems Generalist', focus: 'Computer Architecture', isCurrentUser: false),
    LeaderboardEntry(id: 'l16', name: 'Nikita', xp: 690, level: 4, role: 'API Learner', focus: 'Backend', isCurrentUser: false),
    LeaderboardEntry(id: 'l17', name: 'Asel', xp: 650, level: 4, role: 'Security Apprentice', focus: 'Cybersecurity', isCurrentUser: false),
    LeaderboardEntry(id: 'l18', name: 'Ilia', xp: 620, level: 4, role: 'Cloud Curious', focus: 'SRE / DevOps', isCurrentUser: false),
  ];
}
