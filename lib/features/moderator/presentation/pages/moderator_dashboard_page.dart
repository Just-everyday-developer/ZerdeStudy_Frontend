import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_moderator_data.dart';
import '../../../../core/theme/app_theme_colors.dart';

class ModeratorDashboardPage extends ConsumerWidget {
  const ModeratorDashboardPage({super.key});

  static const _kOrange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Центр управления',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _kOrange.withValues(alpha: 0.1),
                    border:
                        Border.all(color: _kOrange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF4CAF50), size: 8),
                      SizedBox(width: 8),
                      Text(
                        'Модератор активен',
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
              '24 марта 2026 • Дашборд обновлён в реальном времени',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Stat cards
            Row(
              children: [
                _StatCard(
                  icon: Icons.rate_review_rounded,
                  label: 'Ожидают проверки курсов',
                  value: '${kModPendingCourses.length}',
                  color: const Color(0xFFFF9800),
                  colors: colors,
                  onTap: null,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  icon: Icons.flag_rounded,
                  label: 'Новых жалоб',
                  value: '${kModReports.length}',
                  color: const Color(0xFFF44336),
                  colors: colors,
                  onTap: null,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  icon: Icons.help_outline_rounded,
                  label: 'Вопросов в FAQ',
                  value: '${kModFaqQuestions.where((q) => q.answer.isEmpty).length}',
                  color: const Color(0xFF2196F3),
                  colors: colors,
                  onTap: null,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Решено сегодня',
                  value: '7',
                  color: const Color(0xFF4CAF50),
                  colors: colors,
                  onTap: null,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent activity
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity feed
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Лента активности',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
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
                              .map((e) => _ActivityItem(
                                    entry: e.value,
                                    isLast: e.key ==
                                        kModRecentActivity.length - 1,
                                    colors: colors,
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Quick stats
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ожидающие курсы',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
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
                          children: kModPendingCourses
                              .take(4)
                              .map((c) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF9800)
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.video_library_rounded,
                                            color: Color(0xFFFF9800),
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                c.title,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: colors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                c.author,
                                                style: TextStyle(
                                                  color: colors.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
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
    return Expanded(
      child: InkWell(
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
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
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
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            entry.time,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
