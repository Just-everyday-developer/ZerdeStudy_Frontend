import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/adaptive_panel.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';

class CommunityCourseDetailPage extends ConsumerStatefulWidget {
  const CommunityCourseDetailPage({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CommunityCourseDetailPage> createState() =>
      _CommunityCourseDetailPageState();
}

class _CommunityCourseDetailPageState
    extends ConsumerState<CommunityCourseDetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  final List<CommunityCourseReview> _localReviews = <CommunityCourseReview>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(demoAppControllerProvider.notifier)
          .viewCommunityCourse(widget.courseId);
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final backendCourses = ref.watch(backendPublishedCoursesProvider);
    final backendCourseDetail = ref.watch(
      backendCourseDetailProvider(widget.courseId),
    );
    final detailedBackendCourse = backendCourseDetail.maybeWhen(
      data: (course) => course,
      orElse: () => null,
    );
    final course = _resolveCourse(
      catalog: catalog,
      detailedBackendCourse: detailedBackendCourse,
      backendCourses: backendCourses.maybeWhen(
        data: (courses) => courses,
        orElse: () => null,
      ),
    );
    if (course == null) {
      final colors = context.appColors;
      final loading = backendCourses.isLoading || backendCourseDetail.isLoading;

      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: loading
              ? const CircularProgressIndicator()
              : Text(
                  'Course unavailable',
                  style: TextStyle(color: colors.textPrimary),
                ),
        ),
      );
    }
    final saved = state.savedCommunityCourseIds.contains(widget.courseId);
    final enrolled = state.enrolledCommunityCourseIds.contains(widget.courseId);
    final userRating = state.courseRatingsByCourseId[widget.courseId];
    final reviewSummary = catalog.displayCourseReviewSummaryForCourse(
      state,
      course,
    );
    final backendPreviewEnabled =
        detailedBackendCourse?.supportsCoursePlayer ?? false;
    final reviews = <CommunityCourseReview>[
      ..._localReviews,
      ...course.reviews,
    ];
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _CourseDetailBackdrop()),
          SafeArea(
            child: context.isCompactLayout
                ? _CompactCourseDetailLayout(
                    course: course,
                    saved: saved,
                    enrolled: enrolled,
                    reviewSummary: reviewSummary,
                    userRating: userRating,
                    reviews: reviews,
                    commentController: _reviewController,
                    onSave: () => controller.toggleSavedCommunityCourse(
                      widget.courseId,
                      course: course,
                    ),
                    onRate: (stars) => controller.rateCommunityCourse(
                      widget.courseId,
                      stars,
                      courseOverride: course,
                    ),
                    onSubmitComment: () =>
                        _submitReview(state.user?.name ?? 'Talgat', userRating),
                    onPrimaryTap: () => _handlePrimaryTap(
                      context,
                      course,
                      controller,
                      useBackendPreview: backendPreviewEnabled,
                    ),
                  )
                : _WideCourseDetailLayout(
                    course: course,
                    saved: saved,
                    enrolled: enrolled,
                    reviewSummary: reviewSummary,
                    userRating: userRating,
                    reviews: reviews,
                    commentController: _reviewController,
                    onSave: () => controller.toggleSavedCommunityCourse(
                      widget.courseId,
                      course: course,
                    ),
                    onRate: (stars) => controller.rateCommunityCourse(
                      widget.courseId,
                      stars,
                      courseOverride: course,
                    ),
                    onSubmitComment: () =>
                        _submitReview(state.user?.name ?? 'Talgat', userRating),
                    onPrimaryTap: () => _handlePrimaryTap(
                      context,
                      course,
                      controller,
                      useBackendPreview: backendPreviewEnabled,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  CommunityCourse? _resolveCourse({
    required DemoCatalog catalog,
    required CommunityCourse? detailedBackendCourse,
    required List<CommunityCourse>? backendCourses,
  }) {
    if (detailedBackendCourse != null) {
      return detailedBackendCourse;
    }

    for (final course in backendCourses ?? const <CommunityCourse>[]) {
      if (course.id == widget.courseId) {
        return course;
      }
    }

    return catalog.maybeCourseById(widget.courseId);
  }

  void _submitReview(String authorName, int? userRating) {
    final text = _reviewController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _localReviews.insert(
        0,
        CommunityCourseReview(
          id: 'local_review_${DateTime.now().microsecondsSinceEpoch}',
          authorName: authorName,
          timeLabel: 'now',
          rating: userRating ?? 5,
          text: text,
        ),
      );
      _reviewController.clear();
    });
  }

  Future<void> _handlePrimaryTap(
    BuildContext context,
    CommunityCourse course,
    DemoAppController controller, {
    bool useBackendPreview = false,
  }) async {
    if (useBackendPreview) {
      controller.enrollCommunityCourse(course.id, courseOverride: course);
      await _openBackendPreview(context, course);
      return;
    }

    if (!course.supportsCoursePlayer) {
      AppNotice.show(
        context,
        message: context.l10n.text('course_preview_notice'),
        type: AppNoticeType.info,
      );
      return;
    }

    if (context.isCompactLayout) {
      controller.enrollCommunityCourse(course.id);
      if (!context.mounted) {
        return;
      }
      context.push(AppRoutes.coursePlayerById(course.id));
      return;
    }

    await showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 620,
      builder: (panelContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdaptivePanelHandle(),
              const SizedBox(height: 18),
              Text(
                context.l10n.text('course_enroll_title'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                course.title.en,
                style: TextStyle(
                  color: context.appColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.text('course_enroll_body'),
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              ...course.learningOutcomes
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
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
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(panelContext).pop(),
                      child: Text(panelContext.l10n.text('close')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        controller.enrollCommunityCourse(course.id);
                        Navigator.of(panelContext).pop();
                        context.push(
                          AppRoutes.coursePlayerById(
                            course.id,
                            skipIntro: true,
                          ),
                        );
                      },
                      child: Text(panelContext.l10n.text('course_start_now')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openBackendPreview(
    BuildContext context,
    CommunityCourse course,
  ) {
    return showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 1100,
      builder: (context) => _BackendCoursePreviewPanel(course: course),
    );
  }
}

class _BackendCoursePreviewPanel extends StatefulWidget {
  const _BackendCoursePreviewPanel({required this.course});

  final CommunityCourse course;

  @override
  State<_BackendCoursePreviewPanel> createState() =>
      _BackendCoursePreviewPanelState();
}

class _BackendCoursePreviewPanelState
    extends State<_BackendCoursePreviewPanel> {
  late final List<_BackendPreviewLessonEntry> _entries;
  late String? _selectedLessonId;

  @override
  void initState() {
    super.initState();
    _entries = <_BackendPreviewLessonEntry>[
      for (final module in widget.course.coursePlayerModules)
        for (final lesson in module.lessons)
          _BackendPreviewLessonEntry(module: module, lesson: lesson),
    ];
    _selectedLessonId = _entries.isEmpty ? null : _entries.first.lesson.id;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = context.isCompactLayout;
    final height = compact ? MediaQuery.of(context).size.height * 0.92 : 720.0;
    final currentEntry = _currentEntry;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdaptivePanelHandle(),
            const SizedBox(height: 18),
            Text(
              widget.course.title.resolve(context.l10n.locale),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.course.subtitle.resolve(context.l10n.locale),
              style: TextStyle(color: colors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _PreviewStatChip(
                  icon: Icons.layers_rounded,
                  label:
                      '${widget.course.coursePlayerModules.length} ${context.l10n.text('course_tab_modules')}',
                ),
                _PreviewStatChip(
                  icon: Icons.menu_book_rounded,
                  label: '${_entries.length} ${context.l10n.text('lessons')}',
                ),
                _PreviewStatChip(
                  icon: Icons.workspace_premium_rounded,
                  label: widget.course.facts.certificateLabel,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (currentEntry == null)
              Expanded(
                child: Center(
                  child: Text(
                    'Lessons are not available for this course yet.',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              )
            else if (compact)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLessonId,
                      decoration: InputDecoration(
                        labelText: context.l10n.text('course_tab_modules'),
                      ),
                      items: _entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.lesson.id,
                              child: Text(
                                '${entry.module.title.resolve(context.l10n.locale)} - ${entry.lesson.title.resolve(context.l10n.locale)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _selectedLessonId = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _BackendPreviewLessonContent(
                          course: widget.course,
                          entry: currentEntry,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 320,
                      child: GlowCard(
                        accent: widget.course.color,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            for (final module
                                in widget.course.coursePlayerModules) ...[
                              Text(
                                module.title.resolve(context.l10n.locale),
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              for (final lesson in module.lessons)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _BackendPreviewLessonTile(
                                    title: lesson.title.resolve(
                                      context.l10n.locale,
                                    ),
                                    subtitle: module.title.resolve(
                                      context.l10n.locale,
                                    ),
                                    selected: lesson.id == _selectedLessonId,
                                    accent: widget.course.color,
                                    onTap: () => setState(
                                      () => _selectedLessonId = lesson.id,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _BackendPreviewLessonContent(
                          course: widget.course,
                          entry: currentEntry,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hasPrevious ? _selectPrevious : null,
                    child: const Text('Previous lesson'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _hasNext ? _selectNext : null,
                    child: Text(
                      _hasNext ? 'Next lesson' : context.l10n.text('close'),
                    ),
                  ),
                ),
              ],
            ),
            if (!_hasNext) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.text('close')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _BackendPreviewLessonEntry? get _currentEntry {
    for (final entry in _entries) {
      if (entry.lesson.id == _selectedLessonId) {
        return entry;
      }
    }
    return _entries.isEmpty ? null : _entries.first;
  }

  bool get _hasPrevious {
    final index = _selectedIndex;
    return index > 0;
  }

  bool get _hasNext {
    final index = _selectedIndex;
    return index >= 0 && index < _entries.length - 1;
  }

  int get _selectedIndex {
    return _entries.indexWhere((entry) => entry.lesson.id == _selectedLessonId);
  }

  void _selectPrevious() {
    final index = _selectedIndex;
    if (index <= 0) {
      return;
    }
    setState(() => _selectedLessonId = _entries[index - 1].lesson.id);
  }

  void _selectNext() {
    final index = _selectedIndex;
    if (index == -1 || index >= _entries.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _selectedLessonId = _entries[index + 1].lesson.id);
  }
}

class _BackendPreviewLessonEntry {
  const _BackendPreviewLessonEntry({
    required this.module,
    required this.lesson,
  });

  final CoursePlayerModule module;
  final CoursePlayerLesson lesson;
}

class _BackendPreviewLessonContent extends StatelessWidget {
  const _BackendPreviewLessonContent({
    required this.course,
    required this.entry,
  });

  final CommunityCourse course;
  final _BackendPreviewLessonEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final lesson = entry.lesson;
    final locale = context.l10n.locale;
    final keyPoints = lesson.explanation
        .resolve(locale)
        .split(RegExp(r'[.!?]\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .take(4)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlowCard(
          accent: course.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.module.title.resolve(locale),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lesson.title.resolve(locale),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                lesson.annotation.resolve(locale),
                style: TextStyle(color: colors.textSecondary, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlowCard(
          accent: colors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.text('course_what_you_will_learn'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                lesson.objective.resolve(locale),
                style: TextStyle(color: colors.textSecondary, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlowCard(
          accent: colors.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key takeaways',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (keyPoints.isEmpty)
                Text(
                  lesson.explanation.resolve(locale),
                  style: TextStyle(color: colors.textSecondary, height: 1.45),
                )
              else
                ...keyPoints.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: course.color,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlowCard(
          accent: colors.success,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lesson theory',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                lesson.explanation.resolve(locale),
                style: TextStyle(color: colors.textSecondary, height: 1.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlowCard(
          accent: colors.primary,
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
                  color: colors.backgroundElevated,
                  border: Border.all(color: colors.divider),
                ),
                child: SelectableText(
                  lesson.codeSnippet,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.text('lesson_expected_output'),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: colors.surfaceSoft,
                ),
                child: SelectableText(
                  lesson.exampleOutput,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackendPreviewLessonTile extends StatelessWidget {
  const _BackendPreviewLessonTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? accent.withValues(alpha: 0.12) : colors.surfaceSoft,
          border: Border.all(color: selected ? accent : colors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewStatChip extends StatelessWidget {
  const _PreviewStatChip({required this.icon, required this.label});

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

class _CompactCourseDetailLayout extends StatelessWidget {
  const _CompactCourseDetailLayout({
    required this.course,
    required this.saved,
    required this.enrolled,
    required this.reviewSummary,
    required this.reviews,
    required this.userRating,
    required this.commentController,
    required this.onSave,
    required this.onRate,
    required this.onSubmitComment,
    required this.onPrimaryTap,
  });

  final CommunityCourse course;
  final bool saved;
  final bool enrolled;
  final CommunityCourseReviewSummary reviewSummary;
  final List<CommunityCourseReview> reviews;
  final int? userRating;
  final TextEditingController commentController;
  final VoidCallback onSave;
  final ValueChanged<int> onRate;
  final VoidCallback onSubmitComment;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    _MobileHeroCard(
                      course: course,
                      saved: saved,
                      enrolled: enrolled,
                      reviewSummary: reviewSummary,
                      userRating: userRating,
                      onSave: onSave,
                      onRate: onRate,
                      onPrimaryTap: onPrimaryTap,
                    ),
                    const SizedBox(height: 16),
                    _CompactInfoContent(course: course),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _CompactTabHeaderDelegate(
                minExtentValue: 56,
                maxExtentValue: 56,
                child: Container(
                  color: colors.surface.withValues(alpha: 0.98),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: TabBar(
                    isScrollable: false,
                    indicatorColor: colors.primary,
                    labelColor: colors.textPrimary,
                    unselectedLabelColor: colors.textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: [
                      Tab(text: l10n.text('course_tab_reviews')),
                      Tab(text: l10n.text('course_tab_news')),
                      Tab(text: l10n.text('course_tab_modules')),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _CourseReviewsSection(
              course: course,
              compact: true,
              summary: reviewSummary,
              reviews: reviews,
              userRating: userRating,
              commentController: commentController,
              onRate: onRate,
              onSubmitComment: onSubmitComment,
            ),
            _CourseUpdatesSection(course: course, compact: true),
            _CourseProgramSection(course: course, compact: true),
          ],
        ),
      ),
    );
  }
}

class _WideCourseDetailLayout extends StatelessWidget {
  const _WideCourseDetailLayout({
    required this.course,
    required this.saved,
    required this.enrolled,
    required this.reviewSummary,
    required this.reviews,
    required this.userRating,
    required this.commentController,
    required this.onSave,
    required this.onRate,
    required this.onSubmitComment,
    required this.onPrimaryTap,
  });

  final CommunityCourse course;
  final bool saved;
  final bool enrolled;
  final CommunityCourseReviewSummary reviewSummary;
  final List<CommunityCourseReview> reviews;
  final int? userRating;
  final TextEditingController commentController;
  final VoidCallback onSave;
  final ValueChanged<int> onRate;
  final VoidCallback onSubmitComment;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.appPageMaxWidth;
    final horizontalPadding = context.appPageHorizontalPadding;
    final sidebarWidth = context.isWideLayout ? 360.0 : 300.0;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            24,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: context.appColors.textPrimary,
                        ),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                      ),
                      const SizedBox(height: 8),
                      _DesktopHeroCard(
                        course: course,
                        reviewSummary: reviewSummary,
                      ),
                      const SizedBox(height: 18),
                      _CourseTextSection(
                        title: context.l10n.text('course_about'),
                        child: Text(
                          course.description.en,
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CourseBulletSection(
                        title: context.l10n.text('course_what_you_will_learn'),
                        items: course.learningOutcomes,
                      ),
                      const SizedBox(height: 16),
                      _CourseProgramSection(course: course, compact: false),
                      const SizedBox(height: 16),
                      _CourseAudienceRequirementsSection(course: course),
                      const SizedBox(height: 16),
                      _CourseTeachersSection(course: course),
                      const SizedBox(height: 16),
                      _CourseCertificateSection(course: course),
                      const SizedBox(height: 16),
                      _CourseReviewsSection(
                        course: course,
                        compact: false,
                        summary: reviewSummary,
                        reviews: reviews,
                        userRating: userRating,
                        commentController: commentController,
                        onRate: onRate,
                        onSubmitComment: onSubmitComment,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              SizedBox(
                width: sidebarWidth,
                child: SingleChildScrollView(
                  child: _CourseSidebar(
                    course: course,
                    saved: saved,
                    enrolled: enrolled,
                    reviewSummary: reviewSummary,
                    userRating: userRating,
                    onSave: onSave,
                    onRate: onRate,
                    onPrimaryTap: onPrimaryTap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopHeroCard extends StatelessWidget {
  const _DesktopHeroCard({required this.course, required this.reviewSummary});

  final CommunityCourse course;
  final CommunityCourseReviewSummary reviewSummary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return GlowCard(
      accent: course.color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: course.color.withValues(alpha: 0.14),
                  ),
                  child: Text(
                    course.heroBadge,
                    style: TextStyle(
                      color: course.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  course.title.en,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  course.subtitle.en,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  course.description.en,
                  style: TextStyle(color: colors.textSecondary, height: 1.55),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroStatChip(
                      icon: Icons.signal_cellular_alt_rounded,
                      label: l10n.courseLevelLabel(course.level),
                      color: course.color,
                    ),
                    _HeroStatChip(
                      icon: Icons.workspace_premium_rounded,
                      label: course.facts.certificateLabel,
                      color: colors.success,
                    ),
                    _HeroStatChip(
                      icon: Icons.groups_rounded,
                      label:
                          '${course.enrollmentCount} ${l10n.text('enrolled')}',
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    course.color.withValues(alpha: 0.24),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: colors.surface.withValues(
                                alpha: 0.94,
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 38,
                                color: course.color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.text('course_preview_cta'),
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: course.color, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        reviewSummary.averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${reviewSummary.reviewCount} ${context.l10n.text('course_reviews_count')}',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileHeroCard extends StatelessWidget {
  const _MobileHeroCard({
    required this.course,
    required this.saved,
    required this.enrolled,
    required this.reviewSummary,
    required this.userRating,
    required this.onSave,
    required this.onRate,
    required this.onPrimaryTap,
  });

  final CommunityCourse course;
  final bool saved;
  final bool enrolled;
  final CommunityCourseReviewSummary reviewSummary;
  final int? userRating;
  final VoidCallback onSave;
  final ValueChanged<int> onRate;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontSize: 28, height: 1.1);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            course.color.withValues(alpha: 0.28),
            colors.surface,
            colors.backgroundElevated,
          ],
        ),
        border: Border.all(color: course.color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, right: 10),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: colors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  course.title.en,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onSave,
                icon: Icon(
                  saved
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: saved ? course.color : colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppButton.primary(
            label: enrolled
                ? context.l10n.text('course_open_cta')
                : context.l10n.text('course_primary_cta'),
            icon: Icons.play_circle_fill_rounded,
            maxWidth: null,
            onPressed: onPrimaryTap,
          ),
          const SizedBox(height: 14),
          Text(
            course.subtitle.en,
            style: TextStyle(color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.star_rounded, color: course.color, size: 18),
              const SizedBox(width: 6),
              Text(
                reviewSummary.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.groups_rounded, color: colors.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text(
                '${course.enrollmentCount}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactInfoContent extends StatelessWidget {
  const _CompactInfoContent({required this.course});

  final CommunityCourse course;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CourseTextSection(
          title: context.l10n.text('course_about'),
          child: Text(
            course.description.en,
            style: TextStyle(
              color: context.appColors.textSecondary,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _CourseBulletSection(
          title: context.l10n.text('course_what_you_will_learn'),
          items: course.learningOutcomes,
        ),
        const SizedBox(height: 16),
        _CourseAudienceRequirementsSection(course: course),
        const SizedBox(height: 16),
        _CourseTeachersSection(course: course),
        const SizedBox(height: 16),
        _CourseCertificateSection(course: course),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CompactTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _CompactTabHeaderDelegate({
    required this.minExtentValue,
    required this.maxExtentValue,
    required this.child,
  });

  final double minExtentValue;
  final double maxExtentValue;
  final Widget child;

  @override
  double get minExtent => minExtentValue;

  @override
  double get maxExtent => maxExtentValue;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _CompactTabHeaderDelegate oldDelegate) {
    return oldDelegate.minExtentValue != minExtentValue ||
        oldDelegate.maxExtentValue != maxExtentValue ||
        oldDelegate.child != child;
  }
}

class _CourseSidebar extends StatelessWidget {
  const _CourseSidebar({
    required this.course,
    required this.saved,
    required this.enrolled,
    required this.reviewSummary,
    required this.userRating,
    required this.onSave,
    required this.onRate,
    required this.onPrimaryTap,
  });

  final CommunityCourse course;
  final bool saved;
  final bool enrolled;
  final CommunityCourseReviewSummary reviewSummary;
  final int? userRating;
  final VoidCallback onSave;
  final ValueChanged<int> onRate;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return GlowCard(
      accent: course.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.offer.priceLabel,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star_rounded, color: course.color, size: 20),
              const SizedBox(width: 8),
              Text(
                reviewSummary.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${reviewSummary.reviewCount} ${l10n.text('course_reviews_count')}',
                style: TextStyle(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SidebarMeta(
            icon: Icons.pie_chart_rounded,
            label: course.offer.installmentLabel,
          ),
          const SizedBox(height: 8),
          _SidebarMeta(
            icon: Icons.stacked_line_chart_rounded,
            label: course.offer.secondaryInstallmentLabel,
          ),
          const SizedBox(height: 16),
          AppButton.primary(
            label: enrolled
                ? l10n.text('course_open_cta')
                : l10n.text('course_primary_cta'),
            icon: Icons.play_circle_fill_rounded,
            maxWidth: 260,
            onPressed: onPrimaryTap,
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: l10n.text('course_preview_cta'),
            icon: Icons.play_circle_outline_rounded,
            maxWidth: 260,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: saved
                ? l10n.text('saved_to_profile')
                : l10n.text('course_save_cta'),
            icon: saved
                ? Icons.check_circle_rounded
                : Icons.favorite_border_rounded,
            maxWidth: 260,
            onPressed: onSave,
          ),
          const SizedBox(height: 18),
          Text(
            l10n.text('course_start_mode'),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            course.facts.startModeLabel,
            style: TextStyle(color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: colors.surfaceSoft,
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('course_includes'),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _SidebarFactRow(
                  label: l10n.text('lessons'),
                  value: '${course.facts.lessonCount}',
                ),
                _SidebarFactRow(
                  label: l10n.text('course_video_time'),
                  value: '${course.facts.videoMinutes} min',
                ),
                _SidebarFactRow(
                  label: l10n.text('tree_assessments'),
                  value: '${course.facts.assessmentCount}',
                ),
                _SidebarFactRow(
                  label: l10n.text('course_interactive_items'),
                  value: '${course.facts.interactiveCount}',
                ),
                _SidebarFactRow(
                  label: l10n.text('locale'),
                  value: course.facts.languageLabel,
                ),
                _SidebarFactRow(
                  label: l10n.text('course_certificate'),
                  value: course.facts.certificateLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseTextSection extends StatelessWidget {
  const _CourseTextSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        child,
      ],
    );

    if (context.isCompactLayout) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colors.surface.withValues(alpha: 0.96),
        ),
        child: content,
      );
    }

    return GlowCard(accent: colors.primary, child: content);
  }
}

class _CourseBulletSection extends StatelessWidget {
  const _CourseBulletSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_rounded, color: colors.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(color: colors.textSecondary, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (context.isCompactLayout) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colors.surface.withValues(alpha: 0.96),
        ),
        child: content,
      );
    }

    return GlowCard(accent: colors.success, child: content);
  }
}

class _CourseProgramSection extends StatelessWidget {
  const _CourseProgramSection({required this.course, required this.compact});

  final CommunityCourse course;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: context.appColors.surface.withValues(alpha: 0.96),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.text('course_program'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                ...course.moduleSections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ProgramSectionCard(section: section, compact: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return GlowCard(
      accent: course.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('course_program'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...course.moduleSections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ProgramSectionCard(section: section, compact: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseAudienceRequirementsSection extends StatelessWidget {
  const _CourseAudienceRequirementsSection({required this.course});

  final CommunityCourse course;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: context.appColors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('course_audience_requirements'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          _AudienceBlock(
            title: context.l10n.text('course_audience'),
            items: course.audience,
          ),
          const SizedBox(height: 16),
          _AudienceBlock(
            title: context.l10n.text('course_requirements'),
            items: course.requirements,
          ),
        ],
      ),
    );
  }
}

class _CourseTeachersSection extends StatelessWidget {
  const _CourseTeachersSection({required this.course});

  final CommunityCourse course;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GlowCard(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('course_teachers'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...course.instructors.map(
            (instructor) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colors.surfaceSoft,
                  border: Border.all(color: colors.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: colors.primary.withValues(alpha: 0.16),
                      child: Text(
                        instructor.name.substring(0, 1),
                        style: TextStyle(
                          color: colors.primary,
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
                            instructor.name,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            instructor.role,
                            style: TextStyle(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            instructor.bio,
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _TeacherPill(
                                label:
                                    '${context.l10n.text('courses_label')} ${instructor.courseCount}',
                              ),
                              _TeacherPill(
                                label:
                                    '${context.l10n.text('followers')} ${instructor.studentCount}',
                              ),
                              _TeacherPill(
                                label: instructor.rating.toStringAsFixed(1),
                              ),
                            ],
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
}

class _CourseCertificateSection extends StatelessWidget {
  const _CourseCertificateSection({required this.course});

  final CommunityCourse course;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: context.appColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('course_certificate_outcomes'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            course.facts.certificateLabel,
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            course.heroHeadline,
            style: TextStyle(
              color: context.appColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseReviewsSection extends StatelessWidget {
  const _CourseReviewsSection({
    required this.course,
    required this.compact,
    required this.summary,
    required this.reviews,
    required this.userRating,
    required this.commentController,
    required this.onRate,
    required this.onSubmitComment,
  });

  final CommunityCourse course;
  final bool compact;
  final CommunityCourseReviewSummary summary;
  final List<CommunityCourseReview> reviews;
  final int? userRating;
  final TextEditingController commentController;
  final ValueChanged<int> onRate;
  final VoidCallback onSubmitComment;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final distribution = [5, 4, 3, 2, 1];
    final maxCount = summary.ratingDistribution.values.fold<int>(
      1,
      (a, b) => a > b ? a : b,
    );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.text('course_reviews'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.averageRating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: List<Widget>.generate(
                5,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: index < summary.averageRating.round()
                      ? course.color
                      : colors.divider,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${summary.reviewCount} ${context.l10n.text('course_reviews_count')}',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 14),
            ...distribution.map((rating) {
              final count = summary.ratingDistribution[rating] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      child: Text(
                        '$rating',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: count / maxCount,
                          minHeight: 9,
                          backgroundColor: colors.backgroundElevated,
                          color: course.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.end,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 18),
        _CourseRatingEditor(
          rating: userRating,
          accent: course.color,
          onRate: onRate,
        ),
        const SizedBox(height: 12),
        _ReviewFeedbackComposer(
          accent: course.color,
          controller: commentController,
          onSubmit: onSubmitComment,
        ),
        const SizedBox(height: 18),
        ...reviews.map(
          (review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colors.surfaceSoft,
                border: Border.all(color: colors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: course.color.withValues(alpha: 0.16),
                        child: Text(
                          review.authorName.substring(0, 1),
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
                              review.authorName,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              review.timeLabel,
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: List<Widget>.generate(
                          5,
                          (index) => Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: index < review.rating
                                ? course.color
                                : colors.divider,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (review.headline != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      review.headline!,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    review.text,
                    style: TextStyle(color: colors.textSecondary, height: 1.45),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (compact) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: colors.surface.withValues(alpha: 0.96),
            ),
            child: content,
          ),
        ],
      );
    }
    return GlowCard(accent: course.color, child: content);
  }
}

class _CourseRatingEditor extends StatelessWidget {
  const _CourseRatingEditor({
    required this.rating,
    required this.accent,
    required this.onRate,
  });

  final int? rating;
  final Color accent;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompactLayout;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.appColors.surfaceSoft,
        border: Border.all(color: context.appColors.divider),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.text('course_rate_prompt'),
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 4,
                  children: List<Widget>.generate(
                    5,
                    (index) => IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      tooltip: '${index + 1}',
                      onPressed: () => onRate(index + 1),
                      icon: Icon(
                        Icons.star_rounded,
                        color: (rating ?? 0) >= index + 1
                            ? accent
                            : context.appColors.divider,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.text('course_rate_prompt'),
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 4,
                  children: List<Widget>.generate(
                    5,
                    (index) => IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      tooltip: '${index + 1}',
                      onPressed: () => onRate(index + 1),
                      icon: Icon(
                        Icons.star_rounded,
                        color: (rating ?? 0) >= index + 1
                            ? accent
                            : context.appColors.divider,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ReviewFeedbackComposer extends StatelessWidget {
  const _ReviewFeedbackComposer({
    required this.accent,
    required this.controller,
    required this.onSubmit,
  });

  final Color accent;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _reviewCommentPrompt(context.l10n.locale),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: _reviewCommentHint(context.l10n.locale),
              filled: true,
              fillColor: colors.backgroundElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accent),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                onSubmit();
              },
              child: Text(context.l10n.text('send_review')),
            ),
          ),
        ],
      ),
    );
  }
}

String _reviewCommentPrompt(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Расскажите почему',
    AppLocale.en => 'Tell us why',
    AppLocale.kk => 'Неге екенін жазыңыз',
  };
}

String _reviewCommentHint(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Напишите комментарий',
    AppLocale.en => 'Write a comment',
    AppLocale.kk => 'Пікір жазыңыз',
  };
}

class _CourseUpdatesSection extends StatelessWidget {
  const _CourseUpdatesSection({required this.course, required this.compact});

  final CommunityCourse course;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: colors.surface.withValues(alpha: 0.96),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('course_news'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          ...course.updates.map(
            (update) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colors.surfaceSoft,
                  border: Border.all(color: colors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      update.timeLabel,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      update.summary,
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.45,
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

    if (compact) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [content],
      );
    }
    return content;
  }
}

class _ProgramSectionCard extends StatelessWidget {
  const _ProgramSectionCard({required this.section, required this.compact});

  final CommunityCourseModuleSection section;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            section.description,
            style: TextStyle(color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 12),
          ...section.items.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colors.backgroundElevated,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colors.surface,
                      ),
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.title,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _TeacherPill(label: entry.value.durationLabel),
                              _TeacherPill(label: '${entry.value.viewerCount}'),
                              if (!compact)
                                _TeacherPill(
                                  label: '${entry.value.helpfulCount}',
                                ),
                            ],
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
}

class _AudienceBlock extends StatelessWidget {
  const _AudienceBlock({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              item,
              style: TextStyle(color: colors.textSecondary, height: 1.45),
            ),
          ),
        ),
      ],
    );
  }
}

class _TeacherPill extends StatelessWidget {
  const _TeacherPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: context.appColors.backgroundElevated,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.appColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SidebarMeta extends StatelessWidget {
  const _SidebarMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceSoft,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarFactRow extends StatelessWidget {
  const _SidebarFactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

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
          Icon(icon, size: 16, color: color),
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

class _CourseDetailBackdrop extends StatelessWidget {
  const _CourseDetailBackdrop();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors.pageGradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -50,
            child: _GlowOrb(
              color: colors.primary.withValues(alpha: 0.18),
              size: 220,
            ),
          ),
          Positioned(
            top: 160,
            right: -60,
            child: _GlowOrb(
              color: colors.accent.withValues(alpha: 0.14),
              size: 200,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: color.a * 0.25),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
