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
  static const String stats = '/stats';
  static const String leaderboard = '/leaderboard';

  static String trackById(String trackId) => '$track/$trackId';

  static String lessonById(String lessonId) => '$lesson/$lessonId';

  static String practiceById(String practiceId) => '$practice/$practiceId';
}
