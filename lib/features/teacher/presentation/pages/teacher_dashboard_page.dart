import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/data/models/backend_course_dto.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../../../teacher/application/teacher_authoring_service.dart';
import '../teacher_text.dart';
import '../widgets/teacher_studio_widgets.dart';
import 'teacher_course_editor_page.dart';
import 'teacher_course_form_page.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final demoState = ref.watch(demoAppControllerProvider);
    final coursesAsync = ref.watch(teacherBackendCoursesProvider);
    final colors = context.appColors;
    final profile = ref.watch(backendProfileProvider).asData?.value;
    final firstName = (profile?.login.trim().isNotEmpty == true
            ? profile!.login
            : (demoState.user?.name ?? ''))
        .trim();

    return TsPageScrollView(
      children: [
        TsPageHeader(
          eyebrow: _heroEyebrow.resolve(locale),
          title: firstName.isNotEmpty
              ? _heroTitleTemplate.resolve(locale).replaceAll('{name}', firstName)
              : _heroTitleFallback.resolve(locale),
          subtitle: _heroSubtitle.resolve(locale),
          actions: [
            TsButton.primary(
              label: _actionNew.resolve(locale),
              icon: Icons.add_rounded,
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) => const TeacherCourseFormPage(),
                  ),
                );
                if (created == true) {
                  ref.invalidate(teacherBackendCoursesProvider);
                }
              },
            ),
          ],
        ),
        TsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TsCardHeader(
                eyebrow: _portfolioEyebrow.resolve(locale),
                title: _portfolioTitle.resolve(locale),
                subtitle: _portfolioSubtitle.resolve(locale),
                actions: [
                  TsButton(
                    label: _portfolioRefresh.resolve(locale),
                    icon: Icons.refresh_rounded,
                    onPressed: () => ref.invalidate(teacherBackendCoursesProvider),
                  ),
                ],
              ),
              coursesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _errorText.resolve(locale),
                    style: TextStyle(color: colors.danger),
                  ),
                ),
                data: (courses) => courses.isEmpty
                    ? _EmptyCourses(colors: colors, locale: locale)
                    : _CourseList(courses: courses, colors: colors, locale: locale),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses({required this.colors, required this.locale});
  final AppThemeColors colors;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 44, color: colors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 14),
          Text(
            _emptyTitle.resolve(locale),
            style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _emptyBody.resolve(locale),
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList({required this.courses, required this.colors, required this.locale});
  final List<BackendCourseDto> courses;
  final AppThemeColors colors;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < courses.length; i++) ...[
          if (i > 0) Divider(height: 1, color: colors.divider),
          _CourseRow(course: courses[i], colors: colors, locale: locale),
        ],
      ],
    );
  }
}

class _CourseRow extends ConsumerWidget {
  const _CourseRow({required this.course, required this.colors, required this.locale});
  final BackendCourseDto course;
  final AppThemeColors colors;
  final AppLocale locale;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_deleteTitle.resolve(locale)),
        content: Text(
          _deleteBodyTemplate.resolve(locale).replaceAll('{title}', course.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_cancelLabel.resolve(locale)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_deleteLabel.resolve(locale)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final service = ref.read(teacherAuthoringServiceProvider);
    if (service == null || !context.mounted) return;
    try {
      await service.deleteCourse(course.id);
      ref.invalidate(teacherBackendCoursesProvider);
      if (context.mounted) {
        AppNotice.show(
          context,
          message: _deletedMsg.resolve(locale),
          type: AppNoticeType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotice.show(
          context,
          message: '${_errorText.resolve(locale)}: $e',
          type: AppNoticeType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPublished = course.status.code.toLowerCase() == 'published';
    final statusColor = isPublished ? colors.success : colors.textSecondary;
    final statusLabel = isPublished
        ? 'LIVE'
        : switch (locale) {
            AppLocale.ru => 'ЧЕРНОВИК',
            AppLocale.kk => 'НОБАЙ',
            _ => 'DRAFT',
          };

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TeacherCourseEditorPage(course: course),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${course.lessonsCount} уроков · ${course.level.name}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TsTag(label: statusLabel, color: statusColor),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _confirmDelete(context, ref),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: colors.danger.withValues(alpha: 0.7),
                  size: 17,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Strings ──────────────────────────────────────────────────────────────────

final _heroEyebrow = teacherText(ru: 'КАБИНЕТ ПРЕПОДАВАТЕЛЯ', en: 'TEACHER STUDIO', kk: 'ОҚЫТУШЫ КАБИНЕТІ');
final _heroTitleTemplate = teacherText(
  ru: 'Добро пожаловать, {name}',
  en: 'Welcome back, {name}',
  kk: 'Қош келдіңіз, {name}',
);
final _heroTitleFallback = teacherText(
  ru: 'Кабинет преподавателя',
  en: 'Teacher Studio',
  kk: 'Оқытушы кабинеті',
);
final _heroSubtitle = teacherText(
  ru: 'Управляйте курсами, следите за прогрессом студентов.',
  en: 'Manage your courses and track student progress.',
  kk: 'Курстарыңызды басқарып, студенттер прогресін қадағалаңыз.',
);
final _actionNew = teacherText(ru: 'Новый курс', en: 'New course', kk: 'Жаңа курс');

final _portfolioEyebrow = teacherText(ru: 'МОИ КУРСЫ', en: 'MY COURSES', kk: 'МЕНІҢ КУРСТАРЫМ');
final _portfolioTitle = teacherText(ru: 'Ваши курсы', en: 'Your courses', kk: 'Сіздің курстарыңыз');
final _portfolioSubtitle = teacherText(
  ru: 'Нажмите на курс для редактирования.',
  en: 'Tap a course to open the editor.',
  kk: 'Редактор ашу үшін курсты басыңыз.',
);
final _portfolioRefresh = teacherText(ru: 'Обновить', en: 'Refresh', kk: 'Жаңарту');
final _errorText = teacherText(
  ru: 'Не удалось загрузить курсы',
  en: 'Failed to load courses',
  kk: 'Курстарды жүктеу мүмкін болмады',
);
final _emptyTitle = teacherText(
  ru: 'Курсов пока нет',
  en: 'No courses yet',
  kk: 'Курстар әлі жоқ',
);
final _emptyBody = teacherText(
  ru: 'Создайте первый курс, нажав «Новый курс».',
  en: 'Create your first course by tapping "New course".',
  kk: '«Жаңа курс» батырмасын басып алғашқы курс жасаңыз.',
);
final _deleteTitle = teacherText(ru: 'Удалить курс?', en: 'Delete course?', kk: 'Курсты жою?');
final _deleteBodyTemplate = teacherText(
  ru: 'Курс «{title}» и его содержимое будут удалены. Это необратимо.',
  en: 'Course "{title}" and all its content will be deleted. This cannot be undone.',
  kk: '«{title}» курсы және оның мазмұны жойылады. Бұл қайтарымсыз.',
);
final _cancelLabel = teacherText(ru: 'Отмена', en: 'Cancel', kk: 'Болдырмау');
final _deleteLabel = teacherText(ru: 'Удалить', en: 'Delete', kk: 'Жою');
final _deletedMsg = teacherText(ru: 'Курс удалён', en: 'Course deleted', kk: 'Курс жойылды');
