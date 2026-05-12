import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/theme/app_theme_colors.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
  fillInTheBlank,
  matchingPairs,
}

class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.id,
    required this.type,
    required this.title,
    required this.options, // For single/multiple choice
    required this.correctIndices, // For single/multiple choice
    required this.leftItems, // For matching pairs
    required this.rightItems, // For matching pairs
    required this.correctMapping, // For matching pairs
    required this.correctBlanks, // For fill in the blanks
    required this.blankOptions, // For fill in the blanks
  });

  final String id;
  final QuestionType type;
  final LocalizedText title;
  final List<LocalizedText>? options;
  final List<int>? correctIndices;
  final List<LocalizedText>? leftItems;
  final List<LocalizedText>? rightItems;
  final Map<int, int>? correctMapping;
  final List<int>? correctBlanks;
  final List<LocalizedText>? blankOptions;
}

class LocalizedText {
  const LocalizedText({
    required this.ru,
    required this.kk,
    required this.en,
  });

  final String ru;
  final String kk;
  final String en;

  String resolve(AppLocale locale) {
    return switch (locale) {
      AppLocale.ru => ru,
      AppLocale.kk => kk,
      _ => en,
    };
  }
}

// 15 Multilingual High-Quality Questions covering computer science and software engineering core
final List<DiagnosticQuestion> _questionsPool = [
  // 1. OOP principles (Single choice)
  DiagnosticQuestion(
    id: 'q1',
    type: QuestionType.singleChoice,
    title: LocalizedText(
      ru: "Какой фундаментальный принцип ООП скрывает внутренние детали реализации класса и защищает данные от прямого доступа?",
      kk: "Сыныптың ішкі жүзеге асыру мәліметтерін жасыратын және деректерді тікелей қатынасудан қорғайтын ООП-тың қандай негізгі принципі бар?",
      en: "Which fundamental OOP principle hides internal class implementation details and protects data from direct access?",
    ),
    options: [
      LocalizedText(ru: "Инкапсуляция", kk: "Инкапсуляция", en: "Encapsulation"),
      LocalizedText(ru: "Наследование", kk: "Мұрагерлік", en: "Inheritance"),
      LocalizedText(ru: "Полиморфизм", kk: "Полиморфизм", en: "Polymorphism"),
      LocalizedText(ru: "Абстракция", kk: "Абстракция", en: "Abstraction"),
    ],
    correctIndices: [0],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 2. Polymorphism & Inheritance (Multiple choice)
  DiagnosticQuestion(
    id: 'q2',
    type: QuestionType.multipleChoice,
    title: LocalizedText(
      ru: "Выберите ВСЕ верные утверждения о полиморфизме и наследовании:",
      kk: "Полиморфизм және мұрагерлік туралы БАРЛЫҚ дұрыс тұжырымдарды таңдаңыз:",
      en: "Select ALL true statements about polymorphism and inheritance:",
    ),
    options: [
      LocalizedText(
        ru: "Наследование позволяет повторно использовать код родительского класса",
        kk: "Мұрагерлік ата-аналық сыныптың кодын қайта пайдалануға мүмкіндік береді",
        en: "Inheritance allows reusing parent class code",
      ),
      LocalizedText(
        ru: "Полиморфизм позволяет объектам разных классов реагировать на один и тот же вызов метода по-разному",
        kk: "Полиморфизм әртүрлі сыныптардың объектілеріне бірдей әдіс шақыруына әртүрлі жауап беруге мүмкіндік береді",
        en: "Polymorphism allows objects of different classes to respond to the same method call differently",
      ),
      LocalizedText(
        ru: "Приватные методы класса всегда наследуются и могут быть переопределены",
        kk: "Сыныптың жеке (private) әдістері әрқашан мұрагерлікке беріледі және қайта анықталады",
        en: "Private class methods are always inherited and can be overridden",
      ),
      LocalizedText(
        ru: "Переопределение метода (Overriding) происходит во время компиляции",
        kk: "Әдісті қайта анықтау (Overriding) компиляция кезінде орындалады",
        en: "Method overriding occurs at compile time",
      ),
      LocalizedText(
        ru: "Класс может наследоваться только от одного класса в стандартной модели единичного наследования (как в Java)",
        kk: "Сынып бір мұрагерлік моделінде (мысалы, Java-да) тек бір сыныптан ғана мұра ала алады",
        en: "A class can only inherit from a single class in a standard single-inheritance model (like in Java)",
      ),
    ],
    correctIndices: [0, 1, 4],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 3. Big O Notation (Single choice, 6 options)
  DiagnosticQuestion(
    id: 'q3',
    type: QuestionType.singleChoice,
    title: LocalizedText(
      ru: "Какова временная сложность худшего случая для быстрого поиска элемента в сбалансированном бинарном дереве поиска (BST)?",
      kk: "Балансталған екілік іздеу ағашында (BST) элементті жылдам іздеу үшін ең нашар жағдайдағы уақыт күрделілігі қандай?",
      en: "What is the worst-case time complexity of looking up an element in a balanced Binary Search Tree (BST)?",
    ),
    options: [
      LocalizedText(ru: "O(1)", kk: "O(1)", en: "O(1)"),
      LocalizedText(ru: "O(log n)", kk: "O(log n)", en: "O(log n)"),
      LocalizedText(ru: "O(n)", kk: "O(n)", en: "O(n)"),
      LocalizedText(ru: "O(n log n)", kk: "O(n log n)", en: "O(n log n)"),
      LocalizedText(ru: "O(n²)", kk: "O(n²)", en: "O(n²)"),
      LocalizedText(ru: "O(2ⁿ)", kk: "O(2ⁿ)", en: "O(2ⁿ)"),
    ],
    correctIndices: [1],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 4. Database Normalization (Multiple choice, 6 options)
  DiagnosticQuestion(
    id: 'q4',
    type: QuestionType.multipleChoice,
    title: LocalizedText(
      ru: "Какие цели преследует нормализация реляционных баз данных? Выберите все подходящие:",
      kk: "Реляциялық деректер базасын нормализациялау қандай мақсаттарды көздейді? Сәйкес келетіндердің бәрін таңдаңыз:",
      en: "What are the goals of relational database normalization? Select all that apply:",
    ),
    options: [
      LocalizedText(
        ru: "Минимизация избыточности (дублирования) данных",
        kk: "Деректердің артықшылығын (дубликатталуын) азайту",
        en: "Minimizing data redundancy (duplication)",
      ),
      LocalizedText(
        ru: "Ускорение выполнения абсолютно всех сложных SELECT запросов с JOIN",
        kk: "JOIN көмегімен барлық күрделі SELECT сұраныстарының орындалуын жылдамдату",
        en: "Speeding up execution of absolutely all complex SELECT queries with JOINs",
      ),
      LocalizedText(
        ru: "Устранение аномалий вставки, обновления и удаления данных",
        kk: "Деректерді кірістіру, жаңарту және жою аномалияларын жою",
        en: "Eliminating insertion, update, and deletion anomalies",
      ),
      LocalizedText(
        ru: "Обеспечение целостности данных",
        kk: "Деректердің тұтастығын қамтамасыз ету",
        en: "Ensuring data integrity",
      ),
      LocalizedText(
        ru: "Автоматическое физическое шифрование жесткого диска",
        kk: "Қатты дискіні автоматты түрде физикалық шифрлау",
        en: "Automatic physical hard drive encryption",
      ),
      LocalizedText(
        ru: "Организация логической структуры таблиц на основе функциональных зависимостей",
        kk: "Функционалдық тәуелділіктер негізінде кестелердің логикалық құрылымын ұйымдастыру",
        en: "Organizing the logical table structure based on functional dependencies",
      ),
    ],
    correctIndices: [0, 2, 3, 5],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 5. Web Protocols HTTP vs HTTPS (Single choice, 5 options)
  DiagnosticQuestion(
    id: 'q5',
    type: QuestionType.singleChoice,
    title: LocalizedText(
      ru: "В чем основное отличие протокола HTTPS от базового HTTP?",
      kk: "HTTPS протоколының негізгі HTTP протоколынан басты айырмашылығы неде?",
      en: "What is the primary difference between HTTPS and basic HTTP?",
    ),
    options: [
      LocalizedText(
        ru: "HTTPS использует TLS/SSL для шифрования данных и аутентификации сервера",
        kk: "HTTPS деректерді шифрлау және серверді аутентификациялау үшін TLS/SSL пайдаланады",
        en: "HTTPS uses TLS/SSL for data encryption and server authentication",
      ),
      LocalizedText(
        ru: "HTTPS работает на транспортном уровне, а HTTP — на прикладном",
        kk: "HTTPS көлік (transport) деңгейінде, ал HTTP қолданбалы (application) деңгейде жұмыс істейді",
        en: "HTTPS operates at the transport layer, while HTTP operates at the application layer",
      ),
      LocalizedText(
        ru: "HTTPS поддерживает передачу файлов только в формате ZIP",
        kk: "HTTPS тек ZIP форматындағы файлдарды тасымалдауды қолдайды",
        en: "HTTPS only supports transmitting files in ZIP format",
      ),
      LocalizedText(
        ru: "HTTPS не поддерживает куки (Cookies) для сохранения сессий",
        kk: "HTTPS сессияларды сақтау үшін cookie файлдарын қолдамайды",
        en: "HTTPS does not support Cookies for maintaining sessions",
      ),
      LocalizedText(
        ru: "HTTPS является устаревшим протоколом, замененным на HTTP/3",
        kk: "HTTPS — ескірген протокол, оның орнына HTTP/3 келді",
        en: "HTTPS is an obsolete protocol replaced by HTTP/3",
      ),
    ],
    correctIndices: [0],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 6. Operating Systems Threads vs Processes (Multiple choice, 5 options)
  DiagnosticQuestion(
    id: 'q6',
    type: QuestionType.multipleChoice,
    title: LocalizedText(
      ru: "Выберите ВСЕ верные утверждения о процессах и потоках в операционных системах:",
      kk: "Операциялық жүйелердегі процестер мен ағындар туралы БАРЛЫҚ дұрыс тұжырымдарды таңдаңыз:",
      en: "Select ALL true statements about processes and threads in operating systems:",
    ),
    options: [
      LocalizedText(
        ru: "Процессы изолированы друг от друга и не делят адресное пространство по умолчанию",
        kk: "Процестер бір-бірінен оқшауланған және әдепкі бойынша мекенжай кеңістігін бөліспейді",
        en: "Processes are isolated from each other and do not share address space by default",
      ),
      LocalizedText(
        ru: "Потоки одного процесса делят общую память и ресурсы этого процесса",
        kk: "Бір процестің ағындары осы процестің жалпы жадын және ресурстарын бөліседі",
        en: "Threads of the same process share that process's memory and resources",
      ),
      LocalizedText(
        ru: "Создание и переключение потоков обычно требует больше накладных расходов ОС, чем процессов",
        kk: "Ағындарды құру және ауыстыру әдетте процестерге қарағанда ОЖ үшін көп шығынды қажет етеді",
        en: "Creating and switching threads typically incurs more OS overhead than processes",
      ),
      LocalizedText(
        ru: "Потоки не могут выполняться параллельно на многоядерных процессорах",
        kk: "Ағындар көп ядролы процессорларда параллель орындала алмайды",
        en: "Threads cannot execute concurrently on multi-core CPUs",
      ),
      LocalizedText(
        ru: "Падение одного потока может привести к аварийному завершению всего процесса",
        kk: "Бір ағынның құлауы бүкіл процестің авариялық аяқталуына әкелуі мүмкін",
        en: "The crash of a single thread can cause the entire process to terminate abruptly",
      ),
    ],
    correctIndices: [0, 1, 4],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 7. Computer Architecture Cache Memory (Single choice, 4 options)
  DiagnosticQuestion(
    id: 'q7',
    type: QuestionType.singleChoice,
    title: LocalizedText(
      ru: "Какова основная цель использования сверхоперативной памяти (кэша L1/L2/L3) в современных процессорах?",
      kk: "Қазіргі процессорларда өте жылдам жадты (L1/L2/L3 кэш) пайдаланудың басты мақсаты қандай?",
      en: "What is the primary purpose of using cache memory (L1/L2/L3) in modern CPUs?",
    ),
    options: [
      LocalizedText(
        ru: "Сокращение среднего времени доступа к данным из оперативной памяти (RAM)",
        kk: "Жедел жадтан (RAM) деректерге қол жеткізудің орташа уақытын қысқарту",
        en: "Reducing the average time to access data from main memory (RAM)",
      ),
      LocalizedText(
        ru: "Увеличение общей емкости постоянного жесткого диска",
        kk: "Тұрақты қатты дискінің жалпы сыйымдылығын арттыру",
        en: "Increasing the total capacity of the hard drive",
      ),
      LocalizedText(
        ru: "Повышение безопасности при передаче пакетов по сети",
        kk: "Желі арқылы пакеттерді тасымалдау кезінде қауіпсіздікті арттыру",
        en: "Improving security during packet transmission over the network",
      ),
      LocalizedText(
        ru: "Охлаждение физических кристаллов процессора при высокой нагрузке",
        kk: "Жоғары жүктеме кезінде процессордың физикалық кристалдарын салқындату",
        en: "Cooling the physical CPU chips under high loads",
      ),
    ],
    correctIndices: [0],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 8. Software Design Patterns (Matching pairs)
  DiagnosticQuestion(
    id: 'q8',
    type: QuestionType.matchingPairs,
    title: LocalizedText(
      ru: "Установите соответствие между паттерном проектирования и его основным назначением:",
      kk: "Жобалау үлгісі (pattern) мен оның негізгі мақсаты арасындағы сәйкестікті орнатыңыз:",
      en: "Match the design pattern with its primary purpose:",
    ),
    options: null,
    correctIndices: null,
    leftItems: [
      LocalizedText(ru: "Singleton", kk: "Singleton", en: "Singleton"),
      LocalizedText(ru: "Observer", kk: "Observer", en: "Observer"),
      LocalizedText(ru: "Factory Method", kk: "Factory Method", en: "Factory Method"),
    ],
    rightItems: [
      LocalizedText(
        ru: "Гарантирует создание единственного экземпляра класса в системе",
        kk: "Жүйеде сыныптың тек бір ғана данасының жасалуын қамтамасыз етеді",
        en: "Guarantees that a class has only one instance across the system",
      ),
      LocalizedText(
        ru: "Организует рассылку уведомлений об изменении состояния зависимым объектам",
        kk: "Тәуелді объектілерге күйдің өзгеруі туралы хабарландыруларды таратуды ұйымдастырады",
        en: "Notifies dependent objects automatically when state changes",
      ),
      LocalizedText(
        ru: "Делегирует создание объектов дочерним классам через общий интерфейс",
        kk: "Объектілерді құруды ортақ интерфейс арқылы еншілес сыныптарға тапсырады",
        en: "Delegates object creation to subclasses through a common interface",
      ),
    ],
    correctMapping: {0: 0, 1: 1, 2: 2},
    correctBlanks: null,
    blankOptions: null,
  ),
  // 9. Cloud Computing models (Fill in the blanks)
  DiagnosticQuestion(
    id: 'q9',
    type: QuestionType.fillInTheBlank,
    title: LocalizedText(
      ru: "В облачных вычислениях модель, предоставляющая виртуальные серверы, сети и диски, называется {blank}, в то время как модель, предоставляющая готовую среду для запуска кода без заботы об ОС, называется {blank}.",
      kk: "Бұлттық есептеулерде виртуалды серверлерді, желілерді және дискілерді ұсынатын модель {blank} деп аталады, ал ОЖ туралы алаңдамай-ақ кодты іске қосуға дайын ортаны ұсынатын модель {blank} деп аталады.",
      en: "In cloud computing, the model providing virtual servers, networks, and storage is called {blank}, while the model providing a ready environment to run code without worrying about the OS is called {blank}.",
    ),
    options: null,
    correctIndices: null,
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: [0, 1], // IaaS (0), PaaS (1)
    blankOptions: [
      LocalizedText(ru: "IaaS", kk: "IaaS", en: "IaaS"),
      LocalizedText(ru: "PaaS", kk: "PaaS", en: "PaaS"),
      LocalizedText(ru: "SaaS", kk: "SaaS", en: "SaaS"),
    ],
  ),
  // 10. Cryptography Public vs Private Key (Single choice, 5 options)
  DiagnosticQuestion(
    id: 'q10',
    type: QuestionType.singleChoice,
    title: LocalizedText(
      ru: "В асимметричном шифровании, если Алиса хочет отправить Бобу зашифрованное сообщение, какой ключ она должна использовать для шифрования?",
      kk: "Асимметриялық шифрлауда, егер Алиса Бобқа шифрланған хабарлама жібергісі келсе, ол шифрлау үшін қандай кілтті пайдалануы керек?",
      en: "In asymmetric encryption, if Alice wants to send Bob an encrypted message, which key should she use to encrypt it?",
    ),
    options: [
      LocalizedText(
        ru: "Публичный (открытый) ключ Боба",
        kk: "Бобтың жария (ашық) кілті",
        en: "Bob's public key",
      ),
      LocalizedText(
        ru: "Приватный (секретный) ключ Алисы",
        kk: "Алисаның жеке (құпия) кілті",
        en: "Alice's private key",
      ),
      LocalizedText(
        ru: "Приватный (секретный) ключ Боба",
        kk: "Бобтың жеке (құпия) кілті",
        en: "Bob's private key",
      ),
      LocalizedText(
        ru: "Публичный (открытый) ключ Алисы",
        kk: "Алисаның жария (ашық) кілті",
        en: "Alice's public key",
      ),
      LocalizedText(
        ru: "Общий симметричный сессионный ключ",
        kk: "Ортақ симметриялық сессиялық кілт",
        en: "A shared symmetric session key",
      ),
    ],
    correctIndices: [0],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 11. Artificial Intelligence & ML types (Multiple choice, 6 options)
  DiagnosticQuestion(
    id: 'q11',
    type: QuestionType.multipleChoice,
    title: LocalizedText(
      ru: "Какие задачи относятся к машинному обучению с учителем (Supervised Learning)? Выберите все верные:",
      kk: "Мұғаліммен оқыту (Supervised Learning) тапсырмаларына не жатады? Барлық дұрыс жауапты таңдаңыз:",
      en: "Which tasks belong to Supervised Learning in machine learning? Select all that apply:",
    ),
    options: [
      LocalizedText(
        ru: "Предсказание цен на недвижимость по известным характеристикам (Регрессия)",
        kk: "Белгілі сипаттамалар бойынша жылжымайтын мүлік бағасын болжау (Регрессия)",
        en: "Predicting real estate prices based on historical labeled features (Regression)",
      ),
      LocalizedText(
        ru: "Классификация входящих писем на спам и не-спам по размеченной выборке",
        kk: "Кіріс хаттарды белгіленген таңдау бойынша спам және спам емес деп жіктеу",
        en: "Classifying incoming emails into spam and not-spam using a labeled dataset",
      ),
      LocalizedText(
        ru: "Группировка клиентов интернет-магазина без предварительных меток (Кластеризация)",
        kk: "Алдын ала белгілерсіз интернет-дүкен клиенттерін топтастыру (Кластерлеу)",
        en: "Grouping online store customers without predefined labels (Clustering)",
      ),
      LocalizedText(
        ru: "Обучение робота ходьбе методом проб и ошибок с получением наград (Reinforcement)",
        kk: "Марапаттар алу арқылы роботты сынақ пен қателік әдісімен жүруге үйрету (Reinforcement)",
        en: "Training a robot to walk via trial and error with reward feedback (Reinforcement)",
      ),
      LocalizedText(
        ru: "Распознавание рукописных цифр на основе обучающего набора MNIST",
        kk: "MNIST үйрету жиынтығы негізінде қолмен жазылған цифрларды тану",
        en: "Recognizing handwritten digits using the MNIST training set",
      ),
      LocalizedText(
        ru: "Понижение размерности признаков методом главных компонент (PCA)",
        kk: "Басты компоненттер әдісімен (PCA) белгілердің өлшемін азайту",
        en: "Reducing feature dimensions using Principal Component Analysis (PCA)",
      ),
    ],
    correctIndices: [0, 1, 4],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 12. Data Structures Stack vs Queue (Single choice, 4 options)
  DiagnosticQuestion(
    id: 'q12',
    type: QuestionType.singleChoice,
    title: LocalizedText(
      ru: "Каков основной принцип работы классической структуры данных 'Стек' (Stack)?",
      kk: "Классикалық 'Стек' (Stack) деректер құрылымының негізгі жұмыс принципі қандай?",
      en: "What is the primary operational principle of a classic 'Stack' data structure?",
    ),
    options: [
      LocalizedText(ru: "FIFO (First In, First Out)", kk: "FIFO (First In, First Out)", en: "FIFO (First In, First Out)"),
      LocalizedText(ru: "LIFO (Last In, First Out)", kk: "LIFO (Last In, First Out)", en: "LIFO (Last In, First Out)"),
      LocalizedText(ru: "LILO (Last In, Last Out)", kk: "LILO (Last In, Last Out)", en: "LILO (Last In, Last Out)"),
      LocalizedText(
        ru: "Случайный доступ по индексу (Random Access)",
        kk: "Индекс бойынша кездейсоқ қатынасу (Random Access)",
        en: "Random access by index",
      ),
    ],
    correctIndices: [1],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 13. Software Engineering Agile principles (Multiple choice, 5 options)
  DiagnosticQuestion(
    id: 'q13',
    type: QuestionType.multipleChoice,
    title: LocalizedText(
      ru: "Какие из перечисленных ценностей задекларированы в Agile Manifesto? Выберите все верные:",
      kk: "Төменде көрсетілген құндылықтардың қайсысы Agile манифесінде жарияланған? Барлық дұрыс жауапты таңдаңыз:",
      en: "Which of the following values are declared in the Agile Manifesto? Select all that apply:",
    ),
    options: [
      LocalizedText(
        ru: "Люди и взаимодействие важнее процессов и инструментов",
        kk: "Адамдар мен өзара әрекеттесу процестер мен құралдардан маңыздырақ",
        en: "Individuals and interactions over processes and tools",
      ),
      LocalizedText(
        ru: "Работающий продукт важнее исчерпывающей документации",
        kk: "Жұмыс істеп тұрған өнім толық құжаттамадан маңыздырақ",
        en: "Working software over comprehensive documentation",
      ),
      LocalizedText(
        ru: "Следование первоначальному плану важнее, чем адаптация к изменениям",
        kk: "Бастапқы жоспарды орындау өзгерістерге бейімделуден маңыздырақ",
        en: "Following a plan over responding to change",
      ),
      LocalizedText(
        ru: "Сотрудничество с заказчиком важнее согласования условий контракта",
        kk: "Тапсырыс берушімен ынтымақтастық келісімшарт шарттарын келісуден маңыздырақ",
        en: "Customer collaboration over contract negotiation",
      ),
      LocalizedText(
        ru: "Использование самых дорогих инструментов важнее квалификации сотрудников",
        kk: "Ең қымбат құралдарды пайдалану қызметкерлердің біліктілігінен маңыздырақ",
        en: "Using the most expensive tools over team qualification",
      ),
    ],
    correctIndices: [0, 1, 3],
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: null,
    blankOptions: null,
  ),
  // 14. Network Topologies (Matching pairs)
  DiagnosticQuestion(
    id: 'q14',
    type: QuestionType.matchingPairs,
    title: LocalizedText(
      ru: "Установите соответствие между сетевой топологией и ее характерной особенностью:",
      kk: "Желілік топология мен оның сипатты ерекшелігі арасындағы сәйкестікті орнатыңыз:",
      en: "Match the network topology with its key characteristic:",
    ),
    options: null,
    correctIndices: null,
    leftItems: [
      LocalizedText(ru: "Звезда (Star)", kk: "Жұлдыз (Star)", en: "Star"),
      LocalizedText(ru: "Кольцо (Ring)", kk: "Сақина (Ring)", en: "Ring"),
      LocalizedText(ru: "Шина (Bus)", kk: "Шина (Bus)", en: "Bus"),
    ],
    rightItems: [
      LocalizedText(
        ru: "Все устройства подключены к единому центральному узлу (коммутатору)",
        kk: "Барлық құрылғылар бір орталық түйінге (коммутаторға) қосылған",
        en: "All devices connect to a single central hub (switch)",
      ),
      LocalizedText(
        ru: "Данные передаются по кругу в одном направлении через каждого соседа",
        kk: "Деректер шеңбер бойымен бір бағытта әрбір көрші арқылы беріледі",
        en: "Data travels in a single direction circular path through each node",
      ),
      LocalizedText(
        ru: "Все устройства используют один общий коаксиальный кабель для передачи данных",
        kk: "Барлық құрылғылар деректерді беру үшін бір ортақ коаксиалды кабельді пайдаланады",
        en: "All devices share a single common coaxial cable for data transmission",
      ),
    ],
    correctMapping: {0: 0, 1: 1, 2: 2},
    correctBlanks: null,
    blankOptions: null,
  ),
  // 15. Memory Management (Fill in the blanks)
  DiagnosticQuestion(
    id: 'q15',
    type: QuestionType.fillInTheBlank,
    title: LocalizedText(
      ru: "В управлении памятью область, используемая для локальных переменных функций и вызовов методов, называется {blank}, тогда как динамически выделяемая память для объектов называется {blank}.",
      kk: "Жадты басқаруда функциялардың жергілікті айнымалылары мен әдіс шақырулары үшін пайдаланылатын аймақ {blank} деп аталады, ал объектілер үшін динамикалық бөлінетін жад {blank} деп аталады.",
      en: "In memory management, the region used for function local variables and method call stack frames is called the {blank}, while dynamically allocated memory for objects is called the {blank}.",
    ),
    options: null,
    correctIndices: null,
    leftItems: null,
    rightItems: null,
    correctMapping: null,
    correctBlanks: [0, 1], // Stack (0), Heap (1)
    blankOptions: [
      LocalizedText(ru: "Стек (Stack)", kk: "Стек (Stack)", en: "Stack"),
      LocalizedText(ru: "Куча (Heap)", kk: "Үйінді (Heap)", en: "Heap"),
      LocalizedText(ru: "Регистр (Register)", kk: "Регистр (Register)", en: "Register"),
    ],
  ),
];

class DiagnosticTestPage extends ConsumerStatefulWidget {
  const DiagnosticTestPage({super.key});

  @override
  ConsumerState<DiagnosticTestPage> createState() => _DiagnosticTestPageState();
}

class _DiagnosticTestPageState extends ConsumerState<DiagnosticTestPage> {
  AppLocale? _overrideLocale;

  int _currentIndex = 0;
  bool _isFinished = false;

  // Single/Multiple Choice state
  final Set<int> _selectedIndices = {};

  // Matching Pairs state
  int? _selectedLeftIndex;
  final Map<int, int> _userMatches = {}; // leftIndex -> rightIndex

  // Fill in the blanks state
  final Map<int, int> _userBlanks = {}; // blankIndex -> blankOptionIndex

  // Feedback states
  bool _hasChecked = false;
  bool _isCorrect = false;
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final riverpodLocale = ref.watch(demoAppControllerProvider.select((s) => s.locale));
    final activeLocale = _overrideLocale ?? riverpodLocale;

    if (_isFinished) {
      final levelText = _score >= 12
          ? (activeLocale == AppLocale.ru
              ? 'Продвинутый уровень (Advanced)'
              : (activeLocale == AppLocale.kk ? 'Жоғары деңгей (Advanced)' : 'Advanced Level'))
          : (_score >= 6
              ? (activeLocale == AppLocale.ru
                  ? 'Средний уровень (Intermediate)'
                  : (activeLocale == AppLocale.kk ? 'Орташа деңгей (Intermediate)' : 'Intermediate Level'))
              : (activeLocale == AppLocale.ru
                  ? 'Базовый уровень (Beginner)'
                  : (activeLocale == AppLocale.kk ? 'Бастапқы деңгей (Beginner)' : 'Beginner Level')));

      final recommendTitleText = activeLocale == AppLocale.ru
          ? 'Рекомендованные разделы в Дереве Знаний:'
          : (activeLocale == AppLocale.kk ? 'Білім ағашындағы ұсынылған бөлімдер:' : 'Recommended Sections in Knowledge Tree:');

      final backButtonText = activeLocale == AppLocale.ru
          ? 'Вернуться на главную'
          : (activeLocale == AppLocale.kk ? 'Басты бетке оралу' : 'Return to Home');

      final recommendedList = _score < 6
          ? (activeLocale == AppLocale.ru
              ? ['Математика', 'Дискретная математика', 'ООП']
              : (activeLocale == AppLocale.kk ? ['Математика', 'Дискретті математика', 'ООП'] : ['Mathematics', 'Discrete Math', 'OOP']))
          : (_score < 11
              ? (activeLocale == AppLocale.ru
                  ? ['Алгоритмы и структуры данных', 'Системы баз данных', 'Фронтенд разработка']
                  : (activeLocale == AppLocale.kk ? ['Алгоритмдер және деректер құрылымы', 'Деректер базасы жүйелері', 'Фронтенд әзірлеу'] : ['Algorithms & Data Structures', 'Database Systems', 'Frontend Development']))
              : (activeLocale == AppLocale.ru
                  ? ['Операционные системы', 'Проектирование систем', 'Искусственный интеллект']
                  : (activeLocale == AppLocale.kk ? ['Операциялық жүйелер', 'Жүйелерді жобалау', 'Жасанды интеллект'] : ['Operating Systems', 'System Design', 'Artificial Intelligence'])));

      return AppPageScaffold(
        title: activeLocale == AppLocale.ru
            ? 'Результаты тестирования'
            : (activeLocale == AppLocale.kk ? 'Тестілеу нәтижелері' : 'Diagnostic Results'),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.surface, colors.surfaceSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_rounded, color: colors.primary, size: 84),
                const SizedBox(height: 16),
                Text(
                  activeLocale == AppLocale.ru
                      ? 'Диагностика Завершена!'
                      : (activeLocale == AppLocale.kk ? 'Диагностика Аяқталды!' : 'Diagnostics Completed!'),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${activeLocale == AppLocale.ru ? 'Ваш результат' : (activeLocale == AppLocale.kk ? 'Сіздің нәтижеңіз' : 'Your Score')}: $_score / 15',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  levelText,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Divider(height: 40, thickness: 1),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    recommendTitleText,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: recommendedList.map((rec) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, color: colors.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rec,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activeLocale == AppLocale.ru
                                  ? 'Рекомендовано'
                                  : (activeLocale == AppLocale.kk ? 'Ұсынылады' : 'Recommended'),
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      backButtonText,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questionsPool[_currentIndex];

    return AppPageScaffold(
      title: activeLocale == AppLocale.ru
          ? 'Диагностический тест'
          : (activeLocale == AppLocale.kk ? 'Диагностикалық тест' : 'Diagnostic Test'),
      actions: [
        // Language switcher pill button
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: PopupMenuButton<AppLocale>(
            offset: const Offset(0, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: colors.surfaceSoft,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language_rounded, color: colors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    activeLocale.code.toUpperCase(),
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down_rounded, color: colors.primary, size: 16),
                ],
              ),
            ),
            onSelected: (locale) {
              setState(() {
                _overrideLocale = locale;
              });
            },
            itemBuilder: (context) => [
              _buildLangItem(AppLocale.ru, 'Русский'),
              _buildLangItem(AppLocale.kk, 'Қазақша'),
              _buildLangItem(AppLocale.en, 'English'),
            ],
          ),
        ),
      ],
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _questionsPool.length,
                          minHeight: 8,
                          backgroundColor: colors.surfaceSoft,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${_currentIndex + 1} / ${_questionsPool.length}',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
  
                // Main Question card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.surface, colors.surfaceSoft],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.surfaceSoft, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question text
                      Text(
                        question.title.resolve(activeLocale),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
  
                      // Render options based on type
                      if (question.type == QuestionType.singleChoice ||
                          question.type == QuestionType.multipleChoice)
                        _buildChoiceOptions(question, activeLocale, colors)
                      else if (question.type == QuestionType.matchingPairs)
                        _buildMatchingPairsWidget(question, activeLocale, colors)
                      else if (question.type == QuestionType.fillInTheBlank)
                        _buildFillInTheBlanksWidget(question, activeLocale, colors),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
  
                // Feedback Container
                if (_hasChecked) _buildFeedbackContainer(question, activeLocale, colors),
  
                const SizedBox(height: 16),
  
                // Action button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canProceedOrCheck() ? () => _onActionButtonPressed(question) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: colors.surfaceSoft,
                      disabledForegroundColor: colors.textSecondary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _hasChecked
                          ? (activeLocale == AppLocale.ru
                              ? 'Продолжить'
                              : (activeLocale == AppLocale.kk ? 'Жалғастыру' : 'Continue'))
                          : (activeLocale == AppLocale.ru
                              ? 'Проверить ответ'
                              : (activeLocale == AppLocale.kk ? 'Жауапты тексеру' : 'Check Answer')),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<AppLocale> _buildLangItem(AppLocale locale, String label) {
    return PopupMenuItem<AppLocale>(
      value: locale,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
      ),
    );
  }

  bool _canProceedOrCheck() {
    if (_hasChecked) return true;
    final question = _questionsPool[_currentIndex];
    if (question.type == QuestionType.singleChoice || question.type == QuestionType.multipleChoice) {
      return _selectedIndices.isNotEmpty;
    } else if (question.type == QuestionType.matchingPairs) {
      return _userMatches.length == question.leftItems!.length;
    } else if (question.type == QuestionType.fillInTheBlank) {
      return _userBlanks.length == question.correctBlanks!.length;
    }
    return false;
  }

  void _onActionButtonPressed(DiagnosticQuestion question) {
    if (_hasChecked) {
      // Proceed to next question or finish
      setState(() {
        if (_currentIndex + 1 < _questionsPool.length) {
          _currentIndex++;
          _selectedIndices.clear();
          _selectedLeftIndex = null;
          _userMatches.clear();
          _userBlanks.clear();
          _hasChecked = false;
        } else {
          _isFinished = true;
          // Commit results to provider state
          ref.read(demoAppControllerProvider.notifier).completeDiagnostics(score: _score);
        }
      });
    } else {
      // Validate the answers
      bool correct = false;
      if (question.type == QuestionType.singleChoice) {
        correct = _selectedIndices.length == 1 &&
            _selectedIndices.first == question.correctIndices!.first;
      } else if (question.type == QuestionType.multipleChoice) {
        final correctSet = Set<int>.from(question.correctIndices!);
        correct = _selectedIndices.length == correctSet.length &&
            _selectedIndices.every((i) => correctSet.contains(i));
      } else if (question.type == QuestionType.matchingPairs) {
        correct = true;
        question.correctMapping!.forEach((left, right) {
          if (_userMatches[left] != right) {
            correct = false;
          }
        });
      } else if (question.type == QuestionType.fillInTheBlank) {
        correct = true;
        for (int i = 0; i < question.correctBlanks!.length; i++) {
          if (_userBlanks[i] != question.correctBlanks![i]) {
            correct = false;
          }
        }
      }

      setState(() {
        _hasChecked = true;
        _isCorrect = correct;
        if (correct) {
          _score++;
        }
      });
    }
  }

  Widget _buildChoiceOptions(
    DiagnosticQuestion question,
    AppLocale locale,
    AppThemeColors colors,
  ) {
    return Column(
      children: List.generate(question.options!.length, (index) {
        final option = question.options![index];
        final isSelected = _selectedIndices.contains(index);
        final isCorrectOption = question.correctIndices!.contains(index);

        Color borderCol = colors.surfaceSoft;
        Color bgCol = Colors.transparent;

        if (_hasChecked) {
          if (isCorrectOption) {
            borderCol = Colors.green.withValues(alpha: 0.8);
            bgCol = Colors.green.withValues(alpha: 0.08);
          } else if (isSelected) {
            borderCol = Colors.red.withValues(alpha: 0.8);
            bgCol = Colors.red.withValues(alpha: 0.08);
          }
        } else if (isSelected) {
          borderCol = colors.primary;
          bgCol = colors.primary.withValues(alpha: 0.05);
        }

        final isMultiple = question.type == QuestionType.multipleChoice;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: _hasChecked
                ? null
                : () {
                    setState(() {
                      if (isMultiple) {
                        if (_selectedIndices.contains(index)) {
                          _selectedIndices.remove(index);
                        } else {
                          _selectedIndices.add(index);
                        }
                      } else {
                        _selectedIndices.clear();
                        _selectedIndices.add(index);
                      }
                    });
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgCol,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol, width: 1.5),
              ),
              child: Row(
                children: [
                  // Indicator circle or square
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: isMultiple ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: isMultiple ? BorderRadius.circular(4) : null,
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.textSecondary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      color: isSelected ? colors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? Icon(
                            isMultiple ? Icons.check_rounded : Icons.fiber_manual_record_rounded,
                            size: isMultiple ? 14 : 10,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option.resolve(locale),
                      style: TextStyle(
                        color: isSelected ? colors.textPrimary : colors.textPrimary.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_hasChecked && isCorrectOption)
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                  if (_hasChecked && isSelected && !isCorrectOption)
                    const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMatchingPairsWidget(
    DiagnosticQuestion question,
    AppLocale locale,
    AppThemeColors colors,
  ) {
    final lefts = question.leftItems!;
    final rights = question.rightItems!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_hasChecked)
          Text(
            locale == AppLocale.ru
                ? "💡 Выберите элемент слева, затем его соответствие справа:"
                : (locale == AppLocale.kk
                    ? "💡 Сол жақтағы элементті, сосын оң жақтағы сәйкестікті таңдаңыз:"
                    : "💡 Choose an item on the left, then its match on the right:"),
            style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left items
            Expanded(
              child: Column(
                children: List.generate(lefts.length, (leftIdx) {
                  final text = lefts[leftIdx].resolve(locale);
                  final isMatched = _userMatches.containsKey(leftIdx);
                  final isSelected = _selectedLeftIndex == leftIdx;

                  Color borderCol = colors.surfaceSoft;
                  Color bgCol = Colors.transparent;

                  if (isSelected) {
                    borderCol = colors.primary;
                    bgCol = colors.primary.withValues(alpha: 0.05);
                  } else if (isMatched) {
                    borderCol = colors.primary.withValues(alpha: 0.4);
                    bgCol = colors.primary.withValues(alpha: 0.02);
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: _hasChecked
                          ? null
                          : () {
                              setState(() {
                                _selectedLeftIndex = leftIdx;
                              });
                            },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgCol,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderCol, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${leftIdx + 1}',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            // Right items
            Expanded(
              child: Column(
                children: List.generate(rights.length, (rightIdx) {
                  final text = rights[rightIdx].resolve(locale);
                  // Find if matched
                  int matchedLeftIdx = -1;
                  _userMatches.forEach((l, r) {
                    if (r == rightIdx) matchedLeftIdx = l;
                  });

                  Color borderCol = colors.surfaceSoft;
                  Color bgCol = Colors.transparent;

                  if (matchedLeftIdx != -1) {
                    if (_hasChecked) {
                      final correctRight = question.correctMapping![matchedLeftIdx];
                      if (correctRight == rightIdx) {
                        borderCol = Colors.green.withValues(alpha: 0.8);
                        bgCol = Colors.green.withValues(alpha: 0.08);
                      } else {
                        borderCol = Colors.red.withValues(alpha: 0.8);
                        bgCol = Colors.red.withValues(alpha: 0.08);
                      }
                    } else {
                      borderCol = colors.primary;
                      bgCol = colors.primary.withValues(alpha: 0.05);
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: _hasChecked
                          ? null
                          : () {
                              if (_selectedLeftIndex == null) return;
                              setState(() {
                                // Match them
                                _userMatches[_selectedLeftIndex!] = rightIdx;
                                _selectedLeftIndex = null;
                              });
                            },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgCol,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderCol, width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (matchedLeftIdx != -1)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${matchedLeftIdx + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        if (_userMatches.isNotEmpty && !_hasChecked)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _userMatches.clear();
                  _selectedLeftIndex = null;
                });
              },
              icon: Icon(Icons.refresh_rounded, size: 16, color: colors.primary),
              label: Text(
                locale == AppLocale.ru
                    ? 'Сбросить пары'
                    : (locale == AppLocale.kk ? 'Жұптарды тастау' : 'Reset pairs'),
                style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildFillInTheBlanksWidget(
    DiagnosticQuestion question,
    AppLocale locale,
    AppThemeColors colors,
  ) {
    final titleText = question.title.resolve(locale);
    final segments = titleText.split('{blank}');

    final children = <Widget>[];

    for (int i = 0; i < segments.length; i++) {
      children.add(
        Text(
          segments[i],
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
      );

      if (i < segments.length - 1) {
        final blankIdx = i;
        final selectedValIdx = _userBlanks[blankIdx];

        final isCorrect = selectedValIdx == question.correctBlanks![blankIdx];

        Color borderCol = colors.primary.withValues(alpha: 0.5);
        Color bgCol = colors.surfaceSoft;

        if (_hasChecked) {
          borderCol = isCorrect ? Colors.green : Colors.red;
          bgCol = isCorrect ? Colors.green.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.08);
        }

        children.add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: bgCol,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderCol, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedValIdx,
                dropdownColor: colors.surfaceSoft,
                hint: Text(
                  '_____',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: TextStyle(
                  color: _hasChecked ? (isCorrect ? Colors.green : Colors.red) : colors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
                onChanged: _hasChecked
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() {
                            _userBlanks[blankIdx] = val;
                          });
                        }
                      },
                items: List.generate(question.blankOptions!.length, (idx) {
                  return DropdownMenuItem<int>(
                    value: idx,
                    child: Text(question.blankOptions![idx].resolve(locale)),
                  );
                }),
              ),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }

  Widget _buildFeedbackContainer(
    DiagnosticQuestion question,
    AppLocale locale,
    AppThemeColors colors,
  ) {
    final bgCol = _isCorrect ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12);
    final borderCol = _isCorrect ? Colors.green.withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.4);
    final textCol = _isCorrect ? Colors.green : Colors.red;

    String headerText = '';
    String subText = '';

    if (_isCorrect) {
      headerText = locale == AppLocale.ru
          ? '🎉 Великолепно! Вы ответили верно.'
          : (locale == AppLocale.kk ? '🎉 Керемет! Сіз дұрыс жауап бердіңіз.' : '🎉 Excellent! Correct answer.');
    } else {
      headerText = locale == AppLocale.ru
          ? '❌ К сожалению, ответ неверный.'
          : (locale == AppLocale.kk ? '❌ Өкінішке орай, жауап бұрыс.' : '❌ Unfortunately, incorrect answer.');

      // Build what was correct text
      if (question.type == QuestionType.singleChoice || question.type == QuestionType.multipleChoice) {
        final list = question.correctIndices!.map((i) => question.options![i].resolve(locale)).join(', ');
        subText = locale == AppLocale.ru
            ? 'Правильный(е) ответ(ы): $list'
            : (locale == AppLocale.kk ? 'Дұрыс жауап(тар): $list' : 'Correct answer(s): $list');
      } else if (question.type == QuestionType.matchingPairs) {
        final list = question.correctMapping!.entries.map((entry) {
          final leftStr = question.leftItems![entry.key].resolve(locale);
          final rightStr = question.rightItems![entry.value].resolve(locale);
          return '$leftStr ➔ $rightStr';
        }).join('\n');
        subText = '${locale == AppLocale.ru ? 'Правильные пары:' : (locale == AppLocale.kk ? 'Дұрыс жұптар:' : 'Correct matches:')}\n$list';
      } else if (question.type == QuestionType.fillInTheBlank) {
        final list = question.correctBlanks!.map((idx) => question.blankOptions![idx].resolve(locale)).join(', ');
        subText = locale == AppLocale.ru
            ? 'Правильные вставки: $list'
            : (locale == AppLocale.kk ? 'Дұрыс кірістірулер: $list' : 'Correct insertions: $list');
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            headerText,
            style: TextStyle(
              color: textCol,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subText,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
