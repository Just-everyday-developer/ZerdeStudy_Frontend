import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/constants/app_colors.dart';

class CommunityCoursesPage extends ConsumerWidget {
  const CommunityCoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);

    return AppPageScaffold(
      title: 'Community courses',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: catalog.communityCourses.map((course) {
          final saved = state.savedCommunityCourseIds.contains(course.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlowCard(
              accent: course.color,
              child: InkWell(
                onTap: () => context.push(AppRoutes.courseById(course.id)),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.title.resolve(state.locale), style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 6),
                              Text(course.subtitle.resolve(state.locale), style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: course.color.withValues(alpha: 0.14),
                          ),
                          child: Text(saved ? 'Saved' : course.level, style: TextStyle(color: course.color, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(course.description.resolve(state.locale), style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(label: '${course.rating.toStringAsFixed(1)} rating'),
                        _Pill(label: '${course.enrollmentCount} enrolled'),
                        _Pill(label: '${course.estimatedHours}h'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.surfaceSoft,
      ),
      child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    );
  }
}
