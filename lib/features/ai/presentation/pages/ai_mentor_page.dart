import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class AiMentorPage extends ConsumerStatefulWidget {
  const AiMentorPage({super.key});

  @override
  ConsumerState<AiMentorPage> createState() => _AiMentorPageState();
}

class _AiMentorPageState extends ConsumerState<AiMentorPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    ref.read(demoAppControllerProvider.notifier).sendAiMessage(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final l10n = context.l10n;
    final prompts = catalog.suggestedPrompts(state);
    final focusedTitle = state.focusedLessonId == null
        ? state.focusedPracticeId == null
            ? catalog.trackById(state.currentTrackId).title.resolve(state.locale)
            : catalog.practiceById(state.focusedPracticeId!).title.resolve(state.locale)
        : catalog.lessonById(state.focusedLessonId!).title.resolve(state.locale);

    return AppPageScaffold(
      title: l10n.text('ai_mentor'),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              children: [
                GlowCard(
                  accent: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.text('current_focus'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        focusedTitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlowCard(
                  accent: AppColors.accent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.text('suggested_prompts'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: prompts.map((prompt) {
                          return ActionChip(
                            label: Text(prompt),
                            onPressed: () {
                              ref.read(demoAppControllerProvider.notifier).sendAiMessage(prompt);
                            },
                            side: const BorderSide(color: AppColors.divider),
                            backgroundColor: AppColors.surfaceSoft,
                          );
                        }).toList(growable: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (state.aiMessages.isEmpty)
                  GlowCard(
                    accent: AppColors.success,
                    child: Text(
                      l10n.text('empty_chat'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  )
                else
                  ...state.aiMessages.map(
                    (message) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MessageBubble(
                        message: message,
                        locale: state.locale,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GlowCard(
              accent: AppColors.primary,
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.text('message_hint'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton.primary(
                    label: l10n.text('send_message'),
                    icon: Icons.send_rounded,
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.locale,
  });

  final AiMessage message;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final isMentor = message.author == AiAuthor.mentor;
    final accent = isMentor ? AppColors.primary : AppColors.accent;

    return Align(
      alignment: isMentor ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlowCard(
          accent: accent,
          child: Column(
            crossAxisAlignment:
                isMentor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                isMentor ? 'AI Mentor' : 'You',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message.text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
