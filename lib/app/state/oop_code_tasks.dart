/// Уникальные задания кода для каждого урока OOP курса.
/// 12 модулей, в каждом до 4 уроков, у каждого урока: [title, starterCode, expectedOutput]
class OopCodeTask {
  const OopCodeTask({
    required this.title,
    required this.starterCode,
    required this.expectedOutput,
  });
  final String title;
  final String starterCode;
  final String expectedOutput;
}

/// oopCodeTasks[moduleIndex][lessonIndex]
/// moduleIndex: 0..11, lessonIndex: 0..N
const List<List<OopCodeTask>> oopCodeTasks = [
  // Модуль 0: Синтаксис Java / Введение
  [
    OopCodeTask(
      title: 'Выведи приветствие',
      starterCode: 'public class Main {\n    public static void main(String[] args) {\n        // Выведи: Hello, Java!\n    }\n}',
      expectedOutput: 'Hello, Java!',
    ),
    OopCodeTask(
      title: 'Выведи своё имя',
      starterCode: 'public class Main {\n    public static void main(String[] args) {\n        // Выведи: My name is Java\n    }\n}',
      expectedOutput: 'My name is Java',
    ),
    OopCodeTask(
      title: 'Выведи числа 1 2 3',
      starterCode: 'public class Main {\n    public static void main(String[] args) {\n        // Выведи числа 1, 2, 3 каждое на новой строке\n    }\n}',
      expectedOutput: '1\n2\n3',
    ),
    OopCodeTask(
      title: 'Сложение двух чисел',
      starterCode: 'public class Main {\n    public static void main(String[] args) {\n        int a = 5;\n        int b = 3;\n        // Выведи сумму: 8\n    }\n}',
      expectedOutput: '8',
    ),
  ],
  // Модуль 1: Переменные и типы данных
  [
    OopCodeTask(
      title: 'Объяви переменные и выведи',
      starterCode: 'public class Main {\n    public static void main(String[] args) {\n        int age = 20;\n        String name = "Alice";\n        // Выведи: Alice is 20 years old\n    }\n}',
      expectedOutput: 'Alice is 20 years old',
    ),
    OopCodeTask(
      title: 'Длина строки',
      starterCode: 'public class Main {\n    public static void main(String[] args) {\n        String word = "Java";\n        // Выведи длину слова: 4\n    }\n}',
      expectedOutput: '4',
    ),
    OopCodeTask(
      title: 'Вещественные числа',
      starterCode: 'public class Main {\n    public static void main(String[] args) {\n        double pi = 3.14;\n        // Выведи: Pi is 3.14\n    }\n}',
      expectedOutput: 'Pi is 3.14',
    ),
    OopCodeTask(
      title: 'Тип boolean',
      starterCode: 'public class Main {\n    public static void main(String[] args) {\n        boolean isStudent = true;\n        // Выведи: Is student: true\n    }\n}',
      expectedOutput: 'Is student: true',
    ),
  ],
  // Модуль 2: Классы и объекты
  [
    OopCodeTask(
      title: 'Создай класс Dog',
      starterCode: 'class Dog {\n    String name;\n    Dog(String name) {\n        this.name = name;\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Dog d = new Dog("Rex");\n        // Выведи: Dog name: Rex\n    }\n}',
      expectedOutput: 'Dog name: Rex',
    ),
    OopCodeTask(
      title: 'Метод класса',
      starterCode: 'class Car {\n    String brand;\n    Car(String brand) { this.brand = brand; }\n    String describe() {\n        // Верни строку: Car brand is Toyota\n        return "";\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Car c = new Car("Toyota");\n        System.out.println(c.describe());\n    }\n}',
      expectedOutput: 'Car brand is Toyota',
    ),
    OopCodeTask(
      title: 'Два объекта',
      starterCode: 'class Person {\n    String name;\n    int age;\n    Person(String name, int age) {\n        this.name = name;\n        this.age = age;\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Person p1 = new Person("Anna", 25);\n        Person p2 = new Person("Bob", 30);\n        // Выведи: Anna 25\n        // Выведи: Bob 30\n    }\n}',
      expectedOutput: 'Anna 25\nBob 30',
    ),
  ],
  // Модуль 3: Инкапсуляция
  [
    OopCodeTask(
      title: 'Private поле и геттер',
      starterCode: 'class BankAccount {\n    private double balance = 1000.0;\n    public double getBalance() {\n        // Верни balance\n        return 0;\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        BankAccount acc = new BankAccount();\n        System.out.println(acc.getBalance());\n    }\n}',
      expectedOutput: '1000.0',
    ),
    OopCodeTask(
      title: 'Сеттер с валидацией',
      starterCode: 'class Student {\n    private int age;\n    public void setAge(int age) {\n        // Установи age только если age > 0\n    }\n    public int getAge() { return age; }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Student s = new Student();\n        s.setAge(18);\n        System.out.println(s.getAge());\n    }\n}',
      expectedOutput: '18',
    ),
    OopCodeTask(
      title: 'toString метод',
      starterCode: 'class Product {\n    private String name;\n    private double price;\n    Product(String name, double price) {\n        this.name = name;\n        this.price = price;\n    }\n    public String toString() {\n        // Верни: Product: Laptop, Price: 999.0\n        return "";\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Product p = new Product("Laptop", 999.0);\n        System.out.println(p);\n    }\n}',
      expectedOutput: 'Product: Laptop, Price: 999.0',
    ),
  ],
  // Модуль 4: Наследование
  [
    OopCodeTask(
      title: 'Базовый класс Animal',
      starterCode: 'class Animal {\n    String name;\n    Animal(String name) { this.name = name; }\n    void speak() {\n        System.out.println(name + " makes a sound");\n    }\n}\nclass Cat extends Animal {\n    Cat(String name) { super(name); }\n    // Переопредели speak(): выведи name + " says meow"\n}\npublic class Main {\n    public static void main(String[] args) {\n        Cat c = new Cat("Whiskers");\n        c.speak();\n    }\n}',
      expectedOutput: 'Whiskers says meow',
    ),
    OopCodeTask(
      title: 'Вызов super метода',
      starterCode: 'class Vehicle {\n    String brand;\n    Vehicle(String brand) { this.brand = brand; }\n    String info() { return "Vehicle: " + brand; }\n}\nclass ElectricCar extends Vehicle {\n    int range;\n    ElectricCar(String brand, int range) {\n        super(brand);\n        this.range = range;\n    }\n    String info() {\n        // Верни: super.info() + ", Range: " + range + " km"\n        return "";\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        ElectricCar ec = new ElectricCar("Tesla", 400);\n        System.out.println(ec.info());\n    }\n}',
      expectedOutput: 'Vehicle: Tesla, Range: 400 km',
    ),
    OopCodeTask(
      title: 'Цепочка наследования',
      starterCode: 'class Shape {\n    String color;\n    Shape(String color) { this.color = color; }\n}\nclass Circle extends Shape {\n    double radius;\n    Circle(String color, double radius) {\n        super(color);\n        this.radius = radius;\n    }\n    String describe() {\n        // Верни: color + " circle with radius " + radius\n        return "";\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Circle c = new Circle("Red", 5.0);\n        System.out.println(c.describe());\n    }\n}',
      expectedOutput: 'Red circle with radius 5.0',
    ),
  ],
  // Модуль 5: Полиморфизм
  [
    OopCodeTask(
      title: 'Полиморфный вызов',
      starterCode: 'class Animal {\n    void speak() { System.out.println("..."); }\n}\nclass Dog extends Animal {\n    void speak() { System.out.println("Woof"); }\n}\nclass Cat extends Animal {\n    void speak() { System.out.println("Meow"); }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Animal[] animals = { new Dog(), new Cat() };\n        // Вызови speak() для каждого через цикл\n    }\n}',
      expectedOutput: 'Woof\nMeow',
    ),
    OopCodeTask(
      title: 'Instanceof проверка',
      starterCode: 'class Animal {}\nclass Dog extends Animal {}\npublic class Main {\n    public static void main(String[] args) {\n        Animal a = new Dog();\n        // Проверь instanceof и выведи: a is a Dog: true\n    }\n}',
      expectedOutput: 'a is a Dog: true',
    ),
    OopCodeTask(
      title: 'Перегрузка методов',
      starterCode: 'public class Main {\n    static int add(int a, int b) { return a + b; }\n    static double add(double a, double b) {\n        // Верни сумму двух double\n        return 0;\n    }\n    public static void main(String[] args) {\n        System.out.println(add(2, 3));\n        System.out.println(add(1.5, 2.5));\n    }\n}',
      expectedOutput: '5\n4.0',
    ),
  ],
  // Модуль 6: Абстракция
  [
    OopCodeTask(
      title: 'Абстрактный класс Shape',
      starterCode: 'abstract class Shape {\n    abstract double area();\n}\nclass Rectangle extends Shape {\n    double width, height;\n    Rectangle(double w, double h) { width = w; height = h; }\n    double area() {\n        // Верни width * height\n        return 0;\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Shape s = new Rectangle(4.0, 5.0);\n        System.out.println(s.area());\n    }\n}',
      expectedOutput: '20.0',
    ),
    OopCodeTask(
      title: 'Интерфейс Printable',
      starterCode: 'interface Printable {\n    void print();\n}\nclass Document implements Printable {\n    String title;\n    Document(String title) { this.title = title; }\n    public void print() {\n        // Выведи: Printing: + title\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Document doc = new Document("Report");\n        doc.print();\n    }\n}',
      expectedOutput: 'Printing: Report',
    ),
    OopCodeTask(
      title: 'Два интерфейса',
      starterCode: 'interface Flyable { void fly(); }\ninterface Swimmable { void swim(); }\nclass Duck implements Flyable, Swimmable {\n    public void fly() { System.out.println("Duck flies"); }\n    public void swim() {\n        // Выведи: Duck swims\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Duck d = new Duck();\n        d.fly();\n        d.swim();\n    }\n}',
      expectedOutput: 'Duck flies\nDuck swims',
    ),
  ],
  // Модуль 7: Композиция
  [
    OopCodeTask(
      title: 'Класс Engine внутри Car',
      starterCode: 'class Engine {\n    int horsepower;\n    Engine(int hp) { horsepower = hp; }\n    String info() { return "Engine: " + horsepower + " HP"; }\n}\nclass Car {\n    Engine engine;\n    String model;\n    Car(String model, int hp) {\n        this.model = model;\n        // Создай engine = new Engine(hp)\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Car car = new Car("BMW", 300);\n        System.out.println(car.engine.info());\n    }\n}',
      expectedOutput: 'Engine: 300 HP',
    ),
    OopCodeTask(
      title: 'Список объектов',
      starterCode: 'import java.util.ArrayList;\nclass Task {\n    String name;\n    Task(String name) { this.name = name; }\n}\npublic class Main {\n    public static void main(String[] args) {\n        ArrayList<Task> tasks = new ArrayList<>();\n        tasks.add(new Task("Buy food"));\n        tasks.add(new Task("Write code"));\n        // Выведи name каждой задачи через цикл\n    }\n}',
      expectedOutput: 'Buy food\nWrite code',
    ),
    OopCodeTask(
      title: 'Вложенные объекты',
      starterCode: 'class Address {\n    String city;\n    Address(String city) { this.city = city; }\n}\nclass Person {\n    String name;\n    Address address;\n    Person(String name, String city) {\n        this.name = name;\n        this.address = new Address(city);\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Person p = new Person("Ivan", "Almaty");\n        // Выведи: Ivan lives in Almaty\n    }\n}',
      expectedOutput: 'Ivan lives in Almaty',
    ),
  ],
  // Модуль 8: Паттерны - Порождающие
  [
    OopCodeTask(
      title: 'Singleton паттерн',
      starterCode: 'class Config {\n    private static Config instance;\n    private String env = "production";\n    private Config() {}\n    public static Config getInstance() {\n        // Если instance == null, создай new Config()\n        // Верни instance\n        return null;\n    }\n    public String getEnv() { return env; }\n}\npublic class Main {\n    public static void main(String[] args) {\n        System.out.println(Config.getInstance().getEnv());\n    }\n}',
      expectedOutput: 'production',
    ),
    OopCodeTask(
      title: 'Factory метод',
      starterCode: 'class Animal {\n    String type;\n    Animal(String type) { this.type = type; }\n    static Animal create(String type) {\n        // Верни new Animal(type)\n        return null;\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Animal a = Animal.create("Lion");\n        System.out.println("Created: " + a.type);\n    }\n}',
      expectedOutput: 'Created: Lion',
    ),
    OopCodeTask(
      title: 'Builder паттерн',
      starterCode: 'class Pizza {\n    String size;\n    String topping;\n    static class Builder {\n        String size;\n        String topping;\n        Builder size(String s) { size = s; return this; }\n        Builder topping(String t) { topping = t; return this; }\n        Pizza build() {\n            Pizza p = new Pizza();\n            p.size = size;\n            p.topping = topping;\n            return p;\n        }\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Pizza p = new Pizza.Builder().size("Large").topping("Cheese").build();\n        System.out.println(p.size + " pizza with " + p.topping);\n    }\n}',
      expectedOutput: 'Large pizza with Cheese',
    ),
  ],
  // Модуль 9: Паттерны - Структурные
  [
    OopCodeTask(
      title: 'Adapter паттерн',
      starterCode: 'interface JsonLogger {\n    void logJson(String msg);\n}\nclass OldLogger {\n    void log(String msg) { System.out.println("[LOG] " + msg); }\n}\nclass LogAdapter implements JsonLogger {\n    OldLogger old = new OldLogger();\n    public void logJson(String msg) {\n        // Вызови old.log(msg)\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        JsonLogger logger = new LogAdapter();\n        logger.logJson("App started");\n    }\n}',
      expectedOutput: '[LOG] App started',
    ),
    OopCodeTask(
      title: 'Decorator паттерн',
      starterCode: 'interface Coffee {\n    String getDescription();\n}\nclass SimpleCoffee implements Coffee {\n    public String getDescription() { return "Coffee"; }\n}\nclass MilkDecorator implements Coffee {\n    Coffee coffee;\n    MilkDecorator(Coffee c) { coffee = c; }\n    public String getDescription() {\n        // Верни coffee.getDescription() + " + Milk"\n        return "";\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Coffee c = new MilkDecorator(new SimpleCoffee());\n        System.out.println(c.getDescription());\n    }\n}',
      expectedOutput: 'Coffee + Milk',
    ),
    OopCodeTask(
      title: 'Facade паттерн',
      starterCode: 'class CPU { void start() { System.out.println("CPU started"); } }\nclass Memory { void load() { System.out.println("Memory loaded"); } }\nclass Computer {\n    CPU cpu = new CPU();\n    Memory memory = new Memory();\n    void start() {\n        // Вызови cpu.start() и memory.load()\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        new Computer().start();\n    }\n}',
      expectedOutput: 'CPU started\nMemory loaded',
    ),
  ],
  // Модуль 10: Паттерны - Поведенческие
  [
    OopCodeTask(
      title: 'Observer паттерн',
      starterCode: 'import java.util.ArrayList;\ninterface Observer { void update(String event); }\nclass EventBus {\n    ArrayList<Observer> observers = new ArrayList<>();\n    void subscribe(Observer o) { observers.add(o); }\n    void publish(String event) {\n        // Вызови o.update(event) для каждого observer\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        EventBus bus = new EventBus();\n        bus.subscribe(e -> System.out.println("Observer 1: " + e));\n        bus.publish("login");\n    }\n}',
      expectedOutput: 'Observer 1: login',
    ),
    OopCodeTask(
      title: 'Strategy паттерн',
      starterCode: 'interface SortStrategy {\n    void sort(int[] arr);\n}\nclass BubbleSort implements SortStrategy {\n    public void sort(int[] arr) {\n        // Просто выведи: Bubble sort applied\n        System.out.println("Bubble sort applied");\n    }\n}\nclass Sorter {\n    SortStrategy strategy;\n    Sorter(SortStrategy s) { strategy = s; }\n    void sort(int[] arr) {\n        // Вызови strategy.sort(arr)\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Sorter sorter = new Sorter(new BubbleSort());\n        sorter.sort(new int[]{3, 1, 2});\n    }\n}',
      expectedOutput: 'Bubble sort applied',
    ),
    OopCodeTask(
      title: 'Command паттерн',
      starterCode: 'interface Command { void execute(); }\nclass Light {\n    void turnOn() { System.out.println("Light ON"); }\n}\nclass TurnOnCommand implements Command {\n    Light light;\n    TurnOnCommand(Light l) { light = l; }\n    public void execute() {\n        // Вызови light.turnOn()\n    }\n}\npublic class Main {\n    public static void main(String[] args) {\n        Command cmd = new TurnOnCommand(new Light());\n        cmd.execute();\n    }\n}',
      expectedOutput: 'Light ON',
    ),
  ],
  // Модуль 11: Исключения и коллекции
  [
    OopCodeTask(
      title: 'Try-catch блок',
      starterCode: 'public class Main {\n    public static void main(String[] args) {\n        try {\n            int result = 10 / 0;\n        } catch (ArithmeticException e) {\n            // Выведи: Cannot divide by zero\n        }\n    }\n}',
      expectedOutput: 'Cannot divide by zero',
    ),
    OopCodeTask(
      title: 'ArrayList и forEach',
      starterCode: 'import java.util.ArrayList;\npublic class Main {\n    public static void main(String[] args) {\n        ArrayList<String> langs = new ArrayList<>();\n        langs.add("Java");\n        langs.add("Python");\n        langs.add("Kotlin");\n        // Выведи каждый элемент через forEach\n    }\n}',
      expectedOutput: 'Java\nPython\nKotlin',
    ),
    OopCodeTask(
      title: 'HashMap get/put',
      starterCode: 'import java.util.HashMap;\npublic class Main {\n    public static void main(String[] args) {\n        HashMap<String, Integer> scores = new HashMap<>();\n        scores.put("Alice", 95);\n        scores.put("Bob", 87);\n        // Выведи: Alice scored 95\n        System.out.println("Alice scored " + scores.get("Alice"));\n        // Выведи: Bob scored 87\n    }\n}',
      expectedOutput: 'Alice scored 95\nBob scored 87',
    ),
  ],
];

/// Получить задание по индексу модуля и урока.
/// Если индекс выходит за пределы - возвращает дефолтное задание.
OopCodeTask getOopCodeTask(int moduleIndex, int lessonIndex) {
  if (moduleIndex >= 0 && moduleIndex < oopCodeTasks.length) {
    final moduleTasks = oopCodeTasks[moduleIndex];
    if (lessonIndex >= 0 && lessonIndex < moduleTasks.length) {
      return moduleTasks[lessonIndex];
    }
  }
  return OopCodeTask(
    title: 'Задание: выведи результат',
    starterCode: 'public class Main {\n    public static void main(String[] args) {\n        // Напишите ваш код здесь\n        System.out.println("Hello, Java!");\n    }\n}',
    expectedOutput: 'Hello, Java!',
  );
}
