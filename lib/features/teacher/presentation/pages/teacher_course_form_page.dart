import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/data/models/backend_course_dto.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../../application/teacher_authoring_service.dart';

/// Form to create a new backend course. Pops `true` on success.
class TeacherCourseFormPage extends ConsumerStatefulWidget {
  const TeacherCourseFormPage({super.key});

  @override
  ConsumerState<TeacherCourseFormPage> createState() =>
      _TeacherCourseFormPageState();
}

class _TeacherCourseFormPageState extends ConsumerState<TeacherCourseFormPage> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '10');
  final List<TextEditingController> _outcomeCtrls = [TextEditingController()];

  String? _levelId;
  String? _topicId;
  String? _durationId;
  bool _hasCertificate = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _descriptionCtrl.dispose();
    _hoursCtrl.dispose();
    for (final c in _outcomeCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final service = ref.read(teacherAuthoringServiceProvider);
    if (service == null) {
      AppNotice.show(context,
          message: 'Нужна авторизация преподавателя', type: AppNoticeType.error);
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      AppNotice.show(context,
          message: 'Введите название курса', type: AppNoticeType.error);
      return;
    }
    if (_levelId == null || _topicId == null || _durationId == null) {
      AppNotice.show(context,
          message: 'Выберите уровень, тему и длительность',
          type: AppNoticeType.error);
      return;
    }

    // Auto-pick draft status (or first available)
    final dicts = ref.read(backendCourseDictionariesProvider).asData?.value;
    final draftStatus = dicts?.statuses.firstWhere(
      (s) => s.code.toLowerCase().contains('draft') || s.name.toLowerCase().contains('draft'),
      orElse: () => dicts.statuses.first,
    );
    if (draftStatus == null) {
      AppNotice.show(context,
          message: 'Нет доступных статусов курса', type: AppNoticeType.error);
      return;
    }

    setState(() => _saving = true);
    try {
      await service.createCourse(
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        expectedHours: int.tryParse(_hoursCtrl.text.trim()) ?? 1,
        hasCertificate: _hasCertificate,
        learningOutcomes: _outcomeCtrls
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        levelId: _levelId!,
        statusId: draftStatus.id,
        durationCategoryId: _durationId!,
        topicId: _topicId!,
      );
      ref.invalidate(teacherBackendCoursesProvider);
      if (!mounted) return;
      AppNotice.show(context, message: 'Курс создан', type: AppNoticeType.success);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppNotice.show(context,
          message: 'Не удалось создать курс: $e', type: AppNoticeType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dictsAsync = ref.watch(backendCourseDictionariesProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: dictsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка загрузки: $e')),
        data: (dicts) {
          if (dicts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Справочники недоступны. Убедитесь, что бэкенд запущен.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            );
          }
          return Column(
            children: [
              _Header(colors: colors, onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: _FormBody(
                  colors: colors,
                  dicts: dicts,
                  titleCtrl: _titleCtrl,
                  subtitleCtrl: _subtitleCtrl,
                  descriptionCtrl: _descriptionCtrl,
                  hoursCtrl: _hoursCtrl,
                  outcomeCtrls: _outcomeCtrls,
                  levelId: _levelId,
                  topicId: _topicId,
                  durationId: _durationId,
                  hasCertificate: _hasCertificate,
                  onLevelChanged: (v) => setState(() => _levelId = v),
                  onTopicChanged: (v) => setState(() => _topicId = v),
                  onDurationChanged: (v) => setState(() => _durationId = v),
                  onCertificateChanged: (v) => setState(() => _hasCertificate = v),
                  onAddOutcome: () => setState(() => _outcomeCtrls.add(TextEditingController())),
                  onRemoveOutcome: (i) => setState(() {
                    _outcomeCtrls[i].dispose();
                    _outcomeCtrls.removeAt(i);
                  }),
                  saving: _saving,
                  onSave: _save,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.colors, required this.onBack});
  final AppThemeColors colors;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary, size: 22),
            splashRadius: 20,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Новый курс',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Заполните основную информацию о курсе',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.colors,
    required this.dicts,
    required this.titleCtrl,
    required this.subtitleCtrl,
    required this.descriptionCtrl,
    required this.hoursCtrl,
    required this.outcomeCtrls,
    required this.levelId,
    required this.topicId,
    required this.durationId,
    required this.hasCertificate,
    required this.onLevelChanged,
    required this.onTopicChanged,
    required this.onDurationChanged,
    required this.onCertificateChanged,
    required this.onAddOutcome,
    required this.onRemoveOutcome,
    required this.saving,
    required this.onSave,
  });

  final AppThemeColors colors;
  final BackendCourseDictionaries dicts;
  final TextEditingController titleCtrl;
  final TextEditingController subtitleCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController hoursCtrl;
  final List<TextEditingController> outcomeCtrls;
  final String? levelId;
  final String? topicId;
  final String? durationId;
  final bool hasCertificate;
  final ValueChanged<String?> onLevelChanged;
  final ValueChanged<String?> onTopicChanged;
  final ValueChanged<String?> onDurationChanged;
  final ValueChanged<bool> onCertificateChanged;
  final VoidCallback onAddOutcome;
  final ValueChanged<int> onRemoveOutcome;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;
    final h = isWide ? 24.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(h, 20, h, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section 1: Basic info ──────────────────────────────────────
          _SectionCard(
            colors: colors,
            icon: Icons.edit_note_rounded,
            title: 'Основная информация',
            children: [
              _TsField(
                label: 'Название курса *',
                hint: 'Например: Go Backend Development',
                ctrl: titleCtrl,
                colors: colors,
              ),
              const SizedBox(height: 12),
              _TsField(
                label: 'Подзаголовок',
                hint: 'Краткое описание для карточки',
                ctrl: subtitleCtrl,
                colors: colors,
              ),
              const SizedBox(height: 12),
              _TsField(
                label: 'Описание',
                hint: 'Подробное описание курса — цели, содержание, для кого',
                ctrl: descriptionCtrl,
                colors: colors,
                maxLines: 4,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Section 2: Params ──────────────────────────────────────────
          _SectionCard(
            colors: colors,
            icon: Icons.tune_rounded,
            title: 'Параметры',
            children: [
              // Hours
              _TsField(
                label: 'Часов на прохождение',
                hint: '10',
                ctrl: hoursCtrl,
                colors: colors,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              // 2-col dropdowns
              if (isWide)
                Row(
                  children: [
                    Expanded(child: _TsDropdown(label: 'Уровень *', items: dicts.levels, value: levelId, onChanged: onLevelChanged, colors: colors)),
                    const SizedBox(width: 12),
                    Expanded(child: _TsDropdown(label: 'Тема *', items: dicts.topics, value: topicId, onChanged: onTopicChanged, colors: colors)),
                  ],
                )
              else ...[
                _TsDropdown(label: 'Уровень *', items: dicts.levels, value: levelId, onChanged: onLevelChanged, colors: colors),
                const SizedBox(height: 12),
                _TsDropdown(label: 'Тема *', items: dicts.topics, value: topicId, onChanged: onTopicChanged, colors: colors),
              ],
              const SizedBox(height: 12),
              _TsDropdown(label: 'Длительность *', items: dicts.durationCategories, value: durationId, onChanged: onDurationChanged, colors: colors),
            ],
          ),
          const SizedBox(height: 14),

          // ── Section 3: Certificate ─────────────────────────────────────
          _SectionCard(
            colors: colors,
            icon: Icons.workspace_premium_rounded,
            title: 'Сертификат',
            children: [
              _CertToggle(
                value: hasCertificate,
                onChanged: onCertificateChanged,
                colors: colors,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Section 4: Outcomes ────────────────────────────────────────
          _SectionCard(
            colors: colors,
            icon: Icons.check_circle_outline_rounded,
            title: 'Результаты обучения',
            trailing: _AddButton(
              onTap: onAddOutcome,
              colors: colors,
            ),
            children: [
              ...outcomeCtrls.asMap().entries.map(
                (e) => Padding(
                  padding: EdgeInsets.only(
                      bottom: e.key < outcomeCtrls.length - 1 ? 10 : 0),
                  child: _OutcomeRow(
                    index: e.key,
                    ctrl: e.value,
                    canRemove: outcomeCtrls.length > 1,
                    onRemove: () => onRemoveOutcome(e.key),
                    colors: colors,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Save button ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: saving ? null : onSave,
              child: saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: colors.background),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rocket_launch_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Создать курс',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.colors,
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  final AppThemeColors colors;
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 15, color: colors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          // Card body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TsField extends StatelessWidget {
  const _TsField({
    required this.label,
    required this.hint,
    required this.ctrl,
    required this.colors,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController ctrl;
  final AppThemeColors colors;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
            filled: true,
            fillColor: colors.background,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TsDropdown extends StatelessWidget {
  const _TsDropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.colors,
  });

  final String label;
  final List<BackendDictionaryEntryDto> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          dropdownColor: colors.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.background,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(e.name.isNotEmpty ? e.name : e.code),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CertToggle extends StatelessWidget {
  const _CertToggle({
    required this.value,
    required this.onChanged,
    required this.colors,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? colors.primary.withValues(alpha: 0.08) : colors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? colors.primary.withValues(alpha: 0.35) : colors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.verified_rounded : Icons.verified_outlined,
              size: 20,
              color: value ? colors.primary : colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выдавать сертификат',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Студент получит сертификат по окончании курса',
                    style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: colors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({
    required this.index,
    required this.ctrl,
    required this.canRemove,
    required this.onRemove,
    required this.colors,
  });

  final int index;
  final TextEditingController ctrl;
  final bool canRemove;
  final VoidCallback onRemove;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: colors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'IBMPlexMono',
              ),
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: ctrl,
            style: TextStyle(color: colors.textPrimary, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Студент научится...',
              hintStyle: TextStyle(
                  color: colors.textSecondary.withValues(alpha: 0.5), fontSize: 13.5),
              filled: true,
              fillColor: colors.background,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: colors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: colors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        if (canRemove)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 17),
              color: colors.danger,
              splashRadius: 16,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          )
        else
          const SizedBox(width: 38),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap, required this.colors});
  final VoidCallback onTap;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 15, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              'Добавить',
              style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
