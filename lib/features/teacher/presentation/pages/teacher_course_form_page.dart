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
  String? _statusId;
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
    if (_levelId == null ||
        _topicId == null ||
        _durationId == null ||
        _statusId == null) {
      AppNotice.show(context,
          message: 'Выберите уровень, тему, длительность и статус',
          type: AppNoticeType.error);
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
        statusId: _statusId!,
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
      appBar: AppBar(
        backgroundColor: colors.background,
        title: const Text('Новый курс'),
      ),
      body: dictsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка загрузки справочников: $e')),
        data: (dicts) {
          if (dicts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Справочники недоступны. Убедитесь, что бэкенд запущен и вы вошли как преподаватель.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _field('Название', _titleCtrl, colors),
              _field('Подзаголовок', _subtitleCtrl, colors),
              _field('Описание', _descriptionCtrl, colors, maxLines: 4),
              _field('Часов на курс', _hoursCtrl, colors,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _dropdown('Уровень', dicts.levels, _levelId,
                  (v) => setState(() => _levelId = v), colors),
              _dropdown('Тема', dicts.topics, _topicId,
                  (v) => setState(() => _topicId = v), colors),
              _dropdown('Длительность', dicts.durationCategories, _durationId,
                  (v) => setState(() => _durationId = v), colors),
              _dropdown('Статус', dicts.statuses, _statusId,
                  (v) => setState(() => _statusId = v), colors),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Выдаётся сертификат'),
                value: _hasCertificate,
                activeThumbColor: colors.primary,
                onChanged: (v) => setState(() => _hasCertificate = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Результаты обучения',
                      style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(
                        () => _outcomeCtrls.add(TextEditingController())),
                    icon: Icon(Icons.add_circle_outline, color: colors.primary),
                  ),
                ],
              ),
              ..._outcomeCtrls.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: e.value,
                            decoration: InputDecoration(
                              hintText: 'Результат ${e.key + 1}',
                              filled: true,
                              fillColor: colors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.divider),
                              ),
                            ),
                          ),
                        ),
                        if (_outcomeCtrls.length > 1)
                          IconButton(
                            onPressed: () => setState(() {
                              e.value.dispose();
                              _outcomeCtrls.removeAt(e.key);
                            }),
                            icon: Icon(Icons.remove_circle_outline,
                                color: colors.danger),
                          ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_rounded),
                label: const Text('Создать курс'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, AppThemeColors colors,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.divider),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<BackendDictionaryEntryDto> items,
    String? value,
    ValueChanged<String?> onChanged,
    AppThemeColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.divider),
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
    );
  }
}
