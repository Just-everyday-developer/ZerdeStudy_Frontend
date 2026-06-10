import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../courses_backend/data/models/backend_practice_submission_dto.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../teacher_text.dart';
import '../widgets/teacher_studio_widgets.dart';

// ─── List page ────────────────────────────────────────────────────────────────

class TeacherQnaPage extends ConsumerWidget {
  const TeacherQnaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(demoAppControllerProvider.select((s) => s.locale));
    final colors = context.appColors;
    final submissionsAsync = ref.watch(backendTeacherSubmissionsProvider);

    return TsPageScrollView(
      children: [
        TsPageHeader(
          eyebrow: _eyebrow.resolve(locale),
          title: _title.resolve(locale),
          subtitle: _subtitle.resolve(locale),
          actions: [
            TsButton(
              label: _refresh.resolve(locale),
              icon: Icons.refresh_rounded,
              onPressed: () => ref.invalidate(backendTeacherSubmissionsProvider),
            ),
          ],
        ),
        submissionsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => TsCallout(
            color: colors.danger,
            icon: Icons.error_outline_rounded,
            title: _errorTitle.resolve(locale),
            body: e.toString(),
          ),
          data: (submissions) => submissions.isEmpty
              ? _EmptyState(colors: colors, locale: locale)
              : _SubmissionList(submissions: submissions, colors: colors, locale: locale),
        ),
      ],
    );
  }
}

// ─── List widget ──────────────────────────────────────────────────────────────

class _SubmissionList extends StatelessWidget {
  const _SubmissionList({
    required this.submissions,
    required this.colors,
    required this.locale,
  });
  final List<BackendPracticeSubmissionDto> submissions;
  final AppThemeColors colors;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return TsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsCardHeader(
            eyebrow: _listEyebrow.resolve(locale),
            title: _listTitleFn(submissions.length, locale),
          ),
          for (var i = 0; i < submissions.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.divider),
            _SubmissionRow(sub: submissions[i], colors: colors, locale: locale),
          ],
        ],
      ),
    );
  }
}

// ─── List row ─────────────────────────────────────────────────────────────────

class _SubmissionRow extends StatelessWidget {
  const _SubmissionRow({
    required this.sub,
    required this.colors,
    required this.locale,
  });
  final BackendPracticeSubmissionDto sub;
  final AppThemeColors colors;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final (tagLabel, tagColor) = _statusInfo(sub.status, locale, colors);
    final timeAgo = _timeAgo(sub.createdAt, locale);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _SubmissionDetailPage(submission: sub),
        ),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TsTag(label: tagLabel, color: tagColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sub.practiceTitle.isNotEmpty ? sub.practiceTitle : sub.practiceId,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sub.studentEmail}  ·  ${sub.courseTitle}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right_rounded, color: colors.textSecondary, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail page ──────────────────────────────────────────────────────────────

class _SubmissionDetailPage extends ConsumerStatefulWidget {
  const _SubmissionDetailPage({required this.submission});
  final BackendPracticeSubmissionDto submission;

  @override
  ConsumerState<_SubmissionDetailPage> createState() =>
      _SubmissionDetailPageState();
}

class _SubmissionDetailPageState extends ConsumerState<_SubmissionDetailPage> {
  final _commentCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _commentCtrl.text = widget.submission.teacherComment;
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _review(String status) async {
    final locale = ref.read(demoAppControllerProvider.select((s) => s.locale));
    if (status == 'changes_requested' && _commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_commentRequired.resolve(locale))),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final accessToken = ref.read(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        throw Exception('Not authenticated');
      }
      final remote = ref.read(backendCourseRemoteDataSourceProvider);
      await remote.reviewPracticeSubmission(
        accessToken: accessToken,
        submissionId: widget.submission.id,
        request: BackendReviewPracticeSubmissionRequest(
          status: status,
          comment: _commentCtrl.text.trim(),
        ),
      );
      ref.invalidate(backendTeacherSubmissionsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? _approvedMsg.resolve(locale)
                : _changesMsg.resolve(locale),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final locale = ref.read(demoAppControllerProvider.select((s) => s.locale));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_errorMsg.resolve(locale)}: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(demoAppControllerProvider.select((s) => s.locale));
    final colors = context.appColors;
    final sub = widget.submission;
    final (tagLabel, tagColor) = _statusInfo(sub.status, locale, colors);
    final canReview = !sub.isApproved;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.backgroundElevated,
        title: Text(
          _detailTitle.resolve(locale),
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        iconTheme: IconThemeData(color: colors.textSecondary),
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.divider),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Meta card
          TsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TsTag(label: tagLabel, color: tagColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sub.practiceTitle.isNotEmpty
                            ? sub.practiceTitle
                            : sub.practiceId,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MetaRow(
                  icon: Icons.person_rounded,
                  label: sub.studentEmail,
                  colors: colors,
                ),
                const SizedBox(height: 6),
                _MetaRow(
                  icon: Icons.school_rounded,
                  label: sub.courseTitle,
                  colors: colors,
                ),
                const SizedBox(height: 6),
                _MetaRow(
                  icon: Icons.menu_book_rounded,
                  label: sub.lessonTitle,
                  colors: colors,
                ),
                const SizedBox(height: 6),
                _MetaRow(
                  icon: Icons.repeat_rounded,
                  label: '${_attemptLabel.resolve(locale)} ${sub.attemptNumber}',
                  colors: colors,
                ),
                if (sub.reviewedAt != null) ...[
                  const SizedBox(height: 6),
                  _MetaRow(
                    icon: Icons.rate_review_rounded,
                    label: _timeAgo(sub.reviewedAt!, locale),
                    colors: colors,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Code card
          TsCard(
            accentBar: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TsEyebrow(_codeEyebrow.resolve(locale), color: colors.primary),
                    const Spacer(),
                    if (sub.language.isNotEmpty) ...[
                      TsTag(label: sub.language, color: colors.textSecondary),
                      const SizedBox(width: 8),
                    ],
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: sub.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_copiedMsg.resolve(locale))),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.divider.withValues(alpha: 0.4),
                    ),
                  ),
                  child: SelectableText(
                    sub.code.isEmpty ? '// (empty)' : sub.code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      color: Color(0xFFE6EDF3),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Output / error
          if (sub.output.isNotEmpty || sub.error.isNotEmpty) ...[
            const SizedBox(height: 12),
            TsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TsEyebrow(_outputEyebrow.resolve(locale)),
                  const SizedBox(height: 10),
                  if (sub.output.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.surfaceSoft,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colors.divider.withValues(alpha: 0.4),
                        ),
                      ),
                      child: SelectableText(
                        sub.output,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  if (sub.error.isNotEmpty) ...[
                    if (sub.output.isNotEmpty) const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.danger.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colors.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: SelectableText(
                        sub.error,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: colors.danger,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // Already approved callout
          if (!canReview) ...[
            const SizedBox(height: 12),
            TsCallout(
              color: colors.success,
              icon: Icons.check_circle_rounded,
              title: _alreadyApprovedTitle.resolve(locale),
              body: sub.teacherComment.isNotEmpty
                  ? sub.teacherComment
                  : _alreadyApprovedBody.resolve(locale),
            ),
          ],
          // Review action section
          if (canReview) ...[
            const SizedBox(height: 12),
            TsCard(
              accentBar: colors.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TsCardHeader(
                    eyebrow: _reviewEyebrow.resolve(locale),
                    title: _reviewTitle.resolve(locale),
                    subtitle: _reviewSubtitle.resolve(locale),
                  ),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 4,
                    enabled: !_loading,
                    style: TextStyle(color: colors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: _commentHint.resolve(locale),
                      hintStyle: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: colors.surfaceSoft,
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
                        borderSide: BorderSide(color: colors.primary),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _review('changes_requested'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.accent,
                              side: BorderSide(
                                color: colors.accent.withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            icon: const Icon(Icons.edit_note_rounded, size: 16),
                            label: Text(
                              _requestChangesLabel.resolve(locale),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _review('approved'),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: Text(
                              _approveLabel.resolve(locale),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.colors,
  });
  final IconData icon;
  final String label;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: colors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.locale});
  final AppThemeColors colors;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_rounded,
            size: 52,
            color: colors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            _emptyTitle.resolve(locale),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _emptyBody.resolve(locale),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Status helpers ───────────────────────────────────────────────────────────

(String, Color) _statusInfo(
  String status,
  AppLocale locale,
  AppThemeColors colors,
) {
  return switch (status) {
    'approved' => (
        switch (locale) {
          AppLocale.ru => 'ОДОБРЕНО',
          AppLocale.kk => 'МАҚҰЛДАНДЫ',
          _ => 'APPROVED',
        },
        colors.success,
      ),
    'changes_requested' => (
        switch (locale) {
          AppLocale.ru => 'ПРАВКИ',
          AppLocale.kk => 'ТҮЗЕТУ',
          _ => 'CHANGES',
        },
        colors.accent,
      ),
    'in_review' => (
        switch (locale) {
          AppLocale.ru => 'НА РЕВЬЮ',
          AppLocale.kk => 'ТЕКСЕРУДЕ',
          _ => 'IN REVIEW',
        },
        colors.primary,
      ),
    _ => (
        switch (locale) {
          AppLocale.ru => 'НОВОЕ',
          AppLocale.kk => 'ЖАҢА',
          _ => 'NEW',
        },
        const Color(0xFF60A5FA),
      ),
  };
}

String _timeAgo(DateTime dt, AppLocale locale) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) {
    return switch (locale) {
      AppLocale.ru => 'только что',
      AppLocale.kk => 'жаңа ғана',
      _ => 'just now',
    };
  }
  if (diff.inHours < 1) {
    final m = diff.inMinutes;
    return switch (locale) {
      AppLocale.ru => '$m мин назад',
      AppLocale.kk => '$m мин бұрын',
      _ => '${m}m ago',
    };
  }
  if (diff.inDays < 1) {
    final h = diff.inHours;
    return switch (locale) {
      AppLocale.ru => '$h ч назад',
      AppLocale.kk => '$h сағ бұрын',
      _ => '${h}h ago',
    };
  }
  final d = diff.inDays;
  return switch (locale) {
    AppLocale.ru => '$d дн назад',
    AppLocale.kk => '$d күн бұрын',
    _ => '${d}d ago',
  };
}

String _listTitleFn(int count, AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => '$count работ${count == 1 ? 'а' : ''} на проверку',
    AppLocale.kk => 'Тексеруге $count жұмыс',
    _ => '$count submission${count == 1 ? '' : 's'} to review',
  };
}

// ─── Strings ──────────────────────────────────────────────────────────────────

final _eyebrow = teacherText(ru: 'РЕВЬЮ КОДА', en: 'CODE REVIEW', kk: 'КОД РЕВЬЮ');
final _title = teacherText(
  ru: 'Работы на проверке',
  en: 'Submissions',
  kk: 'Тексеру жұмыстары',
);
final _subtitle = teacherText(
  ru: 'Код студентов, ожидающий вашей проверки.',
  en: 'Student practice code waiting for your review.',
  kk: 'Тексеруіңізді күтіп тұрған студент коды.',
);
final _refresh = teacherText(ru: 'Обновить', en: 'Refresh', kk: 'Жаңарту');
final _errorTitle = teacherText(
  ru: 'Ошибка загрузки',
  en: 'Load error',
  kk: 'Жүктеу қатесі',
);
final _listEyebrow = teacherText(
  ru: 'ОЧЕРЕДЬ РЕВЬЮ',
  en: 'REVIEW QUEUE',
  kk: 'РЕВЬЮ КЕЗЕГІ',
);
final _emptyTitle = teacherText(
  ru: 'Нет работ на проверку',
  en: 'No submissions yet',
  kk: 'Тексеретін жұмыс жоқ',
);
final _emptyBody = teacherText(
  ru: 'Когда студенты сдадут практику, она появится здесь.',
  en: 'When students submit practice code, it will appear here.',
  kk: 'Студенттер практика тапсырған кезде ол осында пайда болады.',
);
final _detailTitle = teacherText(
  ru: 'Ревью задания',
  en: 'Review submission',
  kk: 'Тапсырманы тексеру',
);
final _codeEyebrow = teacherText(
  ru: 'КОД СТУДЕНТА',
  en: 'STUDENT CODE',
  kk: 'СТУДЕНТ КОДЫ',
);
final _outputEyebrow = teacherText(
  ru: 'ВЫВОД ПРОГРАММЫ',
  en: 'PROGRAM OUTPUT',
  kk: 'БАҒДАРЛАМА ШЫҒЫСЫ',
);
final _reviewEyebrow = teacherText(
  ru: 'ДЕЙСТВИЕ',
  en: 'ACTION',
  kk: 'ӘРЕКЕТ',
);
final _reviewTitle = teacherText(ru: 'Ваш отзыв', en: 'Your feedback', kk: 'Пікіріңіз');
final _reviewSubtitle = teacherText(
  ru: 'Напишите комментарий и одобрите работу или запросите правки.',
  en: 'Write a comment, then approve or request changes.',
  kk: 'Пікір жазыңыз, жұмысты мақұлдаңыз немесе түзету сұраңыз.',
);
final _commentHint = teacherText(
  ru: 'Комментарий для студента...',
  en: 'Comment for the student...',
  kk: 'Студентке арналған пікір...',
);
final _requestChangesLabel = teacherText(
  ru: 'Запросить правки',
  en: 'Request changes',
  kk: 'Түзету сұрау',
);
final _approveLabel = teacherText(ru: 'Одобрить', en: 'Approve', kk: 'Мақұлдау');
final _alreadyApprovedTitle = teacherText(
  ru: 'РАБОТА ОДОБРЕНА',
  en: 'APPROVED',
  kk: 'МАҚҰЛДАНДЫ',
);
final _alreadyApprovedBody = teacherText(
  ru: 'Эта работа уже проверена и одобрена.',
  en: 'This submission has already been approved.',
  kk: 'Бұл жұмыс тексеріліп, мақұлданды.',
);
final _attemptLabel = teacherText(ru: 'Попытка', en: 'Attempt', kk: 'Әрекет');
final _copiedMsg = teacherText(ru: 'Скопировано', en: 'Copied', kk: 'Көшірілді');
final _commentRequired = teacherText(
  ru: 'Напишите комментарий для запроса правок',
  en: 'Write a comment when requesting changes',
  kk: 'Түзету сұрағанда пікір жазыңыз',
);
final _approvedMsg = teacherText(ru: 'Работа одобрена', en: 'Approved', kk: 'Жұмыс мақұлданды');
final _changesMsg = teacherText(
  ru: 'Запрошены правки',
  en: 'Changes requested',
  kk: 'Түзету сұралды',
);
final _errorMsg = teacherText(ru: 'Ошибка', en: 'Error', kk: 'Қате');
