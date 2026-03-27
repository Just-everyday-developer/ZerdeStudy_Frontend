class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordCode = '/forgot-password-code';
  static const String home = '/home';
  static const String tree = '/tree';
  static const String learn = '/learn';
  static const String ai = '/ai';
  static const String profile = '/profile';
  static const String profilePreview = '/profile-preview';
  static const String track = '/track';
  static const String lesson = '/lesson';
  static const String practice = '/practice';
  static const String assessment = '/assessment';
  static const String stats = '/stats';
  static const String leaderboard = '/leaderboard';
  static const String faq = '/faq';
  static const String courses = '/courses';
  static const String coursePlayer = '/course-player';
  static const String moderator = '/moderator';
  static const String moderatorCourses = '/moderator/courses';
  static const String moderatorReports = '/moderator/reports';
  static const String moderatorFaq = '/moderator/faq';

  static String trackById(String trackId) => '$track/$trackId';

  static String lessonById(String lessonId) => '$lesson/$lessonId';

  static String practiceById(String practiceId) => '$practice/$practiceId';

  static String assessmentByTrackId(String trackId) => '$assessment/$trackId';

  static String courseById(String courseId) => '$courses/$courseId';

  static String forgotPasswordCodeWithEmail(String email) {
    final uri = Uri(
      path: forgotPasswordCode,
      queryParameters: <String, String>{
        'email': email,
      },
    );
    return uri.toString();
  }

  static String coursePlayerById(String courseId, {bool skipIntro = false}) {
    final uri = Uri(
      path: '$coursePlayer/$courseId',
      queryParameters: skipIntro ? const <String, String>{'skipIntro': '1'} : null,
    );
    return uri.toString();
  }

  static String coursesCatalog({
    String? topic,
    String? search,
    String? level,
    double? minRating,
    String? duration,
    bool? certificate,
  }) {
    final queryParameters = <String, String>{
      if (topic != null && topic.isNotEmpty) 'topic': topic,
      if (search != null && search.isNotEmpty) 'search': search,
      if (level != null && level.isNotEmpty) 'level': level,
      if (minRating != null && minRating > 0) 'minRating': '$minRating',
      if (duration != null && duration.isNotEmpty) 'duration': duration,
      if (certificate == true) 'certificate': '1',
    };
    final uri = Uri(path: courses, queryParameters: queryParameters);
    return uri.toString();
  }
}
