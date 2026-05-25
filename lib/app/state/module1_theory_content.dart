// Модуль 1: Синтаксис Java — контент для теории, вопросов и заданий
// Теория использует ► для кода и \n\n для абзацев
// Вопросы используют ключ QuizPrompt
// Задания используют codeChallenge в DemoPracticeCodeChallengeSeed

const String theory1_1 = '''►public class HelloWorld {
    public static void main(String[] args) {
        // Это однострочный комментарий
        System.out.println("Привет, мир!");
        /*
         * Это многострочный
         * комментарий
         */
    }
}

Java — это строго типизированный язык. Каждая программа начинается с класса. Метод main — точка входа. Без него программа не запустится.

►System.out.println() — команда для вывода строки в консоль. После каждой инструкции ставится точка с запятой (;).

Однострочные комментарии пишутся через //. Многострочные — между /* и */. Комментарии игнорируются компилятором и нужны для пояснения кода.''';

const String theory1_1Quiz = 'Что будет выведено на экран?';

const String theory1_2 = '''Переменная — это контейнер для данных. У каждой переменной есть тип, имя и значение.

►int age = 25;
double price = 99.99;
boolean isReady = true;
char letter = 'A';
String name = "Java";

Примитивные типы: int (целые), double (дробные), boolean (true/false), char (один символ). Ссылочный тип: String (строка текста).

Имя переменной должно начинаться с буквы, знака _ или \$. Регистр имеет значение: age и Age — разные переменные.

►int a = 10;
int b = 20;
int sum = a + b; // sum = 30
System.out.println("Сумма: " + sum);''';

const String theory1_2Quiz = 'Какой тип данных подойдёт для хранения цены товара 49.99?';

const String theory1_3 = '''Java поддерживает все базовые арифметические действия и логические сравнения.

►int a = 10, b = 3;
System.out.println(a + b); // 13
System.out.println(a - b); // 7
System.out.println(a * b); // 30
System.out.println(a / b); // 3 (целочисленное деление!)
System.out.println(a % b); // 1 (остаток от деления)

int x = 5;
x++; // теперь x = 6
x--; // снова x = 5

Логические операторы: == (равно), != (не равно), >, <, >=, <=, && (И), || (ИЛИ), ! (НЕ).

►boolean result = (5 > 3) && (2 < 4); // true
System.out.println(!result); // false''';

const String theory1_3Quiz = 'Чему равно 10 / 3?';

const String theory1_4 = '''Условные конструкции позволяют выполнять разный код в зависимости от условия.

►int score = 85;
if (score >= 90) {
    System.out.println("Отлично");
} else if (score >= 70) {
    System.out.println("Хорошо");
} else {
    System.out.println("Попробуй ещё");
}

Тернарный оператор — сокращённая запись if-else:
►String status = (score >= 60) ? "Сдал" : "Не сдал";

Switch-case удобен для множества однотипных условий:
►int day = 3;
switch (day) {
    case 1: System.out.println("Пн"); break;
    case 2: System.out.println("Вт"); break;
    case 3: System.out.println("Ср"); break;
    default: System.out.println("Другой день");
}''';

const String theory1_4Quiz = 'Какой оператор проверит, что число x НЕ равно 10?';

const String theory1_5 = '''Циклы позволяют повторять код несколько раз.

►// for — когда знаем количество шагов
for (int i = 0; i < 5; i++) {
    System.out.println("Шаг " + i);
}

►// while — когда условие проверяется в начале
int i = 0;
while (i < 5) {
    System.out.println(i);
    i++;
}

►// do-while — выполнится хотя бы один раз
int n = 0;
do {
    System.out.println(n);
    n++;
} while (n < 3);

►// break — прерывает цикл
for (int i = 0; i < 10; i++) {
    if (i == 5) break;
    System.out.print(i + " "); // 0 1 2 3 4
}

►// continue — пропускает шаг
for (int i = 0; i < 5; i++) {
    if (i == 2) continue;
    System.out.print(i + " "); // 0 1 3 4
}''';

const String theory1_5Quiz = 'Сколько раз выполнится тело цикла: for (int i = 0; i < 3; i++)?';

const String theory1_6 = '''Массив — это набор элементов одного типа, хранящихся под одним именем. Индексы начинаются с 0.

►// Объявление и инициализация
int[] numbers = new int[5]; // массив из 5 элементов
numbers[0] = 10;
numbers[1] = 20;

// Сокращённая запись
int[] arr = {10, 20, 30, 40, 50};

// Длина массива
System.out.println(arr.length); // 5

// Перебор через цикл
for (int i = 0; i < arr.length; i++) {
    System.out.println(arr[i] + " ");
}

►// for-each — упрощённый перебор
for (int num : arr) {
    System.out.println(num);
}''';

const String theory1_6Quiz = 'Какой индекс у первого элемента массива?';

const String theory1_7 = '''Методы — это именованные блоки кода, которые можно вызывать многократно.

►public static void sayHello() {
    System.out.println("Привет!");
}

// Вызов метода
sayHello();

Методы могут принимать параметры и возвращать значения.

►public static int add(int a, int b) {
    int sum = a + b;
    return sum;
}

int result = add(5, 3); // result = 8
System.out.println(result);

►public static void printSum(int x, int y) {
    System.out.println("Сумма: " + (x + y));
}

printSum(10, 20); // Сумма: 30

Ключевые моменты: void — ничего не возвращает, return — возвращает значение, параметры разделяются запятыми.''';

const String theory1_7Quiz = 'Какое ключевое слово используется для возврата значения из метода?';

// Задания для экзамена модуля 1 (5 задач)
const String examTask1Desc = 'Напишите программу, которая выводит "Hello, Java!" и сумму чисел 5 и 7.';
const String examTask1Expected = 'Hello, Java!\n12';
const String examTask1Solution = 'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, Java!");\n        System.out.println(5 + 7);\n    }\n}';

const String examTask2Desc = 'Объявите переменную int num = 42 и выведите её квадрат.';
const String examTask2Expected = '1764';
const String examTask2Solution = 'public class Main {\n    public static void main(String[] args) {\n        int num = 42;\n        System.out.println(num * num);\n    }\n}';

const String examTask3Desc = 'Напишите программу, которая проверяет число 15: если оно больше 10, вывести "Больше", иначе "Меньше".';
const String examTask3Expected = 'Больше';
const String examTask3Solution = 'public class Main {\n    public static void main(String[] args) {\n        int x = 15;\n        if (x > 10) {\n            System.out.println("Больше");\n        } else {\n            System.out.println("Меньше");\n        }\n    }\n}';

const String examTask4Desc = 'Напишите цикл, который выводит числа от 1 до 5 каждое на новой строке.';
const String examTask4Expected = '1\n2\n3\n4\n5';
const String examTask4Solution = 'public class Main {\n    public static void main(String[] args) {\n        for (int i = 1; i <= 5; i++) {\n            System.out.println(i);\n        }\n    }\n}';

const String examTask5Desc = 'Создайте массив {1, 2, 3, 4, 5} и выведите его сумму.';
const String examTask5Expected = '15';
const String examTask5Solution = 'public class Main {\n    public static void main(String[] args) {\n        int[] arr = {1, 2, 3, 4, 5};\n        int sum = 0;\n        for (int i = 0; i < arr.length; i++) {\n            sum += arr[i];\n        }\n        System.out.println(sum);\n    }\n}';

// Тестовые входные данные для каждого задания
const String examTask1Input = '';
const String examTask2Input = '';
const String examTask3Input = '';
const String examTask4Input = '';
const String examTask5Input = '';
