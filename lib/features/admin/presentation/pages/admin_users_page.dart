import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../core/common_widgets/adaptive_panel.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/data/models/backend_achievement_dto.dart';
import '../../../courses_backend/data/models/backend_progress_dto.dart';
import '../../data/models/admin_role_dto.dart';
import '../../data/models/admin_user_dto.dart';
import '../providers/admin_providers.dart';

String _adminStr(BuildContext context, {required String ru, required String kk, required String en}) {
  return switch (context.l10n.locale) {
    AppLocale.ru => ru,
    AppLocale.kk => kk,
    _ => en,
  };
}

const Color _kAdminViolet = Color(0xFF8E24AA);

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final Set<String> _busyUserIds = <String>{};
  String _query = '';

  Future<void> _runUserAction(
    String userId,
    Future<void> Function() action,
  ) async {
    setState(() => _busyUserIds.add(userId));
    String? error;
    try {
      await action();
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _busyUserIds.remove(userId));
      }
    }

    if (!mounted) return;
    // Refresh the list so the UI reflects the server state.
    ref.invalidate(adminUsersProvider);
    ref.invalidate(adminUserDetailsProvider(userId));

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось: $error')));
    }
  }

  Future<void> _toggleStatus(AdminUserDto user) {
    final token = ref.read(adminAccessTokenProvider);
    if (token == null || token.isEmpty) return Future<void>.value();
    final remote = ref.read(adminRemoteDataSourceProvider);
    return _runUserAction(
      user.id,
      () => remote.updateUserStatus(
        accessToken: token,
        userId: user.id,
        isActive: !user.isActive,
      ),
    );
  }

  Future<void> _editRoles(AdminUserDto user) async {
    // The "manager" role is retired — don't offer it as an assignable
    // option even though the backend still returns it in the role list.
    final allRoles = ref
        .read(adminRolesProvider)
        .maybeWhen(
          data: (roles) => roles,
          orElse: () => const <AdminRoleDto>[],
        )
        .where((role) => role.code.toLowerCase() != 'manager')
        .toList(growable: false);
    if (allRoles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Список ролей недоступен')));
      return;
    }

    final assignableIds = allRoles.map((role) => role.id).toSet();
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (_) => _RoleEditorDialog(
        allRoles: allRoles,
        // Drop any role the dialog doesn't show (e.g. the retired "manager"
        // role) so saving doesn't silently keep it on the user.
        initialRoleIds: user.roles
            .map((r) => r.id)
            .where(assignableIds.contains)
            .toSet(),
        userName: user.displayName,
      ),
    );

    if (selected == null) return; // cancelled
    final token = ref.read(adminAccessTokenProvider);
    if (token == null || token.isEmpty) return;
    final remote = ref.read(adminRemoteDataSourceProvider);
    await _runUserAction(
      user.id,
      () => remote.replaceUserRoles(
        accessToken: token,
        userId: user.id,
        roleIds: selected,
      ),
    );
  }

  Future<void> _showUserDetails(AdminUserDto user) {
    return showAdaptivePanel<void>(
      context: context,
      wideMaxWidth: 780,
      builder: (ctx) => _UserDetailsPanel(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = context.isCompactLayout;
    final usersAsync = ref.watch(adminUsersProvider);
    // Pre-fetch roles so they're available instantly when user taps "Роли"
    ref.watch(adminRolesProvider);
    final currentUserId =
        ref.watch(authControllerProvider).session?.user.id ?? '';

    final titleStr = _adminStr(context,
        ru: 'Управление пользователями',
        kk: 'Пайдаланушыларды басқару',
        en: 'User Management');
    final subtitleStr = _adminStr(context,
        ru: 'Список зарегистрированных пользователей, управление ролями и статусами.',
        kk: 'Тіркелген пайдаланушылар тізімі, рөлдер мен мәртебелерді басқару.',
        en: 'List of registered users, role and status management.');
    final refreshStr = _adminStr(context, ru: 'Обновить', kk: 'Жаңарту', en: 'Refresh');
    final searchStr = _adminStr(context,
        ru: 'Поиск по имени, email или роли',
        kk: 'Аты, email немесе рөлі бойынша іздеу',
        en: 'Search by name, email or role');
    final emptyStr = _adminStr(context, ru: 'Никого не найдено', kk: 'Ешкім табылмады', en: 'Nobody found');

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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800, fontSize: compact ? 18 : null),
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
                  onPressed: usersAsync.isLoading
                      ? null
                      : () => ref.invalidate(adminUsersProvider),
                  icon: usersAsync.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colors.textSecondary),
                        )
                      : Icon(Icons.refresh_rounded, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            usersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _ErrorCard(
                message: '$error',
                onRetry: () => ref.invalidate(adminUsersProvider),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return _EmptyCard(colors: colors);
                }

                final normalizedQuery = _query.trim().toLowerCase();
                final filtered = normalizedQuery.isEmpty
                    ? users
                    : users
                          .where(
                            (u) =>
                                u.displayName.toLowerCase().contains(normalizedQuery) ||
                                u.email.toLowerCase().contains(normalizedQuery) ||
                                u.roles.any((r) => r.code.toLowerCase().contains(normalizedQuery)),
                          )
                          .toList(growable: false);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(users: users, colors: colors),
                    const SizedBox(height: 18),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: searchStr,
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...filtered.map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _UserRowCard(
                          user: user,
                          colors: colors,
                          busy: _busyUserIds.contains(user.id),
                          isSelf: user.id == currentUserId,
                          onToggleStatus: () => _toggleStatus(user),
                          onEditRoles: () => _editRoles(user),
                          onViewDetails: () => _showUserDetails(user),
                        ),
                      ),
                    ),
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(emptyStr, style: TextStyle(color: colors.textSecondary)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.users, required this.colors});

  final List<AdminUserDto> users;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final total = users.length;
    final active = users.where((u) => u.isActive).length;
    final banned = total - active;

    Widget chip(String label, String value, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final l10n = context.l10n;
    final totalLabel = switch (l10n.locale) {
      AppLocale.ru => 'Всего',
      AppLocale.kk => 'Барлығы',
      _ => 'Total',
    };
    final activeLabel = switch (l10n.locale) {
      AppLocale.ru => 'Активны',
      AppLocale.kk => 'Белсенді',
      _ => 'Active',
    };
    final bannedLabel = switch (l10n.locale) {
      AppLocale.ru => 'Заблокированы',
      AppLocale.kk => 'Блокталған',
      _ => 'Banned',
    };

    return Row(
      children: [
        Expanded(child: chip(totalLabel, '$total', colors.textPrimary)),
        const SizedBox(width: 12),
        Expanded(child: chip(activeLabel, '$active', const Color(0xFF4CAF50))),
        const SizedBox(width: 12),
        Expanded(child: chip(bannedLabel, '$banned', const Color(0xFFF44336))),
      ],
    );
  }
}

class _UserRowCard extends StatelessWidget {
  const _UserRowCard({
    required this.user,
    required this.colors,
    required this.busy,
    required this.isSelf,
    required this.onToggleStatus,
    required this.onEditRoles,
    required this.onViewDetails,
  });

  final AdminUserDto user;
  final AppThemeColors colors;
  final bool busy;
  final bool isSelf;
  final VoidCallback onToggleStatus;
  final VoidCallback onEditRoles;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final statusColor = user.isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final selfLabel = _adminStr(context, ru: 'Вы', kk: 'Сіз', en: 'You');
    final noRoleLabel = _adminStr(context, ru: 'без роли', kk: 'рөлсіз', en: 'no role');
    final activeLabel = _adminStr(context, ru: 'Активен', kk: 'Белсенді', en: 'Active');
    final blockedLabel = _adminStr(context, ru: 'Заблокирован', kk: 'Блокталған', en: 'Blocked');
    final detailsTooltip = _adminStr(context, ru: 'Детали пользователя', kk: 'Пайдаланушы мәліметтері', en: 'User details');
    final rolesLabel = _adminStr(context, ru: 'Роли', kk: 'Рөлдер', en: 'Roles');
    final cantChangeSelf = _adminStr(context, ru: 'Нельзя изменить свой статус', kk: 'Өз мәртебеңізді өзгертуге болмайды', en: 'Cannot change own status');
    final blockLabel = _adminStr(context, ru: 'Заблокировать', kk: 'Блоктау', en: 'Block');
    final unblockLabel = _adminStr(context, ru: 'Разблокировать', kk: 'Блоктан шығару', en: 'Unblock');
    final lvLabel = _adminStr(context, ru: 'ур.', kk: 'деңг.', en: 'lv.');
    final statusText = user.isActive ? activeLabel : blockedLabel;

    Widget infoSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            if (isSelf) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _kAdminViolet.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selfLabel,
                  style: const TextStyle(color: _kAdminViolet, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(user.email, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: 12.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (user.roles.isEmpty)
              _RoleChip(label: noRoleLabel, colors: colors, muted: true)
            else
              ...user.roles.map((r) => _RoleChip(label: r.code.isNotEmpty ? r.code : r.name, colors: colors)),
            _RoleChip(label: 'XP ${user.xp} · $lvLabel ${user.level}', colors: colors, muted: true),
          ],
        ),
      ],
    );

    Widget statusDot() => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
        const SizedBox(width: 6),
        Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );

    Widget actionsRow() => busy
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: detailsTooltip,
                onPressed: onViewDetails,
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.visibility_outlined, color: colors.textSecondary),
              ),
              OutlinedButton.icon(
                onPressed: onEditRoles,
                icon: const Icon(Icons.shield_outlined, size: 15),
                label: Text(rolesLabel, style: const TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kAdminViolet,
                  side: BorderSide(color: _kAdminViolet.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: isSelf ? cantChangeSelf : (user.isActive ? blockLabel : unblockLabel),
                child: Switch(
                  value: user.isActive,
                  activeThumbColor: const Color(0xFF4CAF50),
                  onChanged: isSelf ? null : (_) => onToggleStatus(),
                ),
              ),
            ],
          );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardCompact = constraints.maxWidth < 520;
          if (cardCompact) {
            // Mobile: avatar+info on top, status+actions on bottom
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _kAdminViolet.withValues(alpha: 0.12),
                      child: Text(
                        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                        style: const TextStyle(color: _kAdminViolet, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: infoSection()),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    statusDot(),
                    const Spacer(),
                    actionsRow(),
                  ],
                ),
              ],
            );
          }
          // Desktop: horizontal layout
          return Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _kAdminViolet.withValues(alpha: 0.12),
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                  style: const TextStyle(color: _kAdminViolet, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: infoSection()),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  statusDot(),
                  const SizedBox(height: 8),
                  actionsRow(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.colors,
    this.muted = false,
  });

  final String label;
  final AppThemeColors colors;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: muted
            ? colors.surfaceSoft
            : _kAdminViolet.withValues(alpha: 0.1),
        border: Border.all(
          color: muted ? colors.divider : _kAdminViolet.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: muted ? colors.textSecondary : _kAdminViolet,
        ),
      ),
    );
  }
}

class _UserDetailsPanel extends ConsumerWidget {
  const _UserDetailsPanel({required this.user});

  final AdminUserDto user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final detailsAsync = ref.watch(adminUserDetailsProvider(user.id));

    final rolesLabel = switch (l10n.locale) {
      AppLocale.ru => 'Роли',
      AppLocale.kk => 'Рөлдер',
      _ => 'Roles',
    };
    final achievementsLabel = switch (l10n.locale) {
      AppLocale.ru => 'Достижения',
      AppLocale.kk => 'Жетістіктер',
      _ => 'Achievements',
    };
    final courseProgressLabel = switch (l10n.locale) {
      AppLocale.ru => 'Прогресс по курсам',
      AppLocale.kk => 'Курстар бойынша прогресс',
      _ => 'Course progress',
    };
    final noRoleLabel = switch (l10n.locale) {
      AppLocale.ru => 'без роли',
      AppLocale.kk => 'рөлсіз',
      _ => 'no role',
    };
    final refreshLabel = switch (l10n.locale) {
      AppLocale.ru => 'Обновить',
      AppLocale.kk => 'Жаңарту',
      _ => 'Refresh',
    };
    final closeLabel = switch (l10n.locale) {
      AppLocale.ru => 'Закрыть',
      AppLocale.kk => 'Жабу',
      _ => 'Close',
    };

    return Container(
      color: colors.background,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: refreshLabel,
                onPressed: () =>
                    ref.invalidate(adminUserDetailsProvider(user.id)),
              ),
            ],
          ),
          const Divider(height: 16),
          Expanded(
            child: detailsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _DetailsError(
                message: '$error',
                onRetry: () =>
                    ref.invalidate(adminUserDetailsProvider(user.id)),
              ),
              data: (details) {
                if (details == null) {
                  return Center(
                    child: Text(
                      switch (l10n.locale) {
                        AppLocale.ru => 'Нет данных для пользователя.',
                        AppLocale.kk => 'Пайдаланушы деректері жоқ.',
                        _ => 'No data for this user.',
                      },
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailsHeader(
                        profile: details.profile,
                        isActive: user.isActive,
                        colors: colors,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _MetricTile(
                            label: 'XP',
                            value: '${details.profile.xp}',
                            colors: colors,
                          ),
                          _MetricTile(
                            label: switch (l10n.locale) {
                              AppLocale.ru => 'Уровень',
                              AppLocale.kk => 'Деңгей',
                              _ => 'Level',
                            },
                            value: '${details.profile.level}',
                            colors: colors,
                          ),
                          _MetricTile(
                            label: switch (l10n.locale) {
                              AppLocale.ru => 'Серия',
                              AppLocale.kk => 'Жол',
                              _ => 'Streak',
                            },
                            value:
                                '${details.profile.streak}/${details.profile.maxStreak}',
                            colors: colors,
                          ),
                          _MetricTile(
                            label: achievementsLabel,
                            value:
                                '${details.unlockedAchievements}/${details.achievements.length}',
                            colors: colors,
                          ),
                          _MetricTile(
                            label: switch (l10n.locale) {
                              AppLocale.ru => 'Уроки',
                              AppLocale.kk => 'Сабақтар',
                              _ => 'Lessons',
                            },
                            value:
                                '${details.completedLessons}/${details.totalLessons}',
                            colors: colors,
                          ),
                          _MetricTile(
                            label: switch (l10n.locale) {
                              AppLocale.ru => 'Курсы',
                              AppLocale.kk => 'Курстар',
                              _ => 'Courses',
                            },
                            value: '${details.courseProgress.length}',
                            colors: colors,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                        title: rolesLabel,
                        trailing: '${details.roles.length}',
                        colors: colors,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: details.roles.isEmpty
                            ? [
                                _RoleChip(
                                  label: noRoleLabel,
                                  colors: colors,
                                  muted: true,
                                ),
                              ]
                            : details.roles
                                  .map(
                                    (role) => _RoleChip(
                                      label: role.code.isNotEmpty
                                          ? role.code
                                          : role.name,
                                      colors: colors,
                                    ),
                                  )
                                  .toList(growable: false),
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                        title: achievementsLabel,
                        trailing:
                            '${details.unlockedAchievements}/${details.achievements.length}',
                        colors: colors,
                      ),
                      const SizedBox(height: 8),
                      _AchievementsPreview(
                        achievements: details.achievements,
                        colors: colors,
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                        title: courseProgressLabel,
                        trailing: '${details.courseProgress.length}',
                        colors: colors,
                      ),
                      const SizedBox(height: 8),
                      _ProgressPreview(
                        progress: details.courseProgress,
                        courseNames: details.courseNames,
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: _kAdminViolet,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(closeLabel),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({
    required this.profile,
    required this.isActive,
    required this.colors,
  });

  final AdminUserDto profile;
  final bool isActive;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final statusColor = isActive
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: _kAdminViolet.withValues(alpha: 0.12),
          child: Text(
            profile.displayName.isNotEmpty
                ? profile.displayName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: _kAdminViolet,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                profile.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
              ),
              if (profile.bio.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  profile.bio.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isActive ? 'Активен' : 'Заблокирован',
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.trailing,
    required this.colors,
  });

  final String title;
  final String trailing;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Text(
          trailing,
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _AchievementsPreview extends StatelessWidget {
  const _AchievementsPreview({
    required this.achievements,
    required this.colors,
  });

  final List<BackendAchievementDto> achievements;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return Text(
        'Достижений пока нет.',
        style: TextStyle(color: colors.textSecondary),
      );
    }

    return Column(
      children: achievements
          .take(8)
          .map((item) {
            final title = item.title.ru.isNotEmpty
                ? item.title.ru
                : item.title.en.isNotEmpty
                ? item.title.en
                : item.id;
            return _CompactRow(
              icon: item.unlocked
                  ? Icons.emoji_events_rounded
                  : Icons.lock_outline_rounded,
              title: title,
              subtitle: '${item.progress}/${item.goal}',
              color: item.unlocked
                  ? const Color(0xFFFFA000)
                  : colors.textSecondary,
              colors: colors,
            );
          })
          .toList(growable: false),
    );
  }
}

class _ProgressPreview extends StatelessWidget {
  const _ProgressPreview({
    required this.progress,
    required this.courseNames,
    required this.colors,
  });

  final List<BackendCourseProgressDto> progress;
  final Map<String, String> courseNames;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    if (progress.isEmpty) {
      return Text(
        'Прогресса по курсам пока нет.',
        style: TextStyle(color: colors.textSecondary),
      );
    }

    return Column(
      children: progress
          .map((item) {
            final name = courseNames[item.courseId]?.trim();
            final title = (name != null && name.isNotEmpty)
                ? name
                : item.courseId.substring(0, 8);
            return _CompactRow(
              icon: Icons.timeline_rounded,
              title: title,
              subtitle:
                  '${item.progressPercent}% · ${item.completedLessons}/${item.totalLessons} уроков',
              color: _kAdminViolet,
              colors: colors,
            );
          })
          .toList(growable: false),
    );
  }
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            subtitle,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFF44336)),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

class _RoleEditorDialog extends StatefulWidget {
  const _RoleEditorDialog({
    required this.allRoles,
    required this.initialRoleIds,
    required this.userName,
  });

  final List<AdminRoleDto> allRoles;
  final Set<String> initialRoleIds;
  final String userName;

  @override
  State<_RoleEditorDialog> createState() => _RoleEditorDialogState();
}

class _RoleEditorDialogState extends State<_RoleEditorDialog> {
  late final Set<String> _selected = <String>{...widget.initialRoleIds};

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AlertDialog(
      title: Text('Роли · ${widget.userName}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите роли. Сохранение заменяет весь набор ролей пользователя.',
              style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.allRoles.map((role) {
                    final checked = _selected.contains(role.id);
                    return CheckboxListTile(
                      value: checked,
                      activeColor: _kAdminViolet,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        role.name.isNotEmpty ? role.name : role.code,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        role.description.isNotEmpty
                            ? role.description
                            : role.code,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selected.add(role.id);
                          } else {
                            _selected.remove(role.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _kAdminViolet),
          // Backend requires at least one role.
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selected.toList()),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
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
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFF44336)),
              const SizedBox(width: 10),
              Text(
                'Не удалось загрузить пользователей',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _kAdminViolet),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 40,
            color: colors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Пользователи не найдены',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Войдите под учётной записью администратора, чтобы увидеть список.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
