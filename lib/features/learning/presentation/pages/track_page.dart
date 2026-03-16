import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

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
    final l10n = context.l10n;

    return AppPageScaffold(
      title: l10n.text('track_overview'),
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  track.description.resolve(state.locale),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
                    backgroundColor: AppColors.backgroundElevated,
                    color: track.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  track.outcome.resolve(state.locale),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                AppButton.primary(
                  label: track.isPlayable
                      ? l10n.text('start_track')
                      : l10n.text('unlock_later'),
                  icon: track.isPlayable ? Icons.rocket_launch_rounded : Icons.lock_rounded,
                  onPressed: track.isPlayable
                      ? () {
                          controller.setCurrentTrack(track.id);
                          final nextTarget = progress.nextTarget;
                          if (nextTarget == null) {
                            return;
                          }
                          context.push(
                            nextTarget.isPractice
                                ? AppRoutes.practiceById(nextTarget.id)
                                : AppRoutes.lessonById(nextTarget.id),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.text('modules'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...track.modules.map((module) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlowCard(
                  accent: track.color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title.resolve(state.locale),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        module.summary.resolve(state.locale),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (track.isPlayable) ...[
                        const SizedBox(height: 14),
                        ...module.lessons.map((lesson) => ListTile(
                              onTap: () {
                                controller.focusLesson(lesson.id);
                                context.push(AppRoutes.lessonById(lesson.id));
                              },
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                lesson.title.resolve(state.locale),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                lesson.summary.resolve(state.locale),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                            )),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
