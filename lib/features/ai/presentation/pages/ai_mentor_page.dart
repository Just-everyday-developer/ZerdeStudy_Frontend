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
                _FaqSection(
                  locale: state.locale,
                  onAsk: (question) {
                    ref.read(demoAppControllerProvider.notifier).sendAiMessage(
                          question,
                        );
                  },
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

class _FaqSection extends StatelessWidget {
  const _FaqSection({
    required this.locale,
    required this.onAsk,
  });

  final AppLocale locale;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final items = _faqItemsFor(locale);

    return GlowCard(
      accent: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == AppLocale.ru ? 'Частые вопросы' : 'Common questions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            locale == AppLocale.ru
                ? 'Откройте популярные вопросы по дереву знаний и обучающим трекам.'
                : 'Browse common questions about the knowledge tree and learning tracks.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FaqCard(
                item: item,
                askLabel: locale == AppLocale.ru ? 'Использовать вопрос' : 'Use question',
                onAsk: () => onAsk(item.question),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_FaqItem> _faqItemsFor(AppLocale locale) {
    if (locale == AppLocale.ru) {
      return const <_FaqItem>[
        _FaqItem(
          question: 'Почему дерево начинается с Computer Science Core?',
          answer:
              'Потому что это общий фундамент: математика, архитектура компьютера, ОС, сети и базы данных объясняют, как реально ведут себя данные, код и системы.',
        ),
        _FaqItem(
          question: 'Как из core-тем дерево переходит в backend, frontend и другие сферы?',
          answer:
              'Через Fundamentals и прикладные связи: сети и базы данных естественно ведут в backend, ОС и lifecycle помогают mobile и SRE, а математика и статистика ведут в machine learning.',
        ),
        _FaqItem(
          question: 'Что важно сказать про Operating Systems на презентации?',
          answer:
              'ОС управляет процессами, памятью, файлами и доступом к ресурсам. Это слой, который связывает код приложения с реальным железом и поведением системы.',
        ),
        _FaqItem(
          question: 'Зачем в уроках нужны Output Quiz и Code Memory Lab?',
          answer:
              'Output Quiz проверяет понимание выполнения кода, а Code Memory Lab закрепляет синтаксис и структуру через короткие тренажеры. Вместе они делают урок более живым и убедительным на демо.',
        ),
        _FaqItem(
          question: 'Какие темы из core важнее всего для machine learning?',
          answer:
              'Линейная алгебра помогает понимать векторы и преобразования, а вероятность и статистика нужны для оценки моделей, метрик и уверенности в результате.',
        ),
        _FaqItem(
          question: 'Как выбрать следующую ветку после изучения текущей?',
          answer:
              'Ориентируйтесь на связи в дереве: после core-тем обычно удобно идти в Fundamentals, а затем переходить в прикладную сферу, которая опирается на этот фундамент.',
        ),
      ];
    }

    return const <_FaqItem>[
      _FaqItem(
        question: 'Why does the tree begin with Computer Science Core?',
        answer:
            'Because the core topics explain how software, data, hardware, and systems really behave before the learner picks a specialization.',
      ),
      _FaqItem(
        question: 'How does the tree move from core topics into backend, frontend, and the other spheres?',
        answer:
            'The bridge is Fundamentals plus applied connections: networks and databases feed backend, operating systems support mobile and SRE, and math/statistics support machine learning.',
      ),
      _FaqItem(
        question: 'What is the strongest one-line explanation of Operating Systems?',
        answer:
            'Operating Systems manage processes, memory, files, and device access, connecting application logic to the actual runtime environment.',
      ),
      _FaqItem(
        question: 'Why do lessons include Output Quiz and Code Memory Lab?',
        answer:
            'The quiz checks whether the learner can reason about execution, while the memory lab reinforces syntax and code structure through small active exercises.',
      ),
      _FaqItem(
        question: 'Which core topics matter most for machine learning?',
        answer:
            'Linear algebra helps with vectors and transformations, while probability and statistics are essential for metrics, uncertainty, and model evaluation.',
      ),
      _FaqItem(
        question: 'How should I choose the next branch after this one?',
        answer:
            'Follow the nearby tree connections: after a core topic, move into Fundamentals or the closest applied sphere that builds on the same foundation.',
      ),
    ];
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({
    required this.item,
    required this.askLabel,
    required this.onAsk,
  });

  final _FaqItem item;
  final String askLabel;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceSoft,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.answer,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAsk,
              icon: const Icon(
                Icons.send_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                askLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}
