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

class PracticePage extends ConsumerWidget {
  const PracticePage({
    super.key,
    required this.practiceId,
  });

  final String practiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final practice = catalog.practiceById(practiceId);
    final completed = state.completedPracticeIds.contains(practiceId);
    final l10n = context.l10n;

    return AppPageScaffold(
      title: practice.title.resolve(state.locale),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: AppColors.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  practice.summary.resolve(state.locale),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  practice.brief.resolve(state.locale),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Starter Code',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    practice.starterCode,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: AppColors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Success Criteria',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...practice.successCriteria.map((criterion) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              criterion.resolve(state.locale),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton.primary(
            label: completed
                ? l10n.text('status_completed')
                : l10n.text('complete_practice'),
            icon: completed ? Icons.check_circle_rounded : Icons.code_rounded,
            onPressed: completed
                ? null
                : () {
                    controller.completePractice(practiceId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('+${practice.xpReward} XP')),
                    );
                  },
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: l10n.text('ask_ai'),
            icon: Icons.smart_toy_rounded,
            onPressed: () {
              controller.focusPractice(practiceId);
              controller.sendAiMessage(practice.promptSuggestion.resolve(state.locale));
              context.go(AppRoutes.ai);
            },
          ),
        ],
      ),
    );
  }
}
