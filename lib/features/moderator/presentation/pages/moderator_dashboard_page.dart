import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_moderator_controller.dart';
import '../../../../app/state/demo_moderator_data.dart';
import '../../../../core/theme/app_theme_colors.dart';

class ModeratorDashboardPage extends ConsumerWidget {
  const ModeratorDashboardPage({super.key});

  static const _kOrange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final unansweredFaqCount = ref
        .watch(demoModeratorFaqProvider)
        .where((question) => question.answer.isEmpty)
        .length;
    final pendingCommentCount = ref
        .watch(demoModeratorCommentsProvider)
        .where((item) => item.status == ModCommentStatus.needsReview)
        .length;
    final flaggedCommunityCount = ref
        .watch(demoModeratorCommunityProvider)
        .where(
          (item) =>
              item.status == ModCommunityContentStatus.needsReview ||
              item.status == ModCommunityContentStatus.limited,
        )
        .length;

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Центр модерации',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _kOrange.withValues(alpha: 0.1),
                    border: Border.all(color: _kOrange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF4CAF50), size: 8),
                      SizedBox(width: 8),
                      Text(
                        'Moderator active',
                        style: TextStyle(
                          color: _kOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Live queues for courses, reports, comments, community content, and FAQ.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                final columnCount = constraints.maxWidth >= 1450
                    ? 3
                    : constraints.maxWidth >= 1080
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - ((columnCount - 1) * 16)) /
                    columnCount;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: width,
                      child: _StatCard(
                        icon: Icons.rate_review_rounded,
                        label: 'Ожидают проверки курсов',
                        value: '${kModPendingCourses.length}',
                        color: const Color(0xFFFF9800),
                        colors: colors,
                        onTap: () => context.go(AppRoutes.moderatorCourses),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _StatCard(
                        icon: Icons.flag_rounded,
                        label: 'Новых жалоб',
                        value: '${kModReports.length}',
                        color: const Color(0xFFF44336),
                        colors: colors,
                        onTap: () => context.go(AppRoutes.moderatorReports),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _StatCard(
                        icon: Icons.comment_bank_rounded,
                        label: 'Комментариев на ревью',
                        value: '$pendingCommentCount',
                        color: const Color(0xFF8E24AA),
                        colors: colors,
                        onTap: () => context.go(AppRoutes.moderatorComments),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _StatCard(
                        icon: Icons.groups_rounded,
                        label: 'Community-контент в очереди',
                        value: '$flaggedCommunityCount',
                        color: const Color(0xFF00BCD4),
                        colors: colors,
                        onTap: () => context.go(AppRoutes.moderatorCommunity),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _StatCard(
                        icon: Icons.help_outline_rounded,
                        label: 'Вопросов в FAQ',
                        value: '$unansweredFaqCount',
                        color: const Color(0xFF2196F3),
                        colors: colors,
                        onTap: () => context.go(AppRoutes.moderatorFaq),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _StatCard(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Решено сегодня',
                        value: '7',
                        color: const Color(0xFF4CAF50),
                        colors: colors,
                        onTap: null,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Лента активности',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.divider),
                        ),
                        child: Column(
                          children: kModRecentActivity
                              .asMap()
                              .entries
                              .map(
                                (entry) => _ActivityItem(
                                  entry: entry.value,
                                  isLast:
                                      entry.key ==
                                      kModRecentActivity.length - 1,
                                  colors: colors,
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Приоритетные очереди',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      _QueueFocusCard(
                        title: 'Comments queue',
                        accent: const Color(0xFF8E24AA),
                        description:
                            'Комментарии с высокой токсичностью, спамом и повторными жалобами.',
                        primaryStat: '$pendingCommentCount open',
                        secondaryStat:
                            '${ref.watch(demoModeratorCommentsProvider).where((item) => item.status == ModCommentStatus.hidden).length} hidden',
                        icon: Icons.comment_bank_rounded,
                        onTap: () => context.go(AppRoutes.moderatorComments),
                      ),
                      const SizedBox(height: 16),
                      _QueueFocusCard(
                        title: 'Community review',
                        accent: const Color(0xFF00BCD4),
                        description:
                            'Группы, медиа и подборки ссылок с ограничениями или сигналами риска.',
                        primaryStat: '$flaggedCommunityCount flagged',
                        secondaryStat:
                            '${ref.watch(demoModeratorCommunityProvider).where((item) => item.status == ModCommunityContentStatus.archived).length} archived',
                        icon: Icons.groups_rounded,
                        onTap: () => context.go(AppRoutes.moderatorCommunity),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final AppThemeColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.divider),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueFocusCard extends StatelessWidget {
  const _QueueFocusCard({
    required this.title,
    required this.accent,
    required this.description,
    required this.primaryStat,
    required this.secondaryStat,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final Color accent;
  final String description;
  final String primaryStat;
  final String secondaryStat;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: colors.textSecondary,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.45,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SmallPill(label: primaryStat, accent: accent),
                _SmallPill(label: secondaryStat, accent: colors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.entry,
    required this.isLast,
    required this.colors,
  });

  final ModActivityEntry entry;
  final bool isLast;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (entry.type) {
      'ban' => (Icons.block_rounded, const Color(0xFFF44336)),
      'approve' => (Icons.check_circle_rounded, const Color(0xFF4CAF50)),
      'reject' => (Icons.cancel_rounded, const Color(0xFFFF9800)),
      'warn' => (Icons.warning_rounded, const Color(0xFFFFEB3B)),
      _ => (Icons.info_rounded, const Color(0xFF2196F3)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.divider, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.text,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            entry.time,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
