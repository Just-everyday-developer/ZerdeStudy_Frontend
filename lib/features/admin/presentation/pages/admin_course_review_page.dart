import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/models/course_review_dto.dart';
import '../providers/admin_providers.dart';

class AdminCourseReviewPage extends ConsumerWidget {
  const AdminCourseReviewPage({super.key});

  static const Color _kAmber = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final coursesAsync = ref.watch(adminPendingCoursesProvider);

    return coursesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.danger, size: 40),
            const SizedBox(height: 12),
            Text('Ошибка загрузки',
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('$e', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref.invalidate(adminPendingCoursesProvider),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
      data: (courses) {
        final pending = courses.where((c) => !c.isChecked).toList();
        final reviewed = courses.where((c) => c.isChecked).toList();

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminPendingCoursesProvider),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _kAmber.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.rate_review_rounded, color: _kAmber, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Проверка курсов',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Text(
                              '${pending.length} ожидают проверки',
                              style: TextStyle(
                                  color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (pending.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: colors.success, size: 56),
                        const SizedBox(height: 16),
                        Text(
                          'Нет курсов на проверке',
                          style: TextStyle(
                              color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text('Все курсы проверены',
                            style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Text(
                      'ОЖИДАЮТ ПРОВЕРКИ',
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  sliver: SliverList.separated(
                    itemCount: pending.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _CourseCard(
                      course: pending[i],
                      colors: colors,
                      onTap: () => _openReviewSheet(context, ref, pending[i]),
                    ),
                  ),
                ),
              ],
              if (reviewed.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text(
                      'ПРОВЕРЕНО',
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: reviewed.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _CourseCard(
                      course: reviewed[i],
                      colors: colors,
                      onTap: null,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openReviewSheet(BuildContext context, WidgetRef ref, PendingCourseDto course) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewSheet(
        course: course,
        onReviewed: () {
          ref.invalidate(adminPendingCoursesProvider);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ─── Course card ──────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.colors, required this.onTap});

  final PendingCourseDto course;
  final AppThemeColors colors;
  final VoidCallback? onTap;

  static const Color _kAmber = Color(0xFFF59E0B);

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.title.isEmpty ? 'Без названия' : course.title,
                      style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!course.isChecked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kAmber.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _kAmber.withValues(alpha: 0.4)),
                      ),
                      child: Text('На проверке',
                          style: TextStyle(
                              color: _kAmber, fontSize: 11, fontWeight: FontWeight.w700)),
                    )
                  else
                    Icon(Icons.check_circle_rounded, color: colors.success, size: 20),
                ],
              ),
              if (course.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  course.description,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (course.category.isNotEmpty) _Chip(label: course.category, colors: colors),
                  if (course.difficulty.isNotEmpty)
                    _Chip(label: course.difficulty, colors: colors),
                  _Chip(
                      label: _fmt(course.createdAt),
                      colors: colors,
                      icon: Icons.calendar_today_rounded),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Нажмите для проверки →',
                      style: TextStyle(
                          color: _kAmber, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.colors, this.icon});
  final String label;
  final AppThemeColors colors;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: colors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  color: colors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Review bottom sheet ──────────────────────────────────────────────────────

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({required this.course, required this.onReviewed});
  final PendingCourseDto course;
  final VoidCallback onReviewed;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  static const Color _kGreen = Color(0xFF22C55E);
  static const Color _kRed = Color(0xFFEF4444);

  final _commentController = TextEditingController();
  bool _showRejectForm = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool approve}) async {
    final comment = _commentController.text.trim();
    if (!approve && comment.isEmpty) {
      setState(() => _error = 'Укажите причину отклонения');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = ref.read(adminAccessTokenProvider) ?? '';
      final session = ref.read(authControllerProvider).session;
      final adminId = session?.user.id ?? '';
      final remote = ref.read(adminRemoteDataSourceProvider);

      await remote.reviewCourse(
        accessToken: token,
        courseId: widget.course.id,
        adminId: adminId,
        isApproved: approve,
        comment: comment,
      );
      widget.onReviewed();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Ошибка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: colors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.course.title.isEmpty ? 'Без названия' : widget.course.title,
                style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.5),
              ),
              if (widget.course.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(widget.course.description,
                    style: TextStyle(
                        color: colors.textSecondary, fontSize: 14, height: 1.5)),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.course.category.isNotEmpty)
                    _Chip(label: widget.course.category, colors: colors),
                  if (widget.course.difficulty.isNotEmpty)
                    _Chip(label: widget.course.difficulty, colors: colors),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: colors.divider),
              const SizedBox(height: 16),
              if (_showRejectForm) ...[
                Text('Причина отклонения',
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  autofocus: true,
                  maxLines: 4,
                  minLines: 2,
                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Укажите что нужно исправить...',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: _kRed.withValues(alpha: 0.6), width: 1.5),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: const TextStyle(
                          color: _kRed, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() {
                                  _showRejectForm = false;
                                  _error = null;
                                }),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Назад'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _loading ? null : () => _submit(approve: false),
                        style: FilledButton.styleFrom(
                          backgroundColor: _kRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Отклонить',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                if (_error != null) ...[
                  Text(_error!,
                      style: const TextStyle(
                          color: _kRed, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _loading ? null : () => setState(() => _showRejectForm = true),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Отклонить',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kRed,
                          side: BorderSide(color: _kRed.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _loading ? null : () => _submit(approve: true),
                        icon: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Одобрить',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        style: FilledButton.styleFrom(
                          backgroundColor: _kGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
