import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../ai/presentation/providers/ai_chat_controller.dart';

class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({super.key, required this.practiceId});

  final String practiceId;

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  final Set<int> _checkedKnowledgeItems = <int>{};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final controller = ref.read(demoAppControllerProvider.notifier);
    final catalog = ref.watch(demoCatalogProvider);
    final practice = catalog.practiceById(widget.practiceId);
    final completed = state.completedPracticeIds.contains(widget.practiceId);
    final checksComplete =
        _checkedKnowledgeItems.length == practice.knowledgeChecks.length;
    final colors = context.appColors;

    return AppPageScaffold(
      title: practice.title.resolve(state.locale),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: colors.accent,
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
                  style: TextStyle(color: colors.textSecondary, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.primary,
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
                    color: colors.backgroundElevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    practice.starterCode,
                    style: TextStyle(
                      color: colors.textPrimary,
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
            accent: colors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Success Criteria',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...practice.successCriteria.map(
                  (criterion) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: colors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            criterion.resolve(state.locale),
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick check',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ...practice.knowledgeChecks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final check = entry.value;
                  final selected = _checkedKnowledgeItems.contains(index);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: completed
                        ? null
                        : (value) {
                            setState(() {
                              if (value == true) {
                                _checkedKnowledgeItems.add(index);
                              } else {
                                _checkedKnowledgeItems.remove(index);
                              }
                            });
                          },
                    title: Text(
                      check.resolve(state.locale),
                      style: TextStyle(color: colors.textPrimary),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton.primary(
            label: completed
                ? context.l10n.text('status_completed')
                : context.l10n.text('complete_practice'),
            icon: completed ? Icons.check_circle_rounded : Icons.code_rounded,
            onPressed: completed || !checksComplete
                ? null
                : () {
                    controller.completePractice(widget.practiceId);
                    AppNotice.show(
                      context,
                      message: '+${practice.xpReward} XP',
                      type: AppNoticeType.success,
                    );
                  },
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            label: context.l10n.text('ask_ai'),
            icon: Icons.smart_toy_rounded,
            onPressed: () {
              controller.focusPractice(widget.practiceId);
              context.go(AppRoutes.ai);
              unawaited(
                ref
                    .read(aiChatControllerProvider.notifier)
                    .sendMessage(
                      practice.promptSuggestion.resolve(state.locale),
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
