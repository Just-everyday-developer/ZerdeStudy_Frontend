import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final currentTrack = catalog.trackById(state.currentTrackId);
    final progress = catalog.progressForTrack(state, currentTrack.id);
    final assessmentResult =
        catalog.assessmentResultFor(state, currentTrack.id);
    final colors = context.appColors;

    return AppPageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: catalog.tracks.map((track) {
              final selected = track.id == currentTrack.id;
              return ChoiceChip(
                label: Text(track.title.resolve(state.locale)),
                selected: selected,
                onSelected: (_) => controller.setCurrentTrack(track.id),
                selectedColor: track.color.withValues(alpha: 0.18),
                backgroundColor: colors.surfaceSoft,
                side: BorderSide(
                  color: selected ? track.color : colors.divider,
                ),
                labelStyle: TextStyle(
                  color: selected ? track.color : colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: currentTrack.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.text('current_focus'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  currentTrack.title.resolve(state.locale),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  currentTrack.outcome.resolve(state.locale),
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.fraction,
                    minHeight: 10,
                    backgroundColor: colors.backgroundElevated,
                    color: currentTrack.color,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${progress.completedUnits}/${progress.totalUnits} units | ${progress.completedQuizzes}/${progress.totalQuizzes} quizzes | ${progress.completedTrainers}/${progress.totalTrainers} labs',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: colors.surfaceSoft,
                    border: Border.all(color: colors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assessment progress',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              assessmentResult == null
                                  ? 'No attempts yet'
                                  : 'Best ${assessmentResult.bestPercent}%  •  Last ${assessmentResult.lastPercent}%',
                              style: TextStyle(
                                color: colors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push(
                          AppRoutes.assessmentByTrackId(currentTrack.id),
                        ),
                        icon: Icon(
                          Icons.assignment_turned_in_rounded,
                          color: currentTrack.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...currentTrack.modules.map(
            (module) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ModuleCard(
                module: module,
                locale: state.locale,
                completedLessonIds: state.completedLessonIds,
                completedPracticeIds: state.completedPracticeIds,
                onLessonTap: (lesson) {
                  controller.focusLesson(lesson.id);
                  context.push(AppRoutes.lessonById(lesson.id));
                },
                onPracticeTap: (practice) {
                  controller.focusPractice(practice.id);
                  context.push(AppRoutes.practiceById(practice.id));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.locale,
    required this.completedLessonIds,
    required this.completedPracticeIds,
    required this.onLessonTap,
    required this.onPracticeTap,
  });

  final LearningModule module;
  final AppLocale locale;
  final Set<String> completedLessonIds;
  final Set<String> completedPracticeIds;
  final ValueChanged<LessonItem> onLessonTap;
  final ValueChanged<PracticeTask> onPracticeTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GlowCard(
      accent: const Color(0xFF5CE6FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module.title.resolve(locale),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            module.summary.resolve(locale),
            style: TextStyle(color: colors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          ...module.lessons.map(
            (lesson) => _UnitTile(
              title: lesson.title.resolve(locale),
              subtitle: lesson.summary.resolve(locale),
              icon: Icons.play_lesson_rounded,
              completed: completedLessonIds.contains(lesson.id),
              onTap: () => onLessonTap(lesson),
            ),
          ),
          if (module.practice != null)
            _UnitTile(
              title: module.practice!.title.resolve(locale),
              subtitle: module.practice!.summary.resolve(locale),
              icon: Icons.code_rounded,
              completed: completedPracticeIds.contains(module.practice!.id),
              onTap: () => onPracticeTap(module.practice!),
            ),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.completed,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (completed ? colors.success : colors.primary)
            .withValues(alpha: 0.18),
        child: Icon(
          completed ? Icons.check_rounded : icon,
          color: completed ? colors.success : colors.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colors.textSecondary, height: 1.3),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
    );
  }
}
