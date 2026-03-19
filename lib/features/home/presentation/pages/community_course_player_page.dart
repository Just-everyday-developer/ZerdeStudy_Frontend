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
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final course = catalog.courseById(widget.courseId);
    final progress = catalog.coursePlayerProgressFor(state, widget.courseId);
    final currentLesson = catalog.currentCourseLessonFor(state, widget.courseId);
    final l10n = context.l10n;

    if (progress == null || currentLesson == null) {
      return AppPageScaffold(
        title: course.title.en,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final allLessons = <CoursePlayerLesson>[
      for (final module in course.coursePlayerModules) ...module.lessons,
    ];
    final isCompleted = progress.isCompleted;

    if (context.isCompactLayout && !_introCompleted) {
      return AppPageScaffold(
        title: course.title.en,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            GlowCard(
              accent: course.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title.en,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course.description.en,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.text('course_player_intro'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...course.learningOutcomes.take(3).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_rounded, color: course.color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: context.appColors.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                  _LessonCodePanel(
                    title: currentLesson.title.resolve(state.locale),
                    annotation: currentLesson.annotation.resolve(state.locale),
                    explanation: currentLesson.explanation.resolve(state.locale),
                    codeSnippet: currentLesson.codeSnippet,
                    exampleOutput: currentLesson.exampleOutput,
                    accent: course.color,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.secondary(
                          label: l10n.text('ask_ai_inline'),
                          icon: Icons.smart_toy_rounded,
                          onPressed: () => _openInlineAi(context, controller, course),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.primary(
                          label: l10n.text('next_step'),
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            setState(() => _introCompleted = true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (context.isCompactLayout) {
      return AppPageScaffold(
        title: course.title.en,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _CompactPlayerProgress(
              course: course,
              currentIndex: allLessons.indexWhere((lesson) => lesson.id == currentLesson.id),
              totalLessons: allLessons.length,
            ),
            const SizedBox(height: 16),
            _LessonCodePanel(
              title: currentLesson.title.resolve(state.locale),
              annotation: currentLesson.annotation.resolve(state.locale),
              explanation: currentLesson.explanation.resolve(state.locale),
              codeSnippet: currentLesson.codeSnippet,
              exampleOutput: currentLesson.exampleOutput,
              accent: course.color,
            ),
            const SizedBox(height: 16),
            GlowCard(
              accent: context.appColors.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('course_player_task'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentLesson.nextActionLabel.resolve(state.locale),
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton.secondary(
                    label: l10n.text('ask_ai_inline'),
                    icon: Icons.smart_toy_rounded,
                    onPressed: () => _openInlineAi(context, controller, course),
                  ),
                  const SizedBox(height: 10),
                  AppButton.primary(
                    label: isCompleted
                        ? l10n.text('course_completed')
                        : l10n.text('next_step'),
                    icon: isCompleted
                        ? Icons.workspace_premium_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: isCompleted
                        ? null
                        : () {
                            final updated = controller.advanceCoursePlayer(
                              courseId: course.id,
                              lessonId: currentLesson.id,
                            );
                            if (updated.completedAt != null) {
                              AppNotice.show(
                                context,
                                message: l10n.text('course_certificate_earned_notice'),
                                type: AppNoticeType.success,
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AppPageScaffold(
      maxContentWidth: context.isWideLayout ? 1360 : 1040,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.isWideLayout ? 320 : 280,
            child: GlowCard(
              accent: course.color,
              child: _CoursePlayerSidebar(
                course: course,
                currentLessonId: currentLesson.id,
                completedLessonIds: progress.completedLessonIds,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
              children: [
                GlowCard(
                  accent: course.color,
                  child: Row(
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
                              currentLesson.title.resolve(state.locale),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentLesson.annotation.resolve(state.locale),
                              style: TextStyle(
                                color: context.appColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _PlayerMetaPill(
                                  icon: Icons.menu_book_rounded,
                                  label:
                                      '${progress.completedLessonIds.length}/${allLessons.length} ${l10n.text('lessons')}',
                                ),
                                _PlayerMetaPill(
                                  icon: Icons.workspace_premium_rounded,
                                  label: course.facts.certificateLabel,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 2,
                        child: _LessonPreviewPanel(
                          course: course,
                          lesson: currentLesson,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _LessonCodePanel(
                  title: currentLesson.title.resolve(state.locale),
                  annotation: currentLesson.annotation.resolve(state.locale),
                  explanation: currentLesson.explanation.resolve(state.locale),
                  codeSnippet: currentLesson.codeSnippet,
                  exampleOutput: currentLesson.exampleOutput,
                  accent: course.color,
                ),
                const SizedBox(height: 16),
                GlowCard(
                  accent: context.appColors.accent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.text('course_player_task'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentLesson.nextActionLabel.resolve(state.locale),
                              style: TextStyle(
                                color: context.appColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Column(
                          children: [
                            AppButton.secondary(
                              label: l10n.text('ask_ai_inline'),
                              icon: Icons.smart_toy_rounded,
                              onPressed: () => _openInlineAi(context, controller, course),
                            ),
                            const SizedBox(height: 10),
                            AppButton.primary(
                              label: isCompleted
                                  ? l10n.text('course_completed')
                                  : l10n.text('next_step'),
                              icon: isCompleted
                                  ? Icons.workspace_premium_rounded
                                  : Icons.arrow_forward_rounded,
                              onPressed: isCompleted
                                  ? null
                                  : () {
                                      final updated = controller.advanceCoursePlayer(
                                        courseId: course.id,
                                        lessonId: currentLesson.id,
                                      );
                                      if (updated.completedAt != null) {
                                        AppNotice.show(
                                          context,
                                          message: l10n.text('course_certificate_earned_notice'),
                                          type: AppNoticeType.success,
                                        );
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.appColors.surfaceSoft,
                        border: Border.all(color: context.appColors.divider),
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
}

class _CompactPlayerProgress extends StatelessWidget {
  const _CompactPlayerProgress({
    required this.course,
    required this.currentIndex,
    required this.totalLessons,
  });

  final CommunityCourse course;
  final int currentIndex;
  final int totalLessons;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: course.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title.en,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.format(
              'course_player_step',
              <String, Object>{
                'current': currentIndex < 0 ? 1 : currentIndex + 1,
                'total': totalLessons,
              },
            ),
            style: TextStyle(color: context.appColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CoursePlayerSidebar extends StatelessWidget {
  const _CoursePlayerSidebar({
    required this.course,
    required this.currentLessonId,
    required this.completedLessonIds,
  });

  final CommunityCourse course;
  final String currentLessonId;
  final Set<String> completedLessonIds;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title.en,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          course.subtitle.en,
          style: TextStyle(color: colors.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 18),
        for (final module in course.coursePlayerModules) ...[
          Text(
            module.title.en,
            style: TextStyle(
              color: colors.textPrimary,
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
                      : colors.surfaceSoft,
                  border: Border.all(
                    color: lesson.id == currentLessonId
                        ? course.color
                        : colors.divider,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      completedLessonIds.contains(lesson.id)
                          ? Icons.check_circle_rounded
                          : lesson.id == currentLessonId
                              ? Icons.play_circle_fill_rounded
                              : Icons.radio_button_unchecked_rounded,
                      color: completedLessonIds.contains(lesson.id)
                          ? colors.success
                          : lesson.id == currentLessonId
                              ? course.color
                              : colors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lesson.title.en,
                        style: TextStyle(
                          color: colors.textPrimary,
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
}

class _LessonPreviewPanel extends StatelessWidget {
  const _LessonPreviewPanel({
    required this.course,
    required this.lesson,
  });

  final CommunityCourse course;
  final CoursePlayerLesson lesson;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            course.color.withValues(alpha: 0.26),
            colors.surfaceSoft,
            colors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: colors.backgroundElevated,
              ),
              child: Center(
                child: Icon(
                  Icons.play_lesson_rounded,
                  color: course.color,
                  size: 52,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            lesson.title.en,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            lesson.annotation.en,
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCodePanel extends StatelessWidget {
  const _LessonCodePanel({
    required this.title,
    required this.annotation,
    required this.explanation,
    required this.codeSnippet,
    required this.exampleOutput,
    required this.accent,
  });

  final String title;
  final String annotation;
  final String explanation;
  final String codeSnippet;
  final String exampleOutput;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GlowCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            annotation,
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: colors.backgroundElevated,
              border: Border.all(color: colors.divider),
            ),
            child: SelectableText(
              codeSnippet,
              style: TextStyle(
                color: colors.textPrimary,
                height: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            explanation,
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colors.surfaceSoft,
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.text('lesson_expected_output'),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  exampleOutput,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerMetaPill extends StatelessWidget {
  const _PlayerMetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceSoft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
