class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String tree = '/tree';
  static const String learn = '/learn';
  static const String ai = '/ai';
  static const String profile = '/profile';
  static const String track = '/track';
  static const String lesson = '/lesson';
  static const String practice = '/practice';
  static const String assessment = '/assessment';
  static const String stats = '/stats';
  static const String leaderboard = '/leaderboard';
  static const String courses = '/courses';

  static String trackById(String trackId) => '$track/$trackId';

  static String lessonById(String lessonId) => '$lesson/$lessonId';

  static String practiceById(String practiceId) => '$practice/$practiceId';

  static String assessmentByTrackId(String trackId) => '$assessment/$trackId';

  static String courseById(String courseId) => '$courses/$courseId';

  static String coursesCatalog({
    String? topic,
    String? search,
    String? level,
    String? author,
  }) {
    final queryParameters = <String, String>{
      if (topic != null && topic.isNotEmpty) 'topic': topic,
      if (search != null && search.isNotEmpty) 'search': search,
      if (level != null && level.isNotEmpty) 'level': level,
      if (author != null && author.isNotEmpty) 'author': author,
    };
    final uri = Uri(path: courses, queryParameters: queryParameters);
    return uri.toString();
  }
}
