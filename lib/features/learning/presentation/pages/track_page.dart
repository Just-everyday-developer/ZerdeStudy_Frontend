import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class TrackPage extends ConsumerWidget {
  const TrackPage({
    super.key,
    required this.trackId,
  });

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final track = catalog.trackById(trackId);
    final progress = catalog.progressForTrack(state, trackId);
    final assessmentResult = catalog.assessmentResultFor(state, trackId);
    final colors = context.appColors;

    return AppPageScaffold(
      title: context.l10n.text('track_overview'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
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
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  track.description.resolve(state.locale),
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.fraction,
                    minHeight: 10,
                    backgroundColor: colors.backgroundElevated,
                    color: track.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${progress.completedUnits}/${progress.totalUnits} units | ${progress.completedQuizzes}/${progress.totalQuizzes} quizzes | ${progress.completedTrainers}/${progress.totalTrainers} labs',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),
                Container(
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
                          Expanded(
                            child: Text(
                              'Track assessment',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            assessmentResult == null
                                ? 'Not started'
                                : '${assessmentResult.bestPercent}% best',
                            style: TextStyle(
                              color: assessmentResult == null
                                  ? colors.textSecondary
                                  : track.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        assessmentResult == null
                            ? 'Complete the 10-question branch assessment to store your result in the tree, profile, and statistics.'
                            : 'Last result: ${assessmentResult.lastPercent}%  •  Attempts: ${assessmentResult.attemptCount}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppButton.secondary(
                        label: assessmentResult == null
                            ? 'Start assessment'
                            : 'Retake assessment',
                        icon: Icons.assignment_turned_in_rounded,
                        onPressed: () => context.push(
                          AppRoutes.assessmentByTrackId(track.id),
                        ),
                      ),
                    ],
                  ),
                ),
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
              child: GlowCard(
                accent: track.color,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title.resolve(state.locale),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      module.summary.resolve(state.locale),
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...module.lessons.map(
                      (lesson) => ListTile(
                        onTap: () {
                          controller.focusLesson(lesson.id);
                          context.push(AppRoutes.lessonById(lesson.id));
                        },
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          lesson.title.resolve(state.locale),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          lesson.summary.resolve(state.locale),
                          style: TextStyle(
                            color: colors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    if (module.practice != null)
                      ListTile(
                        onTap: () {
                          controller.focusPractice(module.practice!.id);
                          context.push(
                            AppRoutes.practiceById(module.practice!.id),
                          );
                        },
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          module.practice!.title.resolve(state.locale),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          module.practice!.summary.resolve(state.locale),
                          style: TextStyle(
                            color: colors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: colors.textSecondary,
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
