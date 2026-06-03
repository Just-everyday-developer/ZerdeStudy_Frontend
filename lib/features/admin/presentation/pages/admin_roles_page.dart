import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/admin_role_dto.dart';
import '../providers/admin_providers.dart';

const Color _kAdminViolet = Color(0xFF8E24AA);

/// Read-only catalog of system roles (GET /api/v1/roles).
/// The backend exposes no create/update/delete for roles, so this view is
/// reference-only — roles are assigned to users from the Users page.
class AdminRolesPage extends ConsumerWidget {
  const AdminRolesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final rolesAsync = ref.watch(adminRolesProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
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
                        'Роли системы',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Справочник ролей и их прав. Назначение ролей '
                        'выполняется на вкладке «Пользователи».',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Обновить',
                  onPressed: () => ref.invalidate(adminRolesProvider),
                  icon: Icon(Icons.refresh_rounded, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            rolesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF44336).withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Не удалось загрузить роли',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$error',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _kAdminViolet,
                      ),
                      onPressed: () => ref.invalidate(adminRolesProvider),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
              data: (roles) {
                if (roles.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.divider),
                    ),
                    child: Center(
                      child: Text(
                        'Роли не найдены',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  );
                }

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: roles
                      .map((role) => _RoleCard(role: role, colors: colors))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.colors});

  final AdminRoleDto role;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kAdminViolet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: _kAdminViolet,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name.isNotEmpty ? role.name : role.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      role.code,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (role.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              role.description,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (role.isDefault) _flag('по умолчанию', const Color(0xFF4CAF50)),
              if (role.isPrivileged) _flag('привилегии', _kAdminViolet),
              if (role.isSupport) _flag('поддержка', const Color(0xFF2196F3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
