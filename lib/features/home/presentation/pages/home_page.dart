import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/app_locale.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _getLastTopicTitle(DemoAppState state, LearningTrack track) {
    for (final module in track.modules.reversed) {
      if (module.practice != null && state.completedPracticeIds.contains(module.practice!.id)) {
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
    final catalog = ref.watch(demoCatalogProvider);
    final currentTrack = catalog.trackById(state.currentTrackId);
    final currentProgress = catalog.progressForTrack(state, currentTrack.id);
    
    final leaderboard = catalog.leaderboardFor(state);
    final myRank = leaderboard.indexWhere((e) => e.isCurrentUser) + 1;
    final incorrectExercises = catalog.incorrectCourseExercisesFor(state);
    final incorrectQuizzes = catalog.incorrectTrackQuizzesFor(state);
    final mistakesCount = incorrectExercises.length + incorrectQuizzes.length;
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
              const SizedBox(height: 10),
              Text(
                currentTrack.description.resolve(state.locale),
                style: TextStyle(color: colors.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 18),
              _AssessmentDiagnosticCard(
                colors: colors,
                locale: state.locale,
                onTap: () {
                  context.push(AppRoutes.diagnostics);
                },
              ),
              if (mistakesCount > 0) ...[
                const SizedBox(height: 18),
                _MistakesLabCard(
                  mistakesCount: mistakesCount,
                  colors: colors,
                  onTap: () {
                    final target = currentProgress.nextTarget;
                    if (target != null) {
                      context.push(
                        target.isPractice
                            ? AppRoutes.practiceById(target.id)
                            : AppRoutes.lessonById(target.id),
                      );
                    }
                  },
                ),
              ],
              if (currentProgress.nextTarget != null) ...[
                const SizedBox(height: 18),
                _NextTargetCTACard(
                  target: currentProgress.nextTarget!,
                  trackColor: currentTrack.color,
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
                streak: state.streak,
                rank: myRank,
                colors: colors,
              ),
              const SizedBox(height: 24),
              
              // Knowledge Tree Section (Always at the top of progress cards)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  trackSectionTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              if (compact)
                ...trackCards
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: trackCards.map((card) => SizedBox(width: 340, child: card)).toList(),
                ),
              const SizedBox(height: 18),

              // External Courses Section (Always below Knowledge Tree)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  courseSectionTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              if (compact)
                ...courseCards
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: courseCards.map((card) => SizedBox(width: 340, child: card)).toList(),
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
    required this.rank,
    required this.colors,
  });

  final int streak;
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
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
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
                                    final isSelected = currentMonthIndex == index;
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        _monthNames[index],
                                        style: TextStyle(
                                          color: isSelected ? colors.primary : colors.textPrimary,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _currentMonth = DateTime(_currentMonth.year, index + 1, 1);
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
                                    final isSelected = _currentMonth.year == year;
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        '$year',
                                        style: TextStyle(
                                          color: isSelected ? colors.primary : colors.textPrimary,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _currentMonth = DateTime(year, _currentMonth.month, 1);
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
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = _currentMonth.weekday; // 1 = Mon, 7 = Sun
    final previousMonthDays = DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    final calendarDays = <Widget>[];
    
    // Previous month filler days
    for (int i = 1; i < firstWeekday; i++) {
      final day = previousMonthDays - firstWeekday + i + 1;
      calendarDays.add(_buildDayCell(day, isCurrentMonth: false, isFlame: false, colors: colors));
    }
    
    // Current month days
    for (int i = 1; i <= daysInMonth; i++) {
      bool isFlame = false;
      final cellDate = DateTime(_currentMonth.year, _currentMonth.month, i);
      final limitDate = DateTime(2026, 5, 12);
      
      if (!cellDate.isAfter(limitDate)) {
        isFlame = i % 3 != 0;
      } else {
        isFlame = false;
      }
      calendarDays.add(_buildDayCell(i, isCurrentMonth: true, isFlame: isFlame, colors: colors));
    }
    
    // Next month filler days
    final totalCellsNeeded = calendarDays.length <= 35 ? 35 : 42;
    final cellsToAdd = totalCellsNeeded - calendarDays.length;
    for (int i = 1; i <= cellsToAdd; i++) {
      calendarDays.add(_buildDayCell(i, isCurrentMonth: false, isFlame: false, colors: colors));
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: colors.primary),
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
                      Icon(Icons.arrow_drop_down_rounded, size: 20, color: colors.textPrimary),
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
                .map((day) => Expanded(
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
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Column(children: rows),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day, {required bool isCurrentMonth, required bool isFlame, required AppThemeColors colors}) {
    return Expanded(
      child: Center(
        child: isFlame 
            ? Icon(Icons.check_circle_rounded, color: colors.success, size: 18)
            : Text(
                '$day',
                style: TextStyle(
                  color: isCurrentMonth ? colors.textPrimary : colors.textSecondary.withValues(alpha: 0.5),
                  fontWeight: isCurrentMonth ? FontWeight.w600 : colors.textPrimary.a > 0.5 ? FontWeight.w500 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
      ),
    );
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

class _MistakesLabCard extends StatelessWidget {
  const _MistakesLabCard({
    required this.mistakesCount,
    required this.colors,
    required this.onTap,
  });

  final int mistakesCount;
  final AppThemeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: GlowCard(
        accent: colors.danger,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.build_rounded, color: colors.danger, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Лаборатория ошибок',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$mistakesCount нерешённых заданий ждут исправления',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.danger),
          ],
        ),
      ),
    ));
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
      AppLocale.ru => 'Пройдите быстрое адаптивное тестирование по фундаментальным концепциям Computer Science! Система автоматически определит ваш уровень и сформирует персональные рекомендации в Дереве Знаний.',
      AppLocale.kk => 'Компьютерлік ғылымдардың іргелі тұжырымдамалары бойынша жылдам бейімделген тестілеуден өтіңіз! Жүйе сіздің деңгейіңізді автоматты түрде анықтап, Білім ағашында дербес ұсыныстар жасайды.',
      _ => 'Take a quick adaptive test on the fundamental concepts of Computer Science! The system will automatically determine your level and generate personalized recommendations in the Knowledge Tree.',
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
                        child: Icon(Icons.psychology_rounded, color: colors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    ));
  }
}

class _AnimatedGreeting extends StatefulWidget {
  const _AnimatedGreeting({required this.userName, required this.locale});

  final String userName;
  final AppLocale locale;

  @override
  State<_AnimatedGreeting> createState() => _AnimatedGreetingState();
}

class _AnimatedGreetingState extends State<_AnimatedGreeting> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
                  child: const Text(
                    '👋',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NextTargetCTACard extends StatelessWidget {
  const _NextTargetCTACard({
    required this.target,
    required this.trackColor,
    required this.colors,
    required this.locale,
    required this.onTap,
  });

  final LearningTarget target;
  final Color trackColor;
  final AppThemeColors colors;
  final AppLocale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPractice = target.isPractice;
    final icon = isPractice ? Icons.fitness_center_rounded : Icons.menu_book_rounded;
    final tagText = isPractice
        ? (locale == AppLocale.ru ? 'ПРАКТИКА' : (locale == AppLocale.kk ? 'ТӘЖІРИБЕ' : 'PRACTICE'))
        : (locale == AppLocale.ru ? 'УРОК' : (locale == AppLocale.kk ? 'САБАҚ' : 'LESSON'));

    final actionLabel = isPractice
        ? (locale == AppLocale.ru ? 'Начать практику' : (locale == AppLocale.kk ? 'Тәжірибені бастау' : 'Start Practice'))
        : (locale == AppLocale.ru ? 'Перейти к уроку' : (locale == AppLocale.kk ? 'Сабаққа өту' : 'Go to Lesson'));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlowCard(
        accent: trackColor,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: trackColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: trackColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: trackColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tagText,
                      style: TextStyle(
                        color: trackColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    target.title.resolve(locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actionLabel,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: trackColor, size: 16),
          ],
        ),
      ),
    );
  }
}
