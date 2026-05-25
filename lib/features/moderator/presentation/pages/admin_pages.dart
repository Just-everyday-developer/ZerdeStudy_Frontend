import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../app/state/demo_admin_data.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Управление пользователями',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Список всех зарегистрированных пользователей, управление ролями и статусами.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.divider),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(colors.surfaceSoft),
                  columns: const [
                    DataColumn(label: Text('Пользователь')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Роль')),
                    DataColumn(label: Text('Статус')),
                    DataColumn(label: Text('Последний вход')),
                    DataColumn(label: Text('Действия')),
                  ],
                  rows: kAdminUsers.map((user) {
                    final statusColor = switch (user.status) {
                      'Active' => const Color(0xFF4CAF50),
                      'Banned' => const Color(0xFFF44336),
                      _ => colors.textSecondary,
                    };
                    return DataRow(cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: colors.primary.withValues(alpha: 0.1),
                              child: Text(
                                user.name[0],
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              user.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(user.email)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: colors.surfaceSoft,
                          ),
                          child: Text(
                            user.role,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(user.status),
                          ],
                        ),
                      ),
                      DataCell(Text(user.lastLoginAt)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded),
                          onPressed: () {},
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSystemPage extends StatelessWidget {
  const AdminSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Состояние системы',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Мониторинг ресурсов сервера, нагрузки и здоровья базы данных.',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: kAdminMetrics.map((metric) {
                final statusColor = switch (metric.status) {
                  'good' => const Color(0xFF4CAF50),
                  'warning' => const Color(0xFFFF9800),
                  'critical' => const Color(0xFFF44336),
                  _ => colors.textSecondary,
                };
                return Container(
                  width: 260,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.label,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        metric.value,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            metric.trend == 'up'
                                ? Icons.trending_up_rounded
                                : metric.trend == 'down'
                                ? Icons.trending_down_rounded
                                : Icons.trending_flat_rounded,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            metric.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
