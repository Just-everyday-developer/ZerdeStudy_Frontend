import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';

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
    final message = _controller.text.trim();
    if (message.isEmpty) {
      return;
    }
    ref.read(demoAppControllerProvider.notifier).sendAiMessage(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demoAppControllerProvider);
    final catalog = ref.watch(demoCatalogProvider);
    final l10n = context.l10n;
    final prompts = catalog.suggestedPrompts(state);
    final colors = context.appColors;
    final compact = context.isCompactLayout;
    final focusedTitle = state.focusedLessonId == null
        ? state.focusedPracticeId == null
            ? catalog.trackById(state.currentTrackId).title.resolve(state.locale)
            : catalog
                .practiceById(state.focusedPracticeId!)
                .title
                .resolve(state.locale)
        : catalog.lessonById(state.focusedLessonId!).title.resolve(state.locale);

    return AppPageScaffold(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(0, compact ? 6 : 8, 0, 18),
              children: [
                GlowCard(
                  accent: colors.primary,
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
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
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
                              ref
                                  .read(demoAppControllerProvider.notifier)
                                  .sendAiMessage(prompt);
                            },
                            side: BorderSide(color: colors.divider),
                            backgroundColor: colors.surfaceSoft,
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
                    ref
                        .read(demoAppControllerProvider.notifier)
                        .sendAiMessage(question);
                  },
                ),
                const SizedBox(height: 16),
                if (state.aiMessages.isEmpty)
                  GlowCard(
                    accent: colors.success,
                    child: Text(
                      l10n.text('empty_chat'),
                      style: TextStyle(
                        color: colors.textSecondary,
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
            padding: EdgeInsets.fromLTRB(0, 0, 0, compact ? 16 : 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colors.divider),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: l10n.text('message_hint'),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: _send,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.textPrimary.withValues(alpha: 0.92),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: colors.background,
                          ),
                        ),
                      ),
                    ],
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
    final colors = context.appColors;
    final isMentor = message.author == AiAuthor.mentor;
    final accent = isMentor ? colors.primary : colors.accent;

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
                isMentor ? 'Mentor' : 'You',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message.text,
                style: TextStyle(
                  color: colors.textPrimary,
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
    final colors = context.appColors;

    return GlowCard(
      accent: colors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('prepared_questions'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.text('prepared_questions_hint'),
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FaqCard(
                item: item,
                askLabel: context.l10n.text('ask_now'),
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
          question: 'С чего лучше начать в этом дереве знаний?',
          answer:
              'Начните с core-тем: математика, алгоритмы, базы данных, сети и операционные системы дают основу почти для всех инженерных направлений.',
        ),
        _FaqItem(
          question: 'Как Operating Systems помогает понять backend и mobile?',
          answer:
              'ОС объясняют процессы, память, файлы, потоки и работу с ресурсами, а это напрямую влияет на серверные приложения и мобильный runtime.',
        ),
        _FaqItem(
          question: 'Какие core-темы особенно важны для ML Engineer?',
          answer:
              'Линейная алгебра, теория вероятностей и статистика особенно важны: они помогают понимать представление данных, обучение моделей и оценку качества.',
        ),
        _FaqItem(
          question: 'Зачем в уроках есть Output Quiz и Code Memory Lab?',
          answer:
              'Output Quiz тренирует понимание выполнения кода, а Code Memory Lab закрепляет синтаксис и типичные шаблоны через короткие упражнения.',
        ),
        _FaqItem(
          question: 'Как выбрать следующую ветку после текущей?',
          answer:
              'Идите по соседним ветвям: после core-тем логично переходить в специализацию, которая использует этот фундамент на практике.',
        ),
        _FaqItem(
          question: 'Что можно коротко сказать про базы данных на защите?',
          answer:
              'Базы данных отвечают за хранение, поиск, целостность и структуру информации, поэтому они лежат в основе backend, аналитики и многих продуктовых систем.',
        ),
      ];
    }

    return const <_FaqItem>[
      _FaqItem(
        question: 'Where should I start in this tree?',
        answer:
            'Start with the CS core branches because they explain the foundation behind most engineering roles.',
      ),
      _FaqItem(
        question: 'How do Operating Systems support backend and mobile?',
        answer:
            'Operating Systems explain processes, memory, files, threads, and resource access, which shape both server and mobile runtime behavior.',
      ),
      _FaqItem(
        question: 'Which core topics matter most for ML Engineer?',
        answer:
            'Linear algebra, probability, and statistics are especially important because they support model training, data representation, and evaluation.',
      ),
      _FaqItem(
        question: 'Why do lessons include Output Quiz and Code Memory Lab?',
        answer:
            'The quiz checks code execution reasoning, while the memory lab reinforces syntax and structure through short active practice.',
      ),
      _FaqItem(
        question: 'How should I choose the next branch?',
        answer:
            'Move into the specialization that naturally builds on the core topic you just studied.',
      ),
      _FaqItem(
        question: 'What is the short defense-ready explanation of databases?',
        answer:
            'Databases are responsible for structured storage, fast access, and data integrity, which makes them a foundation for backend and analytics systems.',
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
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceSoft,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.35,
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAsk,
              icon: Icon(
                Icons.send_rounded,
                size: 16,
                color: colors.primary,
              ),
              label: Text(
                askLabel,
                style: TextStyle(
                  color: colors.primary,
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
