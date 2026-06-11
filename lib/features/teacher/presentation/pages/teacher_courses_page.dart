import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/data/models/backend_course_dto.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../../application/teacher_authoring_service.dart';
import 'teacher_course_editor_page.dart';
import 'teacher_course_form_page.dart';

/// Teacher's own courses, with create / open editor / delete.
/// Replaces the local graph-only course builder — fully backend-connected.
class TeacherCoursesPage extends ConsumerWidget {
  const TeacherCoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final coursesAsync = ref.watch(teacherBackendCoursesProvider);
    final myId = ref.watch(authControllerProvider).session?.user.id ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.primary,
        onPressed: () => _createCourse(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Создать курс'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Мои курсы',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          'Создавайте курсы, модули, уроки, квизы и практику — всё сохраняется на сервере.',
                          style: TextStyle(
                              color: colors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Обновить',
                    onPressed: () =>
                        ref.invalidate(teacherBackendCoursesProvider),
                    icon: Icon(Icons.refresh_rounded,
                        color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: coursesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Ошибка: $e')),
                data: (allCourses) {
                  // Show courses authored by the current teacher first; if the
                  // author id is missing on records, fall back to all courses.
                  final mine = allCourses
                      .where((c) => c.author.id == myId)
                      .toList();
                  final courses = mine.isNotEmpty ? mine : allCourses;

                  if (courses.isEmpty) {
                    return _EmptyState(colors: colors);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _CourseCard(
                      course: courses[i],
                      colors: colors,
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              TeacherCourseEditorPage(course: courses[i]),
                        ),
                      ),
                      onDelete: () => _deleteCourse(context, ref, courses[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCourse(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const TeacherCourseFormPage()),
    );
    if (created == true) {
      ref.invalidate(teacherBackendCoursesProvider);
    }
  }

  Future<void> _deleteCourse(
      BuildContext context, WidgetRef ref, BackendCourseDto course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить курс?'),
        content: Text(
            'Курс «${course.title}» и его содержимое будут удалены. Это действие необратимо.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final service = ref.read(teacherAuthoringServiceProvider);
    if (service == null || !context.mounted) return;
    try {
      await service.deleteCourse(course.id);
      ref.invalidate(teacherBackendCoursesProvider);
      if (context.mounted) {
        AppNotice.show(context,
            message: 'Курс удалён', type: AppNoticeType.success);
      }
    } catch (e) {
      if (context.mounted) {
        AppNotice.show(context, message: 'Ошибка: $e', type: AppNoticeType.error);
      }
    }
  }
}

class _CourseCard extends ConsumerStatefulWidget {
  const _CourseCard({
    required this.course,
    required this.colors,
    required this.onOpen,
    required this.onDelete,
  });

  final BackendCourseDto course;
  final AppThemeColors colors;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  ConsumerState<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends ConsumerState<_CourseCard> {
  bool _resubmitting = false;

  Future<void> _resubmit() async {
    setState(() => _resubmitting = true);
    try {
      final token = ref.read(backendCourseAccessTokenProvider);
      if (token == null || token.trim().isEmpty) return;
      final remote = ref.read(backendCourseRemoteDataSourceProvider);
      await remote.resubmitCourseForReview(
        accessToken: token,
        courseId: widget.course.id,
      );
      ref.invalidate(courseAdminReviewProvider(widget.course.id));
      ref.invalidate(teacherBackendCoursesProvider);
      if (mounted) {
        AppNotice.show(context,
            message: 'Курс отправлен на проверку', type: AppNoticeType.success);
      }
    } catch (e) {
      if (mounted) {
        AppNotice.show(context,
            message: 'Ошибка: $e', type: AppNoticeType.error);
      }
    } finally {
      if (mounted) setState(() => _resubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final colors = widget.colors;
    final statusCode = course.status.code;
    final statusColor = statusCode == 'published'
        ? const Color(0xFF4CAF50)
        : statusCode == 'archived'
            ? colors.textSecondary
            : colors.accent;

    final reviewAsync = ref.watch(courseAdminReviewProvider(course.id));
    final review = reviewAsync.asData?.value;
    final isChecked = review?['is_checked'] as bool? ?? false;
    final isApproved = review?['is_approved'] as bool? ?? true;
    final comment = (review?['comment'] as String? ?? '').trim();
    final isRejected = isChecked && !isApproved;

    return InkWell(
      onTap: widget.onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRejected ? Colors.red.withValues(alpha: 0.5) : colors.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: colors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title.trim().isEmpty ? 'Без названия' : course.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.status.name.isNotEmpty
                                  ? course.status.name
                                  : statusCode,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              '${course.lessonsCount} уроков · ${course.level.name}',
                              style: TextStyle(
                                  color: colors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: colors.danger),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
              ],
            ),
            if (isRejected) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cancel_outlined,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 6),
                        const Text('Курс отклонён администратором',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (comment.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(comment,
                          style: TextStyle(
                              color: colors.textSecondary, fontSize: 13)),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: _resubmitting ? null : _resubmit,
                        icon: _resubmitting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, size: 16),
                        label: const Text('Отправить на проверку снова'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_books_outlined,
                size: 56, color: colors.textSecondary),
            const SizedBox(height: 16),
            Text('У вас пока нет курсов',
                style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 6),
            Text('Нажмите «Создать курс», чтобы начать.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
