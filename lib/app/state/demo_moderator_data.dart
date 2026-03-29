// Demo data for the moderator panel

class ModPendingCourse {
  const ModPendingCourse({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.submittedAt,
    required this.lessonCount,
    required this.duration,
    required this.description,
  });
  final String id;
  final String title;
  final String author;
  final String category;
  final String submittedAt;
  final int lessonCount;
  final String duration;
  final String description;
}

class ModReport {
  const ModReport({
    required this.id,
    required this.type,
    required this.priority,
    required this.initiator,
    required this.target,
    required this.reason,
    required this.content,
    required this.createdAt,
    this.resolved = false,
  });
  final String id;
  final String type; // 'user' | 'comment' | 'course'
  final String priority; // 'high' | 'medium' | 'low'
  final String initiator;
  final String target;
  final String reason;
  final String content;
  final String createdAt;
  final bool resolved;
}

class ModFaqQuestion {
  const ModFaqQuestion({
    required this.id,
    required this.question,
    required this.askedBy,
    required this.askedAt,
    required this.answer,
    this.isPublic = false,
  });
  final String id;
  final String question;
  final String askedBy;
  final String askedAt;
  final String answer;
  final bool isPublic;
}

class ModActivityEntry {
  const ModActivityEntry({
    required this.text,
    required this.time,
    required this.type, // 'ban' | 'approve' | 'reject' | 'warn'
  });
  final String text;
  final String time;
  final String type;
}

enum ModCommentStatus { needsReview, hidden, approved, escalated }

class ModCommentItem {
  const ModCommentItem({
    required this.id,
    required this.author,
    required this.surface,
    required this.location,
    required this.content,
    required this.reportCount,
    required this.reportedAt,
    required this.reasons,
    required this.status,
    required this.riskSignals,
  });

  final String id;
  final String author;
  final String surface;
  final String location;
  final String content;
  final int reportCount;
  final String reportedAt;
  final List<String> reasons;
  final ModCommentStatus status;
  final List<String> riskSignals;

  ModCommentItem copyWith({ModCommentStatus? status}) {
    return ModCommentItem(
      id: id,
      author: author,
      surface: surface,
      location: location,
      content: content,
      reportCount: reportCount,
      reportedAt: reportedAt,
      reasons: reasons,
      status: status ?? this.status,
      riskSignals: riskSignals,
    );
  }
}

enum ModCommunityContentType { group, media, links }

enum ModCommunityContentStatus { needsReview, limited, approved, archived }

class ModCommunityContentItem {
  const ModCommunityContentItem({
    required this.id,
    required this.title,
    required this.owner,
    required this.type,
    required this.status,
    required this.visibility,
    required this.reportCount,
    required this.lastActivityAt,
    required this.summary,
    required this.tags,
    required this.riskSignals,
    required this.memberCount,
    required this.mediaCount,
    required this.linkCount,
  });

  final String id;
  final String title;
  final String owner;
  final ModCommunityContentType type;
  final ModCommunityContentStatus status;
  final String visibility;
  final int reportCount;
  final String lastActivityAt;
  final String summary;
  final List<String> tags;
  final List<String> riskSignals;
  final int memberCount;
  final int mediaCount;
  final int linkCount;

  ModCommunityContentItem copyWith({ModCommunityContentStatus? status}) {
    return ModCommunityContentItem(
      id: id,
      title: title,
      owner: owner,
      type: type,
      status: status ?? this.status,
      visibility: visibility,
      reportCount: reportCount,
      lastActivityAt: lastActivityAt,
      summary: summary,
      tags: tags,
      riskSignals: riskSignals,
      memberCount: memberCount,
      mediaCount: mediaCount,
      linkCount: linkCount,
    );
  }
}

const List<ModPendingCourse> kModPendingCourses = [
  ModPendingCourse(
    id: 'mc1',
    title: 'Go для профессионалов',
    author: 'Иван Петров',
    category: 'Программирование',
    submittedAt: '23 марта, 14:30',
    lessonCount: 24,
    duration: '8ч 20мин',
    description:
        'Продвинутый курс по языку Go: горутины, каналы, паттерны concurrency, профилирование и оптимизация.',
  ),
  ModPendingCourse(
    id: 'mc2',
    title: 'Flutter с нуля до продакшена',
    author: 'Айгерим Сейткалиева',
    category: 'Мобильная разработка',
    submittedAt: '23 марта, 11:15',
    lessonCount: 32,
    duration: '12ч 05мин',
    description:
        'Полный курс по Flutter: виджеты, Riverpod, GoRouter, публикация в App Store и Google Play.',
  ),
  ModPendingCourse(
    id: 'mc3',
    title: 'Data Science на Python',
    author: 'Марат Жаксыбеков',
    category: 'Аналитика данных',
    submittedAt: '22 марта, 18:45',
    lessonCount: 18,
    duration: '6ч 40мин',
    description:
        'Pandas, NumPy, Matplotlib, sklearn. Практические проекты на реальных датасетах.',
  ),
  ModPendingCourse(
    id: 'mc4',
    title: 'Основы кибербезопасности',
    author: 'Дмитрий Волков',
    category: 'Безопасность',
    submittedAt: '22 марта, 09:20',
    lessonCount: 15,
    duration: '5ч 10мин',
    description:
        'SQL-инъекции, XSS, CSRF, основы криптографии, пентестинг с разрешения владельца.',
  ),
  ModPendingCourse(
    id: 'mc5',
    title: 'Алгоритмы и структуры данных',
    author: 'Наталья Кузнецова',
    category: 'Программирование',
    submittedAt: '21 марта, 16:00',
    lessonCount: 28,
    duration: '10ч 30мин',
    description:
        'Сортировки, деревья, графы, динамическое программирование. Подготовка к техническому интервью.',
  ),
];

const List<ModReport> kModReports = [
  ModReport(
    id: 'r1',
    type: 'comment',
    priority: 'high',
    initiator: 'user_alex92',
    target: 'user_spammer123',
    reason: 'Спам',
    content:
        'Купите курс со скидкой 90%! Только сегодня! Ссылка: http://spam-link.ru',
    createdAt: '24 марта, 08:15',
  ),
  ModReport(
    id: 'r2',
    type: 'user',
    priority: 'high',
    initiator: 'user_dana',
    target: 'user_hate99',
    reason: 'Оскорбление',
    content:
        'Пользователь систематически оскорбляет других студентов в комментариях.',
    createdAt: '24 марта, 07:45',
  ),
  ModReport(
    id: 'r3',
    type: 'course',
    priority: 'medium',
    initiator: 'system',
    target: 'Курс "Взлом за 5 минут"',
    reason: 'Нарушение правил платформы',
    content:
        'Курс обучает незаконному доступу к системам без разрешения владельца.',
    createdAt: '23 марта, 22:10',
  ),
  ModReport(
    id: 'r4',
    type: 'comment',
    priority: 'medium',
    initiator: 'user_marat',
    target: 'user_troll45',
    reason: 'Троллинг',
    content: 'Этот урок — полная чушь, автор ничего не понимает в теме.',
    createdAt: '23 марта, 19:30',
  ),
  ModReport(
    id: 'r5',
    type: 'user',
    priority: 'low',
    initiator: 'user_aigerim',
    target: 'user_newbie77',
    reason: 'Нежелательный контент',
    content: 'Пользователь публикует нерелевантные ссылки в нескольких курсах.',
    createdAt: '23 марта, 15:20',
  ),
  ModReport(
    id: 'r6',
    type: 'comment',
    priority: 'low',
    initiator: 'user_test1',
    target: 'user_advert',
    reason: 'Реклама',
    content: 'Мой канал в Telegram для программистов! Подписывайтесь!',
    createdAt: '22 марта, 21:00',
  ),
];

const List<ModFaqQuestion> kModFaqQuestions = [
  ModFaqQuestion(
    id: 'fq1',
    question: 'Как сбросить прогресс по курсу и начать заново?',
    askedBy: 'user_anna',
    askedAt: '24 марта, 10:00',
    answer: '',
  ),
  ModFaqQuestion(
    id: 'fq2',
    question: 'Почему мой сертификат не отображается в профиле?',
    askedBy: 'user_timur',
    askedAt: '23 марта, 18:30',
    answer:
        'Сертификаты появляются в профиле в течение 24 часов после завершения курса. Если прошло больше — обратитесь в поддержку.',
    isPublic: true,
  ),
  ModFaqQuestion(
    id: 'fq3',
    question: 'Можно ли получить возврат денег за курс?',
    askedBy: 'user_sergey',
    askedAt: '23 марта, 12:15',
    answer: '',
  ),
  ModFaqQuestion(
    id: 'fq4',
    question: 'Как добавить курс в избранное?',
    askedBy: 'user_zarina',
    askedAt: '22 марта, 20:45',
    answer:
        'Нажмите на иконку закладки на карточке курса или внутри курса в правом верхнем углу.',
    isPublic: true,
  ),
  ModFaqQuestion(
    id: 'fq5',
    question: 'Мобильное приложение работает офлайн?',
    askedBy: 'user_nikita',
    askedAt: '22 марта, 09:00',
    answer: '',
  ),
];

const List<ModActivityEntry> kModRecentActivity = [
  ModActivityEntry(
    text: 'Модератор Admin забанил курс "Взлом за 5 минут"',
    time: '2 часа назад',
    type: 'ban',
  ),
  ModActivityEntry(
    text: 'Курс "React для начинающих" одобрен и опубликован',
    time: '3 часа назад',
    type: 'approve',
  ),
  ModActivityEntry(
    text: 'Жалоба на user_spammer отклонена (недостаточно доказательств)',
    time: '5 часов назад',
    type: 'reject',
  ),
  ModActivityEntry(
    text: 'Пользователь user_hate99 получил предупреждение',
    time: '6 часов назад',
    type: 'warn',
  ),
  ModActivityEntry(
    text: 'Курс "Основы SQL" отклонён с комментарием: улучшить качество видео',
    time: 'Вчера',
    type: 'reject',
  ),
  ModActivityEntry(
    text: 'Курс "Python для аналитиков" одобрен и опубликован',
    time: 'Вчера',
    type: 'approve',
  ),
];

const List<ModCommentItem> kModCommentItems = [
  ModCommentItem(
    id: 'comment_1',
    author: 'user_hate99',
    surface: 'Course comments',
    location: 'Flutter from zero to production',
    content:
        'This lesson is useless, the author clearly does not understand the topic at all.',
    reportCount: 6,
    reportedAt: '24 Mar, 09:40',
    reasons: <String>['Insult', 'Trolling'],
    status: ModCommentStatus.needsReview,
    riskSignals: <String>[
      'Repeated negativity across 3 threads',
      'Two prior warnings in the last 14 days',
    ],
  ),
  ModCommentItem(
    id: 'comment_2',
    author: 'user_spammer123',
    surface: 'Community group',
    location: 'Flutter Builders Hub',
    content:
        'Join my private channel and get all paid courses for 90% off today only: spam-link.example',
    reportCount: 9,
    reportedAt: '24 Mar, 08:05',
    reasons: <String>['Spam', 'Suspicious links'],
    status: ModCommentStatus.hidden,
    riskSignals: <String>[
      'External link shared 12 times',
      'Triggered auto-spam pattern',
    ],
  ),
  ModCommentItem(
    id: 'comment_3',
    author: 'user_recruiter77',
    surface: 'Group media thread',
    location: 'Career Lift for Juniors',
    content: 'DM me for guaranteed placement if you send a payment first.',
    reportCount: 4,
    reportedAt: '23 Mar, 18:20',
    reasons: <String>['Fraud risk'],
    status: ModCommentStatus.escalated,
    riskSignals: <String>[
      'Payment request detected',
      'Escalated by automated fraud rule',
    ],
  ),
  ModCommentItem(
    id: 'comment_4',
    author: 'user_productive',
    surface: 'Course comments',
    location: 'SQL Interview Circle',
    content:
        'The last query explanation is still confusing, can we get one more worked example?',
    reportCount: 1,
    reportedAt: '23 Mar, 12:10',
    reasons: <String>['Needs context'],
    status: ModCommentStatus.approved,
    riskSignals: <String>['Low severity review'],
  ),
];

const List<ModCommunityContentItem> kModCommunityContentItems = [
  ModCommunityContentItem(
    id: 'community_1',
    title: 'Career Lift for Juniors',
    owner: 'Dana P.',
    type: ModCommunityContentType.group,
    status: ModCommunityContentStatus.needsReview,
    visibility: 'Open group',
    reportCount: 5,
    lastActivityAt: '24 Mar, 10:05',
    summary:
        'Career support group with CV reviews, group calls, and job-hunt resources.',
    tags: <String>['career', 'cv', 'interview'],
    riskSignals: <String>[
      'Off-platform payment promises mentioned in a linked thread',
      'Two reports mention misleading guarantees',
    ],
    memberCount: 31,
    mediaCount: 11,
    linkCount: 7,
  ),
  ModCommunityContentItem(
    id: 'community_2',
    title: 'Flutter Builders resource dump',
    owner: 'Ruslan K.',
    type: ModCommunityContentType.links,
    status: ModCommunityContentStatus.limited,
    visibility: 'Members only',
    reportCount: 3,
    lastActivityAt: '24 Mar, 07:55',
    summary:
        'Shared links bundle for UI references, repos, and workshop recordings.',
    tags: <String>['flutter', 'resources', 'links'],
    riskSignals: <String>[
      'One copyright claim on an external video link',
      'Needs link-by-link validation',
    ],
    memberCount: 24,
    mediaCount: 18,
    linkCount: 6,
  ),
  ModCommunityContentItem(
    id: 'community_3',
    title: 'SQL Circle whiteboard clips',
    owner: 'Madina S.',
    type: ModCommunityContentType.media,
    status: ModCommunityContentStatus.needsReview,
    visibility: 'Private group',
    reportCount: 2,
    lastActivityAt: '23 Mar, 20:10',
    summary:
        'Recorded walkthroughs and whiteboard clips from the weekend mock interview session.',
    tags: <String>['sql', 'media', 'mock'],
    riskSignals: <String>[
      'Audio quality issue in one clip',
      'One report flags off-topic language',
    ],
    memberCount: 16,
    mediaCount: 9,
    linkCount: 5,
  ),
  ModCommunityContentItem(
    id: 'community_4',
    title: 'AI Start study lounge',
    owner: 'Aruzhan B.',
    type: ModCommunityContentType.group,
    status: ModCommunityContentStatus.approved,
    visibility: 'Open group',
    reportCount: 0,
    lastActivityAt: '23 Mar, 16:45',
    summary:
        'Beginner-friendly study lounge for AI fundamentals, weekly check-ins, and practice prompts.',
    tags: <String>['ai', 'study', 'beginners'],
    riskSignals: <String>['No current alerts'],
    memberCount: 19,
    mediaCount: 4,
    linkCount: 3,
  ),
];
