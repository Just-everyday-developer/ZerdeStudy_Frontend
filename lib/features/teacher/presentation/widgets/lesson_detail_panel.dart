// Right-side lesson detail panel with rich block editor.
//
// Uses ReorderableListView for drag-to-reorder blocks (works on web/desktop/
// mobile out of the box; long-press on touch, drag-handle on desktop).

// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../application/course_constructor_controller.dart';
import '../../domain/models/course_graph.dart';

class LessonDetailPanel extends ConsumerWidget {
  const LessonDetailPanel({super.key});

  static const double desktopWidth = 420;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseConstructorProvider);
    final controller = ref.read(courseConstructorProvider.notifier);
    final colors = context.appColors;
    final node = state.selectedNode;
    if (node == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: colors.backgroundElevated,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DetailHeader(
              node: node,
              onClose: controller.clearSelection,
              onDelete: () => controller.deleteNode(node.id),
              onTitleChanged: (v) => controller.updateNode(node.id, title: v),
              onDurationChanged: (v) =>
                  controller.updateNode(node.id, duration: v),
              onItemCountChanged: (v) =>
                  controller.updateNode(node.id, itemCount: v),
            ),
            Expanded(
              child: _BlockList(
                key: ValueKey(node.id),
                node: node,
                onUpdate: (b, patch) => controller.updateBlock(
                  node.id,
                  b.id,
                  title: patch.title,
                  body: patch.body,
                  url: patch.url,
                  language: patch.language,
                  durationMinutes: patch.durationMinutes,
                  itemCount: patch.itemCount,
                  tone: patch.tone,
                ),
                onRemove: (b) => controller.removeBlock(node.id, b.id),
                onReorder: (old, neu) =>
                    controller.reorderBlocks(node.id, old, neu),
                onAddBlock: (t) => controller.addBlock(node.id, t),
              ),
            ),
            _DetailFooter(
              onSave: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Saved.')));
              },
              onPreview: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header (title, type chip, meta fields)
// ─────────────────────────────────────────────────────────────────────────────

class _DetailHeader extends StatefulWidget {
  const _DetailHeader({
    required this.node,
    required this.onClose,
    required this.onDelete,
    required this.onTitleChanged,
    required this.onDurationChanged,
    required this.onItemCountChanged,
  });

  final CourseNode node;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<int> onItemCountChanged;

  @override
  State<_DetailHeader> createState() => _DetailHeaderState();
}

class _DetailHeaderState extends State<_DetailHeader> {
  late TextEditingController _titleCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.node.title);
  }

  @override
  void didUpdateWidget(covariant _DetailHeader old) {
    super.didUpdateWidget(old);
    if (old.node.id != widget.node.id) {
      _titleCtrl.text = widget.node.title;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final n = widget.node;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeChip(type: n.type),
              const Spacer(),
              IconButton(
                tooltip: 'Delete node',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: colors.danger,
                ),
                onPressed: widget.onDelete,
              ),
              IconButton(
                tooltip: 'Close',
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colors.textSecondary,
                ),
                onPressed: widget.onClose,
              ),
            ],
          ),
          TextField(
            controller: _titleCtrl,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
            ),
            onChanged: widget.onTitleChanged,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                n.id.toUpperCase(),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 10.5,
                  fontFamily: 'monospace',
                ),
              ),
              if (n.durationMinutes != null)
                _NumberField(
                  label: 'Duration',
                  unit: 'min',
                  value: n.durationMinutes!,
                  onChanged: widget.onDurationChanged,
                ),
              if (n.itemCount != null)
                _NumberField(
                  label: n.type == CourseNodeType.practice
                      ? 'Puzzles'
                      : 'Items',
                  value: n.itemCount!,
                  onChanged: widget.onItemCountChanged,
                ),
              if (n.mastery != null && n.mastery! > 0)
                _Pill(
                  text: '${(n.mastery! * 100).round()}% mastery',
                  color: n.mastery! > 0.7
                      ? colors.success
                      : (n.mastery! > 0.5 ? colors.accent : colors.danger),
                ),
              if (n.risk) _Pill(text: '⚠ At risk', color: colors.danger),
            ],
          ),
          if (n.risk) ...[
            const SizedBox(height: 14),
            _CalloutCard(
              color: colors.danger,
              title: 'RISK · DROP-OFF 39%',
              body:
                  '42% of learners stall here. NULL semantics aren\'t introduced before they\'re used. AI suggests inserting a 4-min bridge lesson.',
            ),
          ],
          if (n.type == CourseNodeType.ghost) ...[
            const SizedBox(height: 14),
            _CalloutCard(
              color: colors.accent,
              title: 'AI · CO-AUTHOR PROPOSAL',
              body:
                  'Drafted to address the OUTER joins drop-off. Approve to materialize as a regular lesson in the graph.',
              dashed: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final CourseNodeType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = switch (type) {
      CourseNodeType.module => colors.primary,
      CourseNodeType.lesson => colors.primary,
      CourseNodeType.quiz => colors.accent,
      CourseNodeType.practice => const Color(0xFFB4A8FF),
      CourseNodeType.milestone => colors.success,
      CourseNodeType.ghost => colors.accent,
    };
    final label = switch (type) {
      CourseNodeType.module => 'MODULE',
      CourseNodeType.lesson => 'LESSON',
      CourseNodeType.quiz => 'QUIZ',
      CourseNodeType.practice => 'LAB',
      CourseNodeType.milestone => 'MILESTONE',
      CourseNodeType.ghost => 'AI DRAFT',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.06,
        ),
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.unit,
  });

  final String label;
  final int value;
  final String? unit;
  final ValueChanged<int> onChanged;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.value}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 9.5,
            letterSpacing: 0.14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 11.5,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: colors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: colors.divider),
              ),
            ),
            onSubmitted: (v) {
              final p = int.tryParse(v);
              if (p != null) widget.onChanged(p);
            },
          ),
        ),
        if (widget.unit != null) ...[
          const SizedBox(width: 4),
          Text(
            widget.unit!,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CalloutCard extends StatelessWidget {
  const _CalloutCard({
    required this.color,
    required this.title,
    required this.body,
    this.dashed = false,
  });
  final Color color;
  final String title;
  final String body;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              letterSpacing: 0.14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Block list (reorderable)
// ─────────────────────────────────────────────────────────────────────────────

class _BlockPatch {
  _BlockPatch({
    this.title,
    this.body,
    this.url,
    this.language,
    this.durationMinutes,
    this.itemCount,
    this.tone,
  });
  String? title, body, url, language;
  int? durationMinutes, itemCount;
  CourseCalloutTone? tone;
}

class _BlockList extends StatelessWidget {
  const _BlockList({
    super.key,
    required this.node,
    required this.onUpdate,
    required this.onRemove,
    required this.onReorder,
    required this.onAddBlock,
  });

  final CourseNode node;
  final void Function(CourseBlock b, _BlockPatch patch) onUpdate;
  final void Function(CourseBlock b) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(CourseBlockType type) onAddBlock;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Row(
            children: [
              Text(
                'CONTENT BLOCKS · ${node.blocks.length}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 0.14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                iconSize: 16,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                tooltip: 'AI · suggest blocks',
                onPressed: () {},
                icon: Icon(
                  Icons.auto_awesome_rounded,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            buildDefaultDragHandles: false,
            itemCount: node.blocks.length,
            onReorder: onReorder,
            footer: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 14),
              child: _AddBlock(onAdd: onAddBlock),
            ),
            itemBuilder: (context, index) {
              final block = node.blocks[index];
              return Padding(
                key: ValueKey(block.id),
                padding: const EdgeInsets.only(bottom: 6),
                child: _BlockTile(
                  block: block,
                  index: index,
                  onUpdate: (patch) => onUpdate(block, patch),
                  onRemove: () => onRemove(block),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BlockTile extends StatefulWidget {
  const _BlockTile({
    required this.block,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  final CourseBlock block;
  final int index;
  final void Function(_BlockPatch patch) onUpdate;
  final VoidCallback onRemove;

  @override
  State<_BlockTile> createState() => _BlockTileState();
}

class _BlockTileState extends State<_BlockTile> {
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.block.title);
    _bodyCtrl = TextEditingController(text: widget.block.body);
  }

  @override
  void didUpdateWidget(covariant _BlockTile old) {
    super.didUpdateWidget(old);
    if (old.block.id != widget.block.id) {
      _titleCtrl.text = widget.block.title;
      _bodyCtrl.text = widget.block.body;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final b = widget.block;
    final isCallout = b.type == CourseBlockType.callout;

    Color borderColor = colors.divider;
    Color bgColor = colors.surfaceSoft;
    if (isCallout) {
      final tone = b.tone ?? CourseCalloutTone.primary;
      final c = _toneColor(tone, colors);
      borderColor = c.withValues(alpha: 0.35);
      bgColor = Color.alphaBlend(c.withValues(alpha: 0.08), colors.surfaceSoft);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: widget.index,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, right: 8),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 16,
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _typeIcon(b.type),
                      size: 11,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      b.type.name.toUpperCase(),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 9.5,
                        letterSpacing: 0.12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (b.type == CourseBlockType.video &&
                        b.durationMinutes != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· ${b.durationMinutes} min',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                    if (b.type == CourseBlockType.quiz &&
                        b.itemCount != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· ${b.itemCount} items',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                    if (b.type == CourseBlockType.code &&
                        b.language != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· ${b.language}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _titleCtrl,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Block title…',
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  onChanged: (v) => widget.onUpdate(_BlockPatch(title: v)),
                ),
                const SizedBox(height: 4),
                if (b.type == CourseBlockType.code)
                  _CodeBlockEditor(
                    controller: _bodyCtrl,
                    onChanged: (v) => widget.onUpdate(_BlockPatch(body: v)),
                  )
                else if (b.type == CourseBlockType.video)
                  _VideoPlaceholder(url: b.url, body: b.body)
                else if (b.type == CourseBlockType.quiz)
                  _QuizPreview(items: b.itemCount ?? 0, body: b.body)
                else
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: null,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Write the content here…',
                    ),
                    onChanged: (v) => widget.onUpdate(_BlockPatch(body: v)),
                  ),
              ],
            ),
          ),
          IconButton(
            iconSize: 14,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
            tooltip: 'Delete block',
            icon: Icon(Icons.close_rounded, color: colors.textSecondary),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(CourseBlockType t) => switch (t) {
    CourseBlockType.text => Icons.notes_rounded,
    CourseBlockType.video => Icons.play_circle_outline_rounded,
    CourseBlockType.code => Icons.code_rounded,
    CourseBlockType.quiz => Icons.quiz_rounded,
    CourseBlockType.callout => Icons.warning_amber_rounded,
  };

  Color _toneColor(CourseCalloutTone tone, AppThemeColors c) => switch (tone) {
    CourseCalloutTone.warn => c.accent,
    CourseCalloutTone.danger => c.danger,
    CourseCalloutTone.success => c.success,
    CourseCalloutTone.primary => c.primary,
  };
}

class _CodeBlockEditor extends StatelessWidget {
  const _CodeBlockEditor({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF060912),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.divider),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        style: const TextStyle(
          color: Color(0xFFD6DBEB),
          fontFamily: 'monospace',
          fontSize: 11.5,
          height: 1.5,
        ),
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.url, required this.body});
  final String? url;
  final String body;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          body,
          style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
        ),
        if (url != null && url!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            url!,
            style: TextStyle(
              color: colors.textSecondary.withValues(alpha: 0.7),
              fontSize: 10.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: colors.surfaceSoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.divider, style: BorderStyle.solid),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: colors.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                'VIDEO PLACEHOLDER · DROP MP4 OR URL',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizPreview extends StatelessWidget {
  const _QuizPreview({required this.items, required this.body});
  final int items;
  final String body;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visible = items > 3 ? 3 : items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          body,
          style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < visible; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.divider),
            ),
            child: Row(
              children: [
                Text(
                  'Q${i + 1}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'MCQ · 4 options',
                  style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
                ),
                const Spacer(),
                Text(
                  '1 pt',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        if (items > 3)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '+ ${items - 3} more',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 10.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
      ],
    );
  }
}

class _AddBlock extends StatelessWidget {
  const _AddBlock({required this.onAdd});
  final void Function(CourseBlockType type) onAdd;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PopupMenuButton<CourseBlockType>(
      onSelected: onAdd,
      itemBuilder: (_) => const [
        PopupMenuItem(value: CourseBlockType.text, child: Text('Text')),
        PopupMenuItem(value: CourseBlockType.video, child: Text('Video')),
        PopupMenuItem(value: CourseBlockType.code, child: Text('Code')),
        PopupMenuItem(value: CourseBlockType.quiz, child: Text('Quiz')),
        PopupMenuItem(value: CourseBlockType.callout, child: Text('Callout')),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.divider, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 14, color: colors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Add block',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────────────────

class _DetailFooter extends StatelessWidget {
  const _DetailFooter({required this.onSave, required this.onPreview});
  final VoidCallback onSave;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: const Color(0xFF062623),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.check_rounded, size: 14),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onPreview,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.divider),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
            label: const Text('Preview'),
          ),
        ],
      ),
    );
  }
}
