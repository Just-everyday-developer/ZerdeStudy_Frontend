import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_moderator_controller.dart';
import '../../../../app/state/demo_moderator_data.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/theme/app_theme_colors.dart';

class ModeratorCommunityPage extends ConsumerStatefulWidget {
  const ModeratorCommunityPage({super.key});

  @override
  ConsumerState<ModeratorCommunityPage> createState() =>
      _ModeratorCommunityPageState();
}

class _ModeratorCommunityPageState
    extends ConsumerState<ModeratorCommunityPage> {
  String? _selectedId;
  ModCommunityContentType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final items = ref.watch(demoModeratorCommunityProvider);
    final filteredItems = items
        .where((item) => _typeFilter == null || item.type == _typeFilter)
        .toList(growable: false);
    final selectedItem = _resolveSelectedItem(filteredItems);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 356,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(right: BorderSide(color: colors.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Управление community-контентом',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Группы, медиа и подборки ссылок, которым нужна проверка.',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _CommunityMetric(
                          label: 'На ревью',
                          value: items
                              .where(
                                (item) =>
                                    item.status ==
                                    ModCommunityContentStatus.needsReview,
                              )
                              .length,
                          color: const Color(0xFFFF9800),
                        ),
                        _CommunityMetric(
                          label: 'Ограничены',
                          value: items
                              .where(
                                (item) =>
                                    item.status ==
                                    ModCommunityContentStatus.limited,
                              )
                              .length,
                          color: const Color(0xFFEF6C00),
                        ),
                        _CommunityMetric(
                          label: 'Архив',
                          value: items
                              .where(
                                (item) =>
                                    item.status ==
                                    ModCommunityContentStatus.archived,
                              )
                              .length,
                          color: const Color(0xFF546E7A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TypeFilterChip(
                          label: 'Все',
                          selected: _typeFilter == null,
                          onTap: () => setState(() => _typeFilter = null),
                        ),
                        _TypeFilterChip(
                          label: 'Группы',
                          selected:
                              _typeFilter == ModCommunityContentType.group,
                          onTap: () => setState(
                            () => _typeFilter = ModCommunityContentType.group,
                          ),
                        ),
                        _TypeFilterChip(
                          label: 'Медиа',
                          selected:
                              _typeFilter == ModCommunityContentType.media,
                          onTap: () => setState(
                            () => _typeFilter = ModCommunityContentType.media,
                          ),
                        ),
                        _TypeFilterChip(
                          label: 'Ссылки',
                          selected:
                              _typeFilter == ModCommunityContentType.links,
                          onTap: () => setState(
                            () => _typeFilter = ModCommunityContentType.links,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          'Под выбранный фильтр элементов нет.',
                          style: TextStyle(color: colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isSelected = selectedItem?.id == item.id;

                          return InkWell(
                            onTap: () => setState(() => _selectedId = item.id),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(
                                        0xFFFF6B35,
                                      ).withValues(alpha: 0.12)
                                    : colors.surfaceSoft,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(
                                          0xFFFF6B35,
                                        ).withValues(alpha: 0.32)
                                      : colors.divider,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      _CommunityStatusBadge(
                                        status: item.status,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _TypePill(type: item.type),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.visibility,
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.summary,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      height: 1.45,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _MiniMeta(
                                        icon: Icons.flag_rounded,
                                        label: '${item.reportCount} жалоб',
                                      ),
                                      _MiniMeta(
                                        icon: Icons.people_alt_rounded,
                                        label: '${item.memberCount} участников',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedItem == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: 48,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Выберите community-элемент для проверки',
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedItem.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Владелец: ${selectedItem.owner} · ${selectedItem.lastActivityAt}',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _CommunityStatusBadge(status: selectedItem.status),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: 'Описание',
                        child: Text(
                          selectedItem.summary,
                          style: TextStyle(
                            color: colors.textPrimary,
                            height: 1.6,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SectionCard(
                              title: 'Параметры сообщества',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _CommunityInfoRow(
                                    label: 'Тип',
                                    value: _communityTypeLabel(
                                      selectedItem.type,
                                    ),
                                  ),
                                  _CommunityInfoRow(
                                    label: 'Видимость',
                                    value: selectedItem.visibility,
                                  ),
                                  _CommunityInfoRow(
                                    label: 'Медиа',
                                    value: '${selectedItem.mediaCount}',
                                  ),
                                  _CommunityInfoRow(
                                    label: 'Ссылки',
                                    value: '${selectedItem.linkCount}',
                                  ),
                                  _CommunityInfoRow(
                                    label: 'Участники',
                                    value: '${selectedItem.memberCount}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SectionCard(
                              title: 'Метки и сигналы',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: selectedItem.tags
                                        .map((tag) => _TagPill(label: tag))
                                        .toList(growable: false),
                                  ),
                                  const SizedBox(height: 14),
                                  ...selectedItem.riskSignals.map(
                                    (signal) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 2),
                                            child: Icon(
                                              Icons.priority_high_rounded,
                                              color: Color(0xFFFF6B35),
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              signal,
                                              style: TextStyle(
                                                color: colors.textPrimary,
                                                height: 1.45,
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _applyAction(
                              selectedItem.id,
                              ModCommunityContentStatus.approved,
                              'Элемент оставлен в community-ленте.',
                            ),
                            icon: const Icon(Icons.check_circle_rounded),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                            label: const Text('Оставить в ленте'),
                          ),
                          FilledButton.icon(
                            onPressed: () => _applyAction(
                              selectedItem.id,
                              ModCommunityContentStatus.limited,
                              'Видимость ограничена до ручной проверки.',
                            ),
                            icon: const Icon(Icons.visibility_off_rounded),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFEF6C00),
                            ),
                            label: const Text('Ограничить видимость'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _applyAction(
                              selectedItem.id,
                              ModCommunityContentStatus.archived,
                              'Элемент отправлен в архив moderation team.',
                            ),
                            icon: const Icon(Icons.archive_outlined),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF546E7A),
                              side: const BorderSide(color: Color(0xFF546E7A)),
                            ),
                            label: const Text('Архивировать'),
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

  ModCommunityContentItem? _resolveSelectedItem(
    List<ModCommunityContentItem> items,
  ) {
    if (items.isEmpty) {
      return null;
    }
    for (final item in items) {
      if (item.id == _selectedId) {
        return item;
      }
    }
    return items.first;
  }

  void _applyAction(
    String itemId,
    ModCommunityContentStatus status,
    String noticeMessage,
  ) {
    ref
        .read(demoModeratorCommunityProvider.notifier)
        .updateStatus(itemId, status);
    AppNotice.show(
      context,
      message: noticeMessage,
      type: AppNoticeType.success,
    );
    setState(() => _selectedId = itemId);
  }

  String _communityTypeLabel(ModCommunityContentType type) {
    return switch (type) {
      ModCommunityContentType.group => 'Группа',
      ModCommunityContentType.media => 'Медиа',
      ModCommunityContentType.links => 'Подборка ссылок',
    };
  }
}

class _CommunityMetric extends StatelessWidget {
  const _CommunityMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeFilterChip extends StatelessWidget {
  const _TypeFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF6B35).withValues(alpha: 0.12)
              : colors.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFFFF6B35).withValues(alpha: 0.3)
                : colors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFFF6B35) : colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CommunityStatusBadge extends StatelessWidget {
  const _CommunityStatusBadge({required this.status});

  final ModCommunityContentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ModCommunityContentStatus.needsReview => (
        'На ревью',
        const Color(0xFFFF9800),
      ),
      ModCommunityContentStatus.limited => (
        'Ограничен',
        const Color(0xFFEF6C00),
      ),
      ModCommunityContentStatus.approved => (
        'Одобрен',
        const Color(0xFF4CAF50),
      ),
      ModCommunityContentStatus.archived => ('Архив', const Color(0xFF546E7A)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.type});

  final ModCommunityContentType type;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (type) {
      ModCommunityContentType.group => ('Группа', Icons.groups_rounded),
      ModCommunityContentType.media => ('Медиа', Icons.perm_media_rounded),
      ModCommunityContentType.links => ('Ссылки', Icons.link_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF2196F3)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2196F3),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMeta extends StatelessWidget {
  const _MiniMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _CommunityInfoRow extends StatelessWidget {
  const _CommunityInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF00BCD4).withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF00BCD4),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
