import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/common_widgets/bubble_progress_bar.dart';
import '../../../courses_backend/data/models/backend_progress_dto.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';

class TrackPage extends ConsumerWidget {
  const TrackPage({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final compact = context.isCompactLayout;

    final LearningTrack track;
    final TrackProgress progress;

    if (trackId == 'oop') {
      final backendTrackAsync = ref.watch(backendOopTrackProvider);
      final backendTrack = backendTrackAsync.maybeWhen(
        data: (t) => t,
        orElse: () => null,
      );
      track = backendTrack ?? catalog.trackById(trackId);
      final localProgress = backendTrack != null
          ? _computeTrackProgress(state, backendTrack)
          : catalog.progressForTrack(state, trackId);
      // Overlay server-tracked progress (lessons completed via the curriculum
      // service) when available; fall back to locally computed progress.
      final backendProgress = ref
          .watch(backendOopProgressProvider)
          .maybeWhen(data: (p) => p, orElse: () => null);
      progress = (backendProgress != null && backendProgress.totalLessons > 0)
          ? _mergeBackendProgress(localProgress, backendProgress)
          : localProgress;
    } else {
      track = catalog.trackById(trackId);
      progress = catalog.progressForTrack(state, trackId);
    }

    return AppPageScaffold(
      title: context.l10n.text('track_overview'),
      horizontalPadding: compact ? 0 : null,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 20,
          8,
          compact ? 16 : 20,
          40,
        ),
        children: [
          _TrackSurface(
            compact: compact,
            accent: track.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(track.icon, color: track.color, size: 42),
                const SizedBox(height: 14),
                Text(
                  track.title.resolve(state.locale),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  track.subtitle.resolve(state.locale),
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  track.heroMetric.resolve(state.locale),
                  style: TextStyle(
                    color: track.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                BubbleProgressBar(
                  value: progress.fraction,
                  color: track.color,
                  backgroundColor: context.appColors.backgroundElevated,
                  height: 10,
                ),
                const SizedBox(height: 12),
                Text(
                  '${progress.completedUnits}/${progress.totalUnits} units | ${progress.completedQuizzes}/${progress.totalQuizzes} quizzes | ${progress.completedTrainers}/${progress.totalTrainers} labs',
                  style: TextStyle(color: context.appColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 18),
                AppButton.primary(
                  label: context.l10n.text('start_track'),
                  icon: Icons.rocket_launch_rounded,
                  onPressed: () {
                    controller.setCurrentTrack(track.id);
                    final target = progress.nextTarget;
                    if (target == null) {
                      return;
                    }
                    context.push(
                      target.isPractice
                          ? AppRoutes.practiceById(target.id)
                          : AppRoutes.lessonById(target.id),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.text('modules'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...track.modules.map(
            (module) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TrackSurface(
                compact: compact,
                accent: track.color,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title.resolve(state.locale),
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      module.summary.resolve(state.locale),
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...module.lessons.map((lesson) {
                      final isCompleted = state.completedLessonIds.contains(
                        lesson.id,
                      );
                      final isStarted = state.startedLessonIds.contains(
                        lesson.id,
                      );
                      final statusLabel = isCompleted
                          ? (state.locale == AppLocale.ru
                                ? 'Пройдено'
                                : (state.locale == AppLocale.kk
                                      ? 'Аяқталды'
                                      : 'Completed'))
                          : isStarted
                          ? (state.locale == AppLocale.ru
                                ? 'В процессе'
                                : (state.locale == AppLocale.kk
                                      ? 'Орындалуда'
                                      : 'In Progress'))
                          : '';

                      return ListTile(
                        onTap: () {
                          controller.focusLesson(lesson.id);
                          context.push(AppRoutes.lessonById(lesson.id));
                        },
                        contentPadding: EdgeInsets.zero,
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              lesson.title.resolve(state.locale),
                              style: TextStyle(
                                color: context.appColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (statusLabel.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? context.appColors.success.withValues(
                                          alpha: 0.12,
                                        )
                                      : context.appColors.accent.withValues(
                                          alpha: 0.12,
                                        ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isCompleted
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.pending_actions_rounded,
                                      size: 11,
                                      color: isCompleted
                                          ? context.appColors.success
                                          : context.appColors.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusLabel,
                                      style: TextStyle(
                                        color: isCompleted
                                            ? context.appColors.success
                                            : context.appColors.accent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          lesson.summary.resolve(state.locale),
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: context.appColors.textSecondary,
                        ),
                      );
                    }),
                    if (module.allPractices.isNotEmpty) ...[
                      for (final practice in module.allPractices)
                        (() {
                          final isCompleted = state.completedPracticeIds
                              .contains(practice.id);
                          final isFocused =
                              state.focusedPracticeId == practice.id;
                          final statusLabel = isCompleted
                              ? (state.locale == AppLocale.ru
                                    ? 'Пройдено'
                                    : (state.locale == AppLocale.kk
                                          ? 'Аяқталды'
                                          : 'Completed'))
                              : isFocused
                              ? (state.locale == AppLocale.ru
                                    ? 'В процессе'
                                    : (state.locale == AppLocale.kk
                                          ? 'Орындалуда'
                                          : 'In Progress'))
                              : '';

                          final summary = practice.summary
                              .resolve(state.locale)
                              .trim();

                          return ListTile(
                            onTap: () {
                              controller.focusPractice(practice.id);
                              context.push(AppRoutes.practiceById(practice.id));
                            },
                            contentPadding: EdgeInsets.zero,
                            title: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  practice.title.resolve(state.locale),
                                  style: TextStyle(
                                    color: context.appColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (statusLabel.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? context.appColors.success
                                                .withValues(alpha: 0.12)
                                          : context.appColors.accent.withValues(
                                              alpha: 0.12,
                                            ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isCompleted
                                              ? Icons
                                                    .check_circle_outline_rounded
                                              : Icons.pending_actions_rounded,
                                          size: 11,
                                          color: isCompleted
                                              ? context.appColors.success
                                              : context.appColors.accent,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          statusLabel,
                                          style: TextStyle(
                                            color: isCompleted
                                                ? context.appColors.success
                                                : context.appColors.accent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: summary.isEmpty
                                ? null
                                : Text(
                                    summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.appColors.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: context.appColors.textSecondary,
                            ),
                          );
                        })(),
                    ],
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

/// Overlays server-tracked lesson progress onto the locally computed
/// [TrackProgress], keeping local quiz/trainer counts and next target.
TrackProgress _mergeBackendProgress(
  TrackProgress local,
  BackendCourseProgressDto backend,
) {
  final total = backend.totalLessons;
  final completed = backend.completedLessons.clamp(0, total);
  final availability = completed == 0
      ? TrackAvailability.available
      : completed < total
      ? TrackAvailability.inProgress
      : TrackAvailability.completed;

  return TrackProgress(
    state: availability,
    completedUnits: completed,
    totalUnits: total,
    completedQuizzes: backend.passedQuizIds.isNotEmpty
        ? backend.passedQuizIds.length
        : local.completedQuizzes,
    totalQuizzes: local.totalQuizzes,
    completedTrainers: local.completedTrainers,
    totalTrainers: local.totalTrainers,
    nextTarget: local.nextTarget,
  );
}

TrackProgress _computeTrackProgress(DemoAppState state, LearningTrack track) {
  var completedUnits = 0;
  LearningTarget? nextTarget;

  for (final module in track.modules) {
    for (final lesson in module.lessons) {
      if (state.completedLessonIds.contains(lesson.id)) {
        completedUnits += 1;
      } else {
        nextTarget ??= LearningTarget.lesson(lesson);
      }
    }
    for (final practice in module.allPractices) {
      if (state.completedPracticeIds.contains(practice.id)) {
        completedUnits += 1;
      } else {
        nextTarget ??= LearningTarget.practice(practice);
      }
    }
  }

  final quizIds = <String>[
    for (final module in track.modules)
      for (final lesson in module.lessons)
        for (final quiz in lesson.quizzes) quiz.id,
  ];

  final availability = completedUnits == 0
      ? TrackAvailability.available
      : completedUnits < track.totalUnits
      ? TrackAvailability.inProgress
      : TrackAvailability.completed;

  return TrackProgress(
    state: availability,
    completedUnits: completedUnits,
    totalUnits: track.totalUnits,
    completedQuizzes: quizIds
        .where((quizId) => state.completedQuizIds.contains(quizId))
        .length,
    totalQuizzes: quizIds.length,
    completedTrainers: 0,
    totalTrainers: 0,
    nextTarget: nextTarget,
  );
}

class _TrackSurface extends StatelessWidget {
  const _TrackSurface({
    required this.compact,
    required this.accent,
    required this.child,
  });

  final bool compact;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!compact) {
      return GlowCard(accent: accent, child: child);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: context.appColors.surface.withValues(alpha: 0.96),
      ),
      child: child,
    );
  }
}
