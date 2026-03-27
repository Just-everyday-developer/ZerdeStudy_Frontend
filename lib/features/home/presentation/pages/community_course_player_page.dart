import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/adaptive_panel.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class CommunityCoursePlayerPage extends ConsumerStatefulWidget {
  const CommunityCoursePlayerPage({
    super.key,
    required this.courseId,
    required this.skipIntro,
  });

  final String courseId;
  final bool skipIntro;

  @override
  ConsumerState<CommunityCoursePlayerPage> createState() =>
      _CommunityCoursePlayerPageState();
}

class _CommunityCoursePlayerPageState
    extends ConsumerState<CommunityCoursePlayerPage> {
  late bool _introCompleted;
  final Map<String, String> _single = <String, String>{};
  final Map<String, Set<String>> _multi = <String, Set<String>>{};
  final Map<String, Map<String, String>> _matching =
      <String, Map<String, String>>{};
  final Map<String, List<String>> _drag = <String, List<String>>{};
  final Map<String, TextEditingController> _inputs =
      <String, TextEditingController>{};
  final Set<String> _attempted = <String>{};
  final Set<String> _correct = <String>{};

  @override
  void initState() {
    super.initState();
    _introCompleted = widget.skipIntro;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(demoAppControllerProvider.notifier);
      final state = ref.read(demoAppControllerProvider);
      if (!state.enrolledCommunityCourseIds.contains(widget.courseId)) {
        controller.enrollCommunityCourse(widget.courseId);
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _inputs.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final course = catalog.courseById(widget.courseId);
    final progress = catalog.coursePlayerProgressFor(state, widget.courseId);
    final lesson = catalog.currentCourseLessonFor(state, widget.courseId);

    if (progress == null || lesson == null) {
      return AppPageScaffold(
        title: course.title.en,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final lessons = <CoursePlayerLesson>[
      for (final module in course.coursePlayerModules) ...module.lessons,
    ];
    final totalPoints = catalog.totalCoursePlayerPoints(course.id);
    final earnedPoints = catalog.earnedCoursePlayerPoints(state, course.id);
    final percent = catalog.coursePlayerCompletionPercent(state, course.id);

    final content = _buildContent(
      context,
      controller,
      course,
      progress,
      lesson,
      lessons,
      earnedPoints,
      totalPoints,
      percent,
    );

    if (!_introCompleted && context.isCompactLayout) {
      return AppPageScaffold(
        title: course.title.en,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _heroCard(course, lesson, earnedPoints, totalPoints, percent, compact: true),
            const SizedBox(height: 16),
            _objectiveCard(lesson),
            const SizedBox(height: 16),
            _mediaCard(course, lesson),
            const SizedBox(height: 16),
            _codeCard(lesson),
            const SizedBox(height: 16),
            AppButton.secondary(
              label: context.l10n.text('ask_ai_inline'),
              icon: Icons.smart_toy_rounded,
              onPressed: () => _openInlineAi(context, controller, course),
            ),
            const SizedBox(height: 10),
            AppButton.primary(
              label: context.l10n.text('next_step'),
              icon: Icons.arrow_forward_rounded,
              onPressed: () => setState(() => _introCompleted = true),
            ),
          ],
        ),
      );
    }

    return AppPageScaffold(
      maxContentWidth: context.isWideLayout ? 1380 : 1040,
      child: context.isCompactLayout
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: content,
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: context.isWideLayout ? 320 : 290,
                  child: GlowCard(
                    accent: course.color,
                    child: _sidebar(course, lesson.id, progress, earnedPoints, totalPoints, percent),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(child: content),
              ],
            ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DemoAppController controller,
    CommunityCourse course,
    CoursePlayerProgress progress,
    CoursePlayerLesson lesson,
    List<CoursePlayerLesson> lessons,
    int earnedPoints,
    int totalPoints,
    int percent,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
      children: [
        _heroCard(course, lesson, earnedPoints, totalPoints, percent),
        const SizedBox(height: 16),
        _objectiveCard(lesson),
        const SizedBox(height: 16),
        _mediaCard(course, lesson),
        const SizedBox(height: 16),
        _codeCard(lesson),
        const SizedBox(height: 16),
        ...lesson.exercises.map(
          (exercise) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _exerciseCard(course, exercise),
          ),
        ),
        _commentsCard(course, lesson),
        const SizedBox(height: 16),
        GlowCard(
          accent: context.appColors.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.text('course_player_task'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                lesson.nextActionLabel.resolve(context.l10n.locale),
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              AppButton.secondary(
                label: context.l10n.text('ask_ai_inline'),
                icon: Icons.smart_toy_rounded,
                onPressed: () => _openInlineAi(context, controller, course),
              ),
              const SizedBox(height: 10),
              AppButton.primary(
                label: progress.isCompleted
                    ? context.l10n.text('course_completed')
                    : context.l10n.text('next_step'),
                icon: progress.isCompleted
                    ? Icons.workspace_premium_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: progress.isCompleted || !_lessonAttempted(lesson)
                    ? null
                    : () => _continueLesson(
                          controller: controller,
                          course: course,
                          progress: progress,
                          lesson: lesson,
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sidebar(
    CommunityCourse course,
    String currentLessonId,
    CoursePlayerProgress progress,
    int earnedPoints,
    int totalPoints,
    int percent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(course.title.en, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _pill('XP', '$earnedPoints/$totalPoints'),
            _pill('%', '$percent'),
          ],
        ),
        const SizedBox(height: 18),
        for (final module in course.coursePlayerModules) ...[
          Text(
            module.title.resolve(context.l10n.locale),
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...module.lessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: lesson.id == currentLessonId
                      ? course.color.withValues(alpha: 0.14)
                      : context.appColors.surfaceSoft,
                  border: Border.all(
                    color: lesson.id == currentLessonId
                        ? course.color
                        : context.appColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      progress.completedLessonIds.contains(lesson.id)
                          ? Icons.check_circle_rounded
                          : lesson.id == currentLessonId
                              ? Icons.play_circle_fill_rounded
                              : Icons.radio_button_unchecked_rounded,
                      color: progress.completedLessonIds.contains(lesson.id)
                          ? context.appColors.success
                          : lesson.id == currentLessonId
                              ? course.color
                              : context.appColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lesson.title.resolve(context.l10n.locale),
                        style: TextStyle(
                          color: context.appColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _heroCard(
    CommunityCourse course,
    CoursePlayerLesson lesson,
    int earnedPoints,
    int totalPoints,
    int percent, {
    bool compact = false,
  }) {
    return GlowCard(
      accent: course.color,
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title.en,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  lesson.title.resolve(context.l10n.locale),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill('XP', '$earnedPoints/$totalPoints'),
                    _pill('%', '$percent'),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title.en,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        lesson.title.resolve(context.l10n.locale),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        lesson.annotation.resolve(context.l10n.locale),
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pill('XP', '$earnedPoints/$totalPoints'),
                          _pill('%', '$percent'),
                          _pill(
                            context.l10n.text('course_tab_modules'),
                            '${course.coursePlayerModules.length}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(flex: 2, child: _mediaCard(course, lesson)),
              ],
            ),
    );
  }

  Widget _objectiveCard(CoursePlayerLesson lesson) {
    return GlowCard(
      accent: context.appColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.objective.resolve(context.l10n.locale),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            lesson.explanation.resolve(context.l10n.locale),
            style: TextStyle(
              color: context.appColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaCard(CommunityCourse course, CoursePlayerLesson lesson) {
    return GlowCard(
      accent: course.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    course.color.withValues(alpha: 0.32),
                    context.appColors.backgroundElevated,
                    context.appColors.surface,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor:
                          context.appColors.surface.withValues(alpha: 0.9),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: course.color,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lesson.videoLabel,
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lesson.imageCaption,
            style: TextStyle(
              color: context.appColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeCard(CoursePlayerLesson lesson) {
    return GlowCard(
      accent: context.appColors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('lesson_code_example'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: context.appColors.backgroundElevated,
              border: Border.all(color: context.appColors.divider),
            ),
            child: SelectableText(
              lesson.codeSnippet,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.text('lesson_expected_output'),
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: context.appColors.surfaceSoft,
            ),
            child: SelectableText(
              lesson.exampleOutput,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseCard(CommunityCourse course, CoursePlayerExercise exercise) {
    final attempted = _attempted.contains(exercise.id);
    final solved = _correct.contains(exercise.id);
    final accent = solved
        ? context.appColors.success
        : attempted
            ? context.appColors.accent
            : course.color;
    final controller = _inputs.putIfAbsent(exercise.id, TextEditingController.new);
    final matching = _matching.putIfAbsent(exercise.id, () => <String, String>{});
    final order = _drag.putIfAbsent(
      exercise.id,
      () => List<String>.from(exercise.draggableItems),
    );

    return StatefulBuilder(
      builder: (context, setCardState) {
        return GlowCard(
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.title.resolve(context.l10n.locale),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _pill('XP', '${exercise.points}'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exercise.prompt.resolve(context.l10n.locale),
                style: TextStyle(
                  color: context.appColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              if (exercise.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  exercise.description,
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (exercise.kind == CourseExerciseKind.singleChoice)
                Column(
                  children: exercise.choices
                      .map(
                        (choice) {
                          final selected = _single[exercise.id] == choice.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () {
                                setState(() => _single[exercise.id] = choice.id);
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: selected
                                      ? course.color.withValues(alpha: 0.12)
                                      : context.appColors.surfaceSoft,
                                  border: Border.all(
                                    color: selected
                                        ? course.color
                                        : context.appColors.divider,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color: selected
                                          ? course.color
                                          : context.appColors.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        choice.label,
                                        style: TextStyle(
                                          color: context.appColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                      .toList(growable: false),
                )
              else if (exercise.kind == CourseExerciseKind.multipleChoice)
                Column(
                  children: exercise.choices
                      .map(
                        (choice) => CheckboxListTile(
                          value: (_multi[exercise.id] ?? <String>{})
                              .contains(choice.id),
                          onChanged: (_) {
                            setState(() {
                              final selected = _multi.putIfAbsent(
                                exercise.id,
                                () => <String>{},
                              );
                              if (!selected.add(choice.id)) {
                                selected.remove(choice.id);
                              }
                            });
                          },
                          title: Text(choice.label),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      )
                      .toList(growable: false),
                )
              else if (exercise.kind == CourseExerciseKind.matching)
                Column(
                  children: exercise.leftItems
                      .map(
                        (left) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  left,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: matching[left],
                                  items: exercise.rightItems
                                      .map(
                                        (item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(item),
                                        ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => matching[left] = value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                )
              else if (exercise.kind == CourseExerciseKind.dragDrop)
                SizedBox(
                  height: (order.length * 62).toDouble(),
                  child: ReorderableListView(
                    buildDefaultDragHandles: false,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIndex, newIndex) {
                      setCardState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = order.removeAt(oldIndex);
                        order.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (var index = 0; index < order.length; index++)
                        ListTile(
                          key: ValueKey('${exercise.id}_${order[index]}'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          tileColor: context.appColors.surfaceSoft,
                          title: Text(order[index]),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_indicator_rounded),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (exercise.inputTemplate != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: context.appColors.backgroundElevated,
                          border: Border.all(color: context.appColors.divider),
                        ),
                        child: SelectableText(
                          exercise.inputTemplate ?? '',
                          style: TextStyle(
                            color: context.appColors.textPrimary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(controller: controller),
                  ],
                ),
              const SizedBox(height: 14),
              AppButton.primary(
                label: solved
                    ? context.l10n.text('lesson_solved')
                    : context.l10n.text('lesson_check_answer'),
                icon: solved
                    ? Icons.check_circle_rounded
                    : Icons.task_alt_rounded,
                onPressed: () => _checkExercise(course, exercise),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _commentsCard(CommunityCourse course, CoursePlayerLesson lesson) {
    return GlowCard(
      accent: context.appColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('course_reviews'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...lesson.comments.map(
            (comment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: context.appColors.surfaceSoft,
                  border: Border.all(color: context.appColors.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: course.color.withValues(alpha: 0.16),
                      child: Text(
                        comment.authorName.substring(0, 1),
                        style: TextStyle(
                          color: course.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.authorName,
                            style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.role,
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comment.message,
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: context.appColors.surfaceSoft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  bool _lessonAttempted(CoursePlayerLesson lesson) {
    return lesson.exercises.every(_attempted.contains);
  }

  void _checkExercise(CommunityCourse course, CoursePlayerExercise exercise) {
    final correct = switch (exercise.kind) {
      CourseExerciseKind.singleChoice =>
        _single[exercise.id] == exercise.correctChoiceIds.first,
      CourseExerciseKind.multipleChoice =>
        _setEquals(
          _multi[exercise.id] ?? <String>{},
          exercise.correctChoiceIds.toSet(),
        ),
      CourseExerciseKind.matching =>
        _mapEquals(
          _matching[exercise.id] ?? <String, String>{},
          exercise.correctMatches,
        ),
      CourseExerciseKind.dragDrop =>
        _listEquals(
          _drag[exercise.id] ?? exercise.draggableItems,
          exercise.correctOrder,
        ),
      CourseExerciseKind.textInput =>
        _normalized(_inputs[exercise.id]?.text ?? '') ==
            _normalized(exercise.correctAnswer),
    };

    setState(() {
      _attempted.add(exercise.id);
      if (correct) {
        _correct.add(exercise.id);
      }
    });

    AppNotice.show(
      context,
      message: correct
          ? '${exercise.title.resolve(context.l10n.locale)} • ${context.l10n.text('lesson_quiz_correct')}'
          : context.l10n.text('lesson_quiz_retry'),
      type: correct ? AppNoticeType.success : AppNoticeType.error,
    );
  }

  Future<void> _continueLesson({
    required DemoAppController controller,
    required CommunityCourse course,
    required CoursePlayerProgress progress,
    required CoursePlayerLesson lesson,
  }) async {
    final lessonExerciseIds =
        lesson.exercises.map((exercise) => exercise.id).toSet();
    final correctIds = lessonExerciseIds.intersection(_correct);
    final incorrectIds = lessonExerciseIds.difference(correctIds);
    final newCorrectIds = correctIds.difference(progress.correctExerciseIds);
    final earnedPointsDelta = lesson.exercises
        .where((exercise) => newCorrectIds.contains(exercise.id))
        .fold<int>(0, (sum, exercise) => sum + exercise.points);

    final updated = controller.advanceCoursePlayer(
      courseId: course.id,
      lessonId: lesson.id,
      attemptedExerciseIds: lessonExerciseIds,
      correctExerciseIds: correctIds,
      incorrectExerciseIds: incorrectIds,
      earnedPointsDelta: earnedPointsDelta,
    );

    if (!mounted) {
      return;
    }
    final nextState = ref.read(demoAppControllerProvider);
    final percent = ref
        .read(demoCatalogProvider)
        .coursePlayerCompletionPercent(nextState, course.id);
    AppNotice.show(
      context,
      message: updated.completedAt != null && percent >= 70
          ? context.l10n.text('course_certificate_earned_notice')
          : '${context.l10n.text('course_completed')} • $percent%',
      type: updated.completedAt != null && percent >= 70
          ? AppNoticeType.success
          : AppNoticeType.info,
    );
  }

  Future<void> _openInlineAi(
    BuildContext context,
    DemoAppController controller,
    CommunityCourse course,
  ) async {
    final promptController = TextEditingController();
    String reply = '';
    await showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 560,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdaptivePanelHandle(),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.text('ask_ai_inline'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.title.en,
                    style: TextStyle(color: context.appColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: promptController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: context.l10n.text('course_ai_prompt_hint'),
                    ),
                  ),
                  if (reply.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.appColors.surfaceSoft,
                        border:
                            Border.all(color: context.appColors.divider),
                      ),
                      child: Text(
                        reply,
                        style: TextStyle(
                          color: context.appColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(context.l10n.text('close')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final answer = controller.askInlineCourseAi(
                              courseId: course.id,
                              prompt: promptController.text,
                            );
                            if (answer.isEmpty) {
                              return;
                            }
                            setModalState(() => reply = answer);
                          },
                          child: Text(context.l10n.text('send_message')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _normalized(String value) => value.trim().toLowerCase();

  bool _setEquals(Set<String> left, Set<String> right) =>
      left.length == right.length && left.containsAll(right);

  bool _listEquals(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }

  bool _mapEquals(Map<String, String> left, Map<String, String> right) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in right.entries) {
      if (left[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}
