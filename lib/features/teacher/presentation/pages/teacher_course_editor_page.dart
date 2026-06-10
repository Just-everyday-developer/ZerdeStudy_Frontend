import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/data/models/backend_course_dto.dart';
import '../../../courses_backend/data/models/backend_lesson_dto.dart';
import '../../../courses_backend/data/models/backend_module_dto.dart';
import '../../../payment/data/models/order_models.dart';
import '../../../payment/presentation/providers/payment_providers.dart';
import '../../application/teacher_authoring_service.dart';

Future<TeacherAuthoringService?> _freshService(WidgetRef ref) async {
  await ref.read(authControllerProvider.notifier).refreshSession();
  return ref.read(teacherAuthoringServiceProvider);
}

/// Manages modules → lessons → quizzes/practice for one backend course.
class TeacherCourseEditorPage extends ConsumerWidget {
  const TeacherCourseEditorPage({super.key, required this.course});

  final BackendCourseDto course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final modulesAsync = ref.watch(teacherModulesProvider(course.id));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          course.title.trim().isEmpty ? 'Курс' : course.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            onPressed: () => ref.invalidate(teacherModulesProvider(course.id)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.primary,
        onPressed: () => _addModule(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Модуль'),
      ),
      body: Column(
        children: [
          _CoursePricePanel(courseId: course.id),
          Expanded(
            child: modulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка: $e')),
              data: (modules) {
                if (modules.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_tree_outlined,
                            size: 48,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Модулей пока нет',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Нажмите «Модуль», чтобы добавить первый.',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    for (var i = 0; i < modules.length; i++)
                      _ModuleCard(
                        index: i,
                        module: modules[i],
                        courseId: course.id,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addModule(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_ModuleFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ModuleSheet(),
    );
    if (result == null) return;
    final service = await _freshService(ref);
    if (service == null || !context.mounted) return;
    try {
      await service.createModule(
        courseId: course.id,
        title: result.title,
        summary: result.summary,
      );
      ref.invalidate(teacherModulesProvider(course.id));
      if (context.mounted) {
        AppNotice.show(
          context,
          message: 'Модуль добавлен',
          type: AppNoticeType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotice.show(
          context,
          message: 'Ошибка: $e',
          type: AppNoticeType.error,
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Module sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ModuleFormResult {
  const _ModuleFormResult({required this.title, required this.summary});
  final String title;
  final String summary;
}

class _ModuleSheet extends StatefulWidget {
  const _ModuleSheet();
  @override
  State<_ModuleSheet> createState() => _ModuleSheetState();
}

class _ModuleSheetState extends State<_ModuleSheet> {
  final _title = TextEditingController();
  final _summary = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.view_module_rounded, color: colors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Новый модуль',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SheetField(label: 'Название модуля', ctrl: _title, colors: colors),
            const SizedBox(height: 12),
            _SheetField(
              label: 'Краткое описание',
              ctrl: _summary,
              colors: colors,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_title.text.trim().isEmpty) return;
                Navigator.pop(
                  context,
                  _ModuleFormResult(
                    title: _title.text.trim(),
                    summary: _summary.text.trim(),
                  ),
                );
              },
              child: const Text('Создать модуль', style: TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.ctrl,
    required this.colors,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController ctrl;
  final AppThemeColors colors;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CoursePricePanel extends ConsumerStatefulWidget {
  const _CoursePricePanel({required this.courseId});

  final String courseId;

  @override
  ConsumerState<_CoursePricePanel> createState() => _CoursePricePanelState();
}

class _CoursePricePanelState extends ConsumerState<_CoursePricePanel> {
  final _amount = TextEditingController();
  final _currency = TextEditingController(text: 'KZT');

  String? _priceId;
  String? _seedKey;
  bool _dirty = false;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _currency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final priceAsync = ref.watch(teacherCoursePriceProvider(widget.courseId));
    priceAsync.whenData(_seedFromPrice);
    final currentPrice = priceAsync.maybeWhen(
      data: (price) => price,
      orElse: () => null,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.payments_outlined, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Цена курса',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              priceAsync.maybeWhen(
                loading: () => SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
                orElse: () => Text(
                  _priceStatus(currentPrice),
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _dirty = true,
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    hintText: '0',
                  ),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _currency,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => _dirty = true,
                  decoration: const InputDecoration(
                    labelText: 'Валюта',
                    hintText: 'KZT',
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Сохранить цену'),
              ),
            ],
          ),
          priceAsync.maybeWhen(
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Текущую цену не удалось загрузить: $e',
                style: TextStyle(color: colors.danger, fontSize: 12),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _seedFromPrice(CoursePriceResponse? price) {
    final key = '${price?.id}|${price?.amount}|${price?.currency}';
    if (_dirty || _seedKey == key) {
      return;
    }
    _seedKey = key;
    _priceId = price?.id;
    _amount.text = price == null ? '' : price.amount.toString();
    _currency.text = price == null || price.currency.trim().isEmpty
        ? 'KZT'
        : price.currency;
  }

  String _priceStatus(CoursePriceResponse? price) {
    if (price == null || price.id.trim().isEmpty) {
      return 'цена не задана';
    }
    return 'id ${price.id}';
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amount.text.trim());
    if (amount == null || amount < 0) {
      AppNotice.show(
        context,
        message: 'Введите корректную сумму',
        type: AppNoticeType.error,
      );
      return;
    }

    setState(() => _saving = true);
    final service = await _freshService(ref);
    if (!mounted) return;
    if (service == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      final saved = await service.saveCoursePrice(
        courseId: widget.courseId,
        priceId: _priceId,
        amount: amount,
        currency: _currency.text,
      );
      _dirty = false;
      _priceId = saved.id;
      _seedKey = null;
      ref.invalidate(teacherCoursePriceProvider(widget.courseId));
      ref.invalidate(coursePriceProvider(widget.courseId));
      if (mounted) {
        AppNotice.show(
          context,
          message: 'Цена курса сохранена',
          type: AppNoticeType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotice.show(
          context,
          message: 'Ошибка цены: $e',
          type: AppNoticeType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _ModuleCard extends ConsumerWidget {
  const _ModuleCard({
    required this.index,
    required this.module,
    required this.courseId,
  });

  final int index;
  final BackendModuleDto module;
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final lessonsAsync = ref.watch(teacherLessonsProvider(module.id));
    final title = module.title.isEmpty ? 'Без названия' : module.title;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          subtitle: module.summary.isNotEmpty
              ? Text(
                  module.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _deleteModule(context, ref),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: colors.danger.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ),
              ),
              const Icon(Icons.expand_more_rounded),
            ],
          ),
          children: [
            lessonsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Ошибка уроков: $e',
                  style: TextStyle(color: colors.danger, fontSize: 12),
                ),
              ),
              data: (lessons) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (lessons.isNotEmpty) ...[
                    for (var i = 0; i < lessons.length; i++)
                      _LessonTile(index: i, lesson: lessons[i]),
                    const SizedBox(height: 4),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => _addLesson(context, ref, lessons.length),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Добавить урок'),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteModule(BuildContext context, WidgetRef ref) async {
    final colors = context.appColors;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить модуль?'),
        content: Text(
          'Модуль «${module.title.isEmpty ? "Без названия" : module.title}» и все его уроки будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final service = await _freshService(ref);
    if (service == null || !context.mounted) return;
    try {
      await service.deleteModule(module.id);
      ref.invalidate(teacherModulesProvider(courseId));
      if (context.mounted) {
        AppNotice.show(context, message: 'Модуль удалён', type: AppNoticeType.success);
      }
    } catch (e) {
      if (context.mounted) {
        AppNotice.show(context, message: 'Ошибка: $e', type: AppNoticeType.error);
      }
    }
  }

  Future<void> _addLesson(
    BuildContext context,
    WidgetRef ref,
    int position,
  ) async {
    final result = await showModalBottomSheet<_LessonFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LessonForm(position: position),
    );
    if (result == null) return;
    final service = await _freshService(ref);
    if (service == null || !context.mounted) return;
    try {
      final lesson = await service.createLesson(
        moduleId: module.id,
        position: position,
        durationMinutes: result.durationMinutes,
        xpReward: result.xpReward,
        title: LocalizedInput(ru: result.title),
        summary: LocalizedInput(ru: result.summary),
        outcome: LocalizedInput(ru: result.outcome),
        theoryContent: LocalizedInput(ru: result.theory),
        codeSnippet: result.codeSnippet,
        exampleOutput: result.exampleOutput,
      );
      if (result.videoBytes != null && result.videoFileName != null) {
        await service.uploadLessonVideo(
          lessonId: lesson.id,
          videoBytes: result.videoBytes!,
          fileName: result.videoFileName!,
        );
      }
      ref.invalidate(teacherLessonsProvider(module.id));
      if (context.mounted) {
        AppNotice.show(
          context,
          message: 'Урок добавлен',
          type: AppNoticeType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotice.show(
          context,
          message: 'Ошибка: $e',
          type: AppNoticeType.error,
        );
      }
    }
  }
}

class _LessonTile extends ConsumerWidget {
  const _LessonTile({required this.index, required this.lesson});

  final int index;
  final BackendLessonDto lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final hasVideo =
        lesson.videoObjectKey.trim().isNotEmpty ||
        lesson.videoUrl.trim().isNotEmpty;
    final title = lesson.title.ru.isNotEmpty
        ? lesson.title.ru
        : lesson.title.en.isNotEmpty
        ? lesson.title.en
        : 'Урок ${index + 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${lesson.xpReward} XP',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              TextButton.icon(
                onPressed: () => _addQuiz(context, ref),
                icon: const Icon(Icons.quiz_rounded, size: 16),
                label: const Text('Квиз'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              TextButton.icon(
                onPressed: () => _addPractice(context, ref),
                icon: const Icon(Icons.code_rounded, size: 16),
                label: const Text('Практика'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              TextButton.icon(
                onPressed: () => _uploadLessonVideo(context, ref, lesson),
                icon: Icon(
                  hasVideo
                      ? Icons.video_file_rounded
                      : Icons.video_file_rounded,
                  size: 16,
                ),
                label: Text(hasVideo ? 'Заменить видео' : 'Видео'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addQuiz(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_QuizFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _QuizSheet(),
    );
    if (result == null) return;
    final service = await _freshService(ref);
    if (service == null) return;
    try {
      await service.createQuiz(
        lessonId: lesson.id,
        position: 0,
        question: LocalizedInput(ru: result.question),
        options: result.options.map((o) => LocalizedInput(ru: o)).toList(),
        correctAnswerIndex: result.correctIndex,
        explanation: LocalizedInput(ru: result.explanation),
      );
      if (context.mounted) {
        AppNotice.show(context, message: 'Квиз добавлен', type: AppNoticeType.success);
      }
    } catch (e) {
      if (context.mounted) {
        AppNotice.show(context, message: 'Ошибка: $e', type: AppNoticeType.error);
      }
    }
  }

  Future<void> _addPractice(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_PracticeFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PracticeSheet(),
    );
    if (result == null) return;
    final service = await _freshService(ref);
    if (service == null) return;
    try {
      await service.createPractice(
        lessonId: lesson.id,
        position: 1,
        title: result.title,
        description: result.description,
        language: result.language,
        starterCode: result.starterCode,
        expectedOutput: result.expectedOutput,
        xpReward: result.xpReward,
        checkType: result.checkType,
      );
      if (context.mounted) {
        AppNotice.show(context, message: 'Практика добавлена', type: AppNoticeType.success);
      }
    } catch (e) {
      if (context.mounted) {
        AppNotice.show(
          context,
          message: 'Ошибка: $e',
          type: AppNoticeType.error,
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lesson form (bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _PickedVideo {
  const _PickedVideo({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

Future<_PickedVideo?> _pickLessonVideo(BuildContext context) async {
  final result = await FilePicker.pickFiles(
    type: FileType.video,
    allowMultiple: false,
    withData: true,
  );
  final file = result?.files.single;
  final bytes = file?.bytes;
  if (file == null) {
    return null;
  }
  if (bytes == null || bytes.isEmpty) {
    if (context.mounted) {
      AppNotice.show(
        context,
        message: 'Не удалось прочитать видеофайл',
        type: AppNoticeType.error,
      );
    }
    return null;
  }
  return _PickedVideo(bytes: bytes, fileName: file.name);
}

Future<void> _uploadLessonVideo(
  BuildContext context,
  WidgetRef ref,
  BackendLessonDto lesson,
) async {
  final picked = await _pickLessonVideo(context);
  if (picked == null) return;

  final service = await _freshService(ref);
  if (service == null) return;

  try {
    await service.uploadLessonVideo(
      lessonId: lesson.id,
      videoBytes: picked.bytes,
      fileName: picked.fileName,
    );
    ref.invalidate(teacherLessonsProvider(lesson.moduleId));
    if (context.mounted) {
      AppNotice.show(
        context,
        message: 'Видео урока загружено',
        type: AppNoticeType.success,
      );
    }
  } catch (e) {
    if (context.mounted) {
      AppNotice.show(
        context,
        message: 'Ошибка видео: $e',
        type: AppNoticeType.error,
      );
    }
  }
}

class _LessonFormResult {
  _LessonFormResult({
    required this.title,
    required this.summary,
    required this.outcome,
    required this.theory,
    required this.durationMinutes,
    required this.xpReward,
    required this.codeSnippet,
    required this.exampleOutput,
    this.videoBytes,
    this.videoFileName,
  });
  final String title;
  final String summary;
  final String outcome;
  final String theory;
  final int durationMinutes;
  final int xpReward;
  final String codeSnippet;
  final String exampleOutput;
  final Uint8List? videoBytes;
  final String? videoFileName;
}

class _LessonForm extends StatefulWidget {
  const _LessonForm({required this.position});
  final int position;

  @override
  State<_LessonForm> createState() => _LessonFormState();
}

class _LessonFormState extends State<_LessonForm> {
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _outcome = TextEditingController();
  final _theory = TextEditingController();
  final _duration = TextEditingController(text: '15');
  final _xp = TextEditingController(text: '20');
  final _code = TextEditingController();
  final _expected = TextEditingController();
  Uint8List? _videoBytes;
  String? _videoFileName;

  @override
  void dispose() {
    for (final c in [
      _title,
      _summary,
      _outcome,
      _theory,
      _duration,
      _xp,
      _code,
      _expected,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Новый урок', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _f('Название урока', _title, colors),
            _f('Краткое описание', _summary, colors, maxLines: 2),
            _f('Чему научится', _outcome, colors, maxLines: 2),
            _f('Теория (текст урока)', _theory, colors, maxLines: 5),
            Row(
              children: [
                Expanded(
                  child: _f(
                    'Минут',
                    _duration,
                    colors,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _f(
                    'XP',
                    _xp,
                    colors,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            _f('Стартовый код (опц.)', _code, colors, maxLines: 3),
            _f('Ожидаемый вывод (опц.)', _expected, colors, maxLines: 2),
            OutlinedButton.icon(
              onPressed: _chooseVideo,
              icon: const Icon(Icons.video_file_rounded, size: 18),
              label: Text(_videoFileName ?? 'Прикрепить видео'),
            ),
            if (_videoFileName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.video_file_rounded,
                    color: colors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _videoFileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Убрать видео',
                    onPressed: () => setState(() {
                      _videoBytes = null;
                      _videoFileName = null;
                    }),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                if (_title.text.trim().isEmpty) return;
                Navigator.pop(
                  context,
                  _LessonFormResult(
                    title: _title.text.trim(),
                    summary: _summary.text.trim(),
                    outcome: _outcome.text.trim(),
                    theory: _theory.text.trim(),
                    durationMinutes: int.tryParse(_duration.text.trim()) ?? 15,
                    xpReward: int.tryParse(_xp.text.trim()) ?? 20,
                    codeSnippet: _code.text.trim(),
                    exampleOutput: _expected.text.trim(),
                    videoBytes: _videoBytes,
                    videoFileName: _videoFileName,
                  ),
                );
              },
              child: const Text('Сохранить урок'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseVideo() async {
    final picked = await _pickLessonVideo(context);
    if (picked == null) return;
    setState(() {
      _videoBytes = picked.bytes;
      _videoFileName = picked.fileName;
    });
  }

  Widget _f(
    String label,
    TextEditingController ctrl,
    AppThemeColors colors, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Quiz bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _QuizFormResult {
  _QuizFormResult({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class _QuizSheet extends StatefulWidget {
  const _QuizSheet();
  @override
  State<_QuizSheet> createState() => _QuizSheetState();
}

class _QuizSheetState extends State<_QuizSheet> {
  final _question = TextEditingController();
  final _explanation = TextEditingController();
  final List<TextEditingController> _options = List.generate(4, (_) => TextEditingController());
  int _correct = 0;

  @override
  void dispose() {
    _question.dispose();
    _explanation.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final opts = _options.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (_question.text.trim().isEmpty || opts.length < 2) return;
    Navigator.pop(
      context,
      _QuizFormResult(
        question: _question.text.trim(),
        options: opts,
        correctIndex: _correct.clamp(0, opts.length - 1),
        explanation: _explanation.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.quiz_rounded, color: colors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Новый квиз',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // scrollable body
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                shrinkWrap: true,
                children: [
                  _SheetField(label: 'Вопрос', ctrl: _question, colors: colors, maxLines: 2),
                  const SizedBox(height: 16),
                  Text(
                    'ВАРИАНТЫ ОТВЕТОВ',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._options.asMap().entries.map((e) {
                    final isCorrect = e.key == _correct;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _correct = e.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCorrect
                                    ? colors.success.withValues(alpha: 0.15)
                                    : colors.surface,
                                border: Border.all(
                                  color: isCorrect ? colors.success : colors.divider,
                                  width: isCorrect ? 2 : 1,
                                ),
                              ),
                              child: isCorrect
                                  ? Icon(Icons.check_rounded, size: 16, color: colors.success)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: e.value,
                              decoration: InputDecoration(
                                hintText: 'Вариант ${e.key + 1}${isCorrect ? " (верный)" : ""}',
                                filled: true,
                                fillColor: isCorrect
                                    ? colors.success.withValues(alpha: 0.06)
                                    : colors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isCorrect ? colors.success : colors.divider,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isCorrect ? colors.success : colors.divider,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isCorrect ? colors.success : colors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _SheetField(label: 'Пояснение (опц.)', ctrl: _explanation, colors: colors, maxLines: 2),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text('Добавить квиз', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Practice bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PracticeFormResult {
  _PracticeFormResult({
    required this.title,
    required this.description,
    required this.language,
    required this.starterCode,
    required this.expectedOutput,
    required this.xpReward,
    required this.checkType,
  });
  final String title;
  final String description;
  final String language;
  final String starterCode;
  final String expectedOutput;
  final int xpReward;
  final String checkType;
}

class _PracticeSheet extends StatefulWidget {
  const _PracticeSheet();
  @override
  State<_PracticeSheet> createState() => _PracticeSheetState();
}

class _PracticeSheetState extends State<_PracticeSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _code = TextEditingController();
  final _expectedOutput = TextEditingController();
  final _xp = TextEditingController(text: '40');
  String _language = 'go';
  String _checkType = 'manual';

  static const _languages = ['go', 'python', 'java', 'javascript', 'kotlin', 'cpp'];

  @override
  void dispose() {
    for (final c in [_title, _description, _code, _expectedOutput, _xp]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_title.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      _PracticeFormResult(
        title: _title.text.trim(),
        description: _description.text.trim(),
        language: _language,
        starterCode: _code.text.trim(),
        expectedOutput: _expectedOutput.text.trim(),
        xpReward: int.tryParse(_xp.text.trim()) ?? 40,
        checkType: _checkType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget sectionLabel(String text, IconData icon) => Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.code_rounded, color: colors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Новая практика',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                shrinkWrap: true,
                children: [
                  sectionLabel('ОСНОВНОЕ', Icons.info_outline_rounded),
                  _SheetField(label: 'Название задания', ctrl: _title, colors: colors),
                  const SizedBox(height: 10),
                  _SheetField(
                    label: 'Условие / описание',
                    ctrl: _description,
                    colors: colors,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  sectionLabel('КОД', Icons.terminal_rounded),
                  // Language picker
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _languages.map((lang) {
                      final selected = lang == _language;
                      return GestureDetector(
                        onTap: () => setState(() => _language = lang),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? colors.primary.withValues(alpha: 0.15)
                                : colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? colors.primary : colors.divider,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            lang,
                            style: TextStyle(
                              color: selected ? colors.primary : colors.textSecondary,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  _SheetField(
                    label: 'Стартовый код (опц.)',
                    ctrl: _code,
                    colors: colors,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 10),
                  _SheetField(
                    label: 'Ожидаемый вывод (опц.)',
                    ctrl: _expectedOutput,
                    colors: colors,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  sectionLabel('ПРОВЕРКА', Icons.checklist_rounded),
                  // Check type toggle
                  Row(
                    children: [
                      _CheckTypeChip(
                        label: 'Вручную',
                        icon: Icons.person_rounded,
                        selected: _checkType == 'manual',
                        colors: colors,
                        onTap: () => setState(() => _checkType = 'manual'),
                      ),
                      const SizedBox(width: 10),
                      _CheckTypeChip(
                        label: 'Авто',
                        icon: Icons.play_circle_outline_rounded,
                        selected: _checkType == 'auto',
                        colors: colors,
                        onTap: () => setState(() => _checkType = 'auto'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      controller: _xp,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'XP награда',
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text('Добавить практику', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckTypeChip extends StatelessWidget {
  const _CheckTypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.colors,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final AppThemeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withValues(alpha: 0.15) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? colors.primary : colors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.primary : colors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
