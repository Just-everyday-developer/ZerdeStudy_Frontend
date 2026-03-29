import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/common_widgets/tech_text_field.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../community_text.dart';
import '../providers/community_groups_provider.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  late final TextEditingController _searchController;
  String _query = '';
  CommunityGroupCategory? _selectedCategory;
  bool _joinedOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final colors = context.appColors;
    final groups = ref.watch(communityGroupsProvider);
    final filteredGroups = groups
        .where((group) {
          final matchesCategory =
              _selectedCategory == null || group.category == _selectedCategory;
          final matchesJoined = !_joinedOnly || group.isJoined;
          final normalizedQuery = _query.trim().toLowerCase();
          final matchesQuery =
              normalizedQuery.isEmpty ||
              group.title
                  .resolve(locale)
                  .toLowerCase()
                  .contains(normalizedQuery) ||
              group.summary
                  .resolve(locale)
                  .toLowerCase()
                  .contains(normalizedQuery) ||
              group.topic
                  .resolve(locale)
                  .toLowerCase()
                  .contains(normalizedQuery) ||
              group.tags.any(
                (tag) => tag.toLowerCase().contains(normalizedQuery),
              );

          return matchesCategory && matchesJoined && matchesQuery;
        })
        .toList(growable: false);

    return AppPageScaffold(
      title: _communityTitle.resolve(locale),
      expandContent: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 42),
        children: [
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _heroTitle.resolve(locale),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _heroSubtitle.resolve(locale),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatChip(
                      icon: Icons.groups_rounded,
                      label:
                          '${groups.length} ${_groupsCountLabel.resolve(locale)}',
                      accent: colors.primary,
                    ),
                    _StatChip(
                      icon: Icons.person_add_alt_1_rounded,
                      label:
                          '${groups.where((group) => group.isJoined).length} ${_joinedCountLabel.resolve(locale)}',
                      accent: colors.success,
                    ),
                    _StatChip(
                      icon: Icons.perm_media_rounded,
                      label:
                          '${groups.fold<int>(0, (sum, group) => sum + group.mediaCount)} ${_mediaCountLabel.resolve(locale)}',
                      accent: colors.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton.primary(
                  label: _createGroupLabel.resolve(locale),
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: () => _showCreateGroupDialog(context, locale),
                  maxWidth: 280,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlowCard(
            accent: colors.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TechTextField(
                  hint: _searchHint.resolve(locale),
                  icon: Icons.search_rounded,
                  controller: _searchController,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      selected: _selectedCategory == null,
                      label: Text(_allCategoriesLabel.resolve(locale)),
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                    for (final category in CommunityGroupCategory.values)
                      FilterChip(
                        selected: _selectedCategory == category,
                        label: Text(_categoryLabel(locale, category)),
                        onSelected: (_) => setState(() {
                          _selectedCategory = _selectedCategory == category
                              ? null
                              : category;
                        }),
                      ),
                    FilterChip(
                      selected: _joinedOnly,
                      label: Text(_joinedOnlyLabel.resolve(locale)),
                      onSelected: (value) =>
                          setState(() => _joinedOnly = value),
                    ),
                    ActionChip(
                      label: Text(_applySearchLabel.resolve(locale)),
                      onPressed: () => setState(
                        () => _query = _searchController.text.trim(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (filteredGroups.isEmpty)
            GlowCard(
              accent: colors.danger,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _emptyTitle.resolve(locale),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _emptySubtitle.resolve(locale),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = switch (constraints.maxWidth) {
                  >= 1180 => 2,
                  _ => 1,
                };
                final itemWidth =
                    (constraints.maxWidth - ((crossAxisCount - 1) * 16)) /
                    crossAxisCount;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: filteredGroups
                      .map(
                        (group) => SizedBox(
                          width: itemWidth,
                          child: _CommunityGroupCard(
                            group: group,
                            locale: locale,
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showCreateGroupDialog(
    BuildContext context,
    AppLocale locale,
  ) async {
    final nameController = TextEditingController();
    final summaryController = TextEditingController();
    final topicController = TextEditingController();
    var selectedCategory = CommunityGroupCategory.study;
    var isPrivate = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.appColors;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: colors.divider),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _createDialogTitle.resolve(locale),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _createDialogSubtitle.resolve(locale),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TechTextField(
                        hint: _groupNameHint.resolve(locale),
                        icon: Icons.group_work_rounded,
                        controller: nameController,
                      ),
                      const SizedBox(height: 12),
                      TechTextField(
                        hint: _groupTopicHint.resolve(locale),
                        icon: Icons.sell_rounded,
                        controller: topicController,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: summaryController,
                        minLines: 3,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: _groupSummaryHint.resolve(locale),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 40),
                            child: Icon(Icons.notes_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<CommunityGroupCategory>(
                        initialValue: selectedCategory,
                        decoration: InputDecoration(
                          labelText: _groupCategoryLabel.resolve(locale),
                        ),
                        items: CommunityGroupCategory.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(_categoryLabel(locale, category)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() => selectedCategory = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        value: isPrivate,
                        contentPadding: EdgeInsets.zero,
                        title: Text(_privateGroupLabel.resolve(locale)),
                        subtitle: Text(_privateGroupSubtitle.resolve(locale)),
                        onChanged: (value) =>
                            setModalState(() => isPrivate = value),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          AppButton.primary(
                            label: _createGroupLabel.resolve(locale),
                            icon: Icons.done_rounded,
                            onPressed: () {
                              final name = nameController.text.trim();
                              final summary = summaryController.text.trim();
                              final topic = topicController.text.trim();
                              if (name.isEmpty ||
                                  summary.isEmpty ||
                                  topic.isEmpty) {
                                AppNotice.show(
                                  dialogContext,
                                  message: _createValidationLabel.resolve(
                                    locale,
                                  ),
                                  type: AppNoticeType.error,
                                );
                                return;
                              }

                              ref
                                  .read(communityGroupsProvider.notifier)
                                  .createGroup(
                                    name: name,
                                    summary: summary,
                                    category: selectedCategory,
                                    topic: topic,
                                    isPrivate: isPrivate,
                                  );

                              Navigator.of(dialogContext).pop();
                              AppNotice.show(
                                context,
                                message: _createSuccessLabel.resolve(locale),
                                type: AppNoticeType.success,
                              );
                            },
                            maxWidth: 240,
                          ),
                          AppButton.secondary(
                            label: _closeDialogLabel.resolve(locale),
                            icon: Icons.close_rounded,
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            maxWidth: 180,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    summaryController.dispose();
    topicController.dispose();
  }
}

class _CommunityGroupCard extends StatelessWidget {
  const _CommunityGroupCard({required this.group, required this.locale});

  final CommunityGroup group;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statusAccent = group.isJoined ? colors.success : colors.accent;

    return GlowCard(
      accent: statusAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatChip(
                icon: Icons.topic_rounded,
                label: group.topic.resolve(locale),
                accent: colors.primary,
              ),
              _StatChip(
                icon: group.isJoined
                    ? Icons.verified_rounded
                    : Icons.remove_red_eye_rounded,
                label: group.isJoined
                    ? _joinedBadge.resolve(locale)
                    : _previewBadge.resolve(locale),
                accent: statusAccent,
              ),
              _StatChip(
                icon: Icons.lock_outline_rounded,
                label: group.visibility.resolve(locale),
                accent: colors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            group.title.resolve(locale),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            group.summary.resolve(locale),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InlineMetric(
                icon: Icons.groups_rounded,
                value: '${group.memberCount}',
                label: _membersLabel.resolve(locale),
              ),
              _InlineMetric(
                icon: Icons.perm_media_rounded,
                value: '${group.mediaCount}',
                label: _mediaLabel.resolve(locale),
              ),
              _InlineMetric(
                icon: Icons.link_rounded,
                value: '${group.linkCount}',
                label: _linksLabel.resolve(locale),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceSoft.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colors.divider),
                    ),
                    child: Text(
                      tag,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          AppButton.secondary(
            label: _openGroupLabel.resolve(locale),
            icon: Icons.arrow_forward_rounded,
            onPressed: () =>
                context.push(AppRoutes.communityGroupById(group.id)),
            maxWidth: 240,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent == colors.textSecondary
                  ? colors.textSecondary
                  : colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSoft.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

String _categoryLabel(AppLocale locale, CommunityGroupCategory category) {
  final text = switch (category) {
    CommunityGroupCategory.study => communityText(
      ru: 'Учеба',
      en: 'Study',
      kk: 'Оқу',
    ),
    CommunityGroupCategory.project => communityText(
      ru: 'Проекты',
      en: 'Projects',
      kk: 'Жобалар',
    ),
    CommunityGroupCategory.mentorship => communityText(
      ru: 'Менторство',
      en: 'Mentorship',
      kk: 'Менторлық',
    ),
    CommunityGroupCategory.career => communityText(
      ru: 'Карьера',
      en: 'Career',
      kk: 'Мансап',
    ),
  };
  return text.resolve(locale);
}

final _communityTitle = communityText(
  ru: 'Community',
  en: 'Community',
  kk: 'Community',
);
final _heroTitle = communityText(
  ru: 'Группы, где обучение становится командной работой',
  en: 'Groups where learning becomes a team sport',
  kk: 'Оқуды командалық жұмысқа айналдыратын топтар',
);
final _heroSubtitle = communityText(
  ru: 'Создавайте свои группы, собирайте полезные ссылки, медиа и быстрый доступ к людям, с которыми удобно учиться вместе.',
  en: 'Create your own groups, collect links and media, and keep the right people close while you learn together.',
  kk: 'Өз топтарыңызды құрып, сілтемелер мен медианы жинап, бірге оқуға ыңғайлы адамдарды жақын ұстаңыз.',
);
final _groupsCountLabel = communityText(ru: 'группы', en: 'groups', kk: 'топ');
final _joinedCountLabel = communityText(
  ru: 'внутри',
  en: 'joined',
  kk: 'қосылған',
);
final _mediaCountLabel = communityText(ru: 'медиа', en: 'media', kk: 'медиа');
final _createGroupLabel = communityText(
  ru: 'Создать группу',
  en: 'Create group',
  kk: 'Топ құру',
);
final _searchHint = communityText(
  ru: 'Искать группу по названию, теме или тегам',
  en: 'Search groups by name, topic, or tags',
  kk: 'Топты атауы, тақырыбы немесе тегтері бойынша іздеу',
);
final _allCategoriesLabel = communityText(
  ru: 'Все категории',
  en: 'All categories',
  kk: 'Барлық санат',
);
final _joinedOnlyLabel = communityText(
  ru: 'Только мои группы',
  en: 'Joined only',
  kk: 'Тек менің топтарым',
);
final _applySearchLabel = communityText(
  ru: 'Применить',
  en: 'Apply',
  kk: 'Қолдану',
);
final _emptyTitle = communityText(
  ru: 'Группы не найдены',
  en: 'No groups found',
  kk: 'Топтар табылмады',
);
final _emptySubtitle = communityText(
  ru: 'Попробуйте очистить фильтры или создайте свою группу с нуля.',
  en: 'Try clearing filters or create a new group from scratch.',
  kk: 'Фильтрлерді тазалап көріңіз немесе жаңа топ құрыңыз.',
);
final _joinedBadge = communityText(
  ru: 'Вы внутри',
  en: 'Joined',
  kk: 'Қосылған',
);
final _previewBadge = communityText(
  ru: 'Предпросмотр',
  en: 'Preview',
  kk: 'Алдын ала көру',
);
final _membersLabel = communityText(
  ru: 'участников',
  en: 'members',
  kk: 'қатысушы',
);
final _mediaLabel = communityText(ru: 'медиа', en: 'media', kk: 'медиа');
final _linksLabel = communityText(ru: 'ссылок', en: 'links', kk: 'сілтеме');
final _openGroupLabel = communityText(
  ru: 'Открыть группу',
  en: 'Open group',
  kk: 'Топты ашу',
);
final _createDialogTitle = communityText(
  ru: 'Новая группа',
  en: 'New group',
  kk: 'Жаңа топ',
);
final _createDialogSubtitle = communityText(
  ru: 'Задайте фокус группы, краткое описание и тип доступа. После создания группа сразу появится в общем списке.',
  en: 'Set the focus, summary, and access level. The group appears in the list right away.',
  kk: 'Топтың фокусын, қысқаша сипаттамасын және қолжетімділік түрін орнатыңыз. Топ бірден тізімде көрінеді.',
);
final _groupNameHint = communityText(
  ru: 'Название группы',
  en: 'Group name',
  kk: 'Топ атауы',
);
final _groupTopicHint = communityText(
  ru: 'Тема или трек группы',
  en: 'Group topic or track',
  kk: 'Топтың тақырыбы немесе трегі',
);
final _groupSummaryHint = communityText(
  ru: 'Коротко опишите, зачем создана группа и что в ней обсуждают',
  en: 'Briefly describe the group purpose and what people discuss inside',
  kk: 'Топ не үшін құрылғанын және ішінде не талқыланатынын қысқаша жазыңыз',
);
final _groupCategoryLabel = communityText(
  ru: 'Категория',
  en: 'Category',
  kk: 'Санат',
);
final _privateGroupLabel = communityText(
  ru: 'Частная группа',
  en: 'Private group',
  kk: 'Жабық топ',
);
final _privateGroupSubtitle = communityText(
  ru: 'Открытые группы легче найти, частные подходят для небольших команд и cohort-ов.',
  en: 'Open groups are easier to discover, while private ones fit teams and focused cohorts.',
  kk: 'Ашық топтарды табу оңай, ал жабық топтар шағын командалар мен cohort үшін ыңғайлы.',
);
final _createValidationLabel = communityText(
  ru: 'Заполните название, тему и описание группы.',
  en: 'Fill in the group name, topic, and summary.',
  kk: 'Топ атауын, тақырыбын және сипаттамасын толтырыңыз.',
);
final _createSuccessLabel = communityText(
  ru: 'Группа создана и добавлена в список.',
  en: 'The group was created and added to the list.',
  kk: 'Топ құрылып, тізімге қосылды.',
);
final _closeDialogLabel = communityText(ru: 'Закрыть', en: 'Close', kk: 'Жабу');
