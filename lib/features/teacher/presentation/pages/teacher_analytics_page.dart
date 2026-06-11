import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../teacher_text.dart';
import '../widgets/teacher_studio_widgets.dart';

class TeacherAnalyticsPage extends ConsumerWidget {
  const TeacherAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(demoAppControllerProvider.select((s) => s.locale));
    final colors = context.appColors;
    final coursesAsync = ref.watch(teacherBackendCoursesProvider);
    final submissionsAsync = ref.watch(backendTeacherSubmissionsProvider);

    return TsPageScrollView(
      children: [
        TsPageHeader(
          eyebrow: _eyebrow.resolve(locale),
          title: _title.resolve(locale),
          subtitle: _subtitle.resolve(locale),
        ),
        coursesAsync.when(
          loading: () => const _LoadingCard(),
          error: (_, __) => _EmptyState(colors: colors, locale: locale),
          data: (courses) {
            if (courses.isEmpty) {
              return _EmptyState(colors: colors, locale: locale);
            }
            final totalStudents = courses.fold<int>(0, (s, c) => s + c.studentsCount);
            final totalLessons = courses.fold<int>(0, (s, c) => s + c.lessonsCount);

            return submissionsAsync.when(
              loading: () => _Body(
                locale: locale,
                colors: colors,
                courses: courses,
                totalStudents: totalStudents,
                totalLessons: totalLessons,
                pending: 0,
                approved: 0,
                changesRequested: 0,
              ),
              error: (_, __) => _Body(
                locale: locale,
                colors: colors,
                courses: courses,
                totalStudents: totalStudents,
                totalLessons: totalLessons,
                pending: 0,
                approved: 0,
                changesRequested: 0,
              ),
              data: (subs) {
                final pending = subs.where((s) => s.isPending).length;
                final approved = subs.where((s) => s.isApproved).length;
                final changes = subs.where((s) => s.needsChanges).length;
                return _Body(
                  locale: locale,
                  colors: colors,
                  courses: courses,
                  totalStudents: totalStudents,
                  totalLessons: totalLessons,
                  pending: pending,
                  approved: approved,
                  changesRequested: changes,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.locale,
    required this.colors,
    required this.courses,
    required this.totalStudents,
    required this.totalLessons,
    required this.pending,
    required this.approved,
    required this.changesRequested,
  });

  final AppLocale locale;
  final AppThemeColors colors;
  final List<dynamic> courses;
  final int totalStudents;
  final int totalLessons;
  final int pending;
  final int approved;
  final int changesRequested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI row
        _KpiGrid(
          locale: locale,
          colors: colors,
          coursesCount: courses.length,
          totalStudents: totalStudents,
          totalLessons: totalLessons,
          pendingReviews: pending,
        ),
        const SizedBox(height: 20),
        // Code review breakdown
        if (pending + approved + changesRequested > 0) ...[
          _SectionLabel(
            label: _reviewLabel.resolve(locale),
            colors: colors,
          ),
          const SizedBox(height: 10),
          _ReviewBreakdown(
            colors: colors,
            locale: locale,
            pending: pending,
            approved: approved,
            changesRequested: changesRequested,
          ),
          const SizedBox(height: 20),
        ],
        // Per-course table
        _SectionLabel(label: _coursesLabel.resolve(locale), colors: colors),
        const SizedBox(height: 10),
        _CoursesTable(courses: courses, colors: colors, locale: locale),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.locale,
    required this.colors,
    required this.coursesCount,
    required this.totalStudents,
    required this.totalLessons,
    required this.pendingReviews,
  });

  final AppLocale locale;
  final AppThemeColors colors;
  final int coursesCount;
  final int totalStudents;
  final int totalLessons;
  final int pendingReviews;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Icons.library_books_rounded,
        value: '$coursesCount',
        label: _kpiCourses.resolve(locale),
        accent: colors.primary,
      ),
      (
        icon: Icons.menu_book_rounded,
        value: '$totalLessons',
        label: _kpiLessons.resolve(locale),
        accent: const Color(0xFFA78BFA),
      ),
      (
        icon: Icons.rate_review_rounded,
        value: '$pendingReviews',
        label: _kpiPending.resolve(locale),
        accent: const Color(0xFFFBBF24),
      ),
    ];

    return LayoutBuilder(builder: (context, box) {
      final cols = box.maxWidth > 600 ? 3 : 2;
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: box.maxWidth > 600 ? 1.6 : 1.5,
        children: items
            .map((it) => _KpiCard(
                  icon: it.icon,
                  value: it.value,
                  label: it.label,
                  accent: it.accent,
                  colors: colors,
                ))
            .toList(),
      );
    });
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.colors,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: accent),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'IBMPlexMono',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReviewBreakdown extends StatelessWidget {
  const _ReviewBreakdown({
    required this.colors,
    required this.locale,
    required this.pending,
    required this.approved,
    required this.changesRequested,
  });

  final AppThemeColors colors;
  final AppLocale locale;
  final int pending;
  final int approved;
  final int changesRequested;

  @override
  Widget build(BuildContext context) {
    final total = pending + approved + changesRequested;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          _ReviewPill(
            count: pending,
            label: _revPending.resolve(locale),
            color: const Color(0xFF60A5FA),
            colors: colors,
          ),
          const SizedBox(width: 8),
          _ReviewPill(
            count: changesRequested,
            label: _revChanges.resolve(locale),
            color: const Color(0xFFFBBF24),
            colors: colors,
          ),
          const SizedBox(width: 8),
          _ReviewPill(
            count: approved,
            label: _revApproved.resolve(locale),
            color: const Color(0xFF34D399),
            colors: colors,
          ),
          const Spacer(),
          Text(
            _totalLabel.resolve(locale).replaceAll('{n}', '$total'),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontFamily: 'IBMPlexMono',
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewPill extends StatelessWidget {
  const _ReviewPill({
    required this.count,
    required this.label,
    required this.color,
    required this.colors,
  });

  final int count;
  final String label;
  final Color color;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontFamily: 'IBMPlexMono',
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CoursesTable extends StatelessWidget {
  const _CoursesTable({
    required this.courses,
    required this.colors,
    required this.locale,
  });

  final List<dynamic> courses;
  final AppThemeColors colors;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colors.divider.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    _colTitle.resolve(locale),
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                _HeaderCell(_colStudents.resolve(locale), colors),
                _HeaderCell(_colLessons.resolve(locale), colors),
                _HeaderCell(_colRating.resolve(locale), colors),
                _HeaderCell(_colLevel.resolve(locale), colors),
              ],
            ),
          ),
          ...courses.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            final isLast = i == courses.length - 1;
            return _CourseRow(
              course: c,
              colors: colors,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, this.colors);
  final String text;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.course,
    required this.colors,
    required this.isLast,
  });

  final dynamic course;
  final AppThemeColors colors;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final rating = (course.rating as num?)?.toDouble() ?? 0.0;
    final statusCode = (course.status?.code as String?) ?? '';
    final isLive = statusCode == 'published';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isLive ? const Color(0xFF34D399) : colors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    course.title as String? ?? '',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _DataCell('${course.studentsCount ?? 0}', colors),
          _DataCell('${course.lessonsCount ?? 0}', colors),
          _DataCell(
            rating > 0 ? rating.toStringAsFixed(1) : '—',
            colors,
            accent: rating >= 4.0 ? const Color(0xFF34D399) : null,
          ),
          SizedBox(
            width: 68,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (course.level?.name != null
                          ? _levelColor(course.level!.name as String)
                          : colors.textSecondary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _shortLevel(course.level?.name as String? ?? '?'),
                  style: TextStyle(
                    color: course.level?.name != null
                        ? _levelColor(course.level!.name as String)
                        : colors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _levelColor(String name) {
    final l = name.toLowerCase();
    if (l.contains('begin') || l.contains('начал')) return const Color(0xFF34D399);
    if (l.contains('inter') || l.contains('средн')) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  static String _shortLevel(String name) {
    final l = name.toLowerCase();
    if (l.contains('begin') || l.contains('начал')) return 'Нач';
    if (l.contains('inter') || l.contains('средн')) return 'Ср';
    if (l.contains('adv') || l.contains('прод')) return 'Пр';
    return name.length > 4 ? name.substring(0, 4) : name;
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell(this.text, this.colors, {this.accent});
  final String text;
  final AppThemeColors colors;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: accent ?? colors.textSecondary,
          fontFamily: 'IBMPlexMono',
          fontSize: 13,
          fontWeight: accent != null ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.colors});
  final String label;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            fontFamily: 'IBMPlexMono',
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.locale});
  final AppThemeColors colors;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 52, color: colors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            _emptyTitle.resolve(locale),
            style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _emptyBody.resolve(locale),
            style: TextStyle(color: colors.textSecondary, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Strings
// ─────────────────────────────────────────────────────────────────────────────

final _eyebrow = teacherText(ru: 'АНАЛИТИКА', en: 'ANALYTICS', kk: 'АНАЛИТИКА');
final _title = teacherText(ru: 'Статистика курсов', en: 'Course Analytics', kk: 'Курс статистикасы');
final _subtitle = teacherText(
  ru: 'Данные о прохождении, результатах ревью и активности студентов.',
  en: 'Completion rates, code review results and learner activity.',
  kk: 'Аяқтау деңгейі, тест нәтижелері және оқушы белсенділігі.',
);
final _emptyTitle = teacherText(
  ru: 'Аналитика пока недоступна',
  en: 'Analytics not available yet',
  kk: 'Аналитика әлі қолжетімді емес',
);
final _emptyBody = teacherText(
  ru: 'Статистика появится после того, как студенты начнут проходить ваши курсы.',
  en: 'Stats will appear once students start progressing through your courses.',
  kk: 'Студенттер курстарыңызды өте бастаған соң статистика пайда болады.',
);
final _kpiCourses = teacherText(ru: 'Курсов', en: 'Courses', kk: 'Курс');
final _kpiLessons = teacherText(ru: 'Уроков', en: 'Lessons', kk: 'Сабақ');
final _kpiPending = teacherText(ru: 'На ревью', en: 'Pending review', kk: 'Ревьюда');
final _reviewLabel = teacherText(ru: 'Код-ревью', en: 'Code review', kk: 'Код-ревью');
final _coursesLabel = teacherText(ru: 'Мои курсы', en: 'My courses', kk: 'Менің курстарым');
final _revPending = teacherText(ru: 'ожидает', en: 'pending', kk: 'күтуде');
final _revChanges = teacherText(ru: 'правки', en: 'changes', kk: 'өзгертулер');
final _revApproved = teacherText(ru: 'одобрено', en: 'approved', kk: 'мақұлданды');
final _totalLabel = teacherText(ru: 'всего {n}', en: 'total {n}', kk: 'барлығы {n}');
final _colTitle = teacherText(ru: 'КУРС', en: 'COURSE', kk: 'КУРС');
final _colStudents = teacherText(ru: 'СТУД.', en: 'STUD.', kk: 'СТУД.');
final _colLessons = teacherText(ru: 'УР.', en: 'LES.', kk: 'САБ.');
final _colRating = teacherText(ru: 'РЕЙ.', en: 'RATE', kk: 'РЕЙ.');
final _colLevel = teacherText(ru: 'УРВ.', en: 'LVL', kk: 'ДЕН.');
