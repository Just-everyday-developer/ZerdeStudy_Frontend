import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_moderator_data.dart';
import '../../../../core/theme/app_theme_colors.dart';

enum _SortColumn { none, priority, date, reason }

class ModeratorReportsPage extends ConsumerStatefulWidget {
  const ModeratorReportsPage({super.key});

  @override
  ConsumerState<ModeratorReportsPage> createState() =>
      _ModeratorReportsPageState();
}

class _ModeratorReportsPageState extends ConsumerState<ModeratorReportsPage> {
  final Set<String> _selected = {};
  ModReport? _openReport;
  String _banReason = 'Спам';
  String _banDuration = '24 часа';
  bool _deleteContent = false;

  _SortColumn _sortColumn = _SortColumn.none;
  bool _sortAscending = true;

  static const _banReasons = [
    'Спам',
    'Оскорбление',
    'Нарушение авторских прав',
    'Нежелательный контент',
    'Мошенничество',
  ];

  static const _banDurations = [
    '24 часа',
    '3 дня',
    '1 неделя',
    '1 месяц',
    'Навсегда',
  ];

  static int _priorityOrder(String p) =>
      const {'high': 0, 'medium': 1, 'low': 2}[p] ?? 3;

  List<ModReport> get _sortedReports {
    final list = List<ModReport>.from(kModReports);
    if (_sortColumn == _SortColumn.none) return list;

    list.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case _SortColumn.priority:
          cmp = _priorityOrder(
            a.priority,
          ).compareTo(_priorityOrder(b.priority));
        case _SortColumn.reason:
          cmp = a.reason.compareTo(b.reason);
        case _SortColumn.date:
          // kModReports is already newest-first, so use index as proxy
          cmp = kModReports.indexOf(a).compareTo(kModReports.indexOf(b));
        case _SortColumn.none:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });
    return list;
  }

  void _toggleSort(_SortColumn col) {
    setState(() {
      if (_sortColumn == col) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = col;
        _sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reports = _sortedReports;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main table
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + batch actions
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Жалобы и баны',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${kModReports.length} активных жалоб',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_selected.isNotEmpty) ...[
                      Text(
                        'Выбрано: ${_selected.length}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _selected.clear()),
                        icon: const Icon(Icons.deselect_rounded, size: 16),
                        label: const Text('Снять выбор'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          side: BorderSide(color: colors.divider),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _selected.clear()),
                        icon: const Icon(Icons.block_rounded, size: 16),
                        label: const Text('Массовый бан'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Column headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const SizedBox(width: 36),
                    _TableHeader(
                      label: 'Приоритет',
                      flex: 2,
                      sortColumn: _SortColumn.priority,
                      activeSort: _sortColumn,
                      ascending: _sortAscending,
                      onTap: _toggleSort,
                    ),
                    _TableHeader(label: 'Тип', flex: 2),
                    _TableHeader(label: 'Инициатор', flex: 2),
                    _TableHeader(label: 'Объект жалобы', flex: 3),
                    _TableHeader(
                      label: 'Причина',
                      flex: 2,
                      sortColumn: _SortColumn.reason,
                      activeSort: _sortColumn,
                      ascending: _sortAscending,
                      onTap: _toggleSort,
                    ),
                    _TableHeader(
                      label: 'Дата',
                      flex: 2,
                      sortColumn: _SortColumn.date,
                      activeSort: _sortColumn,
                      ascending: _sortAscending,
                      onTap: _toggleSort,
                    ),
                    const SizedBox(width: 96), // fixed width for actions
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Table rows
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  itemCount: reports.length,
                  itemBuilder: (context, i) {
                    final report = reports[i];
                    final isSelected = _selected.contains(report.id);
                    return _ReportRow(
                      report: report,
                      isSelected: isSelected,
                      colors: colors,
                      onSelect: (v) => setState(() {
                        if (v) {
                          _selected.add(report.id);
                        } else {
                          _selected.remove(report.id);
                        }
                      }),
                      onTap: () => setState(() => _openReport = report),
                      onBan: () => setState(() => _openReport = report),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Ban panel
        if (_openReport != null)
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(left: BorderSide(color: colors.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Детали жалобы',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() => _openReport = null),
                        icon: const Icon(Icons.close_rounded),
                        iconSize: 18,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          label: 'Инициатор',
                          value: _openReport!.initiator,
                          colors: colors,
                        ),
                        _InfoRow(
                          label: 'Объект',
                          value: _openReport!.target,
                          colors: colors,
                        ),
                        _InfoRow(
                          label: 'Причина',
                          value: _openReport!.reason,
                          colors: colors,
                        ),
                        _InfoRow(
                          label: 'Дата',
                          value: _openReport!.createdAt,
                          colors: colors,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нарушающий контент',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF44336,
                            ).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xFFF44336,
                              ).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            _openReport!.content,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Инструменты бана',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Причина бана',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _banReason,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colors.divider),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: _banReasons
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _banReason = v ?? _banReason),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Срок бана',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _banDuration,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colors.divider),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: _banDurations
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _banDuration = v ?? _banDuration),
                        ),
                        const SizedBox(height: 10),
                        CheckboxListTile(
                          value: _deleteContent,
                          onChanged: (v) =>
                              setState(() => _deleteContent = v ?? false),
                          title: const Text(
                            'Удалить весь связанный контент',
                            style: TextStyle(fontSize: 12),
                          ),
                          activeColor: const Color(0xFFF44336),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _openReport = null),
                            icon: const Icon(Icons.block_rounded, size: 16),
                            label: Text('Заблокировать · $_banDuration'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF44336),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _openReport = null),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Отклонить жалобу'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.textSecondary,
                              side: BorderSide(color: colors.divider),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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
      ],
    );
  }
}

// ── Row widget ──────────────────────────────────────────────────────────────

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.report,
    required this.isSelected,
    required this.colors,
    required this.onSelect,
    required this.onTap,
    required this.onBan,
  });

  final ModReport report;
  final bool isSelected;
  final AppThemeColors colors;
  final ValueChanged<bool> onSelect;
  final VoidCallback onTap;
  final VoidCallback onBan;

  static const _kOrange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? _kOrange.withValues(alpha: 0.06) : colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _kOrange.withValues(alpha: 0.2) : colors.divider,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (v) => onSelect(v ?? false),
                  activeColor: _kOrange,
                ),
              ),
              // Priority
              Expanded(
                flex: 2,
                child: _PriorityBadge(priority: report.priority),
              ),
              // Type
              Expanded(flex: 2, child: _TypeChip(type: report.type)),
              // Initiator
              Expanded(
                flex: 2,
                child: Text(
                  report.initiator,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textPrimary),
                ),
              ),
              // Target
              Expanded(
                flex: 3,
                child: Text(
                  report.target,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textPrimary),
                ),
              ),
              // Reason
              Expanded(
                flex: 2,
                child: Text(
                  report.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textPrimary),
                ),
              ),
              // Date
              Expanded(
                flex: 2,
                child: Text(
                  report.createdAt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ),
              // Actions — fixed 96px to match header spacer
              SizedBox(
                width: 96,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuickAction(
                      icon: Icons.check_rounded,
                      color: const Color(0xFF4CAF50),
                      tooltip: 'Принять жалобу',
                      onTap: () {},
                    ),
                    const SizedBox(width: 4),
                    _QuickAction(
                      icon: Icons.block_rounded,
                      color: const Color(0xFFF44336),
                      tooltip: 'Заблокировать',
                      onTap: onBan,
                    ),
                    const SizedBox(width: 4),
                    _QuickAction(
                      icon: Icons.close_rounded,
                      color: Colors.grey,
                      tooltip: 'Отклонить жалобу',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.label,
    required this.flex,
    this.sortColumn,
    this.activeSort,
    this.ascending = true,
    this.onTap,
  });

  final String label;
  final int flex;
  final _SortColumn? sortColumn;
  final _SortColumn? activeSort;
  final bool ascending;
  final void Function(_SortColumn)? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = sortColumn != null && activeSort == sortColumn;
    final baseStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    final content = sortColumn != null
        ? InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => onTap?.call(sortColumn!),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: baseStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    isActive
                        ? (ascending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded)
                        : Icons.unfold_more_rounded,
                    size: 12,
                    color: isActive
                        ? const Color(0xFFFF6B35)
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          )
        : Text(label, style: baseStyle, overflow: TextOverflow.ellipsis);

    return Expanded(flex: flex, child: content);
  }
}

// ── Cell widgets ─────────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (priority) {
      'high' => (const Color(0xFFF44336), 'Высокий'),
      'medium' => (const Color(0xFFFF9800), 'Средний'),
      _ => (const Color(0xFF9E9E9E), 'Низкий'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (type) {
      'user' => (Icons.person_rounded, 'Польз.'),
      'comment' => (Icons.comment_rounded, 'Коммент.'),
      'course' => (Icons.video_library_rounded, 'Курс'),
      _ => (Icons.info_rounded, type),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.colors,
  });
  final String label;
  final String value;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
