import 'package:flutter/material.dart';

import 'demo_catalog_support.dart';
import 'demo_models.dart';

List<LearningTrack> buildComputerScienceTracks() {
  return <LearningTrack>[
    _track(
      id: 'mathematics',
      title: 'Mathematics',
      subtitle: 'The common mathematical foundation for computing and engineering',
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
      id: 'mathematical_analysis',
      title: 'Mathematical Analysis',
      subtitle: 'Limits, derivatives, continuity, and change over time',
      description:
          'Understand how continuous change, rates, and accumulation support technical reasoning.',
      teaser: 'Useful for optimization, modeling, and dynamic system intuition.',
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
          summary: 'Sequences, limit theorems, one-sided limits, and continuous behavior.',
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
                instruction: 'Choose the value that the function approaches as x nears 1.',
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
                options: <String>['Left-hand limit', 'Right-hand limit', 'Continuity'],
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
          summary: 'Derivative definition, differentiation rules, and the chain rule.',
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
              codeSnippet: '''// d/dx(3x^2) using power rule: n * coeff * x^(n-1)
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
            starterCode: '''// Use a Riemann sum to approximate integral of x^3 from 0 to 2
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
              codeSnippet: '''// Geometric series: sum = a / (1 - r) when |r| < 1
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
                prompt: 'Order the first four terms of the Taylor series for e^x.',
                orderedLines: <String>[
                  '1',
                  '+ x',
                  '+ x^2 / 2!',
                  '+ x^3 / 3!',
                ],
              ),
            ),
          ],
          practice: _practice(
            id: 'mathematical_analysis_practice_4',
            title: 'Approximate e using a Taylor series',
            starterCode: '''// Compute e^1 using the first 10 terms of the Taylor series
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
      description: 'Learn the language behind algorithms and structured reasoning.',
      teaser: 'Strong for algorithms, backend reasoning, and state modeling.',
      outcome: 'You can reason about structure, conditions, and combinations clearly.',
      icon: Icons.route_rounded,
      color: const Color(0xFF7CE7FF),
      order: 2,
      nodeId: 'cs-discrete',
      connections: <String>[
        'linear_algebra_calculus',
        'probability_statistics_analytics',
      ],
      modules: <DemoModuleSeed>[
        // ── Module 1: Logic and Sets ──────────────────────────
        _module(
          id: 'discrete_math_module_1',
          title: 'Logic and Sets',
          summary: 'Propositions, logical connectives, truth tables, set operations, and inclusion-exclusion.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_1_1',
              title: 'Propositions and truth tables',
              trackTitle: 'Discrete Math',
              summary: 'Learn what propositions are, how logical connectives work, and how to build truth tables.',
              outcome: 'You can evaluate compound propositions and apply De Morgan\'s laws.',
              theoryContent:
                  'A proposition is a declarative statement that is either true or false, but not both. '
                  'For example, “2 + 3 = 5” is a proposition (true), while “x > 3” is not a proposition until we know x.\n\n'
                  'Logical connectives combine propositions into compound statements:\n'
                  '• Negation ¬p — “not p”, flips the truth value\n'
                  '• Conjunction p ∧ q — “p and q”, true only when both are true\n'
                  '• Disjunction p ∨ q — “p or q”, true when at least one is true\n'
                  '• Implication p → q — “if p then q”, false only when p is true and q is false\n'
                  '• Biconditional p ↔ q — “p if and only if q”, true when both have the same value\n\n'
                  '►Truth table for the basic connectives:\n'
                  '  p   q   ¬p   p∧q   p∨q   p→q   p↔q\n'
                  '  T   T    F     T     T     T     T\n'
                  '  T   F    F     F     T     F     F\n'
                  '  F   T    T     F     T     T     F\n'
                  '  F   F    T     F     F     T     T\n\n'
                  'De Morgan\'s laws allow you to move negation inside a compound expression:\n\n'
                  '►¬(p ∧ q) ≡ ¬p ∨ ¬q\n'
                  '¬(p ∨ q) ≡ ¬p ∧ ¬q\n\n'
                  'These identities are essential for simplifying boolean conditions. '
                  'Every if/else chain in a program is built from these connectives.',
              keyPoints: <String>[
                'A proposition always has exactly one truth value: true or false.',
                'Implication p → q is false only when p is true and q is false.',
                'De Morgan\'s laws let you transform ¬(AND) into OR and vice versa.',
              ],
              codeSnippet: '''final p = true;
final q = false;
// De Morgan: !(p && q) == (!p || !q)
print(!(p && q) == (!p || !q));''',
              output: 'true',
              quizPrompt: 'Does De Morgan\'s law hold here? What does the code print?',
              quizOptions: <String>['true', 'false', 'null'],
              correctQuizIndex: 0,
              quizExplanation:
                  'De Morgan\'s law states ¬(p ∧ q) ≡ ¬p ∨ ¬q. Both sides evaluate identically, so the equality returns true.',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Apply De Morgan\'s law',
                instruction: 'Complete the equivalent expression using De Morgan\'s law.',
                prompt: '!(a && b) is equivalent to (!a ____ !b)',
                options: <String>['||', '&&', '=='],
                correctIndex: 0,
                template: 'print(!(a && b) == (!a ____ !b));',
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Match logical symbols',
                  instruction: 'Connect each logical symbol to its meaning.',
                  prompt: 'Match the connective to its English name.',
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
            ),
            _lesson(
              id: 'discrete_math_lesson_1_2',
              title: 'Sets and operations',
              trackTitle: 'Discrete Math',
              summary: 'Master set notation, operations (union, intersection, difference), and the inclusion-exclusion principle.',
              outcome: 'You can compute set operations and apply the inclusion-exclusion formula.',
              theoryContent:
                  'A set is an unordered collection of distinct elements. We write A = {1, 2, 3} '
                  'and say 2 ∈ A (2 belongs to A) but 5 ∉ A.\n\n'
                  'Core set operations:\n'
                  '• Union A ∪ B — all elements in A or B (or both)\n'
                  '• Intersection A ∩ B — elements in both A and B\n'
                  '• Difference A ∖ B — elements in A but not in B\n'
                  '• Complement Aᶜ — elements not in A (relative to a universal set)\n\n'
                  '►The Inclusion-Exclusion Principle:\n'
                  '|A ∪ B| = |A| + |B| − |A ∩ B|\n\n'
                  'This prevents double-counting elements that belong to both sets. '
                  'For three sets:\n'
                  '|A ∪ B ∪ C| = |A| + |B| + |C| − |A∩B| − |A∩C| − |B∩C| + |A∩B∩C|\n\n'
                  'Subsets: A ⊂ B means every element of A is also in B.\n'
                  'Empty set: ∅ is the set with no elements; ∅ ⊂ A for any set A.\n\n'
                  'In programming, sets are used for deduplication, membership testing, and computing '
                  'overlaps — such as shared permissions, common tags, or feature intersections.',
              keyPoints: <String>[
                'Inclusion-exclusion: |A ∪ B| = |A| + |B| − |A ∩ B|.',
                'The empty set ∅ is a subset of every set.',
                'Set operations mirror boolean logic: ∪ ↔ OR, ∩ ↔ AND, complement ↔ NOT.',
              ],
              codeSnippet: '''final A = {1, 2, 3, 4};
final B = {3, 4, 5, 6};
// Inclusion-exclusion: |A ∪ B| = |A| + |B| - |A ∩ B|
print(A.union(B).length);''',
              output: '6',
              quizPrompt: 'What is |A ∪ B| for A = {1,2,3,4} and B = {3,4,5,6}?',
              quizOptions: <String>['6', '8', '4'],
              correctQuizIndex: 0,
              quizExplanation:
                  '|A| = 4, |B| = 4, |A ∩ B| = |{3,4}| = 2. So |A ∪ B| = 4 + 4 − 2 = 6.',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Complete inclusion-exclusion',
                instruction: 'Fill in the missing operator in the inclusion-exclusion formula.',
                prompt: '|A ∪ B| = |A| + |B| ____ |A ∩ B|',
                options: <String>['-', '+', '*'],
                correctIndex: 0,
                template: 'final unionSize = a.length + b.length ____ intersection.length;',
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Compute set operations',
                  instruction: 'For A = {1,2,3} and B = {2,3,4}, match each operation to its result.',
                  prompt: 'Match operations to results.',
                  options: <String>['A ∪ B', 'A ∩ B', 'A ∖ B', 'B ∖ A'],
                  orderedLines: <String>[
                    '{1, 2, 3, 4}',
                    '{2, 3}',
                    '{1}',
                    '{4}',
                  ],
                ),
              ],
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_1',
            title: 'Inclusion-exclusion in practice',
            starterCode: '''final users = {'Alice', 'Bob', 'Carol', 'Dave'};
final premium = {'Bob', 'Carol', 'Eve'};

// 1. Find users who are also premium
// 2. Verify inclusion-exclusion: |union| == |users| + |premium| - |intersection|
// 3. Print both results''',
          ),
        ),
        // ── Module 2: Graphs and Counting ─────────────────────
        _module(
          id: 'discrete_math_module_2',
          title: 'Graphs and counting',
          summary: 'Graph terminology, adjacency, handshaking lemma, and fundamental counting principles.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_2_1',
              title: 'Graph theory basics',
              trackTitle: 'Discrete Math',
              summary: 'Understand vertices, edges, degree, and the handshaking lemma.',
              outcome: 'You can model a system as a graph and compute edge counts using the handshaking lemma.',
              theoryContent:
                  'A graph G = (V, E) consists of a set of vertices V and a set of edges E '
                  'connecting pairs of vertices.\n\n'
                  'Types of graphs:\n'
                  '• Undirected — edges have no direction: {u, v}\n'
                  '• Directed (digraph) — edges have direction: (u, v) means u → v\n'
                  '• Weighted — edges carry a numerical cost or distance\n\n'
                  'The degree of a vertex is the number of edges touching it. In a directed graph '
                  'we distinguish in-degree (incoming) and out-degree (outgoing).\n\n'
                  '►Handshaking Lemma:\n'
                  'Sum of all vertex degrees = 2 × |E|\n'
                  'Each edge contributes 1 to the degree of each endpoint.\n\n'
                  'A path is a sequence of vertices connected by edges. A cycle is a path '
                  'that returns to its starting vertex. A connected graph with no cycles is called a tree — '
                  'a tree with n vertices always has exactly n − 1 edges.\n\n'
                  'Graphs model real-world systems: social networks (people → friendships), '
                  'web pages (pages → links), route maps (cities → roads), and dependency trees in software.',
              keyPoints: <String>[
                'Handshaking lemma: sum of degrees = 2 × number of edges.',
                'A tree with n vertices has exactly n − 1 edges.',
                'Adjacency lists and adjacency matrices are two ways to store a graph.',
              ],
              codeSnippet: '''final graph = {
  'A': ['B', 'C'],
  'B': ['A', 'C', 'D'],
  'C': ['A', 'B'],
  'D': ['B'],
};
final sumDeg = graph.values.fold<int>(0, (s, e) => s + e.length);
print('Edges: \${sumDeg ~/ 2}');''',
              output: 'Edges: 4',
              quizPrompt: 'Sum of degrees is 8. How many edges does this graph have?',
              quizOptions: <String>['3', '4', '8'],
              correctQuizIndex: 1,
              quizExplanation:
                  'Degrees: A=2, B=3, C=2, D=1 → sum = 8. By the handshaking lemma, edges = 8 / 2 = 4.',
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Count the edges',
                instruction: 'Use the handshaking lemma to find the number of edges.',
                prompt: '''final g = {'X': ['Y', 'Z'], 'Y': ['X'], 'Z': ['X', 'Y']};
final deg = g.values.fold<int>(0, (s, e) => s + e.length);
print(deg ~/ 2);''',
                options: <String>['2', '3', '4'],
                correctIndex: 1,
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Match graph terms',
                  instruction: 'Connect each graph term to its definition.',
                  prompt: 'Match terminology to meaning.',
                  options: <String>['Vertex', 'Edge', 'Degree', 'Cycle'],
                  orderedLines: <String>[
                    'A node in a graph',
                    'A connection between two nodes',
                    'Number of edges at a node',
                    'A path that returns to its start',
                  ],
                ),
              ],
            ),
            _lesson(
              id: 'discrete_math_lesson_2_2',
              title: 'Counting principles',
              trackTitle: 'Discrete Math',
              summary: 'Master the multiplication, addition, and pigeonhole principles.',
              outcome: 'You can determine which counting principle applies and compute the result.',
              theoryContent:
                  'The Multiplication Principle: if a process has k independent stages with '
                  'n₁, n₂, …, nₖ choices, the total number of outcomes is n₁ × n₂ × … × nₖ.\n\n'
                  'Example: a password with 3 lowercase letters → 26 × 26 × 26 = 17 576 possibilities.\n\n'
                  'The Addition Principle: if a process can be done via one of k mutually exclusive '
                  'methods with n₁, n₂, …, nₖ options, the total is n₁ + n₂ + … + nₖ.\n\n'
                  'Example: choosing a dessert from 5 cakes OR 3 pies → 5 + 3 = 8 options.\n\n'
                  '►Pigeonhole Principle:\n'
                  'If n items are placed into k containers and n > k,\n'
                  'at least one container holds ≥ ⌈n/k⌉ items.\n\n'
                  'Example: among 13 people, at least ⌈13/12⌉ = 2 share the same birth month.\n\n'
                  'These three principles are the foundation of all counting arguments. '
                  'When order matters we use permutations; when it doesn\'t, combinations (Module 4).',
              keyPoints: <String>[
                'Multiplication: independent stages → multiply the options.',
                'Addition: mutually exclusive alternatives → add the options.',
                'Pigeonhole: more items than containers → at least one container has ≥ 2.',
              ],
              codeSnippet: '''// Password: 2 digits (0-9) + 1 letter (a-z)
final digits = 10;
final letters = 26;
final passwords = digits * digits * letters;
print(passwords);''',
              output: '2600',
              quizPrompt: 'How many passwords of the form digit-digit-letter exist?',
              quizOptions: <String>['36', '260', '2600'],
              correctQuizIndex: 2,
              quizExplanation:
                  '10 choices × 10 choices × 26 choices = 2600 by the multiplication principle.',
              trainer: const DemoTrainerSeed.fillBlank(
                title: 'Pick the right principle',
                instruction: 'Choosing one of 3 bus routes OR one of 4 flights — which operator?',
                prompt: 'Mutually exclusive alternatives use the ____ operator.',
                options: <String>['+', '*', '-'],
                correctIndex: 0,
                template: 'final options = routes ____ flights;',
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Match counting principles',
                  instruction: 'Connect each problem to the correct principle.',
                  prompt: 'Which principle solves each problem?',
                  options: <String>[
                    '3 shirts × 4 pants',
                    '5 buses + 3 trains',
                    '13 people, 12 months',
                    'Total − unwanted',
                  ],
                  orderedLines: <String>[
                    'Multiplication principle',
                    'Addition principle',
                    'Pigeonhole principle',
                    'Complement counting',
                  ],
                ),
              ],
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_2',
            title: 'Count passwords and routes',
            starterCode: '''// 1. How many 4-digit PINs (0-9) exist?
// 2. A student can travel by bus (5 routes) or train (3 routes).
//    How many travel options are there?
// Print both answers.''',
          ),
        ),
        // ── Module 3: Relations and Functions ─────────────────
        _module(
          id: 'discrete_math_module_3',
          title: 'Relations and functions',
          summary: 'Equivalence relations, congruence modulo n, injections, surjections, and bijections.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_3_1',
              title: 'Equivalence relations',
              trackTitle: 'Discrete Math',
              summary: 'Understand reflexive, symmetric, and transitive properties. Explore congruence modulo n.',
              outcome: 'You can verify whether a relation is an equivalence and identify its equivalence classes.',
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
              quizPrompt: 'Is “strictly less than” (<) an equivalence relation on integers?',
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
                  instruction: 'Determine whether each relation has the given property.',
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
            ),
            _lesson(
              id: 'discrete_math_lesson_3_2',
              title: 'Functions and bijections',
              trackTitle: 'Discrete Math',
              summary: 'Learn about injections, surjections, bijections, and inverse functions.',
              outcome: 'You can classify a function as injective, surjective, or bijective.',
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
                instruction: 'For a bijection between finite sets, domain and codomain must have…',
                prompt: 'A bijection requires |domain| ____ |codomain|.',
                options: <String>['==', '>', '<'],
                correctIndex: 0,
                template: 'final isBijection = domain.length ____ codomain.length;',
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
            ),
          ],
          practice: _practice(
            id: 'discrete_math_practice_3',
            title: 'Verify equivalence and classify functions',
            starterCode: '''// 1. Check: is “same remainder mod 4” an equivalence on {0..11}?
//    Test reflexive, symmetric, transitive for a few values.
bool congMod4(int a, int b) => a % 4 == b % 4;

// 2. Is the mapping {0:0, 1:1, 2:4, 3:9} injective? surjective onto {0..9}?
// Print your findings.''',
          ),
        ),
        // ── Module 4: Combinatorics ───────────────────────────
        _module(
          id: 'discrete_math_module_4',
          title: 'Combinatorics',
          summary: 'Permutations, combinations, Pascal\'s triangle, and the binomial theorem.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'discrete_math_lesson_4_1',
              title: 'Permutations and combinations',
              trackTitle: 'Discrete Math',
              summary: 'Distinguish when order matters (permutations) from when it does not (combinations).',
              outcome: 'You can compute P(n,k) and C(n,k) and choose the right formula for a problem.',
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
              codeSnippet: '''int factorial(int n) => n <= 1 ? 1 : n * factorial(n - 1);
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
                instruction: 'Arrange the steps to compute C(n,k) in the correct order.',
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
            ),
            _lesson(
              id: 'discrete_math_lesson_4_2',
              title: 'Binomial theorem',
              trackTitle: 'Discrete Math',
              summary: 'Expand (a+b)ⁿ using Pascal\'s triangle and prove the 2ⁿ identity.',
              outcome: 'You can expand binomial expressions and use Pascal\'s triangle to find coefficients.',
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
                instruction: 'Sum of binomial coefficients for (a+b)⁶ equals 2⁶.',
                prompt: '''final row6 = [1, 6, 15, 20, 15, 6, 1];
print(row6.reduce((a, b) => a + b));''',
                options: <String>['32', '64', '128'],
                correctIndex: 1,
              ),
              extraTrainers: const <DemoTrainerSeed>[
                DemoTrainerSeed.matching(
                  title: 'Match binomial expressions',
                  instruction: 'Connect each expression to its value or expansion.',
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
      ],
    ),
    _track(
      id: 'linear_algebra_calculus',
      title: 'Linear Algebra',
      subtitle: 'Vectors, matrices, transformations, and feature spaces',
      description: 'Build intuition for transformations and optimization.',
      teaser: 'Strong for ML, graphics, and representing structured data.',
      outcome: 'You can describe how values move through vector and matrix transforms.',
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
          summary: 'Represent inputs as vectors and transform them consistently.',
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
          summary: 'Cofactor expansion, determinant properties, and Cramer\'s rule.',
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
                instruction: 'Fill in the operator for the determinant formula.',
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
          summary: 'Characteristic polynomial, eigenvalues, and diagonalization.',
          lessons: <DemoLessonSeed>[
            _lesson(
              id: 'linear_algebra_calculus_lesson_4_1',
              title: 'Characteristic polynomial',
              trackTitle: 'Linear Algebra',
              codeSnippet: '''// For [[4,1],[2,3]], char poly: (4-λ)(3-λ) - 2 = 0
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
      subtitle: 'Randomness, sampling, uncertainty, and evidence-based decisions',
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
          summary: 'Sample spaces, events, conditional probability, and Bayes\' theorem.',
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
                instruction: 'Choose the operator that gives probability as a ratio.',
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
          summary: 'Discrete and continuous random variables, expected value, and variance.',
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
                options: <String>['Expected value', 'Variance', 'Standard deviation'],
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
              codeSnippet: '''final data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
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
                instruction: 'Arrange the steps to compute a binomial probability.',
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
                instruction: 'Match each distribution to its key characteristic.',
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
            starterCode: '''int factorial(int n) => n <= 1 ? 1 : n * factorial(n - 1);

// A fair die is rolled 4 times.
// What is the probability of getting exactly 2 sixes?
// p = 1/6, n = 4, k = 2
// print the result''',
          ),
        ),
        _module(
          id: 'probability_statistics_analytics_module_4',
          title: 'Hypothesis Testing',
          summary: 'Null hypothesis, p-values, t-tests, and confidence intervals.',
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
                instruction: 'Choose the comparison for rejecting the null hypothesis.',
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
              codeSnippet: '''// 95% confidence interval: mean +/- z * (stdDev / sqrt(n))
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
            starterCode: '''// A website claims average load time is 2.0 seconds.
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
      subtitle: 'Complexity, arrays, maps, trees, queues, and problem-solving patterns',
      description:
          'Learn how information is organized and how efficient procedures act on it.',
      teaser: 'A central branch for backend, frontend state, QA thinking, and ML pipelines.',
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
      outcome: 'You can explain how instructions, memory, and hardware affect software.',
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
      teaser: 'Strong for backend performance, mobile behavior, and systems debugging.',
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
      outcome: 'You can explain where packets, protocols, and delays enter the story.',
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
      outcome: 'You can explain how data is stored, queried, and kept consistent.',
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
      subtitle: 'Search, reasoning, learning paradigms, and intelligent systems',
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
      subtitle: 'Confidentiality, integrity, access control, and secure system design',
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
  return buildTrackFromSeed(
    id: id,
    title: title,
    subtitle: subtitle,
    description: description,
    teaser: teaser,
    outcome: outcome,
    heroMetric: '2 modules • 4 lessons • 2 practices',
    icon: icon,
    color: color,
    zone: TrackZone.computerScienceCore,
    order: order,
    nodeId: nodeId,
    connections: connections,
    modules: modules.isEmpty ? _fallbackModules(id, title) : modules,
  );
}

DemoModuleSeed _module({
  required String id,
  required String title,
  required String summary,
  required List<DemoLessonSeed> lessons,
  required DemoPracticeSeed practice,
}) {
  return DemoModuleSeed(
    id: id,
    title: title,
    summary: summary,
    lessons: lessons,
    practice: practice,
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
}) {
  return DemoLessonSeed(
    id: id,
    title: title,
    summary: summary ?? 'Core idea in $trackTitle: $title.',
    outcome: outcome ?? 'You can explain $title using code and a short narrative.',
    codeSnippet: codeSnippet,
    exampleOutput: output,
    keyPoints: keyPoints ??
        <String>[
          'Follow the data transformation step by step.',
          'Connect the code example to a real engineering situation.',
          'Use the output to verify your mental model.',
        ],
    quizPrompt: quizPrompt ?? 'What does this example print or return?',
    quizOptions: quizOptions,
    correctQuizIndex: correctQuizIndex,
    quizExplanation: quizExplanation ??
        'The correct answer follows from the final value computed in the example.',
    trainer: trainer,
    promptSuggestion: promptSuggestion ??
        'Explain $title as if I am presenting $trackTitle on stage.',
    theoryContent: theoryContent,
    extraTrainers: extraTrainers ?? const <DemoTrainerSeed>[],
    durationMinutes: durationMinutes,
    xpReward: xpReward,
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
    brief: 'Complete the starter code, print one meaningful result, and explain what the learner should notice.',
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
    promptSuggestion: 'Help me turn this practice into a presenter-friendly walkthrough.',
  );
}

List<DemoModuleSeed> _fallbackModules(String trackId, String title) {
  switch (trackId) {
    case 'probability_statistics_analytics':
      return <DemoModuleSeed>[
        _module(
          id: '${trackId}_module_1',
          title: 'Probability Foundations',
          summary: 'Sample spaces, events, conditional probability, and Bayes\' theorem.',
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
                instruction: 'Choose the operator that gives probability as a ratio.',
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
                instruction: 'The binomial distribution counts successes in n trials.',
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
          summary: 'Null hypothesis, p-values, t-tests, and confidence intervals.',
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
                instruction: 'Choose the operator that divides work across workers.',
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
                instruction: 'Select the value that identifies the outer runtime container.',
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
                instruction: 'Choose the protocol that usually sits at the application level.',
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
                instruction: 'Arrange the lines from hop values to total latency.',
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
              quizOptions: <String>['http://zerdestudy.app', 'https://zerdestudy.app', 'tls://zerdestudy.app'],
              correctQuizIndex: 1,
              trainer: const DemoTrainerSeed.matchOutput(
                title: 'Choose the secure URL',
                instruction: 'Pick the output that matches the secure scheme.',
                prompt: '''final scheme = 'https';
print('\$scheme://demo.local');''',
                options: <String>['http://demo.local', 'https://demo.local', 'tls://demo.local'],
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
              quizOptions: <String>['api.zerdestudy.app:80', 'api.zerdestudy.app:443', 'zerdestudy.app:443'],
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
                instruction: 'Select the column typically used as a table identifier.',
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
              quizOptions: <String>['All lesson rows', 'The number of completed lessons', 'The latest lesson title'],
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
                instruction: 'Pick the printed difference between scan and index.',
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
                instruction: 'Choose the property that counts the listed building blocks.',
                prompt: 'Which property returns the number of items in the list?',
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
                instruction: 'Choose the property that returns the starting item.',
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
