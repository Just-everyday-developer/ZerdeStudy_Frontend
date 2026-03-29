import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/demo_moderator_data.dart';
import '../../../../core/theme/app_theme_colors.dart';

class ModeratorCoursesPage extends ConsumerStatefulWidget {
  const ModeratorCoursesPage({super.key});

  @override
  ConsumerState<ModeratorCoursesPage> createState() =>
      _ModeratorCoursesPageState();
}

class _ModeratorCoursesPageState extends ConsumerState<ModeratorCoursesPage> {
  ModPendingCourse? _selected;
  final Map<String, bool> _checklist = {};
  final TextEditingController _rejectMsgCtrl = TextEditingController();
  final TextEditingController _banReasonCtrl = TextEditingController();
  String? _verdict; // 'approve' | 'reject' | 'ban'
  static const _kOrange = Color(0xFFFF6B35);

  // Checklist items
  static const _checklistItems = [
    'Качество видео/аудио соответствует стандартам',
    'Описание курса соответствует содержанию',
    'Нет нарушений авторских прав',
    'Структура курса логична и полна',
    'Код/примеры корректны и работают',
    'Нет оскорбительного или вредоносного контента',
    'Уровень сложности указан верно',
    'Сертификат предоставляется при полном прохождении',
  ];

  @override
  void dispose() {
    _rejectMsgCtrl.dispose();
    _banReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        // Left: course list
        Container(
          width: 280,
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
                      'Проверка курсов',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${kModPendingCourses.length} ожидают проверки',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: kModPendingCourses.length,
                  itemBuilder: (context, index) {
                    final course = kModPendingCourses[index];
                    final isSelected = _selected?.id == course.id;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selected = course;
                          _verdict = null;
                          _checklist.clear();
                          _rejectMsgCtrl.clear();
                          _banReasonCtrl.clear();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? _kOrange.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? _kOrange.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF9800,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.video_library_rounded,
                                color: Color(0xFFFF9800),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected
                                          ? _kOrange
                                          : colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    course.author,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceSoft,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      course.category,
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
        // Right: review panel
        Expanded(
          child: _selected == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 48,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Выберите курс для проверки',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ],
                  ),
                )
              : _CourseReviewPanel(
                  course: _selected!,
                  checklist: _checklist,
                  checklistItems: _checklistItems,
                  rejectMsgCtrl: _rejectMsgCtrl,
                  banReasonCtrl: _banReasonCtrl,
                  verdict: _verdict,
                  onChecklistChanged: (key, val) =>
                      setState(() => _checklist[key] = val),
                  onVerdict: (v) => setState(() => _verdict = v),
                  colors: colors,
                ),
        ),
      ],
    );
  }
}

class _CourseReviewPanel extends StatelessWidget {
  const _CourseReviewPanel({
    required this.course,
    required this.checklist,
    required this.checklistItems,
    required this.rejectMsgCtrl,
    required this.banReasonCtrl,
    required this.verdict,
    required this.onChecklistChanged,
    required this.onVerdict,
    required this.colors,
  });

  final ModPendingCourse course;
  final Map<String, bool> checklist;
  final List<String> checklistItems;
  final TextEditingController rejectMsgCtrl;
  final TextEditingController banReasonCtrl;
  final String? verdict;
  final void Function(String key, bool val) onChecklistChanged;
  final void Function(String verdict) onVerdict;
  final AppThemeColors colors;

  static const _kOrange = Color(0xFFFF6B35);
  static const _kGreen = Color(0xFF4CAF50);
  static const _kYellow = Color(0xFFFF9800);
  static const _kRed = Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    final checkedCount = checklist.values.where((v) => v).length;
    final progress = checklistItems.isEmpty
        ? 0.0
        : checkedCount / checklistItems.length;

    if (verdict != null) {
      return _VerdictSent(verdict: verdict!, colors: colors, course: course);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course preview area
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.author,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.video_library_outlined,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.lessonCount} уроков',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.duration,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kOrange.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    'Подана: ${course.submittedAt}',
                    style: const TextStyle(color: _kOrange, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Описание курса',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.divider),
                  ),
                  child: Text(
                    course.description,
                    style: TextStyle(
                      color: colors.textPrimary,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Mock course content preview
                Text(
                  'Предпросмотр программы курса',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  4,
                  (i) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors.surfaceSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Урок ${i + 1}: ${['Введение', 'Основные концепции', 'Практическое задание', 'Итоговый проект'][i]}',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.play_circle_outline_rounded,
                          color: colors.textSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Checklist + verdict panel
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(left: BorderSide(color: colors.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Чек-лист модератора',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: colors.surfaceSoft,
                              valueColor: const AlwaysStoppedAnimation(_kGreen),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$checkedCount/${checklistItems.length}',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: checklistItems.length,
                  itemBuilder: (context, i) {
                    final key = checklistItems[i];
                    final checked = checklist[key] ?? false;
                    return CheckboxListTile(
                      value: checked,
                      onChanged: (v) => onChecklistChanged(key, v ?? false),
                      title: Text(
                        key,
                        style: TextStyle(
                          fontSize: 12,
                          color: checked
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                      activeColor: _kGreen,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  },
                ),
              ),
              // Verdict buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => onVerdict('approve'),
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('Опубликовать'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => onVerdict('reject'),
                      icon: const Icon(Icons.edit_note_rounded, size: 16),
                      label: const Text('Отклонить с комментарием'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kYellow,
                        side: const BorderSide(color: _kYellow),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => onVerdict('ban'),
                      icon: const Icon(Icons.block_rounded, size: 16),
                      label: const Text('Заблокировать курс'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kRed,
                        side: const BorderSide(color: _kRed),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerdictSent extends StatelessWidget {
  const _VerdictSent({
    required this.verdict,
    required this.colors,
    required this.course,
  });
  final String verdict;
  final AppThemeColors colors;
  final ModPendingCourse course;

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, subtitle) = switch (verdict) {
      'approve' => (
        Icons.check_circle_rounded,
        const Color(0xFF4CAF50),
        'Курс опубликован!',
        '«${course.title}» успешно прошёл проверку и опубликован.',
      ),
      'reject' => (
        Icons.cancel_rounded,
        const Color(0xFFFF9800),
        'Курс отклонён',
        '«${course.title}» отправлен на доработку с комментарием.',
      ),
      _ => (
        Icons.block_rounded,
        const Color(0xFFF44336),
        'Курс заблокирован',
        '«${course.title}» заблокирован за нарушение правил платформы.',
      ),
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
