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
    content: 'Купите курс со скидкой 90%! Только сегодня! Ссылка: http://spam-link.ru',
    createdAt: '24 марта, 08:15',
  ),
  ModReport(
    id: 'r2',
    type: 'user',
    priority: 'high',
    initiator: 'user_dana',
    target: 'user_hate99',
    reason: 'Оскорбление',
    content: 'Пользователь систематически оскорбляет других студентов в комментариях.',
    createdAt: '24 марта, 07:45',
  ),
  ModReport(
    id: 'r3',
    type: 'course',
    priority: 'medium',
    initiator: 'system',
    target: 'Курс "Взлом за 5 минут"',
    reason: 'Нарушение правил платформы',
    content: 'Курс обучает незаконному доступу к системам без разрешения владельца.',
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
    answer: 'Сертификаты появляются в профиле в течение 24 часов после завершения курса. Если прошло больше — обратитесь в поддержку.',
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
    answer: 'Нажмите на иконку закладки на карточке курса или внутри курса в правом верхнем углу.',
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
