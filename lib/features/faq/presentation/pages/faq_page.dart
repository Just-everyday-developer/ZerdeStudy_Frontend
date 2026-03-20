import 'package:flutter/material.dart';

import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final items = <({String question, String answer, IconData icon})>[
      (
        question: l10n.text('faq_q_platform'),
        answer: l10n.text('faq_a_platform'),
        icon: Icons.space_dashboard_rounded,
      ),
      (
        question: l10n.text('faq_q_tree'),
        answer: l10n.text('faq_a_tree'),
        icon: Icons.account_tree_rounded,
      ),
      (
        question: l10n.text('faq_q_courses'),
        answer: l10n.text('faq_a_courses'),
        icon: Icons.auto_stories_rounded,
      ),
      (
        question: l10n.text('faq_q_ai'),
        answer: l10n.text('faq_a_ai'),
        icon: Icons.smart_toy_rounded,
      ),
      (
        question: l10n.text('faq_q_certificates'),
        answer: l10n.text('faq_a_certificates'),
        icon: Icons.workspace_premium_rounded,
      ),
      (
        question: l10n.text('faq_q_profile'),
        answer: l10n.text('faq_a_profile'),
        icon: Icons.person_rounded,
      ),
    ];

    return AppPageScaffold(
      title: l10n.text('faq_title'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('faq_subtitle'),
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlowCard(
                accent: colors.accent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: colors.primary.withValues(alpha: 0.16),
                      ),
                      child: Icon(item.icon, color: colors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.question,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.answer,
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
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
