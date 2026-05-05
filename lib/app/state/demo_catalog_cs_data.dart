import 'package:flutter/material.dart';

import 'demo_catalog_support.dart';
import 'demo_models.dart';

List<LearningTrack> buildComputerScienceTracks() {
  return <LearningTrack>[
    _track(
      id: 'mathematics',
      title: 'Mathematics',
      subtitle:
          'The common mathematical foundation for computing and engineering',
      description:
          'Build the broad mathematical base that supports algorithms, AI, analytics, and systems thinking.',
      teaser:
          'Acts as the parent branch for analysis, discrete math, linear algebra, and probability/statistics.',
      outcome:
          'You can explain why different math branches support different computing tasks.',
      icon: Icons.calculate_rounded,
      color: const Color(0xFF8DD8FF),
      order: 0,
      nodeId: 'cs-math-root',
      connections: <String>[
        'mathematical_analysis',
        'discrete_math',
        'linear_algebra_calculus',
        'probability_statistics_analytics',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'oop',
      title: 'OOP',
      subtitle: 'Classes, inheritance, encapsulation, and polymorphism',
      description:
          'Build a practical object-oriented mental model for reusable program structure and small system design.',
      teaser:
          'Useful for backend services, app architecture, domain modeling, and interview-style coding tasks.',
      outcome:
          'You can model small learning scenarios with classes, overridden behavior, and clean object APIs.',
      icon: Icons.account_tree_rounded,
      color: const Color(0xFF6FD8FF),
      order: 12,
      nodeId: 'cs-oop',
      connections: <String>['algorithms_data_structures', 'backend', 'mobile'],
      modules: <DemoModuleSeed>[
        _module(
          id: 'oop_module_1',
          title: 'Classes and Objects',
          summary:
              'Fields, constructors, methods, and the basic object model behind small learning entities.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'oop_lesson_1_1',
              title: 'Classes, fields, and constructors',
              trackTitle: 'OOP',
              summary:
                  'Create a class, initialize it with a constructor, and read values from a real object instance.',
              outcome:
                  'You can define a small class and instantiate it with clear field values.',
              codeSnippet: '''class Course {
  Course(this.title);

  final String title;
}

void main() {
  final course = Course('OOP Basics');
  print(course.title);
}''',
              output: 'OOP Basics',
              quizOptions: <String>['Course', 'OOP Basics', 'title'],
              correctQuizIndex: 1,
              quizPrompt:
                  'What does the object print after the Course instance is created?',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the constructor field',
                instruction:
                    'Choose the property that stores the course name inside the object.',
                prompt: 'Course(this.____);',
                options: <String>['title', 'modules', 'summary'],
                correctIndex: 0,
                template: 'Course(this.____);',
              ),
            ),
            _lesson(
              id: 'oop_lesson_1_2',
              title: 'Methods and encapsulation',
              trackTitle: 'OOP',
              summary:
                  'Group object behavior with methods and keep the object response readable from the outside.',
              outcome:
                  'You can place a method on a class and use it to expose a clean result.',
              codeSnippet: '''class StudentProgress {
  StudentProgress(this.completedLessons);

  final int completedLessons;

  String badge() => completedLessons >= 5 ? 'Ready' : 'Warming up';
}

void main() {
  final progress = StudentProgress(6);
  print(progress.badge());
}''',
              output: 'Ready',
              quizOptions: <String>['Ready', '6', 'badge'],
              correctQuizIndex: 0,
              quizPrompt:
                  'What does the badge() method return for a learner with 6 completed lessons?',
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Match the method output',
                instruction:
                    'Choose the string returned by the method for the current object state.',
                prompt: '''class StudentProgress {
  StudentProgress(this.completedLessons);
  final int completedLessons;
  String badge() => completedLessons >= 3 ? 'On track' : 'Starting';
}

void main() {
  final progress = StudentProgress(4);
  print(progress.badge());
}''',
                options: <String>['Starting', 'On track', '4'],
                correctIndex: 1,
              ),
            ),
          ],
          practice: _practice(
            id: 'oop_practice_1',
            title: 'Model a course object',
            starterCode: '''class LessonCard {
  LessonCard(this.title, this.minutes);

  final String title;
  final int minutes;
}

void main() {
  final card = LessonCard('Encapsulation', 18);

  // print one short summary for the card
}''',
          ),
        ),
        _module(
          id: 'oop_module_2',
          title: 'Inheritance and Polymorphism',
          summary:
              'Extend a base type, override behavior, and compare the output of parent and child objects.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'oop_lesson_2_1',
              title: 'Inheritance with extends',
              trackTitle: 'OOP',
              summary:
                  'Reuse a base class and add specialized data in a derived object.',
              outcome:
                  'You can create a child class that extends a parent model with one extra field.',
              codeSnippet: '''class Person {
  Person(this.name);

  final String name;
}

class Mentor extends Person {
  Mentor(super.name, this.track);

  final String track;
}

void main() {
  final mentor = Mentor('Dana', 'OOP');
  print('\${mentor.name} -> \${mentor.track}');
}''',
              output: 'Dana -> OOP',
              quizOptions: <String>[
                'Dana -> OOP',
                'Mentor -> Dana',
                'OOP -> Dana',
              ],
              correctQuizIndex: 0,
              quizPrompt:
                  'What is printed after the Mentor object inherits the name field and adds track?',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the inheritance keyword',
                instruction:
                    'Choose the keyword used when one class derives from another in Dart.',
                prompt: 'class Mentor ____ Person { ... }',
                options: <String>['extends', 'implements', 'mixes'],
                correctIndex: 0,
                template: 'class Mentor ____ Person {',
              ),
            ),
            _lesson(
              id: 'oop_lesson_2_2',
              title: 'Override and dynamic dispatch',
              trackTitle: 'OOP',
              summary:
                  'Replace a parent method with more specific child behavior and read the updated output.',
              outcome:
                  'You can override a method and explain why the child implementation runs.',
              codeSnippet: '''class CourseItem {
  String label() => 'Base course';
}

class MidtermCourse extends CourseItem {
  @override
  String label() => 'OOP midterm';
}

void main() {
  final item = MidtermCourse();
  print(item.label());
}''',
              output: 'OOP midterm',
              quizOptions: <String>[
                'Base course',
                'OOP midterm',
                'MidtermCourse',
              ],
              correctQuizIndex: 1,
              quizPrompt:
                  'Which label is printed after the child class overrides the base method?',
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the override flow',
                instruction:
                    'Arrange the lines so the child class prints its own implementation.',
                prompt:
                    'Put the overridden method example back in a working order.',
                orderedLines: <String>[
                  'class BaseItem { String label() => \'base\'; }',
                  'class ChildItem extends BaseItem { @override String label() => \'child\'; }',
                  'final item = ChildItem();',
                  'print(item.label());',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'oop_practice_2',
            title: 'Compare parent and child behavior',
            starterCode: '''class LearningUnit {
  String status() => 'generic';
}

class QuizUnit extends LearningUnit {
  @override
  String status() => 'quiz ready';
}

void main() {
  final item = QuizUnit();

  // print the specialized status
}''',
          ),
        ),
        _module(
          id: 'oop_module_3',
          title: 'Encapsulation and Interfaces',
          summary:
              'Control access to fields and enforce consistent behavior across multiple object types using interfaces.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'oop_lesson_3_1',
              title: 'Private fields and Getters',
              trackTitle: 'OOP',
              summary:
                  'Hide internal object state and expose safe read-only data.',
              outcome:
                  'You can protect object variables from unintended external modifications.',
              codeSnippet: '''class BankAccount {
  BankAccount(this._balance);

  final double _balance; // private field

  double get balance => _balance;
}

void main() {
  final account = BankAccount(100.0);
  print(account.balance);
}''',
              output: '100.0',
              quizOptions: <String>[
                '_balance',
                'balance',
                'BankAccount',
              ],
              correctQuizIndex: 0,
              quizPrompt:
                  'Which field is kept private inside the class?',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Hide the internal state',
                instruction:
                    'Choose the prefix used in Dart to make a field private.',
                prompt: 'class User { final String ____password; }',
                options: <String>['_', 'private ', 'hidden '],
                correctIndex: 0,
                template: 'class User { final String ____password; }',
              ),
            ),
            _lesson(
              id: 'oop_lesson_3_2',
              title: 'Interfaces with implements',
              trackTitle: 'OOP',
              summary:
                  'Define a strict contract that multiple unrelated classes must follow.',
              outcome:
                  'You can force different objects to provide the same method signatures.',
              codeSnippet: '''abstract class Printable {
  String printDetails();
}

class Invoice implements Printable {
  @override
  String printDetails() => 'Invoice data';
}

void main() {
  final doc = Invoice();
  print(doc.printDetails());
}''',
              output: 'Invoice data',
              quizOptions: <String>[
                'implements',
                'extends',
                'abstract',
              ],
              correctQuizIndex: 0,
              quizPrompt:
                  'Which keyword forces a class to follow an interface contract?',
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the interface flow',
                instruction:
                    'Arrange the lines so the class implements the required contract.',
                prompt:
                    'Put the interface example back in a working order.',
                orderedLines: <String>[
                  'abstract class Logger { void log(); }',
                  'class FileLogger implements Logger {',
                  '  @override void log() => print(\'file\');',
                  '}',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'oop_practice_3',
            title: 'Build a secure model',
            starterCode: '''class Vault {
  Vault(this._secret);

  final String _secret;
}

void main() {
  final vault = Vault('hidden code');

  // use a getter to print the secret securely
}''',
          ),
        ),
        _module(
          id: 'oop_module_4_midterm',
          title: 'Midterm',
          summary:
              'A temporary OOP checkpoint with a draft code runner, final submission, and a review thread.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'oop_lesson_4_1',
              title: 'Midterm brief',
              trackTitle: 'OOP',
              summary:
                  'Read the task, identify the base class, the child class, and the overridden method before typing.',
              outcome:
                  'You can plan the final object model before touching the code editor.',
              codeSnippet: '''// Midterm idea:
// 1. Create StudentProfile
// 2. Extend it with BootcampStudent
// 3. Override summary()
// 4. Print the final result''',
              output: 'Plan the object model before writing the final code.',
              quizOptions: <String>[
                'Start from inheritance and final output',
                'Delete the base class',
                'Avoid overriding methods',
              ],
              correctQuizIndex: 0,
              quizPrompt:
                  'Which approach gives the cleanest start before solving the OOP midterm?',
              trainer: const DemoTrainerSeed.matching(
                title: 'Map the midterm pieces',
                instruction: 'Match each OOP element to its role in the task.',
                prompt: 'Connect the structural parts of the midterm.',
                options: <String>[
                  'Base class',
                  'Child class',
                  'Overridden method',
                ],
                orderedLines: <String>[
                  'Stores shared state for every learner object',
                  'Adds points and specialized behavior',
                  'Returns the final customized summary',
                ],
              ),
            ),
            _lesson(
              id: 'oop_lesson_4_2',
              title: 'Submission checklist',
              trackTitle: 'OOP',
              summary:
                  'Review the required snippets so the draft run and final review can recognize the OOP solution.',
              outcome:
                  'You can verify your own code against the core OOP requirements before submitting.',
              codeSnippet: '''// Required pieces:
// class StudentProfile
// class BootcampStudent extends StudentProfile
// @override
// String summary()
// print(student.summary())''',
              output: 'Check the required snippets before submission.',
              quizOptions: <String>[
                '@override',
                'print("done") only',
                'No child class',
              ],
              correctQuizIndex: 0,
              quizPrompt:
                  'Which snippet is required for the final midterm review?',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the child class declaration',
                instruction:
                    'Choose the inheritance keyword used by the review checklist.',
                prompt: 'class BootcampStudent ____ StudentProfile { ... }',
                options: <String>['extends', 'with', 'typedef'],
                correctIndex: 0,
                template: 'class BootcampStudent ____ StudentProfile { ... }',
              ),
            ),
          ],
          practice: const DemoPracticeSeed(
            id: 'oop_midterm',
            title: 'OOP Midterm',
            summary:
                'Solve a small OOP modeling task in the editor, run a draft console output, then submit the result for review.',
            brief:
                'Create a base learner class, extend it with a bootcamp-specific student, override the summary method, and print the final sentence.',
            starterCode: '''class StudentProfile {
  StudentProfile(this.name);

  final String name;

  String summary() {
    return 'Student: \$name';
  }
}

class BootcampStudent extends StudentProfile {
  BootcampStudent(super.name, this.points);

  final int points;

  @override
  String summary() {
    // TODO: return the final midterm sentence
  }
}

void main() {
  final student = BootcampStudent('Aida', 86);

  // TODO: print the overridden summary
}''',
            successCriteria: <String>[
              'Keep the base and child classes readable and separated.',
              'Override summary() in the child class.',
              'Print the final result from main().',
            ],
            knowledgeChecks: <String>[
              'Which field belongs to the base class and which one belongs to the child class?',
              'Why does the child implementation of summary() run instead of the base one?',
            ],
            promptSuggestion:
                'Help me explain why this OOP midterm solution uses inheritance and method overriding.',
            xpReward: 120,
            codeChallenge: DemoPracticeCodeChallengeSeed(
              title: 'Interactive code lab',
              instructions:
                  'Finish the OOP task, run the code as a draft, then submit it for review. The checker looks for the base class, the child class, the override, and the final print.',
              expectedOutput: 'Aida finished OOP Midterm with 86 points.',
              requiredSnippets: <String>[
                'class StudentProfile',
                'class BootcampStudent extends StudentProfile',
                '@override',
                'String summary()',
                'finished OOP Midterm',
                'student.summary()',
                'print(',
              ],
              successMessage:
                  'Midterm passed. The OOP structure, override, and final output all match the review rules.',
              retryMessage:
                  'The midterm is not ready yet. Check the inheritance structure, overridden summary(), and final print statement.',
            ),
            comments: <DemoPracticeCommentSeed>[
              DemoPracticeCommentSeed(
                id: 'oop_midterm_comment_1',
                authorName: 'Dana Mentor',
                role: 'Teacher',
                message:
                    'Start from the shared field in StudentProfile, then keep the custom points logic inside BootcampStudent.',
              ),
              DemoPracticeCommentSeed(
                id: 'oop_midterm_comment_2',
                authorName: 'Aruzhan',
                role: 'Student',
                message:
                    'I forgot to print student.summary() on the first try, so the draft run helped me catch it quickly.',
              ),
            ],
          ),
        ),
      ],
    ),
    _track(
      id: 'mathematical_analysis',
      title: 'Mathematical Analysis',
      subtitle: 'Limits, derivatives, continuity, and change over time',
      description:
          'Understand how continuous change, rates, and accumulation support technical reasoning.',
      teaser:
          'Useful for optimization, modeling, and dynamic system intuition.',
      outcome:
          'You can explain how change over time appears in technical systems and models.',
      icon: Icons.functions_rounded,
      color: const Color(0xFF7CB8FF),
      order: 1,
      nodeId: 'cs-math-analysis',
      connections: <String>[
        'mathematics',
        'linear_algebra_calculus',
        'probability_statistics_analytics',
        'ai_theory',
      ],
      modules: <DemoModuleSeed>[
        _module(
          id: 'mathematical_analysis_module_1',
          title: 'Limits and Continuity',
          summary:
              'Sequences, limit theorems, one-sided limits, and continuous behavior.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'mathematical_analysis_lesson_1_1',
              title: 'Sequences and limits',
              trackTitle: 'Mathematical Analysis',
              codeSnippet: '''final f = (double x) => (x * x - 1) / (x - 1);
print(f(1.001).toStringAsFixed(3));''',
              output: '2.001',
              quizOptions: <String>['1.001', '2.001', '0.999'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the limit expression',
                instruction:
                    'Choose the value that the function approaches as x nears 1.',
                prompt: 'lim(x->1) (x^2 - 1)/(x - 1) = ?',
                options: <String>['2', '1', '0'],
                correctIndex: 0,
                template: 'final limit = ____;',
              ),
            ),
            _lesson(
              id: 'mathematical_analysis_lesson_1_2',
              title: 'Continuity and one-sided limits',
              trackTitle: 'Mathematical Analysis',
              codeSnippet: '''final leftLimit = 2.999;
final rightLimit = 3.001;
final diff = (rightLimit - leftLimit).abs();
print(diff.toStringAsFixed(3));''',
              output: '0.002',
              quizOptions: <String>['0.002', '0.020', '6.000'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.matching(
                title: 'Match limit concepts',
                instruction: 'Match each concept to its definition.',
                prompt: 'Connect limit terms to their meanings.',
                options: <String>[
                  'Left-hand limit',
                  'Right-hand limit',
                  'Continuity',
                ],
                orderedLines: <String>[
                  'Value approached from below',
                  'Value approached from above',
                  'Left limit equals right limit equals f(a)',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'mathematical_analysis_practice_1',
            title: 'Explore a limit numerically',
            starterCode: '''final f = (double x) => (x * x * x - 8) / (x - 2);

// Evaluate f at 2.01 and 1.99 to approximate the limit
// print the average of both values''',
          ),
        ),
        _module(
          id: 'mathematical_analysis_module_2',
          title: 'Differentiation',
          summary:
              'Derivative definition, differentiation rules, and the chain rule.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'mathematical_analysis_lesson_2_1',
              title: 'Derivative as rate of change',
              trackTitle: 'Mathematical Analysis',
              codeSnippet: '''final x = 3.0;
final h = 0.001;
final df = ((x + h) * (x + h) - x * x) / h;
print(df.toStringAsFixed(1));''',
              output: '6.0',
              quizOptions: <String>['3.0', '6.0', '9.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Order the derivative computation',
                instruction: 'Arrange lines to compute a numerical derivative.',
                prompt: 'Rebuild the discrete derivative approximation.',
                orderedLines: <String>[
                  'final x = 4.0;',
                  'final h = 0.001;',
                  'final df = ((x + h) * (x + h) - x * x) / h;',
                  'print(df.toStringAsFixed(1));',
                ],
              ),
            ),
            _lesson(
              id: 'mathematical_analysis_lesson_2_2',
              title: 'Chain rule and product rule',
              trackTitle: 'Mathematical Analysis',
              codeSnippet:
                  '''// d/dx(3x^2) using power rule: n * coeff * x^(n-1)
final x = 2.0;
final derivative = 2 * 3 * x;
print(derivative);''',
              output: '12.0',
              quizOptions: <String>['6.0', '12.0', '24.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Apply the power rule',
                instruction: 'Fill in the exponent after differentiation.',
                prompt: 'd/dx(x^n) = n * x^____',
                options: <String>['n-1', 'n', 'n+1'],
                correctIndex: 0,
                template: '// d/dx(x^3) = 3 * x^____',
              ),
            ),
          ],
          practice: _practice(
            id: 'mathematical_analysis_practice_2',
            title: 'Compute a derivative numerically',
            starterCode: '''double f(double x) => x * x * x; // f(x) = x^3

final x = 2.0;
final h = 0.0001;

// compute the numerical derivative using (f(x+h) - f(x)) / h
// print the result rounded to 1 decimal''',
          ),
        ),
        _module(
          id: 'mathematical_analysis_module_3',
          title: 'Indefinite Integrals',
          summary: 'Antiderivatives, substitution, and integration by parts.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'mathematical_analysis_lesson_3_1',
              title: 'Antiderivatives',
              trackTitle: 'Mathematical Analysis',
              codeSnippet: '''// Integral of 2x dx = x^2 + C
// Verify: area under f(x)=2x from 0 to 3
final area = 3.0 * 3.0; // x^2 evaluated at 3
print(area);''',
              output: '9.0',
              quizOptions: <String>['6.0', '9.0', '12.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Predict the integral result',
                instruction: 'Choose the value of the antiderivative at x=4.',
                prompt: '''// integral of 2x dx = x^2 + C
// F(4) - F(0) where F(x) = x^2
final result = 4.0 * 4.0 - 0;
print(result);''',
                options: <String>['8.0', '12.0', '16.0'],
                correctIndex: 2,
              ),
            ),
            _lesson(
              id: 'mathematical_analysis_lesson_3_2',
              title: 'Substitution and integration by parts',
              trackTitle: 'Mathematical Analysis',
              codeSnippet: '''// Riemann sum: integral of x^2 from 0 to 3
var sum = 0.0;
final n = 1000;
final dx = 3.0 / n;
for (var i = 0; i < n; i++) {
  final x = i * dx;
  sum += x * x * dx;
}
print(sum.toStringAsFixed(1));''',
              output: '9.0',
              quizOptions: <String>['3.0', '9.0', '27.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matching(
                title: 'Match integration techniques',
                instruction: 'Match each technique to its use case.',
                prompt: 'Connect integration methods to their descriptions.',
                options: <String>['U-substitution', 'By parts', 'Power rule'],
                orderedLines: <String>[
                  'Replace inner function with a new variable',
                  'Split product into two factors using uv formula',
                  'Increase exponent by 1 and divide by it',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'mathematical_analysis_practice_3',
            title: 'Approximate a definite integral',
            starterCode:
                '''// Use a Riemann sum to approximate integral of x^3 from 0 to 2
var sum = 0.0;
final n = 1000;
final dx = 2.0 / n;

// complete the loop and print the result''',
          ),
        ),
        _module(
          id: 'mathematical_analysis_module_4',
          title: 'Series and Sequences',
          summary: 'Convergence tests, power series, and Taylor series.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'mathematical_analysis_lesson_4_1',
              title: 'Convergence tests',
              trackTitle: 'Mathematical Analysis',
              codeSnippet:
                  '''// Geometric series: sum = a / (1 - r) when |r| < 1
final a = 1.0;
final r = 0.5;
final sum = a / (1 - r);
print(sum);''',
              output: '2.0',
              quizOptions: <String>['1.0', '1.5', '2.0'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the geometric series formula',
                instruction: 'Fill in the denominator of the closed-form sum.',
                prompt: 'Sum of geometric series = a / ____',
                options: <String>['(1 - r)', 'r', '(1 + r)'],
                correctIndex: 0,
                template: 'final sum = a / ____;',
              ),
            ),
            _lesson(
              id: 'mathematical_analysis_lesson_4_2',
              title: 'Taylor series',
              trackTitle: 'Mathematical Analysis',
              codeSnippet: '''// e^x Taylor: 1 + x + x^2/2! + x^3/3! ...
// Approximate e^1 with 4 terms
final approx = 1 + 1 + 0.5 + (1/6);
print(approx.toStringAsFixed(3));''',
              output: '2.667',
              quizOptions: <String>['2.500', '2.667', '2.718'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Build the Taylor expansion',
                instruction: 'Arrange the terms of e^x Taylor series in order.',
                prompt:
                    'Order the first four terms of the Taylor series for e^x.',
                orderedLines: <String>['1', '+ x', '+ x^2 / 2!', '+ x^3 / 3!'],
              ),
            ),
          ],
          practice: _practice(
            id: 'mathematical_analysis_practice_4',
            title: 'Approximate e using a Taylor series',
            starterCode:
                '''// Compute e^1 using the first 10 terms of the Taylor series
// e^x = sum(x^n / n!) for n = 0, 1, 2, ...
var approx = 0.0;
var factorial = 1;

// complete the loop and print the approximation''',
          ),
        ),
      ],
    ),
    _track(
      id: 'discrete_math',
      title: 'Discrete Math',
      subtitle: 'Logic, sets, graphs, and counting techniques',
      description:
          'Learn the language behind algorithms and structured reasoning.',
      teaser: 'Strong for algorithms, backend reasoning, and state modeling.',
      outcome:
          'You can reason about structure, conditions, and combinations clearly.',
      icon: Icons.route_rounded,
      color: const Color(0xFF7CE7FF),
      order: 2,
      nodeId: 'cs-discrete',
      connections: <String>[
        'linear_algebra_calculus',
        'probability_statistics_analytics',
      ],
      modules: <DemoModuleSeed>[
        // ── Module 1: Logic & Proof Techniques ──────────────────────────
        _module(
          id: 'discrete_math_module_1',
          title: 'Logic & Proof Techniques',
          titleRu: 'Логика и методы доказательства',
          titleKk: 'Логика және дәлелдеу әдістері',
          summary:
              'Propositional and predicate logic, truth tables, and classical proof methods including direct proof, contrapositive, contradiction, and mathematical induction.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_1_1',
              title: 'Propositional logic and truth tables',
              trackTitle: 'Discrete Math',
              summary:
                  'Propositions, logical connectives, truth tables, tautologies, contradictions, and De Morgan\'s laws.',
              outcome:
                  'Construct truth tables for compound propositions and apply De Morgan\'s laws to simplify logical expressions.',
              theoryContent:
                  'A proposition is a declarative statement that is either true (T) or false (F), but not both. '
                  'For example, “2 + 2 = 4” is a proposition (true), while “x > 5” is not a proposition until x is specified — it is a predicate.\n\n'
                  '► Logical Connectives\n'
                  'Given propositions P and Q, we build compound propositions using five fundamental connectives:\n'
                  '  • Negation: ¬P — “not P”. True when P is false.\n'
                  '  • Conjunction: P ∧ Q — “P and Q”. True only when both P and Q are true.\n'
                  '  • Disjunction: P ∨ Q — “P or Q”. True when at least one of P, Q is true.\n'
                  '  • Implication: P → Q — “if P then Q”. False only when P is true and Q is false.\n'
                  '  • Biconditional: P ↔ Q — “P if and only if Q”. True when P and Q have the same truth value.\n\n'
                  '► Truth Tables\n'
                  'A truth table lists all possible combinations of truth values for the component propositions and computes the result. '
                  'For n atomic propositions there are 2^n rows. For P → Q:\n\n'
                  '  P | Q | P → Q\n'
                  '  T | T |   T\n'
                  '  T | F |   F\n'
                  '  F | T |   T\n'
                  '  F | F |   T\n\n'
                  'Notice that an implication is vacuously true whenever the hypothesis P is false.\n\n'
                  '► Tautology and Contradiction\n'
                  'A tautology is always true regardless of component truth values (e.g., P ∨ ¬P). '
                  'A contradiction is always false (e.g., P ∧ ¬P).\n\n'
                  '► De Morgan\'s Laws\n'
                  '  1. ¬(P ∧ Q) ≡ ¬P ∨ ¬Q\n'
                  '  2. ¬(P ∨ Q) ≡ ¬P ∧ ¬Q\n\n'
                  'Proof of Law 1 by truth table:\n'
                  '  P | Q | P∧Q | ¬(P∧Q) | ¬P | ¬Q | ¬P∨¬Q\n'
                  '  T | T |  T  |   F    |  F |  F |   F\n'
                  '  T | F |  F  |   T    |  F |  T |   T\n'
                  '  F | T |  F  |   T    |  T |  F |   T\n'
                  '  F | F |  F  |   T    |  T |  T |   T\n\n'
                  'The columns ¬(P∧Q) and ¬P∨¬Q are identical ⟹ equivalence holds. '
                  'These laws extend to n propositions: ¬(P₁ ∧ … ∧ Pₙ) ≡ ¬P₁ ∨ … ∨ ¬Pₙ.',
              keyPoints: <String>[
                'The five logical connectives are ¬, ∧, ∨, →, and ↔.',
                'De Morgan\'s laws: ¬(P ∧ Q) ≡ ¬P ∨ ¬Q and ¬(P ∨ Q) ≡ ¬P ∧ ¬Q.',
                'A tautology is always true; a contradiction is always false.',
              ],
              codeSnippet: '''final values = [true, false];
for (final p in values) {
  for (final q in values) {
    final lhs = !(p && q);
    final rhs = !p || !q;
    print('p=\$p q=\$q  ¬(p∧q)=\$lhs  ¬p∨¬q=\$rhs  equal=\${lhs == rhs}');
  }
}''',
              output:
                  'p=true q=true  ¬(p∧q)=false  ¬p∨¬q=false  equal=true\np=true q=false  ¬(p∧q)=true  ¬p∨¬q=true  equal=true\np=false q=true  ¬(p∧q)=true  ¬p∨¬q=true  equal=true\np=false q=false  ¬(p∧q)=true  ¬p∨¬q=true  equal=true',
              quizPrompt:
                  'According to De Morgan\'s law, ¬(P ∨ Q) is equivalent to:',
              quizOptions: <String>['¬P ∨ ¬Q', '¬P ∧ ¬Q', 'P ∧ Q'],
              correctQuizIndex: 1,
              quizExplanation:
                  'De Morgan\'s second law: ¬(P ∨ Q) ≡ ¬P ∧ ¬Q. Negation of a disjunction becomes the conjunction of negations.',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Apply De Morgan\'s law',
                instruction:
                    'Complete the equivalent expression using De Morgan\'s law.',
                prompt: '¬(P ∧ Q) ≡ ¬P ____ ¬Q',
                options: <String>['∨', '∧', '→'],
                correctIndex: 0,
                template: 'print(!(a && b) == (!a ____ !b));',
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Match logical connectives',
                  instruction: 'Connect each logical symbol to its meaning.',
                  prompt: 'Match the connective to its operation.',
                  options: <String>['∧', '∨', '¬', '→', '↔'],
                  orderedLines: <String>[
                    'AND — true when both are true',
                    'OR — true when at least one is true',
                    'NOT — flips the truth value',
                    'IF...THEN — false only when T→F',
                    'IF AND ONLY IF — same truth values',
                  ],
                ),
              ],
              titleRu: 'Пропозициональная логика и таблицы истинности',
              titleKk: 'Пропозициялық логика және шындық кестелері',
              summaryRu:
                  'Высказывания, логические связки, таблицы истинности, тавтологии, противоречия и законы Де Моргана.',
              summaryKk:
                  'Ұсыныстар, логикалық байланыстырғыштар, шындық кестелері, тавтологиялар, қарама-қайшылықтар және Де Морган заңдары.',
              outcomeRu:
                  'Составлять таблицы истинности для составных высказываний и применять законы Де Моргана.',
              outcomeKk:
                  'Күрделі ұсыныстар үшін шындық кестелерін құру және Де Морган заңдарын қолдану.',
              keyPointsRu: <String>[
                'Пять логических связок: ¬, ∧, ∨, →, и ↔.',
                'Законы Де Моргана: ¬(P ∧ Q) ≡ ¬P ∨ ¬Q и ¬(P ∨ Q) ≡ ¬P ∧ ¬Q.',
                'Тавтология всегда истинна; противоречие всегда ложно.',
              ],
              keyPointsKk: <String>[
                'Бес логикалық байланыстырғыш: ¬, ∧, ∨, →, және ↔.',
                'Де Морган заңдары: ¬(P ∧ Q) ≡ ¬P ∨ ¬Q және ¬(P ∨ Q) ≡ ¬P ∧ ¬Q.',
                'Тавтология әрқашан шын; қарама-қайшылық әрқашан жалған.',
              ],
              quizPromptRu:
                  'По второму закону Де Моргана, ¬(P ∨ Q) эквивалентно:',
            ),
            _lesson(
              id: 'discrete_math_lesson_1_2',
              title: 'Proof techniques',
              trackTitle: 'Discrete Math',
              summary:
                  'Direct proof, proof by contrapositive, proof by contradiction, and mathematical induction with detailed examples.',
              outcome:
                  'Apply the appropriate proof technique and carry out proofs by induction.',
              theoryContent:
                  'A mathematical proof is a logical argument that establishes the truth of a statement beyond any doubt.\n\n'
                  '► Direct Proof\n'
                  'To prove "if P then Q" directly, assume P is true and deduce Q.\n\n'
                  'Example: Prove that if n is even, then n² is even.\n'
                  'Proof: Assume n is even. Then n = 2k for some integer k. So n² = (2k)² = 4k² = 2(2k²). Since 2k² is an integer, n² is even. ∎\n\n'
                  '► Proof by Contrapositive\n'
                  'The contrapositive of "P → Q" is "¬Q → ¬P". These are logically equivalent.\n\n'
                  'Example: Prove that if n² is odd, then n is odd.\n'
                  'Contrapositive: if n is even, then n² is even — proved above! ∎\n\n'
                  '► Proof by Contradiction\n'
                  'To prove statement S, assume ¬S and derive a contradiction.\n\n'
                  'Example: Prove that √2 is irrational.\n'
                  'Proof: Assume √2 = a/b where a, b have no common factors. Then a² = 2b². '
                  'So a² is even → a is even, say a = 2c. Then 4c² = 2b² → b² = 2c² → b is even. '
                  'But then a and b share factor 2 — contradiction. ∎\n\n'
                  '► Mathematical Induction\n'
                  'Proves statements ∀n ≥ n₀, P(n) in two steps:\n'
                  '  1. Base case: Verify P(n₀) is true.\n'
                  '  2. Inductive step: Assume P(k), prove P(k+1).\n\n'
                  '► Example: 1 + 2 + … + n = n(n+1)/2\n\n'
                  'Base case (n = 1): LHS = 1. RHS = 1·2/2 = 1. ✓\n\n'
                  'Inductive step: Assume 1 + 2 + … + k = k(k+1)/2.\n'
                  'Then 1 + 2 + … + k + (k+1) = k(k+1)/2 + (k+1)\n'
                  '     = (k+1)(k+2)/2 = RHS. ✓\n\n'
                  'By induction, the formula holds for all n ≥ 1. ∎\n\n'
                  '► Strong Induction\n'
                  'A variant where the hypothesis assumes P(n₀), P(n₀+1), …, P(k) are all true. '
                  'Useful when P(k+1) depends on multiple earlier cases (e.g., Fibonacci, prime factorization).',
              keyPoints: <String>[
                'Direct proof assumes the hypothesis and deduces the conclusion step by step.',
                'Proof by contradiction assumes the negation and derives an impossibility.',
                'Induction requires: base case + inductive step (assume P(k), prove P(k+1)).',
              ],
              codeSnippet:
                  '''// Verify induction formula: 1 + 2 + ... + n = n*(n+1)/2
int sumByLoop(int n) {
  var total = 0;
  for (var i = 1; i <= n; i++) total += i;
  return total;
}
int sumByFormula(int n) => n * (n + 1) ~/ 2;

for (var n = 1; n <= 10; n++) {
  print('n=\$n  loop=\${sumByLoop(n)}  formula=\${sumByFormula(n)}  match=\${sumByLoop(n) == sumByFormula(n)}');
}''',
              output:
                  'n=1  loop=1  formula=1  match=true\nn=2  loop=3  formula=3  match=true\nn=3  loop=6  formula=6  match=true\nn=4  loop=10  formula=10  match=true\nn=5  loop=15  formula=15  match=true\nn=6  loop=21  formula=21  match=true\nn=7  loop=28  formula=28  match=true\nn=8  loop=36  formula=36  match=true\nn=9  loop=45  formula=45  match=true\nn=10  loop=55  formula=55  match=true',
              quizPrompt:
                  'In mathematical induction, what is the inductive step?',
              quizOptions: <String>[
                'Prove P(n) for all n directly',
                'Assume P(k) and prove P(k+1)',
                'Assume P(k+1) and prove P(k)',
              ],
              correctQuizIndex: 1,
              quizExplanation:
                  'The inductive step: assume P(k) holds (inductive hypothesis) and prove P(k+1). Combined with the base case, this proves P(n) for all n ≥ n₀.',
              trainer: const DemoTrainerSeed.reorder(
                title: 'Induction proof steps',
                instruction:
                    'Arrange the steps of an induction proof in the correct order.',
                prompt: 'Put these proof steps in the correct logical order.',
                orderedLines: <String>[
                  'State: Prove 1+2+…+n = n(n+1)/2 for all n ≥ 1',
                  'Base case: verify n=1 → 1 = 1·2/2 = 1 ✓',
                  'Inductive hypothesis: assume formula holds for some k ≥ 1',
                  'Consider the sum 1+2+…+k+(k+1)',
                  'Substitute hypothesis: k(k+1)/2 + (k+1)',
                  'Simplify to (k+1)(k+2)/2',
                  'Conclude: by induction, formula holds for all n ≥ 1',
                ],
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Proof techniques',
                  instruction: 'Match each proof technique to its description.',
                  prompt: 'Match the proof method to its approach.',
                  options: <String>[
                    'Direct Proof',
                    'Contrapositive',
                    'Contradiction',
                    'Induction',
                  ],
                  orderedLines: <String>[
                    'Assume P, deduce Q step by step',
                    'Prove ¬Q → ¬P instead of P → Q',
                    'Assume ¬S, derive an impossibility',
                    'Verify base case, then assume P(k) to prove P(k+1)',
                  ],
                ),
              ],
              titleRu: 'Методы доказательства',
              titleKk: 'Дәлелдеу әдістері',
              summaryRu:
                  'Прямое доказательство, контрапозитив, доказательство от противоречия и математическая индукция.',
              summaryKk:
                  'Тікелей дәлелдеу, контрапозитив, қарама-қайшылықпен дәлелдеу және математикалық индукция.',
              outcomeRu:
                  'Применять подходящий метод доказательства и проводить доказательства по индукции.',
              outcomeKk:
                  'Тиісті дәлелдеу әдісін қолдану және индукция бойынша дәлелдемелер жүргізу.',
              keyPointsRu: <String>[
                'Прямое доказательство предполагает гипотезу и выводит заключение шаг за шагом.',
                'Доказательство от противоречия предполагает отрицание и выводит невозможность.',
                'Индукция: базовый случай + шаг (предположить P(k), доказать P(k+1)).',
              ],
              keyPointsKk: <String>[
                'Тікелей дәлелдеу гипотезаны болжайды және қорытындыны қадамма-қадам шығарады.',
                'Қарама-қайшылықпен дәлелдеу терістеуді болжайды және мүмкін еместікті шығарады.',
                'Индукция: базалық жағдай + қадам (P(k) деп болжап, P(k+1) дәлелдеу).',
              ],
              quizPromptRu: 'В математической индукции что такое шаг индукции?',
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_1',
            title: 'Logic & proof challenge',
            starterCode: '''// 1. Build a truth table for (P → Q) ↔ (¬P ∨ Q)
//    Verify it is a tautology (always true)
// 2. Prove by induction: 1² + 2² + ... + n² = n(n+1)(2n+1)/6
//    Verify for n = 1..10 programmatically''',
          ),
        ),
        // ── Module 2: Set Theory ─────────────────────
        _module(
          id: 'discrete_math_module_2',
          title: 'Set Theory',
          titleRu: 'Теория множеств',
          titleKk: 'Жиындар теориясы',
          summary:
              'Set operations, Venn diagrams, inclusion-exclusion, power sets, Cartesian products, and cardinality.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_2_1',
              title: 'Sets and operations',
              trackTitle: 'Discrete Math',
              summary:
                  'Set notation, union, intersection, difference, complement, and the inclusion-exclusion principle.',
              outcome:
                  'Perform set operations and apply the inclusion-exclusion principle to compute the cardinality of unions.',
              theoryContent:
                  'A set is an unordered collection of distinct objects called elements. '
                  'We write a ∈ A to mean "a is an element of A" and a ∉ A for "a is not in A".\n\n'
                  '► Set Notation\n'
                  'Roster notation: A = {1, 2, 3, 4, 5}. '
                  'Set-builder: A = {x ∈ ℤ | 1 ≤ x ≤ 5}. '
                  'Empty set: ∅ = {} contains no elements.\n\n'
                  '► Fundamental Operations\n'
                  '• Union: A ∪ B = {x | x ∈ A or x ∈ B} — all elements in either set.\n'
                  '• Intersection: A ∩ B = {x | x ∈ A and x ∈ B} — elements in both.\n'
                  '• Difference: A \\ B = {x | x ∈ A and x ∉ B} — in A but not B.\n'
                  '• Complement: Aᶜ = U \\ A — elements not in A.\n'
                  '• Symmetric difference: A △ B = (A \\ B) ∪ (B \\ A) — in exactly one set.\n\n'
                  '► Subset and Equality\n'
                  'A ⊆ B means every element of A is also in B. A = B means A ⊆ B and B ⊆ A.\n\n'
                  '► The Inclusion-Exclusion Principle\n'
                  'For two sets:\n'
                  '  |A ∪ B| = |A| + |B| − |A ∩ B|\n\n'
                  'This corrects for double-counting elements in the intersection. For three sets:\n'
                  '  |A ∪ B ∪ C| = |A| + |B| + |C| − |A∩B| − |A∩C| − |B∩C| + |A∩B∩C|\n\n'
                  'Example: 18 study math, 15 study physics, 10 study both.\n'
                  '  |M ∪ P| = 18 + 15 − 10 = 23 students study at least one.\n\n'
                  '► Set Identities (analogous to logic)\n'
                  '  • Commutative: A ∪ B = B ∪ A, A ∩ B = B ∩ A\n'
                  '  • Distributive: A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C)\n'
                  '  • De Morgan\'s: (A ∪ B)ᶜ = Aᶜ ∩ Bᶜ\n'
                  '  • Identity: A ∪ ∅ = A, A ∩ U = A',
              keyPoints: <String>[
                'Union (∪) combines elements; intersection (∩) keeps only shared elements.',
                'Inclusion-exclusion: |A ∪ B| = |A| + |B| − |A ∩ B|.',
                'Set identities mirror logical equivalences (De Morgan\'s, distributive, etc.).',
              ],
              codeSnippet: '''final a = {1, 2, 3, 4, 5};
final b = {3, 4, 5, 6, 7};
print('A ∪ B = \${a.union(b)}');
print('A ∩ B = \${a.intersection(b)}');
print('A \\ B = \${a.difference(b)}');
// Inclusion-exclusion verification
final lhs = a.union(b).length;
final rhs = a.length + b.length - a.intersection(b).length;
print('|A ∪ B| = \$lhs, |A|+|B|-|A∩B| = \$rhs, equal=\${lhs == rhs}');''',
              output:
                  'A ∪ B = {1, 2, 3, 4, 5, 6, 7}\nA ∩ B = {3, 4, 5}\nA \\ B = {1, 2}\n|A ∪ B| = 7, |A|+|B|-|A∩B| = 7, equal=true',
              quizPrompt:
                  'If |A| = 12, |B| = 9, and |A ∩ B| = 4, what is |A ∪ B|?',
              quizOptions: <String>['21', '17', '13'],
              correctQuizIndex: 1,
              quizExplanation:
                  'By inclusion-exclusion: |A ∪ B| = 12 + 9 − 4 = 17. Without subtracting the intersection we\'d double-count 4 elements.',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Inclusion-exclusion formula',
                instruction:
                    'Complete the inclusion-exclusion formula for two sets.',
                prompt: '|A ∪ B| = |A| + |B| ____ |A ∩ B|',
                options: <String>['−', '+', '×'],
                correctIndex: 0,
                template:
                    'final unionSize = a.length + b.length ____ intersection.length;',
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Set operations',
                  instruction:
                      'For A = {1,2,3} and B = {2,3,4}, match each operation to its result.',
                  prompt: 'Match the operation to its result.',
                  options: <String>['A ∪ B', 'A ∩ B', 'A \\ B', 'B \\ A'],
                  orderedLines: <String>[
                    '{1, 2, 3, 4}',
                    '{2, 3}',
                    '{1}',
                    '{4}',
                  ],
                ),
              ],
              titleRu: 'Множества и операции',
              titleKk: 'Жиындар және амалдар',
              summaryRu:
                  'Обозначения множеств, объединение, пересечение, разность, дополнение и принцип включений-исключений.',
              summaryKk:
                  'Жиын белгілемесі, бірігу, қиылысу, айырым, толықтырушы және қосу-алу принципі.',
              outcomeRu:
                  'Выполнять операции над множествами и применять принцип включений-исключений.',
              outcomeKk:
                  'Жиындар үстінде амалдар орындау және қосу-алу принципін қолдану.',
              keyPointsRu: <String>[
                'Объединение (∪) объединяет; пересечение (∩) оставляет только общие элементы.',
                'Включение-исключение: |A ∪ B| = |A| + |B| − |A ∩ B|.',
                'Тождества множеств аналогичны логическим эквиваленциям.',
              ],
              keyPointsKk: <String>[
                'Бірігу (∪) біріктіреді; қиылысу (∩) тек жалпы элементтерді қалдырады.',
                'Қосу-алу: |A ∪ B| = |A| + |B| − |A ∩ B|.',
                'Жиын тождестволары логикалық эквиваленттіліктерге ұқсас.',
              ],
              quizPromptRu:
                  'Если |A| = 12, |B| = 9, и |A ∩ B| = 4, чему равно |A ∪ B|?',
            ),
            _lesson(
              id: 'discrete_math_lesson_2_2',
              title: 'Power sets, Cartesian products, and cardinality',
              trackTitle: 'Discrete Math',
              summary:
                  'Power sets, Cartesian products, and the cardinality of finite and infinite sets.',
              outcome:
                  'Compute power sets and Cartesian products, and reason about cardinality of infinite sets.',
              theoryContent:
                  '► Power Set\n'
                  'The power set P(A) is the set of all subsets of A, including ∅ and A itself.\n\n'
                  'Example: If A = {1, 2}, then P(A) = {∅, {1}, {2}, {1, 2}}.\n\n'
                  '► Theorem: |P(A)| = 2^|A|\n'
                  'For each element, we choose to include or exclude it — 2 choices per element.\n'
                  'With |A| = n elements: 2^n subsets total.\n\n'
                  'For A = {1, 2, 3}: |P(A)| = 2³ = 8 subsets:\n'
                  '  ∅, {1}, {2}, {3}, {1,2}, {1,3}, {2,3}, {1,2,3}\n\n'
                  '► Cartesian Product\n'
                  'A × B = {(a, b) | a ∈ A, b ∈ B} — the set of all ordered pairs.\n\n'
                  '► Theorem: |A × B| = |A| · |B|\n\n'
                  'Example: A = {1, 2}, B = {x, y, z}\n'
                  '  A × B = {(1,x), (1,y), (1,z), (2,x), (2,y), (2,z)}\n'
                  '  |A × B| = 2 · 3 = 6. ✓\n\n'
                  'Note: A × B ≠ B × A in general (order matters in ordered pairs).\n\n'
                  '► Cardinality of Infinite Sets\n'
                  'Two sets have the same cardinality if there exists a bijection between them.\n'
                  'A set is countably infinite if it bijects with ℕ = {0, 1, 2, …}.\n\n'
                  'Surprisingly, |ℤ| = |ℕ|. List ℤ as 0, 1, −1, 2, −2, 3, −3, … — this bijects with ℕ.\n'
                  'Even |ℚ| = |ℕ| (Cantor\'s zigzag argument over a grid of fractions).\n\n'
                  '► Cantor\'s Diagonal Argument\n'
                  'The real numbers ℝ are uncountable: |ℝ| > |ℕ|.\n'
                  'Proof: Suppose we could list all reals in [0,1). Write each rᵢ in decimal. '
                  'Construct d whose i-th digit differs from the i-th digit of rᵢ. '
                  'Then d differs from every rᵢ — contradiction. ∎\n\n'
                  'This gives a hierarchy of infinities: |ℕ| = ℵ₀ < |ℝ| = 2^ℵ₀.',
              keyPoints: <String>[
                'The power set P(A) has 2^|A| elements — every possible subset of A.',
                '|A × B| = |A| · |B| — Cartesian product gives all ordered pairs.',
                'Cantor proved ℝ is uncountable: |ℝ| > |ℕ| (diagonal argument).',
              ],
              codeSnippet: '''// Generate the power set using bitmasks
List<Set<int>> powerSet(Set<int> s) {
  final elts = s.toList();
  return [
    for (var mask = 0; mask < (1 << elts.length); mask++)
      {for (var i = 0; i < elts.length; i++) if (mask & (1 << i) != 0) elts[i]}
  ];
}
final a = {1, 2, 3};
final ps = powerSet(a);
print('P({1,2,3}) = \$ps');
print('|P(A)| = \${ps.length} (expected 2^3 = 8)');

// Cartesian product
final b = ['x', 'y'];
final cp = [for (final x in a) for (final y in b) '(\$x,\$y)'];
print('A × B = \$cp');
print('|A × B| = \${cp.length} (expected 3 × 2 = 6)');''',
              output:
                  'P({1,2,3}) = [{}, {1}, {2}, {1, 2}, {3}, {1, 3}, {2, 3}, {1, 2, 3}]\n|P(A)| = 8 (expected 2^3 = 8)\nA × B = [(1,x), (1,y), (2,x), (2,y), (3,x), (3,y)]\n|A × B| = 6 (expected 3 × 2 = 6)',
              quizPrompt:
                  'How many elements are in the power set P({1, 2, 3})?',
              quizOptions: <String>['3', '6', '8'],
              correctQuizIndex: 2,
              quizExplanation:
                  '|P(A)| = 2^|A| = 2³ = 8 subsets: ∅, {1}, {2}, {3}, {1,2}, {1,3}, {2,3}, {1,2,3}.',
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Power set size',
                instruction: 'Predict the size of the power set.',
                prompt: 'Set A = {a, b, c, d}. What is |P(A)|?',
                options: <String>['4', '8', '16'],
                correctIndex: 2,
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Cardinality formulas',
                  instruction: 'Match each concept to its formula.',
                  prompt: 'Match the construct to its cardinality.',
                  options: <String>[
                    '|P(A)|',
                    '|A × B|',
                    '|A ∪ B|',
                    'Subsets of size k from n',
                  ],
                  orderedLines: <String>[
                    '2^|A|',
                    '|A| · |B|',
                    '|A| + |B| − |A ∩ B|',
                    'C(n, k)',
                  ],
                ),
              ],
              titleRu: 'Степенные множества, декартовы произведения и мощность',
              titleKk:
                  'Дәреже жиындары, декарттық көбейтінділер және кардиналдылық',
              summaryRu:
                  'Степенные множества, декартовы произведения и мощность конечных и бесконечных множеств.',
              summaryKk:
                  'Дәреже жиындары, декарттық көбейтінділер және ақырлы мен шексіз жиындардың кардиналдылығы.',
              outcomeRu:
                  'Вычислять степенные множества и декартовы произведения, рассуждать о мощности бесконечных множеств.',
              outcomeKk:
                  'Дәреже жиындары мен декарттық көбейтінділерді есептеу, шексіз жиындардың кардиналдылығы туралы ойлану.',
              keyPointsRu: <String>[
                'Степенное множество P(A) содержит 2^|A| элементов — каждое возможное подмножество A.',
                '|A × B| = |A| · |B| — декартово произведение даёт все упорядоченные пары.',
                'Кантор: ℝ несчётно: |ℝ| > |ℕ| (диагональный аргумент).',
              ],
              keyPointsKk: <String>[
                'Дәреже жиыны P(A) 2^|A| элементтен тұрады — A-ның барлық ішкі жиындары.',
                '|A × B| = |A| · |B| — декарттық көбейтінді барлық ретті жұптарды береді.',
                'Кантор: ℝ санауылмайтын: |ℝ| > |ℕ| (диагональдық аргумент).',
              ],
              quizPromptRu:
                  'Сколько элементов содержит степенное множество P({1, 2, 3})?',
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_2',
            title: 'Set theory challenge',
            starterCode:
                '''// 1. Write a function powerSet(Set<int> s) that returns all subsets
//    using bitmask enumeration. Verify |P({1,2,3,4})| == 16.
// 2. Verify inclusion-exclusion for three sets A, B, C:
//    |A ∪ B ∪ C| = |A|+|B|+|C| - |A∩B| - |A∩C| - |B∩C| + |A∩B∩C|
final a = {1, 2, 3, 4};
final b = {3, 4, 5, 6};
final c = {4, 5, 6, 7};''',
          ),
        ),
        // ── Module 3: Relations & Functions ─────────────────
        _module(
          id: 'discrete_math_module_3',
          title: 'Relations & Functions',
          titleRu: 'Отношения и функции',
          titleKk: 'Қатынастар және функциялар',
          summary:
              'Binary relations, equivalence relations, partial and total orders, injections, surjections, bijections, composition, and inverses.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_3_1',
              title: 'Equivalence relations',
              trackTitle: 'Discrete Math',
              summary:
                  'Understand reflexive, symmetric, and transitive properties. Explore congruence modulo n.',
              outcome:
                  'You can verify whether a relation is an equivalence and identify its equivalence classes.',
              theoryContent:
                  'A binary relation R on a set A is a set of ordered pairs from A × A. '
                  'We write aRb to mean (a, b) ∈ R.\n\n'
                  'Three key properties:\n'
                  '• Reflexive: aRa for every a ∈ A — every element relates to itself\n'
                  '• Symmetric: if aRb then bRa — the relation works in both directions\n'
                  '• Transitive: if aRb and bRc then aRc — the relation chains\n\n'
                  'A relation that is reflexive, symmetric, AND transitive is called an '
                  'equivalence relation. It partitions the set into equivalence classes — '
                  'non-overlapping groups where every pair within a group is related.\n\n'
                  '►Congruence modulo n:\n'
                  'a ≡ b (mod n) means n divides (a − b).\n'
                  '• Reflexive: a − a = 0, divisible by n ✓\n'
                  '• Symmetric: n | (a−b) ⟹ n | (b−a) ✓\n'
                  '• Transitive: n | (a−b) and n | (b−c) ⟹ n | (a−c) ✓\n\n'
                  'The equivalence classes mod 3 are:\n'
                  '[0] = {…, −3, 0, 3, 6, …}\n'
                  '[1] = {…, −2, 1, 4, 7, …}\n'
                  '[2] = {…, −1, 2, 5, 8, …}\n\n'
                  'Not every relation is an equivalence: “≤” on integers is reflexive and transitive '
                  'but NOT symmetric (3 ≤ 5 but 5 ≰ 3), so it is a partial order, not an equivalence.',
              keyPoints: <String>[
                'An equivalence relation must be reflexive, symmetric, AND transitive.',
                'Congruence modulo n is the classic example of an equivalence relation.',
                '”≤” is reflexive and transitive but not symmetric → partial order, not equivalence.',
              ],
              codeSnippet: '''bool congMod3(int a, int b) => a % 3 == b % 3;
// Reflexive? Symmetric? Transitive?
print(congMod3(7, 7));          // reflexive
print(congMod3(7, 4) == congMod3(4, 7)); // symmetric
print(congMod3(7, 4) && congMod3(4, 1)); // transitive check''',
              output: 'true\ntrue\ntrue',
              quizPrompt:
                  'Is “strictly less than” (<) an equivalence relation on integers?',
              quizOptions: <String>[
                'No — a < a is false (not reflexive)',
                'Yes — it satisfies all three properties',
                'No — not symmetric, but reflexive',
              ],
              correctQuizIndex: 0,
              quizExplanation:
                  '”<” fails reflexivity: no number is strictly less than itself. Missing even one property disqualifies it.',
              trainer: const DemoTrainerSeed.matching(
                title: 'Match relation properties',
                instruction: 'Connect each property to its formal definition.',
                prompt: 'Match the three properties of equivalence relations.',
                options: <String>['Reflexive', 'Symmetric', 'Transitive'],
                orderedLines: <String>[
                  'a R a for all a ∈ A',
                  'a R b ⟹ b R a',
                  'a R b and b R c ⟹ a R c',
                ],
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Classify relations',
                  instruction:
                      'Determine whether each relation has the given property.',
                  prompt: 'Match each statement to Yes or No.',
                  options: <String>[
                    '”=” is reflexive',
                    '”<” is reflexive',
                    '”≡ mod 3” is symmetric',
                    '”≤” is symmetric',
                  ],
                  orderedLines: <String>[
                    'Yes — a = a always holds',
                    'No — a < a is always false',
                    'Yes — a ≡ b ⟹ b ≡ a',
                    'No — 3 ≤ 5 but 5 ≰ 3',
                  ],
                ),
              ],
              titleRu: 'Отношения эквивалентности',
              titleKk: 'Эквиваленттілік қатынастары',
              summaryRu:
                  'Рефлексивность, симметричность и транзитивность. Сравнение по модулю n.',
              summaryKk:
                  'Рефлексивтілік, симметриялылық және транзитивтілік. n модулі бойынша конгруэнттілік.',
              outcomeRu:
                  'Проверять, является ли отношение эквивалентностью, и находить его классы эквивалентности.',
              outcomeKk:
                  'Қатынастың эквиваленттілік екенін тексеру және эквиваленттілік кластарын анықтау.',
              keyPointsRu: <String>[
                'Отношение эквивалентности должно быть рефлексивным, симметричным И транзитивным.',
                'Сравнение по модулю n — классический пример отношения эквивалентности.',
                '"≤" — рефлексивно и транзитивно, но не симметрично → частичный порядок.',
              ],
              keyPointsKk: <String>[
                'Эквиваленттілік қатынасы рефлексивті, симметриялы ЖӘНЕ транзитивті болуы керек.',
                'n модулі бойынша конгруэнттілік — эквиваленттілік қатынасының классикалық мысалы.',
                '"≤" — рефлексивті және транзитивті, бірақ симметриялы емес → толық емес тәртіп.',
              ],
              quizPromptRu:
                  'Является ли "строго меньше" (<) отношением эквивалентности на целых числах?',
            ),
            _lesson(
              id: 'discrete_math_lesson_3_2',
              title: 'Functions and bijections',
              trackTitle: 'Discrete Math',
              summary:
                  'Learn about injections, surjections, bijections, and inverse functions.',
              outcome:
                  'You can classify a function as injective, surjective, or bijective.',
              theoryContent:
                  'A function f: A → B assigns each element of A exactly one element of B. '
                  'The set A is the domain, B is the codomain, and f(A) = {f(a) : a ∈ A} is the image.\n\n'
                  'Three important types:\n'
                  '• Injection (one-to-one): different inputs → different outputs.\n'
                  '  If f(a₁) = f(a₂), then a₁ = a₂.\n'
                  '• Surjection (onto): every element of B is hit.\n'
                  '  For all b ∈ B, there exists a ∈ A with f(a) = b.\n'
                  '• Bijection: both injective and surjective — a perfect 1-to-1 correspondence.\n\n'
                  '►Key fact:\n'
                  'A bijection f: A → B exists ⟺ |A| = |B| (for finite sets).\n'
                  'An inverse function f⁻¹ exists if and only if f is a bijection.\n\n'
                  'Examples:\n'
                  '• f(x) = 2x on ℤ → ℤ: injective (2a = 2b ⟹ a = b), not surjective (odd numbers have no preimage)\n'
                  '• f(x) = x² on ℤ → ℤ: not injective (f(2) = f(−2) = 4), not surjective (negative outputs impossible)\n'
                  '• f(x) = x + 1 on ℤ → ℤ: bijective — every integer is hit exactly once',
              keyPoints: <String>[
                'Injection: no two inputs map to the same output.',
                'Surjection: every element in the codomain has a preimage.',
                'Bijection = injection + surjection. Inverse exists only for bijections.',
              ],
              codeSnippet: '''final domain = ['a', 'b', 'c'];
final mapping = {'a': 1, 'b': 2, 'c': 3};
final range = mapping.values.toSet();
final injective = range.length == domain.length;
final surjective = range.length == {1, 2, 3}.length;
print('Bijection: \${injective && surjective}');''',
              output: 'Bijection: true',
              quizPrompt: 'Is f(x) = x² a bijection on integers ℤ → ℤ?',
              quizOptions: <String>[
                'No — f(2) = f(−2), not injective',
                'Yes — every integer is mapped',
                'No — not surjective only',
              ],
              correctQuizIndex: 0,
              quizExplanation:
                  'f(2) = f(−2) = 4, so different inputs give the same output. Not injective → not a bijection.',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Bijection condition',
                instruction:
                    'For a bijection between finite sets, domain and codomain must have…',
                prompt: 'A bijection requires |domain| ____ |codomain|.',
                options: <String>['==', '>', '<'],
                correctIndex: 0,
                template:
                    'final isBijection = domain.length ____ codomain.length;',
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Classify functions',
                  instruction: 'Match each function to its classification.',
                  prompt: 'What type is each function on ℤ → ℤ?',
                  options: <String>[
                    'f(x) = x + 1',
                    'f(x) = x²',
                    'f(x) = 2x',
                    'f: {a,b} → {1,2,3}',
                  ],
                  orderedLines: <String>[
                    'Bijection (injective + surjective)',
                    'Neither (f(2) = f(−2) = 4)',
                    'Injective only (odd numbers missed)',
                    'Cannot be surjective (|domain| < |codomain|)',
                  ],
                ),
              ],
              titleRu: 'Функции и биекции',
              titleKk: 'Функциялар және биекциялар',
              summaryRu: 'Инъекции, сюръекции, биекции и обратные функции.',
              summaryKk:
                  'Инъекциялар, сюръекциялар, биекциялар және кері функциялар.',
              outcomeRu:
                  'Классифицировать функцию как инъективную, сюръективную или биективную.',
              outcomeKk:
                  'Функцияны инъективті, сюръективті немесе биективті деп жіктеу.',
              keyPointsRu: <String>[
                'Инъекция: различные входные данные → различные выходные (f(a₁)=f(a₂) ⟹ a₁=a₂).',
                'Сюръекция: каждый элемент кодомена достигается.',
                'Биекция = инъекция + сюръекция. Обратная функция существует только для биекций.',
              ],
              keyPointsKk: <String>[
                'Инъекция: әртүрлі кірістер → әртүрлі шығыстар (f(a₁)=f(a₂) ⟹ a₁=a₂).',
                'Сюръекция: кодомендіктің барлық элементтері жетіледі.',
                'Биекция = инъекция + сюръекция. Кері функция тек биекциялар үшін бар.',
              ],
              quizPromptRu:
                  'Является ли f(x) = x² биекцией на целых числах ℤ → ℤ?',
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_3',
            title: 'Relations & functions challenge',
            starterCode:
                '''// 1. Given {0..19} and “congruence mod 4”, compute all equivalence classes.
bool congMod4(int a, int b) => a % 4 == b % 4;

// 2. Given a mapping Map<int, String>, write isInjective() and isSurjective().
//    Test with {1:'a', 2:'b', 3:'c'} and {1:'a', 2:'a', 3:'b'}.''',
          ),
        ),
        // ── Module 4: Combinatorics ───────────────────────────
        _module(
          id: 'discrete_math_module_4',
          title: 'Combinatorics',
          titleRu: 'Комбинаторика',
          titleKk: 'Комбинаторика',
          summary:
              'Permutations, combinations, Pascal\'s triangle, and the binomial theorem.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_4_1',
              title: 'Permutations and combinations',
              trackTitle: 'Discrete Math',
              summary:
                  'Distinguish when order matters (permutations) from when it does not (combinations).',
              outcome:
                  'You can compute P(n,k) and C(n,k) and choose the right formula for a problem.',
              theoryContent:
                  'A permutation is an ordered arrangement of elements. The number of ways '
                  'to arrange k elements from a set of n is:\n\n'
                  '►P(n, k) = n! / (n − k)!\n\n'
                  'Example: arranging 3 books from a shelf of 5 → P(5,3) = 5!/2! = 60.\n\n'
                  'A combination is an unordered selection. The number of ways to choose '
                  'k elements from n is:\n\n'
                  '►C(n, k) = n! / (k! · (n − k)!)\n\n'
                  'Example: choosing a committee of 3 from 5 people → C(5,3) = 10.\n\n'
                  'The key question: does ORDER matter?\n'
                  '• Assigning 1st, 2nd, 3rd place → Permutation\n'
                  '• Choosing a team of 3 → Combination\n\n'
                  'Notice: C(n,k) = P(n,k) / k! because combinations remove the ordering.\n\n'
                  '►Pascal\'s Rule:\n'
                  'C(n, k) = C(n−1, k−1) + C(n−1, k)\n\n'
                  'This says: either a specific element is in the selection (pick k−1 more from n−1) '
                  'or it isn\'t (pick all k from n−1).',
              keyPoints: <String>[
                'Permutations count ordered arrangements: P(n,k) = n!/(n−k)!',
                'Combinations count unordered selections: C(n,k) = n!/(k!(n−k)!)',
                'Pascal\'s rule: C(n,k) = C(n−1,k−1) + C(n−1,k).',
              ],
              codeSnippet:
                  '''int factorial(int n) => n <= 1 ? 1 : n * factorial(n - 1);
int P(int n, int k) => factorial(n) ~/ factorial(n - k);
int C(int n, int k) => factorial(n) ~/ (factorial(k) * factorial(n - k));
print('P(7,3) = \${P(7, 3)}, C(7,3) = \${C(7, 3)}');''',
              output: 'P(7,3) = 210, C(7,3) = 35',
              quizPrompt: 'What is C(7,3)?',
              quizOptions: <String>['21', '35', '210'],
              correctQuizIndex: 1,
              quizExplanation:
                  'C(7,3) = 7! / (3! · 4!) = 5040 / (6 · 24) = 35. P(7,3) = 210 would be the answer if order mattered.',
              trainer: const DemoTrainerSeed.reorder(
                title: 'Build the combination formula',
                instruction:
                    'Arrange the steps to compute C(n,k) in the correct order.',
                prompt: 'Order the calculation steps.',
                orderedLines: <String>[
                  'Define n and k',
                  'Compute n!',
                  'Compute k! and (n−k)!',
                  'Divide: n! / (k! × (n−k)!)',
                ],
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Permutation or combination?',
                  instruction: 'Match each problem to whether it uses P or C.',
                  prompt: 'Which formula solves each problem?',
                  options: <String>[
                    'Gold/Silver/Bronze from 10',
                    'Committee of 4 from 10',
                    'Arrange 5 books on a shelf',
                    'Choose 3 toppings from 8',
                  ],
                  orderedLines: <String>[
                    'P(10,3) = 720',
                    'C(10,4) = 210',
                    'P(5,5) = 5! = 120',
                    'C(8,3) = 56',
                  ],
                ),
              ],
              titleRu: 'Перестановки и сочетания',
              titleKk: 'Ауыстырып қоюлар және таңдалымдар',
              summaryRu:
                  'Различить случаи, когда порядок важен (перестановки), от тех, когда нет (сочетания).',
              summaryKk:
                  'Тәртіп маңызды (ауыстырып қоюлар) жағдайларды маңызды емес (таңдалымдар) жағдайлардан ажырату.',
              outcomeRu:
                  'Вычислять P(n,k) и C(n,k) и выбирать правильную формулу для задачи.',
              outcomeKk:
                  'P(n,k) және C(n,k) есептеу және есепке дұрыс формула таңдау.',
              keyPointsRu: <String>[
                'Перестановки считают упорядоченные расстановки: P(n,k) = n!/(n−k)!',
                'Сочетания считают неупорядоченные выборки: C(n,k) = n!/(k!(n−k)!)',
                'Правило Паскаля: C(n,k) = C(n−1,k−1) + C(n−1,k).',
              ],
              keyPointsKk: <String>[
                'Ауыстырып қоюлар реттелген орналасуларды санайды: P(n,k) = n!/(n−k)!',
                'Таңдалымдар реттелмеген іріктемелерді санайды: C(n,k) = n!/(k!(n−k)!)',
                'Паскаль ережесі: C(n,k) = C(n−1,k−1) + C(n−1,k).',
              ],
              quizPromptRu: 'Чему равно C(7,3)?',
            ),
            _lesson(
              id: 'discrete_math_lesson_4_2',
              title: 'Binomial theorem',
              trackTitle: 'Discrete Math',
              summary:
                  'Expand (a+b)ⁿ using Pascal\'s triangle and prove the 2ⁿ identity.',
              outcome:
                  'You can expand binomial expressions and use Pascal\'s triangle to find coefficients.',
              theoryContent:
                  'The Binomial Theorem gives the expansion of (a + b)ⁿ:\n\n'
                  '►(a + b)ⁿ = Σ C(n,k) · aⁿ⁻ᵏ · bᵏ  for k = 0, 1, …, n\n\n'
                  'The coefficients C(n,k) form Pascal\'s triangle:\n\n'
                  '►        1\n'
                  '       1   1\n'
                  '      1   2   1\n'
                  '     1   3   3   1\n'
                  '    1   4   6   4   1\n'
                  '   1   5  10  10   5   1\n\n'
                  'Each entry is the sum of the two entries above it (Pascal\'s rule).\n\n'
                  '►Key identity:\n'
                  'Sum of row n = 2ⁿ\n\n'
                  'Proof: set a = b = 1 in (a+b)ⁿ → (1+1)ⁿ = 2ⁿ = Σ C(n,k).\n\n'
                  'This means a set of n elements has exactly 2ⁿ subsets — each element '
                  'is either included or excluded (2 choices, n times).\n\n'
                  'Example: (x + 1)⁴ = x⁴ + 4x³ + 6x² + 4x + 1\n'
                  'Coefficients: 1, 4, 6, 4, 1 → sum = 16 = 2⁴ ✓',
              keyPoints: <String>[
                '(a+b)ⁿ = Σ C(n,k) · aⁿ⁻ᵏ · bᵏ for k from 0 to n.',
                'Sum of binomial coefficients in row n = 2ⁿ.',
                'A set of n elements has 2ⁿ subsets.',
              ],
              codeSnippet: '''int C(int n, int k) {
  if (k == 0 || k == n) return 1;
  return C(n - 1, k - 1) + C(n - 1, k);
}
final row5 = List.generate(6, (k) => C(5, k));
print(row5);
print('Sum = \${row5.reduce((a, b) => a + b)}');''',
              output: '[1, 5, 10, 10, 5, 1]\nSum = 32',
              quizPrompt: 'What is the sum of Pascal\'s triangle row 5?',
              quizOptions: <String>['16', '32', '64'],
              correctQuizIndex: 1,
              quizExplanation:
                  'Sum of row n = 2ⁿ. For n = 5, the sum is 2⁵ = 32.',
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Predict the sum',
                instruction:
                    'Sum of binomial coefficients for (a+b)⁶ equals 2⁶.',
                prompt: '''final row6 = [1, 6, 15, 20, 15, 6, 1];
print(row6.reduce((a, b) => a + b));''',
                options: <String>['32', '64', '128'],
                correctIndex: 1,
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Match binomial expressions',
                  instruction:
                      'Connect each expression to its value or expansion.',
                  prompt: 'Match binomial expressions to results.',
                  options: <String>[
                    '(a+b)²',
                    '(a+b)³',
                    'C(4,2)',
                    'Sum of row 4',
                  ],
                  orderedLines: <String>[
                    'a² + 2ab + b²',
                    'a³ + 3a²b + 3ab² + b³',
                    '6',
                    '16 = 2⁴',
                  ],
                ),
              ],
              titleRu: 'Бином Ньютона',
              titleKk: 'Ньютон биномы',
              summaryRu:
                  'Разложение (a+b)ⁿ с помощью треугольника Паскаля и доказательство тождества 2ⁿ.',
              summaryKk:
                  '(a+b)ⁿ-ті Паскаль үшбұрышын пайдаланып жаю және 2ⁿ тождестводаны дәлелдеу.',
              outcomeRu:
                  'Раскладывать биномиальные выражения и использовать треугольник Паскаля для нахождения коэффициентов.',
              outcomeKk:
                  'Биномдық өрнектерді жаю және коэффициенттерді табу үшін Паскаль үшбұрышын пайдалану.',
              keyPointsRu: <String>[
                '(a+b)ⁿ = Σ C(n,k) · aⁿ⁻ᵏ · bᵏ для k от 0 до n.',
                'Сумма биномиальных коэффициентов в строке n = 2ⁿ.',
                'Множество из n элементов имеет 2ⁿ подмножеств.',
              ],
              keyPointsKk: <String>[
                '(a+b)ⁿ = Σ C(n,k) · aⁿ⁻ᵏ · bᵏ, k 0-ден n-ге дейін.',
                'n-інші жолдағы биномдық коэффициенттердің қосындысы = 2ⁿ.',
                'n элементтен тұратын жиынның 2ⁿ ішкі жиыны бар.',
              ],
              quizPromptRu:
                  'Чему равна сумма коэффициентов в строке 5 треугольника Паскаля?',
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_4',
            title: 'Pascal\'s triangle and subsets',
            starterCode: '''int C(int n, int k) {
  if (k == 0 || k == n) return 1;
  return C(n - 1, k - 1) + C(n - 1, k);
}

// 1. Print Pascal's triangle rows 0 through 6
// 2. Verify that row sums equal powers of 2
// 3. How many subsets does a set of 6 elements have?''',
          ),
        ),
        // ── Module 5: Graph Theory ────────────────────────────
        _module(
          id: 'discrete_math_module_5',
          title: 'Graph Theory',
          titleRu: 'Теория графов',
          titleKk: 'Граф теориясы',
          summary:
              'Graph types, connectivity, Eulerian and Hamiltonian paths, and the Königsberg bridge problem.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_5_1',
              title: 'Graph types and connectivity',
              trackTitle: 'Discrete Math',
              summary:
                  'Directed, undirected, and weighted graphs. Adjacency representations and the handshaking lemma.',
              outcome:
                  'You can represent a graph using adjacency lists, compute vertex degrees, and apply the handshaking lemma.',
              theoryContent:
                  'A graph G = (V, E) consists of a set V of vertices (nodes) and a set E of edges '
                  'connecting pairs of vertices.\n\n'
                  'Types of graphs:\n'
                  '• Undirected — each edge is an unordered pair {u, v}.\n'
                  '• Directed (digraph) — each edge is an ordered pair (u, v), meaning u → v.\n'
                  '• Weighted — each edge carries a numerical weight (cost, distance).\n'
                  '• Complete graph K_n — every pair of n vertices is connected. K_n has n(n−1)/2 edges.\n\n'
                  '► Degree of a vertex:\n'
                  'deg(v) = number of edges incident to v.\n'
                  'In a digraph: in-degree = incoming edges, out-degree = outgoing edges.\n\n'
                  '► Handshaking Lemma:\n'
                  'Σ deg(v) = 2|E| (for all v ∈ V)\n\n'
                  'Proof: every edge {u, v} contributes 1 to deg(u) and 1 to deg(v), so each edge '
                  'adds 2 to the total sum. Corollary: the number of odd-degree vertices is always even.\n\n'
                  'Graph representations:\n'
                  '• Adjacency list — for each vertex, a list of neighbors. O(|V| + |E|) space.\n'
                  '• Adjacency matrix — n×n matrix, entry (i,j) = 1 if edge exists. O(|V|²) space.\n\n'
                  'Connectivity:\n'
                  'A path from u to v is a sequence of edges connecting them. A graph is connected if '
                  'every pair has a path. A connected component is a maximal connected subgraph.',
              keyPoints: <String>[
                'Handshaking lemma: Σ deg(v) = 2|E|, so the sum of degrees is always even.',
                'K_n has n(n−1)/2 edges — every pair is connected.',
                'Adjacency lists use O(|V|+|E|) space; adjacency matrices use O(|V|²).',
              ],
              codeSnippet: '''final graph = <String, List<String>>{
  'A': ['B', 'C', 'D'],
  'B': ['A', 'C'],
  'C': ['A', 'B', 'D'],
  'D': ['A', 'C'],
};
for (final v in graph.keys) {
  print('deg(\$v) = \${graph[v]!.length}');
}
final sumDeg = graph.values.fold<int>(0, (s, e) => s + e.length);
print('Sum of degrees: \$sumDeg');
print('Edges: \${sumDeg ~/ 2}');''',
              output:
                  'deg(A) = 3\ndeg(B) = 2\ndeg(C) = 3\ndeg(D) = 2\nSum of degrees: 10\nEdges: 5',
              quizPrompt: 'A graph has degrees [3, 2, 3, 2]. How many edges?',
              quizOptions: <String>['4', '5', '10'],
              correctQuizIndex: 1,
              quizExplanation:
                  'Sum of degrees = 3 + 2 + 3 + 2 = 10. By handshaking lemma, |E| = 10 / 2 = 5.',
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Count edges using handshaking lemma',
                instruction:
                    'Apply the handshaking lemma to find the number of edges.',
                prompt: '''final degrees = [4, 3, 3, 2, 2];
final sumDeg = degrees.reduce((a, b) => a + b);
print(sumDeg ~/ 2);''',
                options: <String>['5', '7', '14'],
                correctIndex: 1,
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Match graph terms',
                  instruction: 'Connect each graph concept to its definition.',
                  prompt: 'Match terminology to meaning.',
                  options: <String>[
                    'Vertex',
                    'Edge',
                    'Degree',
                    'Connected component',
                  ],
                  orderedLines: <String>[
                    'A node in a graph',
                    'A link between two nodes',
                    'Number of edges incident to a node',
                    'A maximal connected subgraph',
                  ],
                ),
              ],
              titleRu: 'Виды графов и связность',
              titleKk: 'Граф түрлері және байланыстылық',
              summaryRu:
                  'Направленные, ненаправленные и взвешенные графы. Представления графов и лемма о рукопожатиях.',
              summaryKk:
                  'Бағытталған, бағытталмаған және салмақталған графтар. Граф ұсынылымдары және қол алысу леммасы.',
              outcomeRu:
                  'Представлять граф с помощью списков смежности, вычислять степени вершин и применять лемму о рукопожатиях.',
              outcomeKk:
                  'Графты суседлік тізімдерімен ұсыну, төбелер дәрежелерін есептеу және қол алысу леммасын қолдану.',
              keyPointsRu: <String>[
                'Степень вершины = количество инцидентных рёбер.',
                'Лемма о рукопожатиях: сумма степеней = 2 · (число рёбер).',
                'Граф связен, если между любыми двумя вершинами существует путь.',
              ],
              keyPointsKk: <String>[
                'Төбенің дәрежесі = инциденттік қырлардың саны.',
                'Қол алысу леммасы: дәрежелер қосындысы = 2 · (қырлар саны).',
                'Кез келген екі төбе арасында жол болса, граф байланысты.',
              ],
              quizPromptRu:
                  'Граф имеет степени вершин [3, 2, 3, 2]. Сколько рёбер?',
            ),
            _lesson(
              id: 'discrete_math_lesson_5_2',
              title: 'Euler and Hamilton paths',
              trackTitle: 'Discrete Math',
              summary:
                  'Eulerian paths (every edge once) vs Hamiltonian paths (every vertex once). Euler\'s theorem.',
              outcome:
                  'You can determine whether a graph has an Euler circuit by checking vertex degrees.',
              theoryContent:
                  'The study of Eulerian paths began with the Seven Bridges of Königsberg (1736). '
                  'Euler proved it was impossible to walk crossing each bridge exactly once — '
                  'giving birth to graph theory.\n\n'
                  '► Eulerian path: a trail that visits every EDGE exactly once.\n'
                  '► Eulerian circuit: an Eulerian path that returns to the starting vertex.\n\n'
                  '► Euler\'s Theorem:\n'
                  '• Euler CIRCUIT exists ⟺ every vertex has even degree (connected graph).\n'
                  '• Euler PATH (not circuit) exists ⟺ exactly two vertices have odd degree.\n\n'
                  'Why? At every intermediate vertex, you enter and leave — each visit uses 2 edges. '
                  'If degree is even, every entry is matched by an exit. Odd degree can only happen at start/end.\n\n'
                  '► Hamiltonian path: visits every VERTEX exactly once.\n'
                  '► Hamiltonian cycle: returns to the starting vertex.\n\n'
                  'Key difference:\n'
                  '• Euler: about EDGES (visit every edge once)\n'
                  '• Hamilton: about VERTICES (visit every vertex once)\n\n'
                  'Unlike Euler\'s theorem, no simple condition exists for Hamiltonian paths. '
                  'The problem is NP-complete. Dirac\'s theorem: if every vertex has degree ≥ n/2, '
                  'then a Hamiltonian cycle exists.\n\n'
                  'Example: degree sequence [2, 2, 3, 3] → two odd-degree vertices → '
                  'Euler path exists (but not Euler circuit).',
              keyPoints: <String>[
                'Euler circuit exists ⟺ every vertex has even degree (connected graph).',
                'Euler path (not circuit) exists ⟺ exactly two vertices have odd degree.',
                'Hamiltonian path problem is NP-complete — no simple degree-based test exists.',
              ],
              codeSnippet: '''// Check if a graph has an Euler circuit
final graph = <String, List<String>>{
  'A': ['B', 'D'],
  'B': ['A', 'C'],
  'C': ['B', 'D'],
  'D': ['C', 'A'],
};
var oddCount = 0;
for (final v in graph.keys) {
  if (graph[v]!.length % 2 != 0) oddCount++;
}
print('Odd-degree vertices: \$oddCount');
print('Euler circuit: \${oddCount == 0}');
print('Euler path: \${oddCount == 0 || oddCount == 2}');''',
              output:
                  'Odd-degree vertices: 0\nEuler circuit: true\nEuler path: true',
              quizPrompt:
                  'Degrees [2, 2, 3, 3]. Does the graph have an Euler circuit?',
              quizOptions: <String>[
                'No — two vertices have odd degree',
                'Yes — all vertices have degree ≥ 2',
                'Yes — sum of degrees is even',
              ],
              correctQuizIndex: 0,
              quizExplanation:
                  'For an Euler circuit, ALL vertices must have even degree. Two vertices have odd degree (3), so no circuit. But since exactly two are odd, an Euler path does exist.',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Euler circuit condition',
                instruction:
                    'Complete the condition for an Euler circuit to exist.',
                prompt: 'Euler circuit exists iff all vertex degrees are ____.',
                options: <String>['even', 'odd', 'greater than 2'],
                correctIndex: 0,
                template:
                    'final hasCircuit = degrees.every((d) => d % 2 == ____);',
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Euler vs Hamilton',
                  instruction: 'Match each concept to its description.',
                  prompt: 'Connect path types to their definitions.',
                  options: <String>[
                    'Eulerian path',
                    'Eulerian circuit',
                    'Hamiltonian path',
                    'Hamiltonian cycle',
                  ],
                  orderedLines: <String>[
                    'Visits every edge exactly once',
                    'Visits every edge once and returns to start',
                    'Visits every vertex exactly once',
                    'Visits every vertex once and returns to start',
                  ],
                ),
              ],
              titleRu: 'Пути Эйлера и Гамильтона',
              titleKk: 'Эйлер және Гамильтон жолдары',
              summaryRu:
                  'Эйлеровы пути (каждое ребро один раз) и гамильтоновы пути (каждая вершина один раз). Теорема Эйлера.',
              summaryKk:
                  'Эйлер жолдары (әрбір қыр бір рет) және Гамильтон жолдары (әрбір төбе бір рет). Эйлер теоремасы.',
              outcomeRu:
                  'Определять наличие эйлерова цикла в графе по степеням вершин.',
              outcomeKk:
                  'Төбелердің дәрежелері бойынша графта Эйлер циклінің бар-жоғын анықтау.',
              keyPointsRu: <String>[
                'Эйлеров цикл: граф связен и все вершины имеют чётную степень.',
                'Эйлеров путь: ровно 2 вершины нечётной степени.',
                'Гамильтонов путь сложнее — нет эффективного алгоритма для всех случаев (NP).',
              ],
              keyPointsKk: <String>[
                'Эйлер циклі: граф байланысты және барлық төбелердің жұп дәрежесі бар.',
                'Эйлер жолы: тек 2 төбенің тақ дәрежесі бар.',
                'Гамильтон жолы қиынырақ — барлық жағдайлар үшін тиімді алгоритм жоқ (NP).',
              ],
              quizPromptRu:
                  'Степени вершин [2, 2, 3, 3]. Есть ли у графа эйлеров цикл?',
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_5',
            title: 'Euler circuit detection',
            starterCode: '''final graph = <String, List<String>>{
  'A': ['B', 'C'],
  'B': ['A', 'C', 'D', 'E'],
  'C': ['A', 'B'],
  'D': ['B', 'E'],
  'E': ['B', 'D'],
};
// 1. Compute the degree of each vertex
// 2. Count how many have odd degree
// 3. Determine: Euler circuit, Euler path, or neither?''',
          ),
        ),
        // ── Module 6: Trees & Algorithms ──────────────────────
        _module(
          id: 'discrete_math_module_6',
          title: 'Trees & Algorithms',
          titleRu: 'Деревья и алгоритмы',
          titleKk: 'Ағаштар және алгоритмдер',
          summary:
              'Rooted trees, traversal algorithms, binary search trees, and minimum spanning trees.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_6_1',
              title: 'Trees and traversals',
              trackTitle: 'Discrete Math',
              summary:
                  'Tree properties, binary tree structure, and preorder/inorder/postorder traversal algorithms.',
              outcome:
                  'You can represent a tree in code and perform all three traversal orders correctly.',
              theoryContent:
                  'A tree is a connected acyclic graph.\n\n'
                  '► Key property: a tree with n vertices has exactly n − 1 edges.\n\n'
                  'Proof: start with n isolated vertices. Each edge connects two components (reducing count by 1) '
                  'or creates a cycle. Being connected (1 component) and acyclic requires exactly n − 1 edges.\n\n'
                  'A rooted tree has a designated root. Every other vertex has a unique parent. '
                  'Vertices with no children are leaves.\n\n'
                  '► Binary tree: each node has at most 2 children (left and right).\n\n'
                  'Tree metrics:\n'
                  '• Depth of a node: edges from root to that node.\n'
                  '• Height: maximum depth among all nodes.\n'
                  '• A balanced binary tree of height h has at most 2^(h+1) − 1 nodes.\n\n'
                  '► Traversal algorithms (binary tree):\n\n'
                  '1. Preorder (Root, Left, Right):\n'
                  '   Visit root first, then left subtree, then right subtree.\n'
                  '   Use: copying a tree, prefix expressions.\n\n'
                  '2. Inorder (Left, Root, Right):\n'
                  '   Left subtree, then root, then right subtree.\n'
                  '   Use: yields sorted order for a BST.\n\n'
                  '3. Postorder (Left, Right, Root):\n'
                  '   Left subtree, right subtree, then root.\n'
                  '   Use: computing sizes, deleting bottom-up.\n\n'
                  'Example tree:\n'
                  '       1\n'
                  '      / \\\n'
                  '     2   3\n'
                  '    / \\\n'
                  '   4   5\n\n'
                  'Preorder:  1, 2, 4, 5, 3\n'
                  'Inorder:   4, 2, 5, 1, 3\n'
                  'Postorder: 4, 5, 2, 3, 1',
              keyPoints: <String>[
                'A tree with n vertices has exactly n − 1 edges.',
                'Preorder: Root → Left → Right. Inorder: Left → Root → Right. Postorder: Left → Right → Root.',
                'Inorder traversal of a BST produces elements in sorted order.',
              ],
              codeSnippet: '''// Binary tree as map: node -> [left, right]
final tree = <int, List<int?>>{
  1: [2, 3], 2: [4, 5], 3: [null, null],
  4: [null, null], 5: [null, null],
};
final result = <int>[];
void preorder(int? node) {
  if (node == null) return;
  result.add(node);
  preorder(tree[node]![0]);
  preorder(tree[node]![1]);
}
preorder(1);
print('Preorder: \$result');''',
              output: 'Preorder: [1, 2, 4, 5, 3]',
              quizPrompt:
                  'What is the preorder traversal of tree 1(2(4,5), 3)?',
              quizOptions: <String>['1 2 4 5 3', '4 2 5 1 3', '4 5 2 3 1'],
              correctQuizIndex: 0,
              quizExplanation:
                  'Preorder visits Root first, then Left, then Right: 1 → 2 → 4 → 5 → 3.',
              trainer: const DemoTrainerSeed.reorder(
                title: 'Preorder traversal steps',
                instruction:
                    'Put the preorder traversal nodes in the correct visit order.',
                prompt: 'Order the nodes as visited in preorder.',
                orderedLines: <String>[
                  'Visit root node 1',
                  'Visit left child 2',
                  'Visit left grandchild 4',
                  'Visit right grandchild 5',
                  'Visit right child 3',
                ],
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Match traversal types',
                  instruction: 'Match each traversal to its visit order.',
                  prompt: 'Connect traversal names to node sequences.',
                  options: <String>['Preorder', 'Inorder', 'Postorder'],
                  orderedLines: <String>[
                    'Root, Left, Right',
                    'Left, Root, Right',
                    'Left, Right, Root',
                  ],
                ),
              ],
              titleRu: 'Деревья и обходы',
              titleKk: 'Ағаштар және аралап өту',
              summaryRu:
                  'Свойства деревьев, структура двоичного дерева и алгоритмы прямого/симметричного/обратного обхода.',
              summaryKk:
                  'Ағаш қасиеттері, екілік ағаш құрылымы және алдын ала/симметриялы/кейін аралап өту алгоритмдері.',
              outcomeRu:
                  'Реализовать дерево в коде и корректно выполнять все три порядка обхода.',
              outcomeKk:
                  'Кодта ағашты іске асыру және үш аралап өту тәртібін дұрыс орындау.',
              keyPointsRu: <String>[
                'Дерево с n вершинами имеет n−1 рёбер — нет циклов, связный граф.',
                'Прямой обход: корень → левое → правое; симметричный: левое → корень → правое.',
                'BST: левые потомки < родитель < правые потомки.',
              ],
              keyPointsKk: <String>[
                'n төбелі ағаштың n−1 қыры бар — цикл жоқ, байланысты граф.',
                'Алдын ала аралау: тамыр → сол → оң; симметриялы: сол → тамыр → оң.',
                'BST: сол ұрпақтар < ата-ана < оң ұрпақтар.',
              ],
              quizPromptRu:
                  'Каков прямой (preorder) обход дерева 1(2(4,5), 3)?',
            ),
            _lesson(
              id: 'discrete_math_lesson_6_2',
              title: 'Spanning trees and algorithms',
              trackTitle: 'Discrete Math',
              summary:
                  'Minimum spanning trees using Kruskal\'s and Prim\'s algorithms.',
              outcome:
                  'You can apply Kruskal\'s algorithm to find the MST of a weighted graph.',
              theoryContent:
                  'A spanning tree of a connected graph G includes all vertices with minimum edges.\n\n'
                  '► MST: a spanning tree whose total edge weight is minimized.\n\n'
                  'Used in: network design (minimize cable), clustering, approximation algorithms.\n\n'
                  '► Kruskal\'s Algorithm:\n'
                  '1. Sort all edges by weight (ascending).\n'
                  '2. Initialize each vertex as its own component.\n'
                  '3. For each edge (u, v) in sorted order:\n'
                  '   — If u and v are in different components: add edge, merge components.\n'
                  '   — If same component: skip (would create a cycle).\n'
                  '4. Stop when n − 1 edges have been added.\n\n'
                  'Uses Union-Find for near-linear time.\n\n'
                  '► Prim\'s Algorithm:\n'
                  '1. Start with any vertex in the MST set.\n'
                  '2. Repeatedly add the cheapest edge connecting MST to non-MST vertex.\n'
                  '3. Stop when all vertices are in the MST.\n\n'
                  'Both produce the same MST (unique when weights are distinct).\n\n'
                  '► MST edge count: always exactly n − 1.\n\n'
                  'Example: edges A-B(4), A-C(2), B-C(5), B-D(10), C-D(3).\n'
                  'Kruskal sorts: A-C(2), C-D(3), A-B(4), B-C(5), B-D(10).\n'
                  'Pick A-C(2) ✓, C-D(3) ✓, A-B(4) ✓, skip B-C (cycle), skip B-D (cycle).\n'
                  'MST weight = 2 + 3 + 4 = 9.',
              keyPoints: <String>[
                'A spanning tree of n vertices has exactly n − 1 edges.',
                'Kruskal\'s: sort edges, greedily add if no cycle (Union-Find).',
                'Prim\'s: grow from a vertex, always choosing cheapest crossing edge.',
              ],
              codeSnippet: '''// Kruskal's MST
final edges = [
  (2, 'A', 'C'), (3, 'C', 'D'),
  (4, 'A', 'B'), (5, 'B', 'C'), (10, 'B', 'D'),
];
final parent = <String, String>{};
String find(String x) {
  parent.putIfAbsent(x, () => x);
  if (parent[x] != x) parent[x] = find(parent[x]!);
  return parent[x]!;
}
var totalWeight = 0;
for (final (w, u, v) in edges) {
  if (find(u) != find(v)) {
    parent[find(u)] = find(v);
    totalWeight += w;
    print('Add \$u-\$v (weight \$w)');
  }
}
print('MST weight: \$totalWeight');''',
              output:
                  'Add A-C (weight 2)\nAdd C-D (weight 3)\nAdd A-B (weight 4)\nMST weight: 9',
              quizPrompt:
                  'A connected graph has 5 vertices. How many edges does its MST have?',
              quizOptions: <String>['3', '4', '5'],
              correctQuizIndex: 1,
              quizExplanation:
                  'A spanning tree with n vertices always has n − 1 edges. For n = 5: 4 edges.',
              trainer: const DemoTrainerSeed.reorder(
                title: 'Kruskal\'s algorithm steps',
                instruction:
                    'Arrange Kruskal\'s algorithm steps in correct order.',
                prompt: 'Rebuild the Kruskal procedure.',
                orderedLines: <String>[
                  'Sort all edges by weight (ascending)',
                  'Initialize each vertex as its own component',
                  'For each edge: check if endpoints are in different components',
                  'If different: add edge and merge components',
                  'Stop when n − 1 edges are added',
                ],
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'MST algorithms and concepts',
                  instruction:
                      'Connect each algorithm/concept to its description.',
                  prompt: 'Match algorithm to strategy.',
                  options: <String>[
                    'Kruskal\'s',
                    'Prim\'s',
                    'Union-Find',
                    'MST edge count',
                  ],
                  orderedLines: <String>[
                    'Sort edges globally, add greedily if no cycle',
                    'Grow from a vertex, add cheapest crossing edge',
                    'Data structure for tracking connected components',
                    'Always exactly n − 1 for n vertices',
                  ],
                ),
              ],
              titleRu: 'Остовные деревья и алгоритмы',
              titleKk: 'Қаңқалы ағаштар және алгоритмдер',
              summaryRu:
                  'Минимальные остовные деревья с использованием алгоритмов Краскала и Прима.',
              summaryKk:
                  'Краскал және Прим алгоритмдерін пайдаланып минималды қаңқалы ағаштар.',
              outcomeRu:
                  'Применять алгоритм Краскала для нахождения МОД взвешенного графа.',
              outcomeKk:
                  'Салмақталған графтың МҚА-сын табу үшін Краскал алгоритмін қолдану.',
              keyPointsRu: <String>[
                'Остовное дерево связного графа охватывает все вершины без циклов.',
                'Краскал: сортирует рёбра по весу, жадно добавляет без циклов (использует DSU).',
                'Прим: растёт от начальной вершины, всегда добавляя минимальное ребро к дереву.',
              ],
              keyPointsKk: <String>[
                'Байланысты графтың қаңқалы ағашы цикл жасамай барлық төбелерді қамтиды.',
                'Краскал: қырларды салмақ бойынша сорттап, цикл жасамай ашкөзді қосады (DSU).',
                'Прим: бастапқы төбеден өсіп, ағашқа ең минималды қырды қосады.',
              ],
              quizPromptRu:
                  'Какие рёбра алгоритм Краскала добавляет в первую очередь?',
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_6',
            title: 'Build a minimum spanning tree',
            starterCode: '''final edges = [
  (7, 'A', 'B'), (5, 'A', 'D'), (8, 'B', 'C'),
  (9, 'B', 'D'), (5, 'B', 'E'), (7, 'C', 'E'),
  (15, 'D', 'E'), (6, 'D', 'F'), (8, 'E', 'F'),
];
// 1. Sort edges by weight
// 2. Apply Kruskal's algorithm
// 3. Print each edge added and total MST weight''',
          ),
        ),
        // ── Module 7: Number Theory ───────────────────────────
        _module(
          id: 'discrete_math_module_7',
          title: 'Number Theory',
          titleRu: 'Теория чисел',
          titleKk: 'Сандар теориясы',
          summary:
              'Divisibility, primes, GCD via the Euclidean algorithm, modular arithmetic, and RSA basics.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_7_1',
              title: 'Divisibility, primes, and GCD',
              trackTitle: 'Discrete Math',
              summary:
                  'Divisibility, prime factorization, and the Euclidean algorithm for computing GCD.',
              outcome:
                  'You can compute GCD using the Euclidean algorithm and explain the Fundamental Theorem of Arithmetic.',
              theoryContent:
                  'Number theory studies properties of integers — the foundation of modern cryptography.\n\n'
                  '► Divisibility:\n'
                  'a | b means there exists integer k such that b = k · a.\n'
                  'Example: 3 | 12 because 12 = 4 · 3. But 3 ∤ 14.\n\n'
                  '► Prime numbers:\n'
                  'A prime p > 1 has no divisors other than 1 and p.\n'
                  'First primes: 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, …\n\n'
                  '► Fundamental Theorem of Arithmetic:\n'
                  'Every integer n > 1 has a unique prime factorization (up to ordering).\n'
                  'Example: 60 = 2² × 3 × 5.\n\n'
                  '► GCD and LCM:\n'
                  'gcd(a, b) = largest integer dividing both a and b.\n'
                  'lcm(a, b) = a · b / gcd(a, b).\n\n'
                  '► The Euclidean Algorithm:\n'
                  'gcd(a, b) = gcd(b, a mod b), repeat until b = 0.\n\n'
                  'Example: gcd(48, 18)\n'
                  '  gcd(48, 18) → gcd(18, 12)   [48 mod 18 = 12]\n'
                  '  gcd(18, 12) → gcd(12, 6)    [18 mod 12 = 6]\n'
                  '  gcd(12, 6)  → gcd(6, 0)     [12 mod 6 = 0]\n'
                  '  b = 0, so gcd = 6. ✓\n\n'
                  '► Bézout\'s Identity:\n'
                  'For any integers a, b: gcd(a, b) = a · x + b · y for some integers x, y.\n'
                  'For gcd(48, 18) = 6: 6 = 48 · (−1) + 18 · 3.\n'
                  'Used in computing modular inverses and RSA.',
              keyPoints: <String>[
                'Fundamental Theorem of Arithmetic: every integer > 1 has unique prime factorization.',
                'Euclidean algorithm: gcd(a, b) = gcd(b, a mod b), stop when b = 0.',
                'Bézout\'s identity: gcd(a, b) = ax + by for some integers x, y.',
              ],
              codeSnippet: '''int gcd(int a, int b) {
  while (b != 0) {
    final temp = b;
    b = a % b;
    a = temp;
  }
  return a;
}
print('gcd(48, 18) = \${gcd(48, 18)}');
print('gcd(56, 42) = \${gcd(56, 42)}');
print('lcm(12, 8) = \${12 * 8 ~/ gcd(12, 8)}');''',
              output: 'gcd(48, 18) = 6\ngcd(56, 42) = 14\nlcm(12, 8) = 24',
              quizPrompt: 'What is gcd(48, 18)?',
              quizOptions: <String>['3', '6', '12'],
              correctQuizIndex: 1,
              quizExplanation:
                  'gcd(48,18) → gcd(18,12) → gcd(12,6) → gcd(6,0) = 6.',
              trainer: const DemoTrainerSeed.reorder(
                title: 'Trace the Euclidean algorithm',
                instruction:
                    'Arrange the Euclidean algorithm steps for gcd(48, 18).',
                prompt: 'Order the reduction steps.',
                orderedLines: <String>[
                  'gcd(48, 18)',
                  'gcd(18, 12) — 48 mod 18 = 12',
                  'gcd(12, 6) — 18 mod 12 = 6',
                  'gcd(6, 0) — 12 mod 6 = 0',
                  'Result: 6',
                ],
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Number theory terms',
                  instruction: 'Connect each concept to its definition.',
                  prompt: 'Match terms to meanings.',
                  options: <String>[
                    'Prime number',
                    'GCD',
                    'LCM',
                    'Bézout\'s identity',
                  ],
                  orderedLines: <String>[
                    'Integer > 1 divisible only by 1 and itself',
                    'Largest integer dividing both a and b',
                    'Smallest positive integer divisible by both a and b',
                    'gcd(a,b) = ax + by for some integers x, y',
                  ],
                ),
              ],
              titleRu: 'Делимость, простые числа и НОД',
              titleKk: 'Бөлінгіштік, жай сандар және ЕҮОБ',
              summaryRu:
                  'Делимость, разложение на простые множители и алгоритм Евклида для вычисления НОД.',
              summaryKk:
                  'Бөлінгіштік, жай көбейткіштерге жіктеу және ЕҮОБ есептеуге арналған Евклид алгоритмі.',
              outcomeRu:
                  'Вычислять НОД с помощью алгоритма Евклида и объяснять Основную теорему арифметики.',
              outcomeKk:
                  'Евклид алгоритмімен ЕҮОБ есептеу және Арифметиканың негізгі теоремасын түсіндіру.',
              keyPointsRu: <String>[
                'Основная теорема арифметики: каждое n > 1 единственным образом раскладывается в произведение простых.',
                'НОД(a,b) — наибольшее число, делящее и a, и b.',
                'Алгоритм Евклида: НОД(a,b) = НОД(b, a mod b), база: НОД(a,0) = a.',
              ],
              keyPointsKk: <String>[
                'Арифметиканың негізгі теоремасы: әрбір n > 1 жай сандардың жалғыз жіктелімі ретінде беріледі.',
                'ЕҮОБ(a,b) — a да, b де бөлінетін ең үлкен сан.',
                'Евклид алгоритмі: ЕҮОБ(a,b) = ЕҮОБ(b, a mod b), негіз: ЕҮОБ(a,0) = a.',
              ],
              quizPromptRu: 'Чему равно gcd(48, 18)?',
            ),
            _lesson(
              id: 'discrete_math_lesson_7_2',
              title: 'Modular arithmetic and RSA basics',
              trackTitle: 'Discrete Math',
              summary:
                  'Modular arithmetic rules, Euler\'s totient, Fermat\'s little theorem, and the RSA scheme.',
              outcome:
                  'You can perform modular arithmetic and describe the RSA encryption/decryption process.',
              theoryContent:
                  'Modular arithmetic is "clock arithmetic" — numbers wrap around after reaching modulus n.\n\n'
                  '► Notation: a ≡ b (mod n) means n divides (a − b).\n\n'
                  '► Arithmetic rules (all mod n):\n'
                  '• (a + b) mod n = ((a mod n) + (b mod n)) mod n\n'
                  '• (a · b) mod n = ((a mod n) · (b mod n)) mod n\n\n'
                  'These let us keep intermediate results small — crucial for cryptography.\n\n'
                  '► Euler\'s totient function φ(n):\n'
                  'φ(n) = count of integers 1..n coprime to n.\n'
                  '• For prime p: φ(p) = p − 1.\n'
                  '• For n = p · q (distinct primes): φ(n) = (p−1)(q−1).\n\n'
                  '► Fermat\'s Little Theorem:\n'
                  'If p is prime and gcd(a, p) = 1: a^(p−1) ≡ 1 (mod p).\n'
                  'Example: 7^4 mod 5 = 2401 mod 5 = 1. ✓\n\n'
                  '► RSA Cryptosystem:\n'
                  '1. Choose primes p, q. Compute n = p · q.\n'
                  '2. Compute φ(n) = (p−1)(q−1).\n'
                  '3. Choose e with gcd(e, φ(n)) = 1.\n'
                  '4. Compute d: e · d ≡ 1 (mod φ(n)).\n'
                  '5. Public key: (n, e). Private key: (n, d).\n'
                  '6. Encrypt: c = m^e mod n.\n'
                  '7. Decrypt: m = c^d mod n.\n\n'
                  'Example: p=3, q=11 → n=33, φ=20. e=7, d=3 (7·3=21≡1 mod 20).\n'
                  'Encrypt m=4: c = 4^7 mod 33 = 16.\n'
                  'Decrypt: 16^3 mod 33 = 4 = m. ✓\n\n'
                  'Security relies on factoring difficulty of large n = p · q.',
              keyPoints: <String>[
                'Modular arithmetic preserves + and ×: (a·b) mod n = ((a mod n)·(b mod n)) mod n.',
                'Fermat\'s little theorem: a^(p−1) ≡ 1 (mod p) for prime p.',
                'RSA: encrypt c = m^e mod n, decrypt m = c^d mod n.',
              ],
              codeSnippet: '''// Modular exponentiation and RSA demo
int modPow(int base, int exp, int mod) {
  var result = 1;
  base = base % mod;
  while (exp > 0) {
    if (exp % 2 == 1) result = (result * base) % mod;
    exp = exp ~/ 2;
    base = (base * base) % mod;
  }
  return result;
}
// RSA: p=3, q=11, n=33, e=7, d=3
final msg = 4;
final enc = modPow(msg, 7, 33);
final dec = modPow(enc, 3, 33);
print('Message: \$msg → Encrypted: \$enc → Decrypted: \$dec');
print('7^2 mod 5 = \${modPow(7, 2, 5)}');''',
              output:
                  'Message: 4 → Encrypted: 16 → Decrypted: 4\n7^2 mod 5 = 4',
              quizPrompt: 'What is 7^2 mod 5?',
              quizOptions: <String>['2', '4', '9'],
              correctQuizIndex: 1,
              quizExplanation: '7^2 = 49. 49 mod 5 = 49 − 9·5 = 4.',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Modular arithmetic',
                instruction: 'Compute the modular arithmetic expression.',
                prompt: '(7 × 8) mod 10 = ____',
                options: <String>['6', '56', '5'],
                correctIndex: 0,
                template: 'final result = (7 * 8) % 10; // ____',
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'RSA steps',
                  instruction: 'Connect each RSA step to its formula.',
                  prompt: 'Match RSA operations.',
                  options: <String>[
                    'Key generation',
                    'Encryption',
                    'Decryption',
                    'Security basis',
                  ],
                  orderedLines: <String>[
                    'Choose primes p, q; compute n = pq, φ(n) = (p−1)(q−1)',
                    'c = m^e mod n using public key (n, e)',
                    'm = c^d mod n using private key (n, d)',
                    'Difficulty of factoring large n into p × q',
                  ],
                ),
              ],
              titleRu: 'Модульная арифметика и основы RSA',
              titleKk: 'Модульдік арифметика және RSA негіздері',
              summaryRu:
                  'Правила модульной арифметики, функция Эйлера, малая теорема Ферма и схема RSA.',
              summaryKk:
                  'Модульдік арифметика ережелері, Эйлер функциясы, Ферманың кіші теоремасы және RSA схемасы.',
              outcomeRu:
                  'Выполнять модульную арифметику и описывать процесс шифрования/дешифрования RSA.',
              outcomeKk:
                  'Модульдік арифметика орындау және RSA шифрлау/шифрды шешу процесін сипаттау.',
              keyPointsRu: <String>[
                'a ≡ b (mod n) означает, что n делит (a − b).',
                'Малая теорема Ферма: если p простое и p∤a, то aᵖ⁻¹ ≡ 1 (mod p).',
                'RSA основан на вычислительной трудности факторизации больших чисел.',
              ],
              keyPointsKk: <String>[
                'a ≡ b (mod n) дегені n (a − b)-ні бөледі.',
                'Ферманың кіші теоремасы: p жай және p∤a болса, aᵖ⁻¹ ≡ 1 (mod p).',
                'RSA үлкен сандарды жіктеудің есептеу қиындығына негізделген.',
              ],
              quizPromptRu: 'Чему равно 7² mod 5?',
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_7',
            title: 'Euclidean algorithm and modular arithmetic',
            starterCode:
                '''// 1. Implement gcd(a, b) using the Euclidean algorithm
// 2. Compute gcd(252, 105)
// 3. Compute (17 * 23) mod 10
// 4. Verify Fermat's little theorem: 3^6 mod 7 == 1''',
          ),
        ),
        // ── Module 8: Automata & Formal Languages ─────────────
        _module(
          id: 'discrete_math_module_8',
          title: 'Automata & Formal Languages',
          titleRu: 'Автоматы и формальные языки',
          titleKk: 'Автоматтар және формалды тілдер',
          summary:
              'Finite automata, regular expressions, context-free grammars, and the Chomsky hierarchy.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_8_1',
              title: 'Finite automata and regular expressions',
              trackTitle: 'Discrete Math',
              summary:
                  'DFAs, NFAs, and their connection to regular expressions and regular languages.',
              outcome:
                  'You can simulate a DFA on an input string and determine whether it is accepted.',
              theoryContent:
                  'A finite automaton reads an input string one symbol at a time and decides to accept or reject.\n\n'
                  '► DFA = (Q, Σ, δ, q₀, F):\n'
                  '• Q = finite set of states\n'
                  '• Σ = input alphabet\n'
                  '• δ: Q × Σ → Q = transition function (exactly one next state)\n'
                  '• q₀ ∈ Q = start state\n'
                  '• F ⊆ Q = accepting states\n\n'
                  'Reading left-to-right, follow transitions. If final state ∈ F: accepted.\n\n'
                  'Example: DFA accepting strings with even number of a\'s over {a, b}:\n'
                  '• States: {q0, q1}, start: q0, accepting: {q0}\n'
                  '• δ(q0,a)=q1, δ(q0,b)=q0, δ(q1,a)=q0, δ(q1,b)=q1\n'
                  '• "abba" → q0→q1→q1→q1→q0 ∈ F → accepted ✓\n'
                  '• "a" → q0→q1 ∉ F → rejected ✗\n\n'
                  '► NFA: like DFA but transitions can map to a SET of states, and ε-transitions are allowed. '
                  'An NFA accepts if ANY path leads to an accepting state.\n\n'
                  '► Equivalence: every NFA can be converted to a DFA (subset construction). '
                  'DFA ↔ NFA ↔ Regular Expression — all define regular languages.\n\n'
                  '► Not all languages are regular:\n'
                  '{aⁿbⁿ : n ≥ 0} is NOT regular — a DFA cannot count unboundedly. '
                  'Proved via the Pumping Lemma.',
              keyPoints: <String>[
                'DFA = (Q, Σ, δ, q₀, F) — exactly one transition per state-symbol pair.',
                'DFA, NFA, and regular expressions all define regular languages.',
                'Not all languages are regular — {aⁿbⁿ} requires unbounded counting.',
              ],
              codeSnippet: '''// DFA: accepts strings with even number of 'a's
bool dfaAccepts(String input) {
  var state = 'q0';
  for (final ch in input.split('')) {
    if (ch == 'a') state = (state == 'q0') ? 'q1' : 'q0';
  }
  return state == 'q0';
}
print(dfaAccepts('abba'));  // 2 a's → true
print(dfaAccepts('aab'));   // 2 a's → true
print(dfaAccepts('a'));     // 1 a → false
print(dfaAccepts('bbb'));   // 0 a's → true''',
              output: 'true\ntrue\nfalse\ntrue',
              quizPrompt:
                  'DFA accepts even number of a\'s. Does it accept "aab"?',
              quizOptions: <String>['true', 'false', 'Error'],
              correctQuizIndex: 0,
              quizExplanation:
                  '"aab" has 2 a\'s (even). q0→q1→q0→q0 ∈ F → accepted.',
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Predict DFA result',
                instruction:
                    'Trace the DFA (even a\'s) and predict the output.',
                prompt: '''var state = 'q0';
for (final ch in 'aba'.split('')) {
  if (ch == 'a') state = (state == 'q0') ? 'q1' : 'q0';
}
print(state == 'q0');''',
                options: <String>['true', 'false'],
                correctIndex: 1,
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Automata terms',
                  instruction: 'Connect each concept to its definition.',
                  prompt: 'Match automata terms.',
                  options: <String>[
                    'DFA',
                    'NFA',
                    'State',
                    'Transition function',
                  ],
                  orderedLines: <String>[
                    'Exactly one next state per symbol',
                    'Multiple possible next states',
                    'A configuration the machine can be in',
                    'Maps (state, symbol) to next state(s)',
                  ],
                ),
              ],
              titleRu: 'Конечные автоматы и регулярные выражения',
              titleKk: 'Ақырлы автоматтар және регулярлы өрнектер',
              summaryRu:
                  'Детерминированные и недетерминированные конечные автоматы и их связь с регулярными выражениями.',
              summaryKk:
                  'Детерминдік және детерминдік емес ақырлы автоматтар және олардың регулярлы өрнектермен байланысы.',
              outcomeRu:
                  'Моделировать работу ДКА на входной строке и определять, принимается ли она.',
              outcomeKk:
                  'Кіріс жолда ДАА жұмысын модельдеу және оның қабылданатынын анықтау.',
              keyPointsRu: <String>[
                'ДКА: из каждого состояния по каждому символу ровно один переход.',
                'Теорема Клини: регулярные языки ≡ языки, распознаваемые конечными автоматами.',
                'НКА → ДКА через построение подмножеств (возможное экспоненциальное раздутие).',
              ],
              keyPointsKk: <String>[
                'ДАА: әрбір күйден әрбір таңба бойынша дәл бір ауысу.',
                'Клини теоремасы: регулярлы тілдер ≡ ақырлы автоматтармен танылатын тілдер.',
                'НАА → ДАА ішкі жиындар конструкциясы арқылы (ықтимал экспоненциалды өсу).',
              ],
              quizPromptRu:
                  'ДКА принимает чётное число символов «a». Принимает ли он строку "aab"?',
            ),
            _lesson(
              id: 'discrete_math_lesson_8_2',
              title: 'Context-free grammars and computability',
              trackTitle: 'Discrete Math',
              summary:
                  'CFGs, the Chomsky hierarchy, Turing machines, and the halting problem.',
              outcome:
                  'You can write a simple CFG and explain why the halting problem is undecidable.',
              theoryContent:
                  'Beyond regular languages, programming constructs require more expressive grammars.\n\n'
                  '► CFG = (V, Σ, R, S):\n'
                  '• V = variables (non-terminals)\n'
                  '• Σ = terminals (alphabet)\n'
                  '• R = production rules: A → α\n'
                  '• S = start variable\n\n'
                  'Example CFG for balanced parentheses:\n'
                  '  S → (S) | SS | ε\n\n'
                  'Derivation of "(())":\n'
                  '  S → (S) → ((S)) → (())\n\n'
                  '► The Chomsky Hierarchy:\n\n'
                  'Type 3: Regular languages\n'
                  '  Recognized by: DFA/NFA. Example: a*b*\n\n'
                  'Type 2: Context-free languages\n'
                  '  Recognized by: pushdown automata (PDA). Example: {aⁿbⁿ}\n\n'
                  'Type 1: Context-sensitive languages\n'
                  '  Recognized by: linear-bounded automata. Example: {aⁿbⁿcⁿ}\n\n'
                  'Type 0: Recursively enumerable languages\n'
                  '  Recognized by: Turing machines.\n\n'
                  'Each level strictly contains the one below: Regular ⊂ CF ⊂ CS ⊂ RE.\n\n'
                  '► Turing Machines:\n'
                  'Infinite tape, read/write head, finite states. Church-Turing thesis: anything computable '
                  'by an algorithm can be computed by a Turing machine.\n\n'
                  '► The Halting Problem:\n'
                  'Given program P and input I, does P halt? Turing proved (1936) no algorithm can solve this '
                  'for all pairs. Proof by contradiction: assume halting detector H exists. Construct D(P) that '
                  'does the opposite of H(P,P). Then D(D) is contradictory. ∎\n\n'
                  'The most famous undecidable problem — fundamental limits of computation.',
              keyPoints: <String>[
                'CFG: S → (S) | SS | ε generates balanced parentheses.',
                'Chomsky hierarchy: Regular ⊂ Context-Free ⊂ Context-Sensitive ⊂ RE.',
                'The halting problem is undecidable — no algorithm can decide for all programs.',
              ],
              codeSnippet: '''// CFG recognizer for balanced parentheses
bool isBalanced(String s) {
  var depth = 0;
  for (final ch in s.split('')) {
    if (ch == '(') depth++;
    else if (ch == ')') {
      depth--;
      if (depth < 0) return false;
    }
  }
  return depth == 0;
}
print(isBalanced('(())'));
print(isBalanced('()()'));
print(isBalanced('((())'));
print(isBalanced(''));''',
              output: 'true\ntrue\nfalse\ntrue',
              quizPrompt: 'Which language is context-free but NOT regular?',
              quizOptions: <String>[
                '{aⁿbⁿ : n ≥ 0} — equal a\'s then b\'s',
                '{all strings of a\'s and b\'s}',
                '{ab, aabb} — could be regular',
              ],
              correctQuizIndex: 0,
              quizExplanation:
                  '{aⁿbⁿ} requires matching counts — DFAs can\'t count unboundedly. But a PDA with a stack can, making it context-free.',
              trainer: const DemoTrainerSeed.reorder(
                title: 'Chomsky hierarchy order',
                instruction:
                    'Arrange from most restrictive to least restrictive.',
                prompt: 'Order the Chomsky hierarchy levels.',
                orderedLines: <String>[
                  'Type 3: Regular (DFA/NFA)',
                  'Type 2: Context-Free (PDA)',
                  'Type 1: Context-Sensitive (LBA)',
                  'Type 0: Recursively Enumerable (Turing Machine)',
                ],
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Language types and examples',
                  instruction: 'Connect each language class to its example.',
                  prompt: 'Match Chomsky levels to examples.',
                  options: <String>[
                    'Regular',
                    'Context-Free',
                    'Context-Sensitive',
                    'Undecidable',
                  ],
                  orderedLines: <String>[
                    'a*b* — any a\'s followed by b\'s',
                    '{aⁿbⁿ} — equal a\'s then equal b\'s',
                    '{aⁿbⁿcⁿ} — equal a\'s, b\'s, and c\'s',
                    'Halting problem — no algorithm decides for all inputs',
                  ],
                ),
              ],
              titleRu: 'Контекстно-свободные грамматики и вычислимость',
              titleKk: 'Контекстен тәуелсіз грамматикалар және есептелімділік',
              summaryRu:
                  'КС-грамматики, иерархия Хомского, машины Тьюринга и проблема остановки.',
              summaryKk:
                  'КС-грамматикалар, Хомский иерархиясы, Тьюринг машинасы және тоқтау мәселесі.',
              outcomeRu:
                  'Составить простую КС-грамматику и объяснить, почему проблема остановки неразрешима.',
              outcomeKk:
                  'Қарапайым КС-грамматика жазу және тоқтау мәселесінің неліктен шешілмейтінін түсіндіру.',
              keyPointsRu: <String>[
                'КС-грамматика: правила вида A → α, где A — переменная, α — строка.',
                'Иерархия Хомского: регулярные ⊂ контекстно-свободные ⊂ контекстно-зависимые.',
                'Проблема остановки неразрешима: никакая программа не может определить это для всех пар (M, w).',
              ],
              keyPointsKk: <String>[
                'КС-грамматика: A → α түріндегі ережелер, мұнда A — айнымалы, α — жол.',
                'Хомский иерархиясы: регулярлы ⊂ контекстен тәуелсіз ⊂ контекстке тәуелді.',
                'Тоқтау мәселесі шешілмейді: ешбір бағдарлама барлық (M, w) үшін анықтай алмайды.',
              ],
              quizPromptRu:
                  'К какому классу иерархии Хомского относятся языки, принимаемые конечными автоматами?',
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_8',
            title: 'DFA simulation and balanced parentheses',
            starterCode:
                '''// 1. Simulate a DFA that accepts binary strings ending in '01'
// States: q0 (start), q1 (saw 0), q2 (saw 01, accepting)
bool dfaEndsWith01(String input) {
  // complete this function
  return false;
}
// 2. Test with '101', '001', '11', '010'
// 3. Check if '(()())' has balanced parentheses''',
          ),
        ),
      ],
    ),
    _track(
      id: 'linear_algebra_calculus',
      title: 'Linear Algebra',
      subtitle: 'Vectors, matrices, transformations, and feature spaces',
      description: 'Build intuition for transformations and optimization.',
      teaser: 'Strong for ML, graphics, and representing structured data.',
      outcome:
          'You can describe how values move through vector and matrix transforms.',
      icon: Icons.stacked_line_chart_rounded,
      color: const Color(0xFF62B5FF),
      order: 3,
      nodeId: 'cs-linear',
      connections: <String>[
        'discrete_math',
        'probability_statistics_analytics',
        'machine_learning',
      ],
      modules: <DemoModuleSeed>[
        _module(
          id: 'linear_algebra_calculus_module_1',
          title: 'Vectors and matrices',
          summary:
              'Represent inputs as vectors and transform them consistently.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'linear_algebra_calculus_lesson_1_1',
              title: 'Vectors as features',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''final vector = [2, 4, 6];
final doubled = vector.map((value) => value * 2).toList();
print(doubled[1]);''',
              output: '8',
              quizOptions: <String>['4', '8', '12'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the transform',
                instruction: 'Choose the operator that scales a value.',
                prompt: 'How do you scale a value by a constant?',
                options: <String>['*', '+', '/'],
                correctIndex: 0,
                template: 'final scaled = value ____ 3;',
              ),
            ),
            _lesson(
              id: 'linear_algebra_calculus_lesson_1_2',
              title: 'Matrices as transformations',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''final x = 2;
final y = 1;
print((2 * x) + y);''',
              output: '5',
              quizOptions: <String>['3', '4', '5'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Order the transform',
                instruction: 'Arrange the lines from input to output.',
                prompt: 'Rebuild the short matrix-style transform.',
                orderedLines: <String>[
                  'final x = 3;',
                  'final projected = (4 * x) + 2;',
                  'print(projected);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'linear_algebra_calculus_practice_1',
            title: 'Transform a feature vector',
            starterCode: '''final features = [1, 3, 5];

// create a transformed list''',
          ),
        ),
        _module(
          id: 'linear_algebra_calculus_module_2',
          title: 'Derivatives and optimization',
          summary: 'Understand change, slope, and iterative improvement.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'linear_algebra_calculus_lesson_2_1',
              title: 'Slope as change',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''final x1 = 2;
final x2 = 3;
print((x2 * x2) - (x1 * x1));''',
              output: '5',
              quizOptions: <String>['1', '4', '5'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Spot the slope output',
                instruction: 'Choose the correct difference.',
                prompt: '''final a = 4;
final b = 5;
print((b * b) - (a * a));''',
                options: <String>['7', '9', '11'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: 'linear_algebra_calculus_lesson_2_2',
              title: 'Optimization loops',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''var loss = 10;
loss -= 3;
loss -= 2;
print(loss);''',
              output: '5',
              quizOptions: <String>['4', '5', '6'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the update step',
                instruction: 'Choose the operation used to reduce loss.',
                prompt: 'Which update symbol moves the loss downward?',
                options: <String>['-=', '+=', '=='],
                correctIndex: 0,
                template: 'loss ____ step;',
              ),
            ),
          ],
          practice: _practice(
            id: 'linear_algebra_calculus_practice_2',
            title: 'Simulate an optimization cycle',
            starterCode: '''var loss = 18;

// apply several update steps''',
          ),
        ),
        _module(
          id: 'linear_algebra_calculus_module_3',
          title: 'Determinants and Inverse',
          summary:
              'Cofactor expansion, determinant properties, and Cramer\'s rule.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'linear_algebra_calculus_lesson_3_1',
              title: 'Computing determinants',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''// det([[a, b], [c, d]]) = a*d - b*c
final a = 3, b = 1, c = 2, d = 4;
final det = a * d - b * c;
print(det);''',
              output: '10',
              quizOptions: <String>['8', '10', '14'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the 2x2 determinant',
                instruction:
                    'Fill in the operator for the determinant formula.',
                prompt: 'det = a*d ____ b*c',
                options: <String>['-', '+', '*'],
                correctIndex: 0,
                template: 'final det = a * d ____ b * c;',
              ),
            ),
            _lesson(
              id: 'linear_algebra_calculus_lesson_3_2',
              title: 'Inverse matrices and Cramer\'s rule',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''// For a 2x2 matrix, inverse exists when det != 0
// Cramer: x = det(Ax) / det(A)
final detA = 5;
final detAx = 15;
final x = detAx / detA;
print(x);''',
              output: '3.0',
              quizOptions: <String>['3.0', '5.0', '10.0'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Order Cramer\'s rule steps',
                instruction: 'Arrange the steps to solve using Cramer\'s rule.',
                prompt: 'Rebuild the Cramer\'s rule procedure.',
                orderedLines: <String>[
                  'Compute det(A)',
                  'Replace column with constants to get det(Ax)',
                  'Divide det(Ax) by det(A)',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'linear_algebra_calculus_practice_3',
            title: 'Compute a 2x2 determinant',
            starterCode: '''final a = 5, b = 3;
final c = 2, d = 7;

// compute det = a*d - b*c and print''',
          ),
        ),
        _module(
          id: 'linear_algebra_calculus_module_4',
          title: 'Eigenvalues and Eigenvectors',
          summary:
              'Characteristic polynomial, eigenvalues, and diagonalization.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'linear_algebra_calculus_lesson_4_1',
              title: 'Characteristic polynomial',
              trackTitle: 'Linear Algebra',
              codeSnippet:
                  '''// For [[4,1],[2,3]], char poly: (4-λ)(3-λ) - 2 = 0
// λ^2 - 7λ + 10 = 0 => (λ-5)(λ-2) = 0
final lambda1 = 5;
final lambda2 = 2;
print(lambda1 + lambda2); // trace = sum of eigenvalues''',
              output: '7',
              quizOptions: <String>['5', '7', '10'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matching(
                title: 'Match eigenvalue concepts',
                instruction: 'Match each concept to its meaning.',
                prompt: 'Connect eigenvalue terms to their definitions.',
                options: <String>['Eigenvalue', 'Eigenvector', 'Trace'],
                orderedLines: <String>[
                  'Scalar lambda satisfying Av = lambda*v',
                  'Non-zero vector unchanged in direction by A',
                  'Sum of diagonal elements equals sum of eigenvalues',
                ],
              ),
            ),
            _lesson(
              id: 'linear_algebra_calculus_lesson_4_2',
              title: 'Diagonalization',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''// If A has n independent eigenvectors, A = PDP^-1
// Product of eigenvalues = determinant
final lambda1 = 5;
final lambda2 = 2;
print(lambda1 * lambda2); // det(A)''',
              output: '10',
              quizOptions: <String>['7', '10', '25'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Predict the determinant from eigenvalues',
                instruction: 'Product of eigenvalues equals the determinant.',
                prompt: '''final e1 = 3;
final e2 = 4;
print(e1 * e2);''',
                options: <String>['7', '12', '16'],
                correctIndex: 1,
              ),
            ),
          ],
          practice: _practice(
            id: 'linear_algebra_calculus_practice_4',
            title: 'Eigenvalue properties',
            starterCode: '''// Given eigenvalues of a 2x2 matrix
final lambda1 = 6;
final lambda2 = 3;

// compute and print the trace and determinant''',
          ),
        ),
      ],
    ),
    _track(
      id: 'probability_statistics_analytics',
      title: 'Probability & Statistics',
      subtitle:
          'Randomness, sampling, uncertainty, and evidence-based decisions',
      description: 'Use uncertainty and measurement to guide decisions.',
      teaser: 'Strong for analytics, experiments, forecasting, QA, and ML.',
      outcome: 'You can reason about uncertainty and explain evidence clearly.',
      icon: Icons.query_stats_rounded,
      color: const Color(0xFF5CE6FF),
      order: 4,
      nodeId: 'cs-probability',
      connections: <String>[
        'linear_algebra_calculus',
        'databases',
        'fundamentals',
        'machine_learning',
      ],
      modules: <DemoModuleSeed>[
        _module(
          id: 'probability_statistics_analytics_module_1',
          title: 'Probability Foundations',
          summary:
              'Sample spaces, events, conditional probability, and Bayes\' theorem.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'probability_statistics_analytics_lesson_1_1',
              title: 'Sample spaces and events',
              trackTitle: 'Probability & Statistics',
              codeSnippet: '''final sampleSpace = {'H', 'T'};
final event = {'H'};
final probability = event.length / sampleSpace.length;
print(probability);''',
              output: '0.5',
              quizOptions: <String>['0.25', '0.5', '1.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the probability formula',
                instruction:
                    'Choose the operator that gives probability as a ratio.',
                prompt: 'P(A) = |A| ____ |S|',
                options: <String>['/', '*', '+'],
                correctIndex: 0,
                template: 'final p = favorable ____ total;',
              ),
            ),
            _lesson(
              id: 'probability_statistics_analytics_lesson_1_2',
              title: 'Conditional probability and Bayes\' theorem',
              trackTitle: 'Probability & Statistics',
              codeSnippet: '''// P(A|B) = P(A and B) / P(B)
final pAandB = 0.12;
final pB = 0.30;
final pAgivenB = pAandB / pB;
print(pAgivenB.toStringAsFixed(1));''',
              output: '0.4',
              quizOptions: <String>['0.3', '0.4', '0.5'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Order the Bayes\' theorem steps',
                instruction: 'Arrange the steps of applying Bayes\' theorem.',
                prompt: 'Rebuild the Bayesian update process.',
                orderedLines: <String>[
                  'Start with prior probability P(A)',
                  'Compute likelihood P(B|A)',
                  'Compute evidence P(B)',
                  'Apply: P(A|B) = P(B|A) * P(A) / P(B)',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'probability_statistics_analytics_practice_1',
            title: 'Compute conditional probability',
            starterCode: '''final pDisease = 0.01; // prior
final pPositiveGivenDisease = 0.95; // sensitivity
final pPositiveGivenHealthy = 0.05; // false positive rate

// use Bayes' theorem to find P(disease | positive test)
// print the result''',
          ),
        ),
        _module(
          id: 'probability_statistics_analytics_module_2',
          title: 'Random Variables',
          summary:
              'Discrete and continuous random variables, expected value, and variance.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'probability_statistics_analytics_lesson_2_1',
              title: 'Expected value',
              trackTitle: 'Probability & Statistics',
              codeSnippet: '''// E[X] = sum of x * P(x)
final values = [1, 2, 3, 4, 5, 6];
final expected = values.reduce((a, b) => a + b) / values.length;
print(expected);''',
              output: '3.5',
              quizOptions: <String>['3.0', '3.5', '4.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matching(
                title: 'Match random variable concepts',
                instruction: 'Match each concept to its definition.',
                prompt: 'Connect terms to their meanings.',
                options: <String>[
                  'Expected value',
                  'Variance',
                  'Standard deviation',
                ],
                orderedLines: <String>[
                  'Weighted average of all possible outcomes',
                  'Average squared deviation from the mean',
                  'Square root of the variance',
                ],
              ),
            ),
            _lesson(
              id: 'probability_statistics_analytics_lesson_2_2',
              title: 'Variance and standard deviation',
              trackTitle: 'Probability & Statistics',
              codeSnippet:
                  '''final data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
final mean = data.reduce((a, b) => a + b) / data.length;
final variance = data.map((x) => (x - mean) * (x - mean))
    .reduce((a, b) => a + b) / data.length;
print(variance);''',
              output: '4.0',
              quizOptions: <String>['2.0', '4.0', '8.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the variance formula',
                instruction: 'Variance measures the average squared deviation.',
                prompt: 'Var(X) = E[(X - ____)^2]',
                options: <String>['mean', 'median', 'mode'],
                correctIndex: 0,
                template: 'final diff = x - ____;',
              ),
            ),
          ],
          practice: _practice(
            id: 'probability_statistics_analytics_practice_2',
            title: 'Compute expected value and variance',
            starterCode: '''final outcomes = [1, 2, 3, 4, 5, 6];
final probs = [1/6, 1/6, 1/6, 1/6, 1/6, 1/6];

// compute E[X] and Var(X) for a fair die
// print both values''',
          ),
        ),
        _module(
          id: 'probability_statistics_analytics_module_3',
          title: 'Probability Distributions',
          summary: 'Bernoulli, binomial, Poisson, and normal distributions.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'probability_statistics_analytics_lesson_3_1',
              title: 'Binomial distribution',
              trackTitle: 'Probability & Statistics',
              codeSnippet: '''// P(X=k) = C(n,k) * p^k * (1-p)^(n-k)
// P(3 heads in 5 flips)
int factorial(int n) => n <= 1 ? 1 : n * factorial(n - 1);
final c = factorial(5) ~/ (factorial(3) * factorial(2));
final p = c * 0.5 * 0.5 * 0.5 * 0.5 * 0.5;
print(p.toStringAsFixed(4));''',
              output: '0.3125',
              quizOptions: <String>['0.2500', '0.3125', '0.5000'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Build the binomial probability',
                instruction:
                    'Arrange the steps to compute a binomial probability.',
                prompt: 'Order the binomial calculation steps.',
                orderedLines: <String>[
                  'Choose n (trials) and k (successes)',
                  'Compute C(n, k)',
                  'Multiply by p^k * (1-p)^(n-k)',
                ],
              ),
            ),
            _lesson(
              id: 'probability_statistics_analytics_lesson_3_2',
              title: 'Normal distribution',
              trackTitle: 'Probability & Statistics',
              codeSnippet: '''// 68-95-99.7 rule for normal distribution
final mean = 100.0;
final stdDev = 15.0;
final oneSD = mean + stdDev;
print('68%% within [\${mean - stdDev}, \$oneSD]');''',
              output: '68% within [85.0, 115.0]',
              quizOptions: <String>[
                '68% within [85.0, 115.0]',
                '95% within [85.0, 115.0]',
                '68% within [70.0, 130.0]',
              ],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.matching(
                title: 'Match distributions to properties',
                instruction:
                    'Match each distribution to its key characteristic.',
                prompt: 'Connect distributions to their descriptions.',
                options: <String>['Bernoulli', 'Binomial', 'Normal'],
                orderedLines: <String>[
                  'Single trial with success or failure',
                  'Number of successes in n independent trials',
                  'Bell-shaped curve defined by mean and std dev',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'probability_statistics_analytics_practice_3',
            title: 'Model a binomial experiment',
            starterCode:
                '''int factorial(int n) => n <= 1 ? 1 : n * factorial(n - 1);

// A fair die is rolled 4 times.
// What is the probability of getting exactly 2 sixes?
// p = 1/6, n = 4, k = 2
// print the result''',
          ),
        ),
        _module(
          id: 'probability_statistics_analytics_module_4',
          title: 'Hypothesis Testing',
          summary:
              'Null hypothesis, p-values, t-tests, and confidence intervals.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'probability_statistics_analytics_lesson_4_1',
              title: 'Null hypothesis and p-values',
              trackTitle: 'Probability & Statistics',
              codeSnippet: '''// If p-value < alpha, reject H0
final pValue = 0.03;
final alpha = 0.05;
final reject = pValue < alpha;
print(reject);''',
              output: 'true',
              quizOptions: <String>['true', 'false', '0.03'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the hypothesis decision',
                instruction:
                    'Choose the comparison for rejecting the null hypothesis.',
                prompt: 'Reject H0 when p-value ____ alpha.',
                options: <String>['<', '>', '=='],
                correctIndex: 0,
                template: 'final reject = pValue ____ alpha;',
              ),
            ),
            _lesson(
              id: 'probability_statistics_analytics_lesson_4_2',
              title: 'T-tests and confidence intervals',
              trackTitle: 'Probability & Statistics',
              codeSnippet:
                  '''// 95% confidence interval: mean +/- z * (stdDev / sqrt(n))
import 'dart:math';
final mean = 50.0;
final stdDev = 10.0;
final n = 25;
final margin = 1.96 * (stdDev / sqrt(n));
print('[\${(mean - margin).toStringAsFixed(1)}, \${(mean + margin).toStringAsFixed(1)}]');''',
              output: '[46.1, 53.9]',
              quizOptions: <String>[
                '[46.1, 53.9]',
                '[40.0, 60.0]',
                '[48.0, 52.0]',
              ],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Build a confidence interval',
                instruction: 'Arrange the steps to construct a 95% CI.',
                prompt: 'Order the confidence interval computation.',
                orderedLines: <String>[
                  'Compute the sample mean',
                  'Calculate standard error = stdDev / sqrt(n)',
                  'Multiply SE by z-score (1.96 for 95%)',
                  'Interval = mean +/- margin',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'probability_statistics_analytics_practice_4',
            title: 'Perform a hypothesis test',
            starterCode:
                '''// A website claims average load time is 2.0 seconds.
// Your sample of 36 pages has mean 2.3s, std dev 0.6s.
// Test at alpha = 0.05 whether the true mean exceeds 2.0.

// compute the z-score and compare to 1.96
// print whether you reject the null hypothesis''',
          ),
        ),
      ],
    ),
    _track(
      id: 'algorithms_data_structures',
      title: 'Algorithms & Data Structures',
      subtitle:
          'Complexity, arrays, maps, trees, queues, and problem-solving patterns',
      description:
          'Learn how information is organized and how efficient procedures act on it.',
      teaser:
          'A central branch for backend, frontend state, QA thinking, and ML pipelines.',
      outcome:
          'You can explain how data structures and algorithms shape runtime behavior.',
      icon: Icons.account_tree_rounded,
      color: const Color(0xFF89E8C4),
      order: 5,
      nodeId: 'cs-algorithms',
      connections: <String>[
        'discrete_math',
        'frontend',
        'backend',
        'mobile',
        'qa_engineering',
        'machine_learning',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'computer_architecture',
      title: 'Computer Architecture',
      subtitle: 'CPU, memory hierarchy, binary, and execution',
      description: 'Connect code behavior to the machine beneath it.',
      teaser: 'Strong for performance intuition and systems reasoning.',
      outcome:
          'You can explain how instructions, memory, and hardware affect software.',
      icon: Icons.memory_rounded,
      color: const Color(0xFFB2F27A),
      order: 9,
      nodeId: 'cs-architecture',
      connections: <String>['operating_systems'],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'operating_systems',
      title: 'Operating Systems',
      subtitle: 'Processes, memory, scheduling, and system calls',
      description: 'Understand the runtime environment beneath an application.',
      teaser:
          'Strong for backend performance, mobile behavior, and systems debugging.',
      outcome: 'You can explain how the OS shapes runtime behavior.',
      icon: Icons.settings_applications_rounded,
      color: const Color(0xFF7AE582),
      order: 11,
      nodeId: 'cs-os',
      connections: <String>[
        'computer_architecture',
        'networking_protocols',
        'fundamentals',
        'sre_devops',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'networking_protocols',
      title: 'Information Networks',
      subtitle: 'Layers, routing, DNS, protocols, transport, and latency',
      description: 'Learn how data moves through layers and protocols.',
      teaser: 'Strong for backend APIs, mobile latency, and security.',
      outcome:
          'You can explain where packets, protocols, and delays enter the story.',
      icon: Icons.wifi_tethering_rounded,
      color: const Color(0xFFFFB86B),
      order: 7,
      nodeId: 'cs-networks',
      connections: <String>[
        'operating_systems',
        'databases',
        'fundamentals',
        'backend',
        'cybersecurity',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'databases',
      title: 'Databases',
      subtitle: 'Schemas, SQL, indexes, transactions, and replication',
      description: 'Store, query, and protect data with structured systems.',
      teaser: 'Strong for backend design, analytics, and product reliability.',
      outcome:
          'You can explain how data is stored, queried, and kept consistent.',
      icon: Icons.storage_rounded,
      color: const Color(0xFFFFD166),
      order: 6,
      nodeId: 'cs-databases',
      connections: <String>[
        'networking_protocols',
        'probability_statistics_analytics',
        'fundamentals',
        'backend',
        'machine_learning',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'ai_theory',
      title: 'AI Theory',
      subtitle:
          'Search, reasoning, learning paradigms, and intelligent systems',
      description:
          'Study the conceptual foundations behind intelligent behavior and machine reasoning.',
      teaser: 'Connects mathematics, algorithms, and ML engineering.',
      outcome:
          'You can explain how core AI ideas translate into model-driven systems.',
      icon: Icons.psychology_rounded,
      color: const Color(0xFFA991FF),
      order: 8,
      nodeId: 'cs-ai-theory',
      connections: <String>[
        'mathematical_analysis',
        'linear_algebra_calculus',
        'probability_statistics_analytics',
        'algorithms_data_structures',
        'machine_learning',
      ],
      modules: const <DemoModuleSeed>[],
    ),
    _track(
      id: 'information_security_foundations',
      title: 'Information Security',
      subtitle:
          'Confidentiality, integrity, access control, and secure system design',
      description:
          'Learn the foundational ideas that protect systems, users, and information.',
      teaser:
          'A core security branch that leads naturally into cybersecurity and system administration.',
      outcome:
          'You can explain the key security principles that shape technical decisions.',
      icon: Icons.verified_user_rounded,
      color: const Color(0xFFFF8D8D),
      order: 10,
      nodeId: 'cs-info-security',
      connections: <String>[
        'networking_protocols',
        'operating_systems',
        'system_administration',
        'cybersecurity',
      ],
      modules: const <DemoModuleSeed>[],
    ),
  ];
}

LearningTrack _track({
  required String id,
  required String title,
  required String subtitle,
  required String description,
  required String teaser,
  required String outcome,
  required IconData icon,
  required Color color,
  required int order,
  required String nodeId,
  required List<String> connections,
  required List<DemoModuleSeed> modules,
}) {
  final resolvedModules = modules.isEmpty
      ? _fallbackModules(id, title)
      : modules;
  final lessonCount = resolvedModules.fold<int>(
    0,
    (s, m) => s + m.lessons.length,
  );
  final practiceCount = resolvedModules.length;
  return buildTrackFromSeed(
    id: id,
    title: title,
    subtitle: subtitle,
    description: description,
    teaser: teaser,
    outcome: outcome,
    heroMetric:
        '${resolvedModules.length} modules • $lessonCount lessons • $practiceCount practices',
    icon: icon,
    color: color,
    zone: TrackZone.computerScienceCore,
    order: order,
    nodeId: nodeId,
    connections: connections,
    modules: resolvedModules,
  );
}

DemoModuleSeed _module({
  required String id,
  required String title,
  required String summary,
  required List<DemoLessonSeed> lessons,
  required DemoPracticeSeed practice,
  String? titleRu,
  String? titleKk,
  String? summaryRu,
  String? summaryKk,
}) {
  LocalizedText? buildL(String base, String? ru, String? kk) =>
      (ru != null || kk != null)
      ? LocalizedText(en: base, ru: ru ?? base, kk: kk ?? ru ?? base)
      : null;
  return DemoModuleSeed(
    id: id,
    title: title,
    summary: summary,
    lessons: lessons,
    practice: practice,
    titleL: buildL(title, titleRu, titleKk),
    summaryL: buildL(summary, summaryRu, summaryKk),
  );
}

DemoLessonSeed _lesson({
  required String id,
  required String title,
  required String trackTitle,
  required String codeSnippet,
  required String output,
  required List<String> quizOptions,
  required int correctQuizIndex,
  required DemoTrainerSeed trainer,
  String? summary,
  String? outcome,
  List<String>? keyPoints,
  String? quizPrompt,
  String? quizExplanation,
  String? promptSuggestion,
  String? theoryContent,
  List<DemoTrainerSeed>? extraTrainers,
  int durationMinutes = 12,
  int xpReward = 55,
  // Localization overrides (ru/kk) — en defaults to the base string
  String? titleRu,
  String? titleKk,
  String? summaryRu,
  String? summaryKk,
  String? outcomeRu,
  String? outcomeKk,
  String? theoryContentRu,
  String? theoryContentKk,
  List<String>? keyPointsRu,
  List<String>? keyPointsKk,
  String? quizPromptRu,
  String? quizPromptKk,
  String? quizExplanationRu,
  String? quizExplanationKk,
  String? promptSuggestionRu,
  String? promptSuggestionKk,
}) {
  final resolvedSummary = summary ?? 'Core idea in $trackTitle: $title.';
  final resolvedOutcome =
      outcome ?? 'You can explain $title using code and a short narrative.';
  final resolvedKeyPoints =
      keyPoints ??
      <String>[
        'Follow the data transformation step by step.',
        'Connect the code example to a real engineering situation.',
        'Use the output to verify your mental model.',
      ];
  final resolvedQuizPrompt =
      quizPrompt ?? 'What does this example print or return?';
  final resolvedQuizExplanation =
      quizExplanation ??
      'The correct answer follows from the final value computed in the example.';
  final resolvedPromptSuggestion =
      promptSuggestion ??
      'Explain $title as if I am presenting $trackTitle on stage.';

  LocalizedText? buildL(String base, String? ru, String? kk) =>
      (ru != null || kk != null)
      ? LocalizedText(en: base, ru: ru ?? base, kk: kk ?? ru ?? base)
      : null;

  LocalizedText? buildListL(
    List<String> base,
    List<String>? ru,
    List<String>? kk,
  ) {
    if (ru == null && kk == null) return null;
    final ruJoined = (ru ?? base).join('\n');
    final kkJoined = (kk ?? ru ?? base).join('\n');
    return LocalizedText(en: base.join('\n'), ru: ruJoined, kk: kkJoined);
  }

  return DemoLessonSeed(
    id: id,
    title: title,
    summary: resolvedSummary,
    outcome: resolvedOutcome,
    codeSnippet: codeSnippet,
    exampleOutput: output,
    keyPoints: resolvedKeyPoints,
    quizPrompt: resolvedQuizPrompt,
    quizOptions: quizOptions,
    correctQuizIndex: correctQuizIndex,
    quizExplanation: resolvedQuizExplanation,
    trainer: trainer,
    promptSuggestion: resolvedPromptSuggestion,
    theoryContent: theoryContent,
    extraTrainers: extraTrainers ?? const <DemoTrainerSeed>[],
    durationMinutes: durationMinutes,
    xpReward: xpReward,
    titleL: buildL(title, titleRu, titleKk),
    summaryL: buildL(resolvedSummary, summaryRu, summaryKk),
    outcomeL: buildL(resolvedOutcome, outcomeRu, outcomeKk),
    theoryContentL: buildL(
      theoryContent ?? '',
      theoryContentRu,
      theoryContentKk,
    ),
    keyPointsL: buildListL(resolvedKeyPoints, keyPointsRu, keyPointsKk) != null
        ? resolvedKeyPoints
              .asMap()
              .entries
              .map(
                (e) => LocalizedText(
                  en: e.value,
                  ru: keyPointsRu != null && e.key < keyPointsRu.length
                      ? keyPointsRu[e.key]
                      : e.value,
                  kk: keyPointsKk != null && e.key < keyPointsKk.length
                      ? keyPointsKk[e.key]
                      : keyPointsRu != null && e.key < keyPointsRu.length
                      ? keyPointsRu[e.key]
                      : e.value,
                ),
              )
              .toList()
        : null,
    quizPromptL: buildL(resolvedQuizPrompt, quizPromptRu, quizPromptKk),
    quizExplanationL: buildL(
      resolvedQuizExplanation,
      quizExplanationRu,
      quizExplanationKk,
    ),
    promptSuggestionL: buildL(
      resolvedPromptSuggestion,
      promptSuggestionRu,
      promptSuggestionKk,
    ),
  );
}

DemoPracticeSeed _practice({
  required String id,
  required String title,
  required String starterCode,
}) {
  return DemoPracticeSeed(
    id: id,
    title: title,
    summary: 'Use a small example to practice the idea and narrate the result.',
    brief:
        'Complete the starter code, print one meaningful result, and explain what the learner should notice.',
    starterCode: starterCode,
    successCriteria: const <String>[
      'Keep the example short and readable.',
      'Print one meaningful result.',
      'Explain why the result matters.',
    ],
    knowledgeChecks: const <String>[
      'What is the key idea behind the example?',
      'How would you explain the result to a teammate?',
    ],
    promptSuggestion:
        'Help me turn this practice into a presenter-friendly walkthrough.',
  );
}

List<DemoModuleSeed> _fallbackModules(String trackId, String title) {
  switch (trackId) {
    case 'probability_statistics_analytics':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Probability Foundations',
          summary:
              'Sample spaces, events, conditional probability, and Bayes\' theorem.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Sample spaces and events',
              trackTitle: title,
              codeSnippet: '''final favorable = 3;
final total = 10;
print(favorable / total);''',
              output: '0.3',
              quizOptions: <String>['0.3', '0.7', '3.0'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the probability formula',
                instruction:
                    'Choose the operator that gives probability as a ratio.',
                prompt: 'P(A) = favorable ____ total',
                options: <String>['/', '*', '+'],
                correctIndex: 0,
                template: 'final p = favorable ____ total;',
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Conditional probability and Bayes\' theorem',
              trackTitle: title,
              codeSnippet: '''// P(A|B) = P(A and B) / P(B)
final pAandB = 0.15;
final pB = 0.50;
print(pAandB / pB);''',
              output: '0.3',
              quizOptions: <String>['0.3', '0.5', '0.65'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Order the Bayes\' theorem steps',
                instruction: 'Arrange the steps for Bayesian reasoning.',
                prompt: 'Rebuild the Bayes\' theorem process.',
                orderedLines: <String>[
                  'Start with prior P(A)',
                  'Compute likelihood P(B|A)',
                  'Compute evidence P(B)',
                  'Apply: P(A|B) = P(B|A) * P(A) / P(B)',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Compute conditional probability',
            starterCode: '''final pRain = 0.2;
final pUmbrellaGivenRain = 0.9;
final pUmbrellaGivenNoRain = 0.3;

// use Bayes to find P(rain | umbrella)
// print the result''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Random Variables',
          summary: 'Discrete and continuous RVs, expected value, and variance.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Expected value',
              trackTitle: title,
              codeSnippet: '''final reward = 5;
final probability = 0.3;
print(reward * probability);''',
              output: '1.5',
              quizOptions: <String>['1.5', '2.0', '3.0'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.matching(
                title: 'Match random variable concepts',
                instruction: 'Match terms to definitions.',
                prompt: 'Connect each concept to its meaning.',
                options: <String>['Expected value', 'Variance', 'PMF'],
                orderedLines: <String>[
                  'Weighted average of outcomes',
                  'Average squared deviation from mean',
                  'Function giving probability for each value',
                ],
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Variance and spread',
              trackTitle: title,
              codeSnippet: '''final sample = [4, 6, 8];
final mean = sample.reduce((a, b) => a + b) / sample.length;
print(mean);''',
              output: '6.0',
              quizOptions: <String>['5.0', '6.0', '7.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Choose the mean',
                instruction: 'Pick the printed average.',
                prompt: '''final data = [2, 4, 10];
print(data.reduce((a, b) => a + b) / data.length);''',
                options: <String>['4.0', '5.33', '6.0'],
                correctIndex: 1,
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Compute expected value',
            starterCode: '''final outcomes = [10, 20, 30];
final probs = [0.2, 0.5, 0.3];

// compute E[X] = sum of outcome * probability
// print the result''',
          ),
        ),
        _module(
          id: '${trackId}_module_3',
          title: 'Probability Distributions',
          summary: 'Bernoulli, binomial, Poisson, and normal distributions.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_3_1',
              title: 'Binomial distribution',
              trackTitle: title,
              codeSnippet: '''// Binomial: P(X=k) = C(n,k) * p^k * (1-p)^(n-k)
final shirts = 3; // C(3,1) ways
final p = 0.5;
print(shirts * p * (1 - p) * (1 - p));''',
              output: '0.375',
              quizOptions: <String>['0.250', '0.375', '0.500'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Fill the binomial parameter',
                instruction:
                    'The binomial distribution counts successes in n trials.',
                prompt: 'P(X=k) = C(n,k) * p^k * (1-p)^____',
                options: <String>['n-k', 'n', 'k'],
                correctIndex: 0,
                template: '// exponent: ____',
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_3_2',
              title: 'Normal distribution',
              trackTitle: title,
              codeSnippet: '''// 68-95-99.7 rule
final mean = 100.0;
final sd = 15.0;
print('68%% within [\${mean - sd}, \${mean + sd}]');''',
              output: '68% within [85.0, 115.0]',
              quizOptions: <String>[
                '68% within [85.0, 115.0]',
                '95% within [85.0, 115.0]',
                '68% within [70.0, 130.0]',
              ],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.matching(
                title: 'Match distributions',
                instruction: 'Match each distribution to its key trait.',
                prompt: 'Connect distributions to descriptions.',
                options: <String>['Bernoulli', 'Binomial', 'Normal'],
                orderedLines: <String>[
                  'Single trial, success or failure',
                  'Count of successes in n trials',
                  'Bell curve with mean and std dev',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_3',
            title: 'Model a binomial experiment',
            starterCode: '''// A coin is flipped 4 times.
// What is P(exactly 2 heads)?
final n = 4;
final k = 2;
final p = 0.5;

// compute and print the probability''',
          ),
        ),
        _module(
          id: '${trackId}_module_4',
          title: 'Hypothesis Testing',
          summary:
              'Null hypothesis, p-values, t-tests, and confidence intervals.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_4_1',
              title: 'Null hypothesis and p-values',
              trackTitle: title,
              codeSnippet: '''final pValue = 0.03;
final alpha = 0.05;
print(pValue < alpha); // reject H0?''',
              output: 'true',
              quizOptions: <String>['true', 'false', '0.03'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the hypothesis test',
                instruction: 'Choose the comparison for rejection.',
                prompt: 'Reject H0 when p-value ____ alpha.',
                options: <String>['<', '>', '=='],
                correctIndex: 0,
                template: 'final reject = pValue ____ alpha;',
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_4_2',
              title: 'Confidence intervals',
              trackTitle: title,
              codeSnippet: '''final control = 0.14;
final variant = 0.18;
print(variant - control);''',
              output: '0.04',
              quizOptions: <String>['0.02', '0.04', '0.32'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Build a confidence interval',
                instruction: 'Arrange the steps to construct a CI.',
                prompt: 'Order the confidence interval steps.',
                orderedLines: <String>[
                  'Compute the sample mean',
                  'Calculate standard error',
                  'Multiply SE by z-score',
                  'Interval = mean +/- margin',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_4',
            title: 'Run a simple hypothesis test',
            starterCode: '''final control = 0.21;
final variant = 0.25;
final alpha = 0.05;

// compute the lift and decide if significant
// print the result''',
          ),
        ),
      ];
    case 'computer_architecture':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'CPU and memory',
          summary: 'Registers, cycles, caches, and latency.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'CPU work cycle',
              trackTitle: title,
              codeSnippet: '''var register = 1;
register = register + 2;
print(register);''',
              output: '3',
              quizOptions: <String>['1', '2', '3'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the arithmetic instruction',
                instruction: 'Choose the operator used in the register update.',
                prompt: 'Which operator adds to the register?',
                options: <String>['+', '-', '='],
                correctIndex: 0,
                template: 'register = register ____ 2;',
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Caches and latency',
              trackTitle: title,
              codeSnippet: '''final cacheHit = 1;
final memoryHit = 6;
print(memoryHit - cacheHit);''',
              output: '5',
              quizOptions: <String>['4', '5', '6'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the latency example',
                instruction: 'Arrange the lines that compare cache and memory.',
                prompt: 'Order the statements from setup to difference.',
                orderedLines: <String>[
                  'final cache = 2;',
                  'final memory = 8;',
                  'print(memory - cache);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Explain a performance gap',
            starterCode: '''final cacheHit = 2;
final slowAccess = 11;

// print the gap''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Representation and execution',
          summary: 'Binary data and parallel work.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Binary representation',
              trackTitle: title,
              codeSnippet: '''final bitA = 1;
final bitB = 0;
print('\$bitA\$bitB\$bitA');''',
              output: '101',
              quizOptions: <String>['011', '101', '110'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Match the printed bit pattern',
                instruction: 'Choose the output that matches the print.',
                prompt: '''final left = 1;
final right = 1;
print('\$left\$right\$left');''',
                options: <String>['101', '111', '110'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Parallel execution intuition',
              trackTitle: title,
              codeSnippet: '''final tasks = 4;
final workers = 2;
print(tasks / workers);''',
              output: '2.0',
              quizOptions: <String>['1.0', '2.0', '4.0'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the parallel split',
                instruction:
                    'Choose the operator that divides work across workers.',
                prompt: 'Which operator shares the load evenly?',
                options: <String>['/', '*', '+'],
                correctIndex: 0,
                template: 'final load = tasks ____ workers;',
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Model a tiny performance scenario',
            starterCode: '''final tasks = 12;
final workers = 3;

// print the distribution''',
          ),
        ),
      ];
    case 'operating_systems':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Processes and memory',
          summary: 'Isolation, sharing, and memory boundaries.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Processes vs threads',
              trackTitle: title,
              codeSnippet: '''final processName = 'api';
final threads = ['io', 'worker'];
print('\$processName:\${threads.length}');''',
              output: 'api:2',
              quizOptions: <String>['api:1', 'api:2', 'worker:2'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the process label',
                instruction:
                    'Select the value that identifies the outer runtime container.',
                prompt: 'Which term owns the resources?',
                options: <String>['process', 'thread', 'queue'],
                correctIndex: 0,
                template: "final owner = '____';",
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Memory layout',
              trackTitle: title,
              codeSnippet: '''final stackFrames = 3;
final heapObjects = 5;
print(stackFrames + heapObjects);''',
              output: '8',
              quizOptions: <String>['6', '7', '8'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the memory summary',
                instruction: 'Arrange the memory counters before the print.',
                prompt: 'Put the simple memory example back in order.',
                orderedLines: <String>[
                  'final stackFrames = 2;',
                  'final heapObjects = 4;',
                  'print(stackFrames + heapObjects);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Describe a runtime container',
            starterCode: '''final process = 'upload-service';
final threads = ['reader', 'writer', 'retry'];

// print the process summary''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Scheduling and IO',
          summary: 'Schedulers, files, and system calls.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Scheduling work',
              trackTitle: title,
              codeSnippet: '''final queue = ['api', 'worker', 'sync'];
print(queue.removeAt(0));''',
              output: 'api',
              quizOptions: <String>['api', 'worker', 'sync'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Match the scheduler output',
                instruction: 'Choose the process that leaves the queue first.',
                prompt: '''final queue = ['cache', 'db'];
print(queue.removeAt(0));''',
                options: <String>['db', 'cache', 'queue'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Files and system calls',
              trackTitle: title,
              codeSnippet: '''final fileReads = 2;
final socketReads = 1;
print(fileReads + socketReads);''',
              output: '3',
              quizOptions: <String>['2', '3', '4'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the IO count',
                instruction: 'Pick the operator that totals two IO sources.',
                prompt: 'Which symbol combines the IO counts?',
                options: <String>['+', '-', '/'],
                correctIndex: 0,
                template: 'print(fileReads ____ socketReads);',
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Model a scheduler snapshot',
            starterCode: '''final jobs = ['index', 'compress', 'backup'];

// remove the next job and print it''',
          ),
        ),
      ];
    case 'networking_protocols':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Layers and routing',
          summary: 'Understand how data crosses abstractions.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Layers of a request',
              trackTitle: title,
              codeSnippet: '''final layers = ['link', 'ip', 'tcp', 'http'];
print(layers.last);''',
              output: 'http',
              quizOptions: <String>['ip', 'tcp', 'http'],
              correctQuizIndex: 2,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the top layer',
                instruction:
                    'Choose the protocol that usually sits at the application level.',
                prompt: 'Which item belongs to the application layer here?',
                options: <String>['http', 'ethernet', 'arp'],
                correctIndex: 0,
                template: "final appLayer = '____';",
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Routing and latency',
              trackTitle: title,
              codeSnippet: '''final hop1 = 12;
final hop2 = 18;
print(hop1 + hop2);''',
              output: '30',
              quizOptions: <String>['24', '30', '36'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the hop calculation',
                instruction:
                    'Arrange the lines from hop values to total latency.',
                prompt: 'Put the route latency example in order.',
                orderedLines: <String>[
                  'final hopA = 9;',
                  'final hopB = 21;',
                  'print(hopA + hopB);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Describe a request path',
            starterCode: '''final hops = [10, 14, 19];

// total the route latency''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Protocols in practice',
          summary: 'HTTP, TLS, DNS, and sockets as real building blocks.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'HTTP and TLS',
              trackTitle: title,
              codeSnippet: '''final scheme = 'https';
final host = 'zerdestudy.app';
print('\$scheme://\$host');''',
              output: 'https://zerdestudy.app',
              quizOptions: <String>[
                'http://zerdestudy.app',
                'https://zerdestudy.app',
                'tls://zerdestudy.app',
              ],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Choose the secure URL',
                instruction: 'Pick the output that matches the secure scheme.',
                prompt: '''final scheme = 'https';
print('\$scheme://demo.local');''',
                options: <String>[
                  'http://demo.local',
                  'https://demo.local',
                  'tls://demo.local',
                ],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'DNS and sockets',
              trackTitle: title,
              codeSnippet: '''final host = 'api.zerdestudy.app';
final port = 443;
print('\$host:\$port');''',
              output: 'api.zerdestudy.app:443',
              quizOptions: <String>[
                'api.zerdestudy.app:80',
                'api.zerdestudy.app:443',
                'zerdestudy.app:443',
              ],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the socket endpoint',
                instruction: 'Choose the standard HTTPS port.',
                prompt: 'Which port is standard for HTTPS?',
                options: <String>['80', '443', '53'],
                correctIndex: 1,
                template: "final endpoint = 'api.demo.local:____';",
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Assemble a request endpoint',
            starterCode: '''final scheme = 'https';
final host = 'api.demo.local';
final port = 443;

// print the full endpoint''',
          ),
        ),
      ];
    case 'databases':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Schemas and queries',
          summary: 'Organize tables and retrieve meaningful data.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Schemas, keys, and rows',
              trackTitle: title,
              codeSnippet: '''final rows = 3;
final primaryKey = 'id';
print('\$primaryKey:\$rows');''',
              output: 'id:3',
              quizOptions: <String>['row:3', 'id:3', 'id:4'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Restore the primary key label',
                instruction:
                    'Select the column typically used as a table identifier.',
                prompt: 'Which label is commonly used as the primary key?',
                options: <String>['id', 'count', 'name'],
                correctIndex: 0,
                template: "final primaryKey = '____';",
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Reading data with SQL',
              trackTitle: title,
              codeSnippet: '''SELECT COUNT(*)
FROM lessons
WHERE status = 'done';''',
              output: 'Returns the number of completed lessons.',
              quizOptions: <String>[
                'All lesson rows',
                'The number of completed lessons',
                'The latest lesson title',
              ],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the SQL query',
                instruction: 'Arrange the lines from selection to filter.',
                prompt: 'Put the small SQL query back in the correct order.',
                orderedLines: <String>[
                  'SELECT COUNT(*)',
                  'FROM users',
                  'WHERE active = true;',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Model a tiny table question',
            starterCode: '''SELECT COUNT(*)
FROM users
WHERE plan = 'pro';

-- explain what this answers''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Indexes and transactions',
          summary: 'Speed up reads and protect correctness.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Indexes reduce search cost',
              trackTitle: title,
              codeSnippet: '''final fullScanCost = 12;
final indexedCost = 3;
print(fullScanCost - indexedCost);''',
              output: '9',
              quizOptions: <String>['6', '9', '15'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Choose the indexed savings',
                instruction:
                    'Pick the printed difference between scan and index.',
                prompt: '''final scan = 20;
final index = 5;
print(scan - index);''',
                options: <String>['10', '15', '25'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Transactions and consistency',
              trackTitle: title,
              codeSnippet: '''var inventory = 4;
inventory -= 1;
print(inventory);''',
              output: '3',
              quizOptions: <String>['2', '3', '4'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the update',
                instruction: 'Choose the operator used to decrement inventory.',
                prompt: 'Which operator reduces the inventory by one?',
                options: <String>['-=', '+=', '*='],
                correctIndex: 0,
                template: 'inventory ____ 1;',
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Explain a safe update',
            starterCode: '''var seats = 10;

// reserve one seat and print the new value''',
          ),
        ),
      ];
    default:
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Core concepts',
          summary: 'Build a clean mental model for the main ideas in $title.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_1_1',
              title: 'Key building blocks',
              trackTitle: title,
              codeSnippet: '''final ideas = ['model', 'reason', 'apply'];
print(ideas.length);''',
              output: '3',
              quizOptions: <String>['2', '3', '4'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the concept metric',
                instruction:
                    'Choose the property that counts the listed building blocks.',
                prompt:
                    'Which property returns the number of items in the list?',
                options: <String>['length', 'last', 'first'],
                correctIndex: 0,
                template: 'print(ideas.____);',
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_1_2',
              title: 'Patterns and structure',
              trackTitle: title,
              codeSnippet: '''final first = 2;
final second = 5;
print(first + second);''',
              output: '7',
              quizOptions: <String>['5', '7', '10'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.reorder(
                title: 'Rebuild the pattern',
                instruction: 'Arrange the setup and final print in order.',
                prompt: 'Put the short structure example back together.',
                orderedLines: <String>[
                  'final left = 4;',
                  'final right = 3;',
                  'print(left + right);',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_1',
            title: 'Map one core idea',
            starterCode: '''final terms = ['signal', 'state', 'result'];

// print one useful summary''',
          ),
        ),
        _module(
          id: '${trackId}_module_2',
          title: 'Applied reasoning',
          summary: 'Connect $title to concrete engineering decisions.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: '${trackId}_lesson_2_1',
              title: 'Reasoning through tradeoffs',
              trackTitle: title,
              codeSnippet: '''final fast = 8;
final safe = 5;
print(fast - safe);''',
              output: '3',
              quizOptions: <String>['2', '3', '13'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Choose the tradeoff result',
                instruction: 'Pick the printed difference.',
                prompt: '''final stable = 9;
final risky = 4;
print(stable - risky);''',
                options: <String>['4', '5', '6'],
                correctIndex: 1,
              ),
            ),
            _lesson(
              id: '${trackId}_lesson_2_2',
              title: 'Explaining an engineering scenario',
              trackTitle: title,
              codeSnippet: '''final steps = ['observe', 'decide', 'verify'];
print(steps.first);''',
              output: 'observe',
              quizOptions: <String>['observe', 'decide', 'verify'],
              correctQuizIndex: 0,
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete the first step',
                instruction:
                    'Choose the property that returns the starting item.',
                prompt: 'Which property returns the first element?',
                options: <String>['first', 'last', 'length'],
                correctIndex: 0,
                template: 'print(steps.____);',
              ),
            ),
          ],
          practice: _practice(
            id: '${trackId}_practice_2',
            title: 'Explain one technical decision',
            starterCode: '''final options = ['simple', 'scalable', 'secure'];

// print the option you want to defend''',
          ),
        ),
      ];
  }
}
