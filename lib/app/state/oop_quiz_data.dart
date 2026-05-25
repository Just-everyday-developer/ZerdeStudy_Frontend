import 'demo_models.dart';

/// Уникальные квизы для каждого из 12 модулей OOP курса.
/// Используются на фронте вместо квизов с бэкенда.

class OopQuizData {
  static List<LessonQuiz> forModule(int moduleIndex) {
    if (moduleIndex < 0 || moduleIndex >= _moduleQuizzes.length) {
      return _moduleQuizzes[0];
    }
    return _moduleQuizzes[moduleIndex];
  }

  static final List<List<LessonQuiz>> _moduleQuizzes = [
    // Модуль 0: Синтаксис Java
    [
      LessonQuiz(
        id: 'oop_m0_q1',
        title: _t('Что выведет System.out.println("Hello")?'),
        prompt: _t('Что выведет System.out.println("Hello")?'),
        options: [
          QuizOption(id: 'a', label: _t('hello')),
          QuizOption(id: 'b', label: _t('Hello')),
          QuizOption(id: 'c', label: _t('HELLO')),
        ],
        correctOptionId: 'b',
        explanation: _t('println выводит строку точно так, как она написана.'),
      ),
      LessonQuiz(
        id: 'oop_m0_q2',
        title: _t('Как объявить переменную целого числа в Java?'),
        prompt: _t('Как объявить переменную целого числа в Java?'),
        options: [
          QuizOption(id: 'a', label: _t('var x = 5')),
          QuizOption(id: 'b', label: _t('int x = 5;')),
          QuizOption(id: 'c', label: _t('number x = 5;')),
        ],
        correctOptionId: 'b',
        explanation: _t('В Java целые числа объявляются с типом int.'),
      ),
      LessonQuiz(
        id: 'oop_m0_q3',
        title: _t('Какое расширение имеют файлы Java?'),
        prompt: _t('Какое расширение имеют файлы Java?'),
        options: [
          QuizOption(id: 'a', label: _t('.js')),
          QuizOption(id: 'b', label: _t('.jv')),
          QuizOption(id: 'c', label: _t('.java')),
        ],
        correctOptionId: 'c',
        explanation: _t('Исходные файлы Java имеют расширение .java.'),
      ),
    ],
    // Модуль 1: Переменные и типы данных
    [
      LessonQuiz(
        id: 'oop_m1_q1',
        title: _t('Какой тип хранит текст в Java?'),
        prompt: _t('Какой тип хранит текст в Java?'),
        options: [
          QuizOption(id: 'a', label: _t('char')),
          QuizOption(id: 'b', label: _t('String')),
          QuizOption(id: 'c', label: _t('text')),
        ],
        correctOptionId: 'b',
        explanation: _t('String — это класс для хранения строк в Java.'),
      ),
      LessonQuiz(
        id: 'oop_m1_q2',
        title: _t('Что такое double в Java?'),
        prompt: _t('Что такое double в Java?'),
        options: [
          QuizOption(id: 'a', label: _t('Целое число')),
          QuizOption(id: 'b', label: _t('Число с плавающей точкой')),
          QuizOption(id: 'c', label: _t('Логическое значение')),
        ],
        correctOptionId: 'b',
        explanation: _t('double хранит числа с дробной частью (64-bit).'),
      ),
      LessonQuiz(
        id: 'oop_m1_q3',
        title: _t('Каково значение boolean переменной по умолчанию?'),
        prompt: _t('Каково значение boolean переменной по умолчанию?'),
        options: [
          QuizOption(id: 'a', label: _t('true')),
          QuizOption(id: 'b', label: _t('false')),
          QuizOption(id: 'c', label: _t('null')),
        ],
        correctOptionId: 'b',
        explanation: _t('По умолчанию boolean поля класса инициализируются как false.'),
      ),
    ],
    // Модуль 2: Классы и объекты
    [
      LessonQuiz(
        id: 'oop_m2_q1',
        title: _t('Что такое класс в Java?'),
        prompt: _t('Что такое класс в Java?'),
        options: [
          QuizOption(id: 'a', label: _t('Готовый объект')),
          QuizOption(id: 'b', label: _t('Шаблон для создания объектов')),
          QuizOption(id: 'c', label: _t('Переменная')),
        ],
        correctOptionId: 'b',
        explanation: _t('Класс — это шаблон (blueprint), по которому создаются объекты.'),
      ),
      LessonQuiz(
        id: 'oop_m2_q2',
        title: _t('Как создать объект класса Dog?'),
        prompt: _t('Как создать объект класса Dog?'),
        options: [
          QuizOption(id: 'a', label: _t('Dog d = Dog();')),
          QuizOption(id: 'b', label: _t('Dog d = new Dog();')),
          QuizOption(id: 'c', label: _t('new Dog d;')),
        ],
        correctOptionId: 'b',
        explanation: _t('Объекты создаются оператором new с вызовом конструктора.'),
      ),
      LessonQuiz(
        id: 'oop_m2_q3',
        title: _t('Что делает конструктор класса?'),
        prompt: _t('Что делает конструктор класса?'),
        options: [
          QuizOption(id: 'a', label: _t('Удаляет объект')),
          QuizOption(id: 'b', label: _t('Инициализирует поля объекта при создании')),
          QuizOption(id: 'c', label: _t('Копирует класс')),
        ],
        correctOptionId: 'b',
        explanation: _t('Конструктор вызывается при new и инициализирует поля объекта.'),
      ),
    ],
    // Модуль 3: Инкапсуляция
    [
      LessonQuiz(
        id: 'oop_m3_q1',
        title: _t('Что означает модификатор private?'),
        prompt: _t('Что означает модификатор private?'),
        options: [
          QuizOption(id: 'a', label: _t('Поле доступно везде')),
          QuizOption(id: 'b', label: _t('Поле доступно только внутри класса')),
          QuizOption(id: 'c', label: _t('Поле нельзя изменить')),
        ],
        correctOptionId: 'b',
        explanation: _t('private ограничивает доступ к полю только внутри самого класса.'),
      ),
      LessonQuiz(
        id: 'oop_m3_q2',
        title: _t('Что такое getter?'),
        prompt: _t('Что такое getter?'),
        options: [
          QuizOption(id: 'a', label: _t('Метод который устанавливает значение')),
          QuizOption(id: 'b', label: _t('Метод который возвращает значение приватного поля')),
          QuizOption(id: 'c', label: _t('Конструктор класса')),
        ],
        correctOptionId: 'b',
        explanation: _t('Getter — публичный метод для чтения приватного поля.'),
      ),
      LessonQuiz(
        id: 'oop_m3_q3',
        title: _t('Зачем нужна инкапсуляция?'),
        prompt: _t('Зачем нужна инкапсуляция?'),
        options: [
          QuizOption(id: 'a', label: _t('Чтобы замедлить программу')),
          QuizOption(id: 'b', label: _t('Чтобы скрыть детали реализации и защитить данные')),
          QuizOption(id: 'c', label: _t('Чтобы создать много объектов')),
        ],
        correctOptionId: 'b',
        explanation: _t('Инкапсуляция защищает данные и скрывает детали реализации.'),
      ),
    ],
    // Модуль 4: Наследование
    [
      LessonQuiz(
        id: 'oop_m4_q1',
        title: _t('Ключевое слово для наследования в Java?'),
        prompt: _t('Ключевое слово для наследования в Java?'),
        options: [
          QuizOption(id: 'a', label: _t('implements')),
          QuizOption(id: 'b', label: _t('extends')),
          QuizOption(id: 'c', label: _t('inherits')),
        ],
        correctOptionId: 'b',
        explanation: _t('Наследование в Java реализуется ключевым словом extends.'),
      ),
      LessonQuiz(
        id: 'oop_m4_q2',
        title: _t('Что вызывает super() в конструкторе?'),
        prompt: _t('Что вызывает super() в конструкторе?'),
        options: [
          QuizOption(id: 'a', label: _t('Конструктор текущего класса')),
          QuizOption(id: 'b', label: _t('Конструктор родительского класса')),
          QuizOption(id: 'c', label: _t('Статический метод')),
        ],
        correctOptionId: 'b',
        explanation: _t('super() вызывает конструктор родительского (базового) класса.'),
      ),
      LessonQuiz(
        id: 'oop_m4_q3',
        title: _t('Может ли Java класс наследовать несколько классов?'),
        prompt: _t('Может ли Java класс наследовать несколько классов?'),
        options: [
          QuizOption(id: 'a', label: _t('Да, через запятую')),
          QuizOption(id: 'b', label: _t('Нет, только один родительский класс')),
          QuizOption(id: 'c', label: _t('Да, через implements')),
        ],
        correctOptionId: 'b',
        explanation: _t('Java поддерживает только одиночное наследование классов.'),
      ),
    ],
    // Модуль 5: Полиморфизм
    [
      LessonQuiz(
        id: 'oop_m5_q1',
        title: _t('Что такое переопределение метода (overriding)?'),
        prompt: _t('Что такое переопределение метода (overriding)?'),
        options: [
          QuizOption(id: 'a', label: _t('Создание метода с другим именем')),
          QuizOption(id: 'b', label: _t('Дочерний класс переопределяет метод родителя')),
          QuizOption(id: 'c', label: _t('Вызов метода дважды')),
        ],
        correctOptionId: 'b',
        explanation: _t('Overriding — дочерний класс предоставляет свою реализацию метода родителя.'),
      ),
      LessonQuiz(
        id: 'oop_m5_q2',
        title: _t('Аннотация для переопределения метода?'),
        prompt: _t('Аннотация для переопределения метода?'),
        options: [
          QuizOption(id: 'a', label: _t('@Override')),
          QuizOption(id: 'b', label: _t('@Overwrite')),
          QuizOption(id: 'c', label: _t('@Super')),
        ],
        correctOptionId: 'a',
        explanation: _t('@Override указывает компилятору что метод переопределяет родительский.'),
      ),
      LessonQuiz(
        id: 'oop_m5_q3',
        title: _t('Что такое перегрузка методов (overloading)?'),
        prompt: _t('Что такое перегрузка методов (overloading)?'),
        options: [
          QuizOption(id: 'a', label: _t('Несколько методов с одинаковым именем, но разными параметрами')),
          QuizOption(id: 'b', label: _t('Два класса с одинаковым именем')),
          QuizOption(id: 'c', label: _t('Метод без параметров')),
        ],
        correctOptionId: 'a',
        explanation: _t('Overloading — несколько методов с одним именем, но разной сигнатурой.'),
      ),
    ],
    // Модуль 6: Абстракция
    [
      LessonQuiz(
        id: 'oop_m6_q1',
        title: _t('Можно ли создать объект абстрактного класса?'),
        prompt: _t('Можно ли создать объект абстрактного класса?'),
        options: [
          QuizOption(id: 'a', label: _t('Да, как обычно')),
          QuizOption(id: 'b', label: _t('Нет, нельзя напрямую')),
          QuizOption(id: 'c', label: _t('Да, только через new')),
        ],
        correctOptionId: 'b',
        explanation: _t('Абстрактный класс нельзя инстанциировать напрямую — только через наследника.'),
      ),
      LessonQuiz(
        id: 'oop_m6_q2',
        title: _t('Чем интерфейс отличается от абстрактного класса?'),
        prompt: _t('Чем интерфейс отличается от абстрактного класса?'),
        options: [
          QuizOption(id: 'a', label: _t('Интерфейс может иметь поля с данными')),
          QuizOption(id: 'b', label: _t('Класс может реализовать несколько интерфейсов, но наследовать только один класс')),
          QuizOption(id: 'c', label: _t('Интерфейс создаётся словом abstract')),
        ],
        correctOptionId: 'b',
        explanation: _t('Ключевое отличие: множественная реализация интерфейсов vs одиночное наследование классов.'),
      ),
      LessonQuiz(
        id: 'oop_m6_q3',
        title: _t('Ключевое слово для реализации интерфейса?'),
        prompt: _t('Ключевое слово для реализации интерфейса?'),
        options: [
          QuizOption(id: 'a', label: _t('extends')),
          QuizOption(id: 'b', label: _t('implements')),
          QuizOption(id: 'c', label: _t('uses')),
        ],
        correctOptionId: 'b',
        explanation: _t('Интерфейс реализуется через ключевое слово implements.'),
      ),
    ],
    // Модуль 7: Композиция
    [
      LessonQuiz(
        id: 'oop_m7_q1',
        title: _t('Что такое композиция в ООП?'),
        prompt: _t('Что такое композиция в ООП?'),
        options: [
          QuizOption(id: 'a', label: _t('Класс наследует другой класс')),
          QuizOption(id: 'b', label: _t('Класс содержит объект другого класса как поле')),
          QuizOption(id: 'c', label: _t('Два класса имеют одинаковые методы')),
        ],
        correctOptionId: 'b',
        explanation: _t('Композиция — "has-a" отношение: класс содержит другой объект как поле.'),
      ),
      LessonQuiz(
        id: 'oop_m7_q2',
        title: _t('В чём преимущество композиции над наследованием?'),
        prompt: _t('В чём преимущество композиции над наследованием?'),
        options: [
          QuizOption(id: 'a', label: _t('Она быстрее работает')),
          QuizOption(id: 'b', label: _t('Более гибкая — можно менять поведение во время выполнения')),
          QuizOption(id: 'c', label: _t('Она проще в написании')),
        ],
        correctOptionId: 'b',
        explanation: _t('Композиция даёт большую гибкость — зависимости можно менять динамически.'),
      ),
      LessonQuiz(
        id: 'oop_m7_q3',
        title: _t('Как называется принцип "предпочитай композицию наследованию"?'),
        prompt: _t('Как называется принцип "предпочитай композицию наследованию"?'),
        options: [
          QuizOption(id: 'a', label: _t('DRY')),
          QuizOption(id: 'b', label: _t('Favor Composition over Inheritance')),
          QuizOption(id: 'c', label: _t('SOLID')),
        ],
        correctOptionId: 'b',
        explanation: _t('"Favor Composition over Inheritance" — один из ключевых принципов ООП дизайна.'),
      ),
    ],
    // Модуль 8: Паттерны — Порождающие
    [
      LessonQuiz(
        id: 'oop_m8_q1',
        title: _t('Что гарантирует Singleton паттерн?'),
        prompt: _t('Что гарантирует Singleton паттерн?'),
        options: [
          QuizOption(id: 'a', label: _t('Быстрое создание объектов')),
          QuizOption(id: 'b', label: _t('Существует только один экземпляр класса')),
          QuizOption(id: 'c', label: _t('Несколько копий одного объекта')),
        ],
        correctOptionId: 'b',
        explanation: _t('Singleton обеспечивает единственный экземпляр и глобальную точку доступа.'),
      ),
      LessonQuiz(
        id: 'oop_m8_q2',
        title: _t('Factory паттерн используется для?'),
        prompt: _t('Factory паттерн используется для?'),
        options: [
          QuizOption(id: 'a', label: _t('Сортировки объектов')),
          QuizOption(id: 'b', label: _t('Создания объектов без указания конкретного класса')),
          QuizOption(id: 'c', label: _t('Удаления объектов')),
        ],
        correctOptionId: 'b',
        explanation: _t('Factory инкапсулирует логику создания объектов, скрывая конкретный тип.'),
      ),
      LessonQuiz(
        id: 'oop_m8_q3',
        title: _t('Builder паттерн удобен когда?'),
        prompt: _t('Builder паттерн удобен когда?'),
        options: [
          QuizOption(id: 'a', label: _t('Объект имеет 1-2 параметра')),
          QuizOption(id: 'b', label: _t('Объект имеет много необязательных параметров')),
          QuizOption(id: 'c', label: _t('Нужно создать только один объект')),
        ],
        correctOptionId: 'b',
        explanation: _t('Builder упрощает создание объектов со множеством необязательных полей.'),
      ),
    ],
    // Модуль 9: Паттерны — Структурные
    [
      LessonQuiz(
        id: 'oop_m9_q1',
        title: _t('Что делает Adapter паттерн?'),
        prompt: _t('Что делает Adapter паттерн?'),
        options: [
          QuizOption(id: 'a', label: _t('Ускоряет выполнение кода')),
          QuizOption(id: 'b', label: _t('Конвертирует интерфейс класса в другой ожидаемый интерфейс')),
          QuizOption(id: 'c', label: _t('Создаёт несколько объектов')),
        ],
        correctOptionId: 'b',
        explanation: _t('Adapter позволяет несовместимым интерфейсам работать вместе.'),
      ),
      LessonQuiz(
        id: 'oop_m9_q2',
        title: _t('Decorator паттерн позволяет?'),
        prompt: _t('Decorator паттерн позволяет?'),
        options: [
          QuizOption(id: 'a', label: _t('Удалить функциональность класса')),
          QuizOption(id: 'b', label: _t('Динамически добавлять поведение объекту')),
          QuizOption(id: 'c', label: _t('Создать копию класса')),
        ],
        correctOptionId: 'b',
        explanation: _t('Decorator добавляет функциональность объекту динамически без изменения класса.'),
      ),
      LessonQuiz(
        id: 'oop_m9_q3',
        title: _t('Facade паттерн предоставляет?'),
        prompt: _t('Facade паттерн предоставляет?'),
        options: [
          QuizOption(id: 'a', label: _t('Сложный интерфейс для системы')),
          QuizOption(id: 'b', label: _t('Простой интерфейс для сложной подсистемы')),
          QuizOption(id: 'c', label: _t('Доступ к приватным полям')),
        ],
        correctOptionId: 'b',
        explanation: _t('Facade упрощает использование сложной системы через единый интерфейс.'),
      ),
    ],
    // Модуль 10: Паттерны — Поведенческие
    [
      LessonQuiz(
        id: 'oop_m10_q1',
        title: _t('Observer паттерн реализует принцип?'),
        prompt: _t('Observer паттерн реализует принцип?'),
        options: [
          QuizOption(id: 'a', label: _t('Один к одному')),
          QuizOption(id: 'b', label: _t('Один ко многим — изменение одного объекта уведомляет подписчиков')),
          QuizOption(id: 'c', label: _t('Многие ко многим')),
        ],
        correctOptionId: 'b',
        explanation: _t('Observer — паттерн pub/sub: один источник уведомляет множество подписчиков.'),
      ),
      LessonQuiz(
        id: 'oop_m10_q2',
        title: _t('Strategy паттерн используется для?'),
        prompt: _t('Strategy паттерн используется для?'),
        options: [
          QuizOption(id: 'a', label: _t('Хранения данных')),
          QuizOption(id: 'b', label: _t('Замены алгоритма во время выполнения')),
          QuizOption(id: 'c', label: _t('Создания объектов')),
        ],
        correctOptionId: 'b',
        explanation: _t('Strategy позволяет выбирать алгоритм динамически, инкапсулируя каждый из них.'),
      ),
      LessonQuiz(
        id: 'oop_m10_q3',
        title: _t('Command паттерн инкапсулирует?'),
        prompt: _t('Command паттерн инкапсулирует?'),
        options: [
          QuizOption(id: 'a', label: _t('Данные объекта')),
          QuizOption(id: 'b', label: _t('Запрос как объект, позволяя отменять действия')),
          QuizOption(id: 'c', label: _t('Интерфейс класса')),
        ],
        correctOptionId: 'b',
        explanation: _t('Command превращает запрос в объект, поддерживая undo/redo операции.'),
      ),
    ],
    // Модуль 11: Исключения и коллекции
    [
      LessonQuiz(
        id: 'oop_m11_q1',
        title: _t('Что такое Exception в Java?'),
        prompt: _t('Что такое Exception в Java?'),
        options: [
          QuizOption(id: 'a', label: _t('Специальная переменная')),
          QuizOption(id: 'b', label: _t('Событие, нарушающее нормальный поток выполнения программы')),
          QuizOption(id: 'c', label: _t('Тип данных')),
        ],
        correctOptionId: 'b',
        explanation: _t('Exception — ошибка или исключительное событие, прерывающее нормальный поток.'),
      ),
      LessonQuiz(
        id: 'oop_m11_q2',
        title: _t('Чем ArrayList отличается от обычного массива?'),
        prompt: _t('Чем ArrayList отличается от обычного массива?'),
        options: [
          QuizOption(id: 'a', label: _t('ArrayList быстрее')),
          QuizOption(id: 'b', label: _t('ArrayList динамически меняет размер')),
          QuizOption(id: 'c', label: _t('ArrayList хранит только числа')),
        ],
        correctOptionId: 'b',
        explanation: _t('ArrayList автоматически расширяется при добавлении элементов.'),
      ),
      LessonQuiz(
        id: 'oop_m11_q3',
        title: _t('Что хранит HashMap?'),
        prompt: _t('Что хранит HashMap?'),
        options: [
          QuizOption(id: 'a', label: _t('Только числа')),
          QuizOption(id: 'b', label: _t('Пары ключ-значение')),
          QuizOption(id: 'c', label: _t('Только строки')),
        ],
        correctOptionId: 'b',
        explanation: _t('HashMap хранит данные в формате ключ-значение для быстрого поиска.'),
      ),
    ],
  ];
}

LocalizedText _t(String s) => LocalizedText(ru: s, en: s, kk: s);
