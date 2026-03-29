import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/app_page_scaffold.dart';
import '../../../../core/common_widgets/glow_card.dart';
import '../../../../core/common_widgets/tech_text_field.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../community_text.dart';
import '../providers/community_groups_provider.dart';

class CommunityGroupPage extends ConsumerStatefulWidget {
  const CommunityGroupPage({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<CommunityGroupPage> createState() => _CommunityGroupPageState();
}

class _CommunityGroupPageState extends ConsumerState<CommunityGroupPage> {
  late final TextEditingController _memberSearchController;
  String _memberQuery = '';

  @override
  void initState() {
    super.initState();
    _memberSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _memberSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final colors = context.appColors;
    final group = ref.watch(
      communityGroupsProvider.select((groups) {
        for (final item in groups) {
          if (item.id == widget.groupId) {
            return item;
          }
        }
        return null;
      }),
    );

    if (group == null) {
      return AppPageScaffold(
        title: _tx(
          locale,
          ru: 'Группа не найдена',
          en: 'Group not found',
          kk: 'Топ табылмады',
        ),
        child: GlowCard(
          accent: colors.danger,
          child: Text(
            _tx(
              locale,
              ru: 'Похоже, эта группа больше не активна.',
              en: 'This group is no longer active.',
              kk: 'Бұл топ енді белсенді емес.',
            ),
          ),
        ),
      );
    }

    final filteredMembers = group.members
        .where((member) {
          final query = _memberQuery.trim().toLowerCase();
          if (query.isEmpty) {
            return true;
          }
          return member.name.toLowerCase().contains(query) ||
              member.role.toLowerCase().contains(query) ||
              member.accent.toLowerCase().contains(query);
        })
        .toList(growable: false);

    return AppPageScaffold(
      title: group.title.resolve(locale),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 42),
        children: [
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _chip(
                      context,
                      Icons.topic_rounded,
                      group.topic.resolve(locale),
                      colors.primary,
                    ),
                    _chip(
                      context,
                      Icons.lock_outline_rounded,
                      group.visibility.resolve(locale),
                      colors.textSecondary,
                    ),
                    _chip(
                      context,
                      group.isJoined
                          ? Icons.verified_rounded
                          : Icons.remove_red_eye_rounded,
                      group.isJoined
                          ? _tx(
                              locale,
                              ru: 'Вы участник',
                              en: 'Joined',
                              kk: 'Қатысушысыз',
                            )
                          : _tx(
                              locale,
                              ru: 'Только просмотр',
                              en: 'Preview only',
                              kk: 'Тек көру',
                            ),
                      group.isJoined ? colors.success : colors.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  group.summary.resolve(locale),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _metric(
                      context,
                      '${group.memberCount}',
                      _tx(
                        locale,
                        ru: 'участников',
                        en: 'members',
                        kk: 'қатысушы',
                      ),
                      Icons.groups_rounded,
                      colors.primary,
                    ),
                    _metric(
                      context,
                      '${group.mediaCount}',
                      'media',
                      Icons.perm_media_rounded,
                      colors.accent,
                    ),
                    _metric(
                      context,
                      '${group.linkCount}',
                      'links',
                      Icons.link_rounded,
                      colors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlowCard(
            accent: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx(
                    locale,
                    ru: 'Участники группы',
                    en: 'Group members',
                    kk: 'Топ қатысушылары',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _tx(
                    locale,
                    ru: 'Ищите людей по имени, роли или фокусу внутри группы.',
                    en: 'Search people by name, role, or focus inside the group.',
                    kk: 'Топ ішінен адамды аты, рөлі немесе фокусы бойынша іздеңіз.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                TechTextField(
                  hint: _tx(
                    locale,
                    ru: 'Искать человека внутри группы',
                    en: 'Search a person inside the group',
                    kk: 'Топ ішінен адам іздеу',
                  ),
                  icon: Icons.search_rounded,
                  controller: _memberSearchController,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ActionChip(
                    label: Text(
                      _tx(locale, ru: 'Применить', en: 'Apply', kk: 'Қолдану'),
                    ),
                    onPressed: () => setState(
                      () => _memberQuery = _memberSearchController.text.trim(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < filteredMembers.length; i++) ...[
                  _memberTile(context, filteredMembers[i]),
                  if (i != filteredMembers.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 980;
              final media = _sectionCard(
                context: context,
                title: 'Media',
                subtitle: _tx(
                  locale,
                  ru: 'Файлы и медиа-материалы, которыми делится группа.',
                  en: 'Files and media materials shared inside the group.',
                  kk: 'Топ ішінде бөлісілетін файлдар мен медиа материалдар.',
                ),
                accent: colors.accent,
                items: group.media
                    .map((item) => _mediaTile(context, item))
                    .toList(growable: false),
              );
              final links = _sectionCard(
                context: context,
                title: 'Links',
                subtitle: _tx(
                  locale,
                  ru: 'Полезные ссылки, документы, доски и внешние материалы.',
                  en: 'Helpful links, docs, boards, and external resources.',
                  kk: 'Пайдалы сілтемелер, құжаттар, тақталар және сыртқы материалдар.',
                ),
                accent: colors.success,
                items: group.links
                    .map((item) => _linkTile(context, item))
                    .toList(growable: false),
              );

              if (compact) {
                return Column(
                  children: [media, const SizedBox(height: 18), links],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: media),
                  const SizedBox(width: 18),
                  Expanded(child: links),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          GlowCard(
            accent: colors.danger,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx(
                    locale,
                    ru: 'Безопасность и участие',
                    en: 'Safety and membership',
                    kk: 'Қауіпсіздік және қатысу',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _tx(
                    locale,
                    ru: 'Здесь можно выйти из группы или отправить жалобу в модерацию.',
                    en: 'Leave the group or send a moderation report from here.',
                    kk: 'Осы жерден топтан шығуға немесе модерацияға шағым жіберуге болады.',
                  ),
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
                    _dangerButton(
                      context,
                      label: _tx(
                        locale,
                        ru: 'Выйти из группы',
                        en: 'Leave group',
                        kk: 'Топтан шығу',
                      ),
                      icon: Icons.logout_rounded,
                      onTap: group.isJoined
                          ? () {
                              ref
                                  .read(communityGroupsProvider.notifier)
                                  .leaveGroup(group.id);
                              AppNotice.show(
                                context,
                                message: _tx(
                                  locale,
                                  ru: 'Вы вышли из группы.',
                                  en: 'You left the group.',
                                  kk: 'Сіз топтан шықтыңыз.',
                                ),
                                type: AppNoticeType.success,
                              );
                              context.pop();
                            }
                          : null,
                    ),
                    _dangerButton(
                      context,
                      label: _tx(
                        locale,
                        ru: 'Пожаловаться',
                        en: 'Report',
                        kk: 'Шағымдану',
                      ),
                      icon: Icons.report_gmailerrorred_rounded,
                      onTap: () => _showReportSheet(context, locale, group.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReportSheet(
    BuildContext context,
    AppLocale locale,
    String groupId,
  ) async {
    final detailsController = TextEditingController();
    CommunityReportReason reason = CommunityReportReason.pornography;
    final attachments = <String>[];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = sheetContext.appColors;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: colors.divider),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tx(
                        locale,
                        ru: 'Пожаловаться на группу',
                        en: 'Report this group',
                        kk: 'Топқа шағымдану',
                      ),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _tx(
                        locale,
                        ru: 'Выберите причину. При необходимости добавьте пояснение и вложения.',
                        en: 'Pick a reason. Add context and attachments if needed.',
                        kk: 'Себепті таңдаңыз. Қажет болса түсіндірме мен тіркемелер қосыңыз.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final value in CommunityReportReason.values)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: value == CommunityReportReason.values.last
                              ? 0
                              : 8,
                        ),
                        child: _ReasonOptionTile(
                          label: _reasonLabel(locale, value),
                          selected: reason == value,
                          onTap: () => setModalState(() => reason = value),
                        ),
                      ),
                    if (reason == CommunityReportReason.other) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: detailsController,
                        minLines: 3,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: _tx(
                            locale,
                            ru: 'Опишите причину подробнее',
                            en: 'Describe the issue in more detail',
                            kk: 'Себебін толығырақ жазыңыз',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          _tx(
                            locale,
                            ru: 'Вложения',
                            en: 'Attachments',
                            kk: 'Тіркемелер',
                          ),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setModalState(
                            () => attachments.add(
                              'evidence_${attachments.length + 1}.png',
                            ),
                          ),
                          icon: Icon(
                            Icons.attach_file_rounded,
                            color: colors.danger,
                          ),
                          tooltip: _tx(
                            locale,
                            ru: 'Прикрепить материалы',
                            en: 'Attach materials',
                            kk: 'Материал тіркеу',
                          ),
                        ),
                      ],
                    ),
                    if (attachments.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: attachments
                            .map(
                              (item) => Chip(
                                label: Text(item),
                                onDeleted: () => setModalState(
                                  () => attachments.remove(item),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    const SizedBox(height: 18),
                    _dangerButton(
                      context,
                      label: _tx(
                        locale,
                        ru: 'Отправить жалобу',
                        en: 'Send report',
                        kk: 'Шағым жіберу',
                      ),
                      icon: Icons.send_rounded,
                      onTap: () {
                        if (reason == CommunityReportReason.other &&
                            detailsController.text.trim().isEmpty) {
                          AppNotice.show(
                            context,
                            message: _tx(
                              locale,
                              ru: 'Для причины «Другое» заполните описание.',
                              en: 'Add a description when you choose “Other”.',
                              kk: '«Басқа» себебін таңдасаңыз, сипаттаманы толтырыңыз.',
                            ),
                            type: AppNoticeType.error,
                          );
                          return;
                        }
                        ref
                            .read(communityGroupsProvider.notifier)
                            .reportGroup(groupId);
                        Navigator.of(sheetContext).pop();
                        AppNotice.show(
                          context,
                          message: _tx(
                            locale,
                            ru: 'Жалоба отправлена модерации.',
                            en: 'The report was sent to moderation.',
                            kk: 'Шағым модерацияға жіберілді.',
                          ),
                          type: AppNoticeType.success,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    detailsController.dispose();
  }
}

enum CommunityReportReason {
  pornography,
  harassment,
  violence,
  spam,
  hateSpeech,
  copyright,
  other,
}

String _tx(
  AppLocale locale, {
  required String ru,
  required String en,
  required String kk,
}) {
  return communityText(ru: ru, en: en, kk: kk).resolve(locale);
}

String _reasonLabel(AppLocale locale, CommunityReportReason value) {
  return switch (value) {
    CommunityReportReason.pornography => _tx(
      locale,
      ru: 'Порнографические материалы',
      en: 'Pornographic materials',
      kk: 'Порнографиялық материалдар',
    ),
    CommunityReportReason.harassment => _tx(
      locale,
      ru: 'Оскорбления или домогательства',
      en: 'Harassment or abuse',
      kk: 'Қорлау немесе қысым',
    ),
    CommunityReportReason.violence => _tx(
      locale,
      ru: 'Насилие или угрозы',
      en: 'Violence or threats',
      kk: 'Зорлық немесе қауіп',
    ),
    CommunityReportReason.spam => _tx(
      locale,
      ru: 'Спам или мошенничество',
      en: 'Spam or fraud',
      kk: 'Спам немесе алаяқтық',
    ),
    CommunityReportReason.hateSpeech => _tx(
      locale,
      ru: 'Язык вражды',
      en: 'Hate speech',
      kk: 'Өшпенділік тілі',
    ),
    CommunityReportReason.copyright => _tx(
      locale,
      ru: 'Нарушение авторских прав',
      en: 'Copyright infringement',
      kk: 'Авторлық құқықты бұзу',
    ),
    CommunityReportReason.other => _tx(
      locale,
      ru: 'Другое',
      en: 'Other',
      kk: 'Басқа',
    ),
  };
}

Widget _sectionCard({
  required BuildContext context,
  required String title,
  required String subtitle,
  required Color accent,
  required List<Widget> items,
}) {
  final colors = context.appColors;
  return GlowCard(
    accent: accent,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < items.length; i++) ...[
          items[i],
          if (i != items.length - 1) const SizedBox(height: 12),
        ],
      ],
    ),
  );
}

Widget _chip(BuildContext context, IconData icon, String label, Color accent) {
  final colors = context.appColors;
  final textColor = accent == colors.textSecondary
      ? colors.textSecondary
      : colors.textPrimary;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: accent.withValues(alpha: 0.22)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

Widget _metric(
  BuildContext context,
  String value,
  String label,
  IconData icon,
  Color accent,
) {
  final colors = context.appColors;
  return Container(
    width: 150,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.surfaceSoft.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: accent.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
      ],
    ),
  );
}

Widget _memberTile(BuildContext context, CommunityMember member) {
  final colors = context.appColors;
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.surfaceSoft.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.divider),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: colors.primary.withValues(alpha: 0.16),
          child: Text(
            member.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                member.role,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          member.accent,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

Widget _mediaTile(BuildContext context, CommunityMediaItem item) {
  final colors = context.appColors;
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.surfaceSoft.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.divider),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.perm_media_rounded, color: colors.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          item.kind,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

Widget _linkTile(BuildContext context, CommunityLinkItem item) {
  final colors = context.appColors;
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.surfaceSoft.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link_rounded, color: colors.success, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              item.kind,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SelectableText(
          item.url,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
      ],
    ),
  );
}

Widget _dangerButton(
  BuildContext context, {
  required String label,
  required IconData icon,
  required VoidCallback? onTap,
}) {
  final colors = context.appColors;
  return FilledButton.tonalIcon(
    onPressed: onTap,
    style: FilledButton.styleFrom(
      backgroundColor: colors.danger.withValues(alpha: 0.16),
      foregroundColor: colors.danger,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.danger.withValues(alpha: 0.28)),
      ),
    ),
    icon: Icon(icon),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
  );
}

class _ReasonOptionTile extends StatelessWidget {
  const _ReasonOptionTile({
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? colors.danger.withValues(alpha: 0.14)
              : colors.surfaceSoft.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? colors.danger : colors.divider),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? colors.danger : colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
