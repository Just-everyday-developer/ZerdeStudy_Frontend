import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/data/models/backend_lesson_dto.dart';
import '../../../courses_backend/data/models/backend_practice_dto.dart';
import '../../../courses_backend/data/models/backend_quiz_dto.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';

const Map<String, String> oopVideoUrls = {
  'ee010101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=Y2iB_DwdyfM',
  'ee010201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=mTucAnRpxcQ',
  'ee010301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=mTucAnRpxcQ',
  'ee010401-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=F0T5ydRpScw',
  'ee010501-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=vbU8Tg9fz7Q',
  'ee010601-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=4oRyzq6Z4KE',
  'ee010701-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=uPK2FVz6qUs',
  'ee020101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=f5vLvG-P73c',
  'ee020201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=uPK2FVz6qUs',
  'ee020301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=uPK2FVz6qUs',
  'ee020401-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=tw_xSEjufD0',
  'ee020501-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=UbB2H6SHfHU',
  'ee030101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=tw_xSEjufD0',
  'ee030201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=tw_xSEjufD0',
  'ee030301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=tw_xSEjufD0',
  'ee030401-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=2PPPW6I-C34',
  'ee040101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=TcBojMaxRPY',
  'ee040201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=TcBojMaxRPY',
  'ee040301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=TcBojMaxRPY',
  'ee050101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=MyLAa2ufn4o',
  'ee050201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=MyLAa2ufn4o',
  'ee050301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=MyLAa2ufn4o',
  'ee060101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=kY07wfP2JiA',
  'ee060201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=kY07wfP2JiA',
  'ee060301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=kY07wfP2JiA',
  'ee060401-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=uX8Ot1u3YV0',
  'ee070101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=HyJtdT5X03E',
  'ee070201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=HyJtdT5X03E',
  'ee070301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=HyJtdT5X03E',
  'ee080101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=NWemqNMCesQ',
  'ee080201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=NWemqNMCesQ',
  'ee090101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee090201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee090301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee090401-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee100101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee100201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee100301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee100401-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee110101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee110201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee110301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee110401-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee110501-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yl0-_8OJyHQ',
  'ee120101-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=66_0-u8P5DQ',
  'ee120201-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=ZnyNsrcLl2I',
  'ee120301-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=yY6oy8xHLT8',
  'ee120401-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=eZx8eiTntAs',
  'ee120501-0000-0000-0000-000000000000': 'https://www.youtube.com/watch?v=epiQxPyOPBY',
};

class BackendCoursePlayerPage extends ConsumerStatefulWidget {
  const BackendCoursePlayerPage({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<BackendCoursePlayerPage> createState() =>
      _BackendCoursePlayerPageState();
}

class _BackendCoursePlayerPageState
    extends ConsumerState<BackendCoursePlayerPage> {
  String? _selectedLessonId;

  Future<void> _completeLessonAsync(String lessonId, int xp) async {
    final accessToken = ref.read(backendCourseAccessTokenProvider);
    if (accessToken == null || accessToken.trim().isEmpty) return;
    try {
      final remote = ref.read(backendCourseRemoteDataSourceProvider);
      await remote.completeLesson(accessToken: accessToken, lessonId: lessonId);
      if (!mounted) return;
      ref.invalidate(backendProfileProvider);
      ref.invalidate(backendAllProgressProvider);
      ref.invalidate(backendOopProgressProvider);
      if (xp > 0) {
        AppNotice.show(context, message: '+$xp XP', type: AppNoticeType.success);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(backendCourseDetailProvider(widget.courseId));

    return courseAsync.when(
      loading: () => const AppPageScaffold(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppPageScaffold(child: Center(child: Text('$e'))),
      data: (course) {
        if (course == null) {
          return const AppPageScaffold(
            child: Center(child: Text('Course not found')),
          );
        }

        final allLessons = <CoursePlayerLesson>[
          for (final m in course.coursePlayerModules) ...m.lessons,
        ];

        if (allLessons.isEmpty) {
          return AppPageScaffold(
            title: course.title.en,
            child: Center(
              child: Text(
                'Уроки ещё не добавлены.',
                style: TextStyle(color: context.appColors.textSecondary),
              ),
            ),
          );
        }

        final selectedId = _selectedLessonId ?? allLessons.first.id;
        final currentIndex = allLessons.indexWhere((l) => l.id == selectedId);
        final effectiveIndex = currentIndex == -1 ? 0 : currentIndex;
        final selectedLesson = allLessons[effectiveIndex];

        final backendLesson = ref
            .watch(backendLessonByIdProvider(selectedId))
            .asData
            ?.value;
        final backendPractice = ref
            .watch(backendPracticeByLessonIdProvider(selectedId))
            .asData
            ?.value;
        final backendQuizzes =
            ref
                .watch(backendQuizzesByLessonIdProvider(selectedId))
                .asData
                ?.value ??
            const <BackendQuizDto>[];

        final locale = context.l10n.locale;
        final hasPrev = effectiveIndex > 0;
        final hasNext = effectiveIndex < allLessons.length - 1;

        void selectLesson(String id) => setState(() => _selectedLessonId = id);
        void goPrev() => selectLesson(allLessons[effectiveIndex - 1].id);
        final xp = backendLesson?.xpReward ?? 0;
        void goNext() {
          final id = selectedId;
          selectLesson(allLessons[effectiveIndex + 1].id);
          _completeLessonAsync(id, xp);
        }
        void goFinish() {
          _completeLessonAsync(selectedId, xp);
          context.go(AppRoutes.courses);
        }

        final contentArea = _LessonContent(
          course: course,
          lesson: selectedLesson,
          backendLesson: backendLesson,
          backendQuizzes: backendQuizzes,
          backendPractice: backendPractice,
          locale: locale,
          hasPrev: hasPrev,
          hasNext: hasNext,
          onPrev: goPrev,
          onNext: goNext,
          onFinish: goFinish,
        );

        return AppPageScaffold(
          expandContent: true,
          maxContentWidth: context.isWideLayout ? 1380 : 1060,
          child: context.isCompactLayout
              ? _CompactLayout(
                  course: course,
                  allLessons: allLessons,
                  selectedLessonId: selectedId,
                  onSelectLesson: selectLesson,
                  contentArea: contentArea,
                )
              : _WideLayout(
                  course: course,
                  allLessons: allLessons,
                  selectedLessonId: selectedId,
                  onSelectLesson: selectLesson,
                  contentArea: contentArea,
                ),
        );
      },
    );
  }
}

// ─── Layouts ──────────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.course,
    required this.allLessons,
    required this.selectedLessonId,
    required this.onSelectLesson,
    required this.contentArea,
  });

  final CommunityCourse course;
  final List<CoursePlayerLesson> allLessons;
  final String selectedLessonId;
  final ValueChanged<String> onSelectLesson;
  final Widget contentArea;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.isWideLayout ? 300 : 260,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 40),
            child: GlowCard(
              accent: course.color,
              child: _SidebarContent(
                course: course,
                allLessons: allLessons,
                selectedLessonId: selectedLessonId,
                onSelectLesson: onSelectLesson,
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(child: contentArea),
      ],
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.course,
    required this.allLessons,
    required this.selectedLessonId,
    required this.onSelectLesson,
    required this.contentArea,
  });

  final CommunityCourse course;
  final List<CoursePlayerLesson> allLessons;
  final String selectedLessonId;
  final ValueChanged<String> onSelectLesson;
  final Widget contentArea;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey<String>(selectedLessonId),
          initialValue: selectedLessonId,
          decoration: InputDecoration(
            labelText: context.l10n.text('course_tab_modules'),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
          items: allLessons
              .map((lesson) {
                return DropdownMenuItem<String>(
                  value: lesson.id,
                  child: Text(
                    lesson.title.resolve(context.l10n.locale),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              })
              .toList(growable: false),
          onChanged: (v) {
            if (v != null) onSelectLesson(v);
          },
        ),
        const SizedBox(height: 12),
        Expanded(child: contentArea),
      ],
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.course,
    required this.allLessons,
    required this.selectedLessonId,
    required this.onSelectLesson,
  });

  final CommunityCourse course;
  final List<CoursePlayerLesson> allLessons;
  final String selectedLessonId;
  final ValueChanged<String> onSelectLesson;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = context.l10n.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title.resolve(locale),
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          '${allLessons.length} уроков',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        for (final module in course.coursePlayerModules) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              module.title.resolve(locale),
              style: TextStyle(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
          ),
          for (final lesson in module.lessons)
            _SidebarLessonTile(
              title: lesson.title.resolve(locale),
              isSelected: lesson.id == selectedLessonId,
              accent: course.color,
              onTap: () => onSelectLesson(lesson.id),
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SidebarLessonTile extends StatelessWidget {
  const _SidebarLessonTile({
    required this.title,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isSelected
                ? accent.withValues(alpha: 0.16)
                : colors.backgroundElevated,
            border: Border.all(
              color: isSelected ? accent : colors.divider,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.play_circle_filled_rounded
                    : Icons.circle_outlined,
                size: 16,
                color: isSelected ? accent : colors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? colors.textPrimary
                        : colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Lesson Content ───────────────────────────────────────────────────────────

class _LessonContent extends StatelessWidget {
  const _LessonContent({
    required this.course,
    required this.lesson,
    required this.backendLesson,
    required this.backendQuizzes,
    required this.backendPractice,
    required this.locale,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
    required this.onFinish,
  });

  final CommunityCourse course;
  final CoursePlayerLesson lesson;
  final BackendLessonDto? backendLesson;
  final List<BackendQuizDto> backendQuizzes;
  final BackendPracticeDto? backendPractice;
  final AppLocale locale;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  String _resolve(BackendLocalizedTextDto? dto, String fallback) {
    if (dto == null) return fallback;
    final v = switch (locale) {
      AppLocale.ru => dto.ru,
      AppLocale.en => dto.en,
      AppLocale.kk => dto.kk,
    }.trim();
    if (v.isNotEmpty) return v;
    final en = dto.en.trim();
    if (en.isNotEmpty) return en;
    return dto.ru.trim().isNotEmpty ? dto.ru.trim() : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final title = _resolve(backendLesson?.title, lesson.title.resolve(locale));
    final summary = _resolve(
      backendLesson?.summary,
      lesson.annotation.resolve(locale),
    );
    final theory = _resolve(
      backendLesson?.theoryContent,
      lesson.explanation.resolve(locale),
    );
    final objective = _resolve(
      backendLesson?.outcome,
      lesson.objective.resolve(locale),
    );
    final codeSnippet = (backendLesson?.codeSnippet.trim().isNotEmpty ?? false)
        ? backendLesson!.codeSnippet
        : lesson.codeSnippet;
    final exampleOutput =
        (backendLesson?.exampleOutput.trim().isNotEmpty ?? false)
        ? backendLesson!.exampleOutput
        : lesson.exampleOutput;
    final keyPoints =
        backendLesson?.keyPoints
            .map((p) => _resolve(p, ''))
            .where((p) => p.isNotEmpty)
            .toList(growable: false) ??
        <String>[];
    final videoUrl = oopVideoUrls[lesson.id] ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 40),
      children: [
        // Header card
        GlowCard(
          accent: course.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  summary,
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Objective
        if (objective.isNotEmpty)
          _SectionCard(
            accent: colors.primary,
            title: 'Цель урока',
            child: Text(
              objective,
              style: TextStyle(color: colors.textSecondary, height: 1.5),
            ),
          ),
        if (objective.isNotEmpty) const SizedBox(height: 16),

        // Theory
        if (theory.isNotEmpty)
          _SectionCard(
            accent: colors.success,
            title: 'Теория',
            child: Text(
              theory,
              style: TextStyle(color: colors.textSecondary, height: 1.6),
            ),
          ),
        if (theory.isNotEmpty) const SizedBox(height: 16),

        // Key points
        if (keyPoints.isNotEmpty) ...[
          _SectionCard(
            accent: colors.accent,
            title: 'Ключевые моменты',
            child: Column(
              children: keyPoints
                  .map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: course.color,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              point,
                              style: TextStyle(
                                color: colors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Code snippet
        if (codeSnippet.trim().isNotEmpty) ...[
          _SectionCard(
            accent: colors.primary,
            title: 'Пример кода',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF0D1117),
                    border: Border.all(color: colors.divider),
                  ),
                  child: SelectableText(
                    codeSnippet,
                    style: const TextStyle(
                      color: Color(0xFFE6EDF3),
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
                if (exampleOutput.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Вывод:',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: colors.surfaceSoft,
                    ),
                    child: SelectableText(
                      exampleOutput,
                      style: TextStyle(
                        color: colors.success,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Recommended video
        if (videoUrl.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () async {
                final uri = Uri.tryParse(videoUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_outline_rounded,
                        color: Color(0xFFFF0000), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Видео по теме',
                      style: TextStyle(
                        color: const Color(0xFFFF0000),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFFF0000),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Quizzes
        if (backendQuizzes.isNotEmpty) ...[
          GlowCard(
            accent: course.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.quiz_rounded, color: course.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Проверь себя',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...backendQuizzes.map(
                  (quiz) => _PlayerQuizCard(
                    quiz: quiz,
                    locale: locale,
                    accent: course.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Practice
        if (backendPractice != null) ...[
          GlowCard(
            accent: colors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.terminal_rounded,
                      color: colors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Практика',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _resolve(backendPractice!.title, 'Code practice'),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (backendPractice!.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    backendPractice!.description.trim(),
                    style: TextStyle(color: colors.textSecondary, height: 1.45),
                  ),
                ],
                const SizedBox(height: 14),
                AppButton.primary(
                  label: 'Открыть редактор кода',
                  icon: Icons.code_rounded,
                  onPressed: () =>
                      context.push(AppRoutes.practiceById(backendPractice!.id)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Navigation
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasPrev ? onPrev : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Предыдущий'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: hasNext ? onNext : onFinish,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(hasNext ? 'Следующий' : 'Завершить'),
                style: FilledButton.styleFrom(
                  backgroundColor: hasNext
                      ? course.color
                      : context.appColors.success,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Section Card helper ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.accent,
    required this.title,
    required this.child,
  });

  final Color accent;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Interactive Quiz Card ────────────────────────────────────────────────────

class _PlayerQuizCard extends StatefulWidget {
  const _PlayerQuizCard({
    required this.quiz,
    required this.locale,
    required this.accent,
  });

  final BackendQuizDto quiz;
  final AppLocale locale;
  final Color accent;

  @override
  State<_PlayerQuizCard> createState() => _PlayerQuizCardState();
}

class _PlayerQuizCardState extends State<_PlayerQuizCard> {
  int? _selected;

  String _resolve(BackendLocalizedTextDto dto) {
    final v = switch (widget.locale) {
      AppLocale.ru => dto.ru,
      AppLocale.en => dto.en,
      AppLocale.kk => dto.kk,
    }.trim();
    if (v.isNotEmpty) return v;
    final en = dto.en.trim();
    return en.isNotEmpty ? en : dto.ru.trim();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final quiz = widget.quiz;
    final accent = widget.accent;
    final answered = _selected != null;
    final sortedOptions = [...quiz.options]
      ..sort((a, b) => a.position.compareTo(b.position));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.backgroundElevated,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.quiz_rounded, color: accent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _resolve(quiz.question),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (sortedOptions.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...sortedOptions.asMap().entries.map((entry) {
              final idx = entry.key;
              final opt = entry.value;
              final isSelected = _selected == idx;
              final isCorrect = idx == quiz.correctAnswerIndex;

              Color bg = colors.surfaceSoft.withValues(alpha: 0.6);
              Color border = colors.divider;
              Color textColor = colors.textPrimary;

              if (answered) {
                if (isSelected && isCorrect) {
                  bg = colors.success.withValues(alpha: 0.14);
                  border = colors.success;
                  textColor = colors.success;
                } else if (isSelected) {
                  bg = colors.danger.withValues(alpha: 0.12);
                  border = colors.danger;
                  textColor = colors.danger;
                } else if (isCorrect) {
                  bg = colors.success.withValues(alpha: 0.07);
                  border = colors.success.withValues(alpha: 0.35);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: answered
                      ? null
                      : () => setState(() => _selected = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: bg,
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${String.fromCharCode(65 + idx)}.',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _resolve(opt.text),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (answered && isSelected)
                          Icon(
                            isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 16,
                            color: isCorrect ? colors.success : colors.danger,
                          ),
                        if (answered && !isSelected && isCorrect)
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: colors.success.withValues(alpha: 0.6),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
          if (answered)
            Builder(
              builder: (context) {
                final explanation = _resolve(quiz.explanation);
                if (explanation.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: accent.withValues(alpha: 0.08),
                    ),
                    child: Text(
                      explanation,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
