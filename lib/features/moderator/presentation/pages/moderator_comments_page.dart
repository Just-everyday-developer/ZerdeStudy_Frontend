import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_moderator_controller.dart';
import '../../../../app/state/demo_moderator_data.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/theme/app_theme_colors.dart';

class ModeratorCommentsPage extends ConsumerStatefulWidget {
  const ModeratorCommentsPage({super.key});

  @override
  ConsumerState<ModeratorCommentsPage> createState() =>
      _ModeratorCommentsPageState();
}

class _ModeratorCommentsPageState extends ConsumerState<ModeratorCommentsPage> {
  String? _selectedId;
  ModCommentStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final comments = ref.watch(demoModeratorCommentsProvider);
    final filteredComments = comments
        .where((item) => _filterStatus == null || item.status == _filterStatus)
        .toList(growable: false);
    final selectedComment = _resolveSelectedComment(filteredComments);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 348,
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
                      'Модерация комментариев',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Очередь жалоб, скрытых комментариев и эскалаций.',
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
                        _CountPill(
                          label: 'На ревью',
                          value: comments
                              .where(
                                (item) =>
                                    item.status == ModCommentStatus.needsReview,
                              )
                              .length,
                          color: const Color(0xFFFF9800),
                        ),
                        _CountPill(
                          label: 'Скрыты',
                          value: comments
                              .where(
                                (item) =>
                                    item.status == ModCommentStatus.hidden,
                              )
                              .length,
                          color: const Color(0xFFF44336),
                        ),
                        _CountPill(
                          label: 'Эскалации',
                          value: comments
                              .where(
                                (item) =>
                                    item.status == ModCommentStatus.escalated,
                              )
                              .length,
                          color: const Color(0xFF8E24AA),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChip(
                          label: 'Все',
                          selected: _filterStatus == null,
                          onTap: () => setState(() => _filterStatus = null),
                        ),
                        _FilterChip(
                          label: 'Новые',
                          selected:
                              _filterStatus == ModCommentStatus.needsReview,
                          onTap: () => setState(
                            () => _filterStatus = ModCommentStatus.needsReview,
                          ),
                        ),
                        _FilterChip(
                          label: 'Скрытые',
                          selected: _filterStatus == ModCommentStatus.hidden,
                          onTap: () => setState(
                            () => _filterStatus = ModCommentStatus.hidden,
                          ),
                        ),
                        _FilterChip(
                          label: 'Эскалации',
                          selected: _filterStatus == ModCommentStatus.escalated,
                          onTap: () => setState(
                            () => _filterStatus = ModCommentStatus.escalated,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredComments.isEmpty
                    ? Center(
                        child: Text(
                          'По выбранному фильтру комментариев нет.',
                          style: TextStyle(color: colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                        itemCount: filteredComments.length,
                        itemBuilder: (context, index) {
                          final comment = filteredComments[index];
                          final isSelected = comment.id == selectedComment?.id;

                          return InkWell(
                            onTap: () =>
                                setState(() => _selectedId = comment.id),
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
                                          comment.author,
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      _CommentStatusBadge(
                                        status: comment.status,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${comment.surface} · ${comment.location}',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    comment.content,
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
                                      _InlineMeta(
                                        icon: Icons.flag_rounded,
                                        label: '${comment.reportCount} жалоб',
                                      ),
                                      _InlineMeta(
                                        icon: Icons.schedule_rounded,
                                        label: comment.reportedAt,
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
          child: selectedComment == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 48,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Выберите комментарий для модерации',
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
                                  'Комментарий от ${selectedComment.author}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${selectedComment.surface} · ${selectedComment.location}',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _CommentStatusBadge(status: selectedComment.status),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _DetailCard(
                        title: 'Текст комментария',
                        child: Text(
                          selectedComment.content,
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
                            child: _DetailCard(
                              title: 'Контекст',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    label: 'Локация',
                                    value: selectedComment.location,
                                  ),
                                  _InfoRow(
                                    label: 'Поверхность',
                                    value: selectedComment.surface,
                                  ),
                                  _InfoRow(
                                    label: 'Последний сигнал',
                                    value: selectedComment.reportedAt,
                                  ),
                                  _InfoRow(
                                    label: 'Жалоб',
                                    value: '${selectedComment.reportCount}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _DetailCard(
                              title: 'Причины жалоб',
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedComment.reasons
                                    .map(
                                      (reason) => _ReasonBadge(label: reason),
                                    )
                                    .toList(growable: false),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DetailCard(
                        title: 'Сигналы риска',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: selectedComment.riskSignals
                              .map(
                                (signal) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Icon(
                                          Icons.bolt_rounded,
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
                              )
                              .toList(growable: false),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _applyAction(
                              selectedComment.id,
                              ModCommentStatus.hidden,
                              'Комментарий скрыт и отправлен в hidden queue.',
                            ),
                            icon: const Icon(Icons.visibility_off_rounded),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF44336),
                            ),
                            label: const Text('Скрыть комментарий'),
                          ),
                          FilledButton.icon(
                            onPressed: () => _applyAction(
                              selectedComment.id,
                              ModCommentStatus.approved,
                              'Комментарий оставлен видимым.',
                            ),
                            icon: const Icon(Icons.check_circle_rounded),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                            label: const Text('Оставить видимым'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _applyAction(
                              selectedComment.id,
                              ModCommentStatus.escalated,
                              'Комментарий эскалирован в reports queue.',
                            ),
                            icon: const Icon(Icons.outbound_rounded),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF8E24AA),
                              side: const BorderSide(color: Color(0xFF8E24AA)),
                            ),
                            label: const Text('Эскалировать'),
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

  ModCommentItem? _resolveSelectedComment(List<ModCommentItem> comments) {
    if (comments.isEmpty) {
      return null;
    }
    for (final comment in comments) {
      if (comment.id == _selectedId) {
        return comment;
      }
    }
    return comments.first;
  }

  void _applyAction(
    String commentId,
    ModCommentStatus status,
    String noticeMessage,
  ) {
    ref
        .read(demoModeratorCommentsProvider.notifier)
        .updateStatus(commentId, status);
    AppNotice.show(
      context,
      message: noticeMessage,
      type: AppNoticeType.success,
    );
    setState(() => _selectedId = commentId);
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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

class _CommentStatusBadge extends StatelessWidget {
  const _CommentStatusBadge({required this.status});

  final ModCommentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ModCommentStatus.needsReview => ('На ревью', const Color(0xFFFF9800)),
      ModCommentStatus.hidden => ('Скрыт', const Color(0xFFF44336)),
      ModCommentStatus.approved => ('Оставлен', const Color(0xFF4CAF50)),
      ModCommentStatus.escalated => ('Эскалация', const Color(0xFF8E24AA)),
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

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({required this.icon, required this.label});

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

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.child});

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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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

class _ReasonBadge extends StatelessWidget {
  const _ReasonBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.26),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2196F3),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
