import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/common_widgets/bubble_progress_bar.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../../../courses_backend/data/models/backend_streak_dto.dart';
import '../../../app_guide/presentation/app_guide_controller.dart';
import '../../../app_guide/presentation/app_guide_target.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/app_locale.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _getLastTopicTitle(DemoAppState state, LearningTrack track) {
    for (final module in track.modules.reversed) {
      if (module.practice != null &&
          state.completedPracticeIds.contains(module.practice!.id)) {
        return module.practice!.title.resolve(state.locale);
      }
      for (final lesson in module.lessons.reversed) {
        if (state.completedLessonIds.contains(lesson.id)) {
          return lesson.title.resolve(state.locale);
        }
      }
    }
    // Fallback to first lesson
    if (track.modules.isNotEmpty && track.modules.first.lessons.isNotEmpty) {
      return track.modules.first.lessons.first.title.resolve(state.locale);
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final backendStreak = ref
        .watch(backendStreakProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final streakDays = backendStreak?.streak ?? state.streak;
    final activeStreakDates =
        backendStreak?.activeDates.toSet() ??
        BackendStreakDto.deriveActiveDates(
          streak: state.streak,
          lastLogin: DateTime.now(),
        ).toSet();
    final catalog = ref.watch(demoCatalogProvider);
    final currentTrack = catalog.trackById(state.currentTrackId);
    final currentProgress = catalog.progressForTrack(state, currentTrack.id);

    final leaderboard = catalog.leaderboardFor(state);
    final myRank = leaderboard.indexWhere((e) => e.isCurrentUser) + 1;
    final colors = context.appColors;
    final compact = context.isCompactLayout;

    // Filter tracks with progress > 0 or current active track
    final startedTracks = catalog.tracks.where((track) {
      final progress = catalog.progressForTrack(state, track.id);
      return progress.completedUnits > 0 || track.id == state.currentTrackId;
    }).toList();

    // Filter community courses with progress > 0 or enrolled
    final startedCourses = catalog.communityCourses.where((course) {
      final percent = catalog.coursePlayerCompletionPercent(state, course.id);
      final enrolled = state.enrolledCommunityCourseIds.contains(course.id);
      return percent > 0 || enrolled;
    }).toList();

    // Fallback if empty
    if (startedCourses.isEmpty && catalog.communityCourses.isNotEmpty) {
      startedCourses.add(catalog.communityCourses.first);
    }

    final trackSectionTitle = switch (state.locale) {
      AppLocale.ru => 'Дерево знаний',
      AppLocale.kk => 'Білім ағашы',
      _ => 'Knowledge Tree',
    };

    final courseSectionTitle = switch (state.locale) {
      AppLocale.ru => 'Внешние курсы',
      AppLocale.kk => 'Сыртқы курстар',
      _ => 'External Courses',
    };

    final trackCards = startedTracks.map((track) {
      final progress = catalog.progressForTrack(state, track.id);
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _CircularProgressCard(
          title: track.title.resolve(state.locale),
          subtitle: _getLastTopicTitle(state, track),
          percent: (progress.fraction * 100).round(),
          color: track.color,
          icon: track.icon,
          onTap: () {
            final target = progress.nextTarget;
            if (target == null) {
              context.push(AppRoutes.trackById(track.id));
              return;
            }
            context.push(
              target.isPractice
                  ? AppRoutes.practiceById(target.id)
                  : AppRoutes.lessonById(target.id),
            );
          },
        ),
      );
    }).toList();

    final courseCards = startedCourses.map((course) {
      final percent = catalog.coursePlayerCompletionPercent(state, course.id);
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _CircularProgressCard(
          title: course.title.resolve(state.locale),
          subtitle: course.subtitle.resolve(state.locale),
          percent: percent,
          color: course.color,
          icon: Icons.school_rounded,
          onTap: () {
            if (catalog.isCourseEnrolled(state, course.id)) {
              context.push(AppRoutes.coursePlayerById(course.id));
            } else {
              context.push(AppRoutes.courseById(course.id));
            }
          },
        ),
      );
    }).toList();

    return AppPageScaffold(
      horizontalPadding: compact ? 0 : null,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 0,
          compact ? 6 : 8,
          compact ? 16 : 0,
          compact ? 104 : 120,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AnimatedGreeting(
                userName: state.user?.name ?? 'Talgat',
                locale: state.locale,
              ),
              if (currentTrack.description
                  .resolve(state.locale)
                  .isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  currentTrack.description.resolve(state.locale),
                  style: TextStyle(color: colors.textSecondary, height: 1.45),
                ),
              ],
              const SizedBox(height: 18),
              _AssessmentDiagnosticCard(
                colors: colors,
                locale: state.locale,
                onTap: () {
                  context.push(AppRoutes.diagnostics);
                },
              ),
              if (currentProgress.nextTarget != null) ...[
                const SizedBox(height: 18),
                _CurrentTrackCard(
                  track: currentTrack,
                  progress: currentProgress,
                  xp: state.xp,
                  colors: colors,
                  locale: state.locale,
                  onTap: () {
                    final target = currentProgress.nextTarget!;
                    context.push(
                      target.isPractice
                          ? AppRoutes.practiceById(target.id)
                          : AppRoutes.lessonById(target.id),
                    );
                  },
                ),
              ],
              const SizedBox(height: 18),
              _HabitTrackerCalendar(
                streak: streakDays,
                activeDates: activeStreakDates,
                rank: myRank,
                colors: colors,
              ),
              const SizedBox(height: 24),

              // Knowledge Tree Section (Always at the top of progress cards)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  trackSectionTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              if (compact)
                ...trackCards
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: trackCards
                      .map((card) => SizedBox(width: 340, child: card))
                      .toList(),
                ),
              const SizedBox(height: 18),

              // External Courses Section (Always below Knowledge Tree)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  courseSectionTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              if (compact)
                ...courseCards
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: courseCards
                      .map((card) => SizedBox(width: 340, child: card))
                      .toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitTrackerCalendar extends StatefulWidget {
  const _HabitTrackerCalendar({
    required this.streak,
    required this.activeDates,
    required this.rank,
    required this.colors,
  });

  final int streak;
  final Set<DateTime> activeDates;
  final int rank;
  final AppThemeColors colors;

  @override
  State<_HabitTrackerCalendar> createState() => _HabitTrackerCalendarState();
}

class _HabitTrackerCalendarState extends State<_HabitTrackerCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    if (prev.isBefore(DateTime(2026, 1, 1))) {
      return;
    }
    setState(() {
      _currentMonth = prev;
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    final currentCalendarMonth = DateTime(now.year, now.month, 1);
    if (next.isAfter(currentCalendarMonth)) {
      return;
    }
    setState(() {
      _currentMonth = next;
    });
  }

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void _showMonthYearPicker(BuildContext context) {
    final colors = widget.colors;
    final currentMonthIndex = _currentMonth.month - 1;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: colors.backgroundElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: colors.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      switch (context.l10n.locale) {
                        AppLocale.ru => 'Выберите дату',
                        AppLocale.kk => 'Күнді таңдаңыз',
                        _ => 'Select Date',
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Month Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                switch (context.l10n.locale) {
                                  AppLocale.ru => 'Месяц',
                                  AppLocale.kk => 'Ай',
                                  _ => 'Month',
                                },
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colors.divider),
                                ),
                                child: ListView.builder(
                                  itemCount: 12,
                                  itemBuilder: (context, index) {
                                    final isSelected =
                                        currentMonthIndex == index;
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        _monthNames[index],
                                        style: TextStyle(
                                          color: isSelected
                                              ? colors.primary
                                              : colors.textPrimary,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _currentMonth = DateTime(
                                            _currentMonth.year,
                                            index + 1,
                                            1,
                                          );
                                        });
                                        setDialogState(() {});
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Year Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                switch (context.l10n.locale) {
                                  AppLocale.ru => 'Год',
                                  AppLocale.kk => 'Жыл',
                                  _ => 'Year',
                                },
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colors.divider),
                                ),
                                child: ListView.builder(
                                  itemCount: 52, // 2026 to 2077
                                  itemBuilder: (context, index) {
                                    final year = 2026 + index;
                                    final isSelected =
                                        _currentMonth.year == year;
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        '$year',
                                        style: TextStyle(
                                          color: isSelected
                                              ? colors.primary
                                              : colors.textPrimary,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _currentMonth = DateTime(
                                            year,
                                            _currentMonth.month,
                                            1,
                                          );
                                        });
                                        setDialogState(() {});
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            switch (context.l10n.locale) {
                              AppLocale.ru => 'Готово',
                              AppLocale.kk => 'Дайын',
                              _ => 'Done',
                            },
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    // Calculate days in month and starting weekday
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstWeekday = _currentMonth.weekday; // 1 = Mon, 7 = Sun
    final previousMonthDays = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    ).day;

    final calendarDays = <Widget>[];

    // Previous month filler days
    for (int i = 1; i < firstWeekday; i++) {
      final day = previousMonthDays - firstWeekday + i + 1;
      final date = DateTime(_currentMonth.year, _currentMonth.month - 1, day);
      calendarDays.add(
        _buildDayCell(day, date: date, isCurrentMonth: false, colors: colors),
      );
    }

    // Current month days — all empty (no fake checkmarks)
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, i);
      calendarDays.add(
        _buildDayCell(i, date: date, isCurrentMonth: true, colors: colors),
      );
    }

    // Next month filler days
    final totalCellsNeeded = calendarDays.length <= 35 ? 35 : 42;
    final cellsToAdd = totalCellsNeeded - calendarDays.length;
    for (int i = 1; i <= cellsToAdd; i++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month + 1, i);
      calendarDays.add(
        _buildDayCell(i, date: date, isCurrentMonth: false, colors: colors),
      );
    }

    // Split into rows
    final rows = <Widget>[];
    for (int i = 0; i < calendarDays.length; i += 7) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: calendarDays.sublist(i, i + 7),
          ),
        ),
      );
    }

    final streakWord = switch (context.l10n.locale) {
      AppLocale.ru => 'Стрик',
      AppLocale.kk => 'Стрик',
      _ => 'Streak',
    };

    return GlowCard(
      accent: colors.divider,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '$streakWord: ${widget.streak}',
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showMonthYearPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _monthNames[_currentMonth.month - 1],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_currentMonth.year}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: colors.textPrimary),
                    onPressed: _previousMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: colors.textPrimary),
                    onPressed: _nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Column(children: rows),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    int day, {
    required DateTime date,
    required bool isCurrentMonth,
    required AppThemeColors colors,
  }) {
    final isFlame = widget.activeDates.contains(_dateOnly(date));
    return Expanded(
      child: Center(
        child: isFlame
            ? Icon(Icons.check_circle_rounded, color: colors.success, size: 18)
            : Text(
                '$day',
                style: TextStyle(
                  color: isCurrentMonth
                      ? colors.textPrimary
                      : colors.textSecondary.withValues(alpha: 0.5),
                  fontWeight: isCurrentMonth
                      ? FontWeight.w600
                      : colors.textPrimary.a > 0.5
                      ? FontWeight.w500
                      : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class _CircularProgressCard extends StatelessWidget {
  const _CircularProgressCard({
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int percent;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: GlowCard(
          accent: color,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle.isNotEmpty ? subtitle : 'Нет начатых тем',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: percent / 100.0,
                          strokeWidth: 7,
                          backgroundColor: colors.backgroundElevated,
                          color: color,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentDiagnosticCard extends StatelessWidget {
  const _AssessmentDiagnosticCard({
    required this.colors,
    required this.locale,
    required this.onTap,
  });

  final AppThemeColors colors;
  final AppLocale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = switch (locale) {
      AppLocale.ru => 'Оценка знаний и диагностика',
      AppLocale.kk => 'Білімді бағалау және диагностика',
      _ => 'Knowledge Assessment & Diagnostics',
    };

    final description = switch (locale) {
      AppLocale.ru =>
        'Пройдите быстрое адаптивное тестирование по фундаментальным концепциям Computer Science! Система автоматически определит ваш уровень и сформирует персональные рекомендации в Дереве Знаний.',
      AppLocale.kk =>
        'Компьютерлік ғылымдардың іргелі тұжырымдамалары бойынша жылдам бейімделген тестілеуден өтіңіз! Жүйе сіздің деңгейіңізді автоматты түрде анықтап, Білім ағашында дербес ұсыныстар жасайды.',
      _ =>
        'Take a quick adaptive test on the fundamental concepts of Computer Science! The system will automatically determine your level and generate personalized recommendations in the Knowledge Tree.',
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: GlowCard(
          accent: colors.primary,
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.psychology_rounded,
                            color: colors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(Icons.chevron_right_rounded, color: colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedGreeting extends StatefulWidget {
  const _AnimatedGreeting({required this.userName, required this.locale});

  final String userName;
  final AppLocale locale;

  @override
  State<_AnimatedGreeting> createState() => _AnimatedGreetingState();
}

class _AnimatedGreetingState extends State<_AnimatedGreeting>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: -0.12,
      end: 0.12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return switch (widget.locale) {
        AppLocale.ru => 'Доброе утро',
        AppLocale.kk => 'Қайырлы таң',
        _ => 'Good morning',
      };
    } else if (hour >= 12 && hour < 18) {
      return switch (widget.locale) {
        AppLocale.ru => 'Добрый день',
        AppLocale.kk => 'Қайырлы күн',
        _ => 'Good afternoon',
      };
    } else if (hour >= 18 && hour < 23) {
      return switch (widget.locale) {
        AppLocale.ru => 'Добрый вечер',
        AppLocale.kk => 'Кеш жарық',
        _ => 'Good evening',
      };
    } else {
      return switch (widget.locale) {
        AppLocale.ru => 'Доброй ночи',
        AppLocale.kk => 'Қайырлы түн',
        _ => 'Good night',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    '$greeting, ${widget.userName}!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: context.isCompactLayout ? 24 : 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: _rotationAnimation,
                  child: const Text('👋', style: TextStyle(fontSize: 28)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CurrentTrackCard extends StatelessWidget {
  const _CurrentTrackCard({
    required this.track,
    required this.progress,
    required this.xp,
    required this.colors,
    required this.locale,
    required this.onTap,
  });

  final LearningTrack track;
  final TrackProgress progress;
  final int xp;
  final AppThemeColors colors;
  final AppLocale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final level = (xp / 200).floor() + 1;
    final xpInCurrentLevel = xp % 200;
    final xpNeededForNext = 200 - xpInCurrentLevel;

    final labelCurrentTrack = switch (locale) {
      AppLocale.ru => 'ТЕКУЩИЙ ТРЕК',
      AppLocale.kk => 'АҒЫМДАҒЫ ТРЕК',
      _ => 'CURRENT TRACK',
    };

    final labelCompleted = switch (locale) {
      AppLocale.ru =>
        '${progress.completedUnits} из ${progress.totalUnits} разделов завершено',
      AppLocale.kk =>
        '${progress.completedUnits} / ${progress.totalUnits} бөлім аяқталды',
      _ =>
        '${progress.completedUnits} of ${progress.totalUnits} units completed',
    };

    final labelNextLevel = switch (locale) {
      AppLocale.ru => 'До следующего уровня: $xpNeededForNext XP',
      AppLocale.kk => 'Келесі деңгейге дейін: $xpNeededForNext XP',
      _ => 'Next level in: $xpNeededForNext XP',
    };

    final labelContinue = switch (locale) {
      AppLocale.ru => 'Продолжить обучение',
      AppLocale.kk => 'Оқуды жалғастыру',
      _ => 'Continue Learning',
    };

    return GlowCard(
      accent: track.color,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: track.color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(track.icon, color: track.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    labelCurrentTrack,
                    style: TextStyle(
                      color: colors.textSecondary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      'Lv.$level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$xp XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Track Title
          Text(
            track.title.resolve(locale),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            labelCompleted,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // Bubble Progress Bar
          BubbleProgressBar(
            value: progress.fraction,
            color: track.color,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            height: 10,
          ),
          const SizedBox(height: 14),
          Text(
            labelNextLevel,
            style: TextStyle(
              color: colors.textSecondary.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          AppGuideTarget(
            id: AppGuideTargetIds.homeContinue,
            child: _AnimatedPremiumButton(
              onTap: onTap,
              label: labelContinue,
              color: track.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPremiumButton extends StatefulWidget {
  const _AnimatedPremiumButton({
    required this.onTap,
    required this.label,
    required this.color,
  });

  final VoidCallback onTap;
  final String label;
  final Color color;

  @override
  State<_AnimatedPremiumButton> createState() => _AnimatedPremiumButtonState();
}

class _AnimatedPremiumButtonState extends State<_AnimatedPremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Animated Border Gradient
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: SweepGradient(
                        center: Alignment.center,
                        startAngle: 0,
                        endAngle: 3.14 * 2,
                        transform: GradientRotation(
                          _controller.value * 3.14 * 2,
                        ),
                        colors: [
                          widget.color.withValues(alpha: 0),
                          widget.color,
                          widget.color.withValues(alpha: 0),
                        ],
                        stops: const [0.35, 0.5, 0.65],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Background Layer (slightly smaller to show border)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(2), // Border width
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            // Interaction Layer
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.black87,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
