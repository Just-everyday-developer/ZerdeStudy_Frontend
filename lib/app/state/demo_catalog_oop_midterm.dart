import 'demo_catalog_support.dart';

/// Demo OOP midterm used by knowledge-tree practice flow and widget tests.
DemoPracticeSeed oopMidtermPracticeSeed() {
  return DemoPracticeSeed(
    id: 'oop_midterm',
    title: 'OOP Midterm',
    summary:
        'Solve a small OOP modeling task in the editor, run a draft console output, then submit the result for review.',
    brief:
        'Create a base learner class, extend it with a bootcamp-specific student, override the summary method, and print the final sentence.',
    starterCode: _oopMidtermStarterCode,
    successCriteria: const <String>[
      'Declare a shared field in the base class.',
      'Extend the base class and override summary().',
      'Print the overridden summary from main().',
    ],
    knowledgeChecks: const <String>[
      'Which field belongs to the base class and which one belongs to the child class?',
      'Why does the child implementation of summary() run instead of the base one?',
    ],
    promptSuggestion:
        'Help me explain why this OOP midterm solution uses inheritance and method overriding.',
    xpReward: 120,
    codeChallenge: const DemoPracticeCodeChallengeSeed(
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
    comments: const <DemoPracticeCommentSeed>[
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
  );
}

DemoModuleSeed oopMidtermModuleSeed() {
  return DemoModuleSeed(
    id: 'oop_module_midterm',
    title: 'OOP Midterm',
    titleL: sameText('OOP Midterm'),
    summary: 'Capstone practice for inheritance and overriding.',
    summaryL: sameText('Capstone practice for inheritance and overriding.'),
    lessons: const <DemoLessonSeed>[],
    practice: oopMidtermPracticeSeed(),
  );
}

const String _oopMidtermStarterCode = '''class StudentProfile {
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
}''';
