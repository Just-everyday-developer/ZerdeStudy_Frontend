import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/admin_role_dto.dart';
import '../providers/admin_providers.dart';

const Color _kAdminViolet = Color(0xFF8E24AA);

String _roleStr(BuildContext context, {required String ru, required String kk, required String en}) {
  return switch (context.l10n.locale) {
    AppLocale.ru => ru,
    AppLocale.kk => kk,
    _ => en,
  };
}

/// Read-only catalog of system roles (GET /api/v1/roles).
class AdminRolesPage extends ConsumerWidget {
  const AdminRolesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final compact = context.isCompactLayout;
    final rolesAsync = ref.watch(adminRolesProvider);

    final titleStr = _roleStr(context,
        ru: 'Роли системы', kk: 'Жүйе рөлдері', en: 'System Roles');
    final subtitleStr = _roleStr(context,
        ru: 'Справочник ролей и их прав. Назначение ролей выполняется на вкладке «Пользователи».',
        kk: 'Рөлдер мен олардың құқықтарының анықтамалығы. Рөлдер «Пайдаланушылар» қойындысында тағайындалады.',
        en: 'Role catalog and permissions. Roles are assigned from the Users tab.');
    final refreshStr = _roleStr(context, ru: 'Обновить', kk: 'Жаңарту', en: 'Refresh');
    final retryStr = _roleStr(context, ru: 'Повторить', kk: 'Қайталау', en: 'Retry');
    final errorStr = _roleStr(context,
        ru: 'Не удалось загрузить роли',
        kk: 'Рөлдерді жүктеу мүмкін болмады',
        en: 'Failed to load roles');
    final emptyStr = _roleStr(context,
        ru: 'Роли не найдены', kk: 'Рөлдер табылмады', en: 'No roles found');

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? 16 : 32),
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
                        titleStr,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: compact ? 18 : null,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitleStr,
                        style: TextStyle(color: colors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: refreshStr,
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
                  border: Border.all(color: const Color(0xFFF44336).withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(errorStr,
                        style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('$error',
                        style: TextStyle(color: colors.textSecondary, fontSize: 12.5)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: _kAdminViolet),
                      onPressed: () => ref.invalidate(adminRolesProvider),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(retryStr),
                    ),
                  ],
                ),
              ),
              data: (roles) {
                final visibleRoles = roles
                    .where((role) => role.code.toLowerCase() != 'manager')
                    .toList(growable: false);
                if (visibleRoles.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.divider),
                    ),
                    child: Center(
                      child: Text(emptyStr, style: TextStyle(color: colors.textSecondary)),
                    ),
                  );
                }

                if (compact) {
                  return Column(
                    children: visibleRoles
                        .map((role) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RoleCard(role: role, colors: colors, fullWidth: true),
                            ))
                        .toList(),
                  );
                }

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: visibleRoles
                      .map((role) => _RoleCard(role: role, colors: colors, fullWidth: false))
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
  const _RoleCard({required this.role, required this.colors, required this.fullWidth});

  final AdminRoleDto role;
  final AppThemeColors colors;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final defaultStr = _roleStr(context, ru: 'по умолчанию', kk: 'әдепкі', en: 'default');
    final privilegedStr = _roleStr(context, ru: 'привилегии', kk: 'артықшылықтар', en: 'privileged');
    final supportStr = _roleStr(context, ru: 'поддержка', kk: 'қолдау', en: 'support');

    return Container(
      width: fullWidth ? double.infinity : 300,
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
                child: const Icon(Icons.shield_rounded, color: _kAdminViolet, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name.isNotEmpty ? role.name : role.code,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    Text(
                      role.code,
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 11.5, fontFamily: 'monospace'),
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
              style: TextStyle(color: colors.textSecondary, fontSize: 12.5, height: 1.4),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (role.isDefault) _flag(defaultStr, const Color(0xFF4CAF50)),
              if (role.isPrivileged) _flag(privilegedStr, _kAdminViolet),
              if (role.isSupport) _flag(supportStr, const Color(0xFF2196F3)),
              if (!role.isDefault && !role.isPrivileged && !role.isSupport)
                Opacity(opacity: 0, child: _flag('—', Colors.transparent)),
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
