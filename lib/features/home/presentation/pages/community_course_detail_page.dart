import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class CommunityCourseDetailPage extends ConsumerStatefulWidget {
  const CommunityCourseDetailPage({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  ConsumerState<CommunityCourseDetailPage> createState() =>
      _CommunityCourseDetailPageState();
}

class _CommunityCourseDetailPageState
    extends ConsumerState<CommunityCourseDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(demoAppControllerProvider.notifier)
          .viewCommunityCourse(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final course = catalog.courseById(widget.courseId);
    final saved = state.savedCommunityCourseIds.contains(widget.courseId);
    final colors = context.appColors;
    final l10n = context.l10n;

    return AppPageScaffold(
      title: course.title.resolve(state.locale),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: course.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.subtitle.resolve(state.locale),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  course.description.resolve(state.locale),
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Meta(label: l10n.courseLevelLabel(course.level)),
                    _Meta(
                      label:
                          '${course.rating.toStringAsFixed(1)} ${l10n.text('rating')}',
                    ),
                    _Meta(
                      label: '${course.enrollmentCount} ${l10n.text('enrolled')}',
                    ),
                    _Meta(label: '${course.estimatedHours}h'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course.author.name} | ${course.author.role}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  course.author.accentLabel,
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: course.tags
                      .map((tag) => _Meta(label: tag))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...course.lessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlowCard(
                accent: course.color,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title.resolve(state.locale),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson.summary.resolve(state.locale),
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.format(
                        'preview_minutes',
                        <String, Object>{'minutes': lesson.durationMinutes},
                      ),
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppButton.primary(
            label: saved ? l10n.text('saved_to_profile') : l10n.text('save_course'),
            icon:
                saved ? Icons.check_circle_rounded : Icons.bookmark_add_rounded,
            onPressed: saved
                ? null
                : () => controller.saveCommunityCourse(widget.courseId),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceSoft,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
