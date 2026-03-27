import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_moderator_data.dart';
import '../../../../core/theme/app_theme_colors.dart';

class ModeratorFaqPage extends ConsumerStatefulWidget {
  const ModeratorFaqPage({super.key});

  @override
  ConsumerState<ModeratorFaqPage> createState() => _ModeratorFaqPageState();
}

class _ModeratorFaqPageState extends ConsumerState<ModeratorFaqPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ModFaqQuestion? _selected;
  late TextEditingController _answerCtrl;

  static const _kOrange = Color(0xFFFF6B35);

  // Template replies
  static const _templates = [
    'Здравствуйте! Для решения проблемы обратитесь в поддержку через форму обратной связи.',
    'Сертификаты выдаются автоматически после завершения курса. Проверьте раздел «Профиль».',
    'Прогресс синхронизируется при наличии подключения к интернету. Попробуйте перезайти в приложение.',
    'Возврат средств возможен в течение 14 дней после покупки при условии прохождения менее 30% курса.',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _answerCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final unanswered = kModFaqQuestions.where((q) => q.answer.isEmpty).toList();
    final answered = kModFaqQuestions.where((q) => q.answer.isNotEmpty).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: question list
        Container(
          width: 340,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(right: BorderSide(color: colors.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'Управление FAQ',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: _kOrange,
                unselectedLabelColor: colors.textSecondary,
                indicatorColor: _kOrange,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                tabs: [
                  Tab(text: 'Новые (${unanswered.length})'),
                  Tab(text: 'База знаний (${answered.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _QuestionList(
                      questions: unanswered,
                      selected: _selected,
                      onSelect: (q) {
                        setState(() {
                          _selected = q;
                          _answerCtrl.text = q.answer;
                        });
                      },
                      colors: colors,
                    ),
                    _QuestionList(
                      questions: answered,
                      selected: _selected,
                      onSelect: (q) {
                        setState(() {
                          _selected = q;
                          _answerCtrl.text = q.answer;
                        });
                      },
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Right: editor
        Expanded(
          child: _selected == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.forum_outlined,
                          size: 48, color: colors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        'Выберите вопрос для ответа',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Вопрос от ${_selected!.askedBy}',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selected!.question,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selected!.askedAt,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selected!.isPublic)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF4CAF50)
                                        .withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.public_rounded,
                                      color: Color(0xFF4CAF50), size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Публичный',
                                    style: TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Templates
                      Text(
                        'Шаблоны ответов',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _templates
                            .map(
                              (t) => InkWell(
                                onTap: () => setState(
                                    () => _answerCtrl.text = t),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceSoft,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: colors.divider),
                                  ),
                                  child: Text(
                                    t.length > 45
                                        ? '${t.substring(0, 45)}...'
                                        : t,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      // Answer editor
                      Text(
                        'Редактор ответа',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _answerCtrl,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText:
                              'Введите ответ на вопрос пользователя...',
                          hintStyle: TextStyle(color: colors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: _kOrange),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Similar answers hint
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3)
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF2196F3)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded,
                                color: Color(0xFF2196F3), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Найдено 2 похожих вопроса в базе знаний. Нажмите «Использовать шаблон» выше.',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('Ответить'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.public_rounded, size: 16),
                            label: const Text('Сделать публичным'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4CAF50),
                              side: const BorderSide(
                                  color: Color(0xFF4CAF50)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
    );
  }
}

class _QuestionList extends StatelessWidget {
  const _QuestionList({
    required this.questions,
    required this.selected,
    required this.onSelect,
    required this.colors,
  });
  final List<ModFaqQuestion> questions;
  final ModFaqQuestion? selected;
  final void Function(ModFaqQuestion) onSelect;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Center(
        child: Text(
          'Нет вопросов',
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      itemCount: questions.length,
      itemBuilder: (context, i) {
        final q = questions[i];
        final isSelected = selected?.id == q.id;
        return InkWell(
          onTap: () => onSelect(q),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? const Color(0xFFFF6B35).withValues(alpha: 0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF6B35).withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFFFF6B35)
                        : colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      q.askedBy,
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '·',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      q.askedAt,
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
