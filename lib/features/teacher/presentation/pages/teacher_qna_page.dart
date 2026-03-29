import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../teacher_text.dart';
import '../widgets/teacher_workspace_widgets.dart';

class TeacherQnaPage extends ConsumerWidget {
  const TeacherQnaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      demoAppControllerProvider.select((state) => state.locale),
    );
    final colors = context.appColors;

    return TeacherPageScrollView(
      children: [
        TeacherSectionCard(
          title: _heroTitle.resolve(locale),
          subtitle: _heroSubtitle.resolve(locale),
          accent: colors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  TeacherTag(
                    label: _tagOne.resolve(locale),
                    accent: colors.primary,
                  ),
                  TeacherTag(
                    label: _tagTwo.resolve(locale),
                    accent: colors.success,
                  ),
                  TeacherTag(
                    label: _tagThree.resolve(locale),
                    accent: colors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppButton.primary(
                label: _primaryAction.resolve(locale),
                icon: Icons.campaign_rounded,
                onPressed: () {},
                maxWidth: 280,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _queueTitle.resolve(locale),
          subtitle: _queueSubtitle.resolve(locale),
          accent: colors.accent,
          child: Column(children: _queueRows(locale, colors)),
        ),
        const SizedBox(height: 18),
        TeacherSectionCard(
          title: _playbookTitle.resolve(locale),
          subtitle: _playbookSubtitle.resolve(locale),
          accent: colors.success,
          child: Column(children: _playbookRows(locale, colors)),
        ),
      ],
    );
  }

  List<Widget> _queueRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _queueOneTitle.resolve(locale),
        _queueOneSubtitle.resolve(locale),
        _queueOneStatus.resolve(locale),
        colors.danger,
      ),
      (
        _queueTwoTitle.resolve(locale),
        _queueTwoSubtitle.resolve(locale),
        _queueTwoStatus.resolve(locale),
        colors.accent,
      ),
      (
        _queueThreeTitle.resolve(locale),
        _queueThreeSubtitle.resolve(locale),
        _queueThreeStatus.resolve(locale),
        colors.success,
      ),
    ];

    return [
      for (var i = 0; i < rows.length; i++) ...[
        TeacherStatusRow(
          title: rows[i].$1,
          subtitle: rows[i].$2,
          status: rows[i].$3,
          accent: rows[i].$4,
        ),
        if (i != rows.length - 1) const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _playbookRows(AppLocale locale, AppThemeColors colors) {
    final rows = [
      (
        _playbookOneTitle.resolve(locale),
        _playbookOneSubtitle.resolve(locale),
        _playbookOneStatus.resolve(locale),
        colors.primary,
      ),
      (
        _playbookTwoTitle.resolve(locale),
        _playbookTwoSubtitle.resolve(locale),
        _playbookTwoStatus.resolve(locale),
        colors.success,
      ),
    ];

    return [
      for (var i = 0; i < rows.length; i++) ...[
        TeacherStatusRow(
          title: rows[i].$1,
          subtitle: rows[i].$2,
          status: rows[i].$3,
          accent: rows[i].$4,
        ),
        if (i != rows.length - 1) const SizedBox(height: 12),
      ],
    ];
  }
}

final _heroTitle = teacherText(ru: 'Q&A', en: 'Q&A', kk: 'Q&A');
final _heroSubtitle = teacherText(
  ru: 'Преподавателю нужна не просто лента вопросов, а рабочая зона для ответов, объявлений и повторяющихся проблем по курсу.',
  en: 'Teachers need more than a message feed: they need a workspace for replies, announcements, and repeated course issues.',
  kk: 'Оқытушыға жай сұрақтар лентасы емес, жауаптар, хабарландырулар және қайталанатын мәселелерге арналған жұмыс аймағы керек.',
);
final _tagOne = teacherText(
  ru: 'Open threads prioritized',
  en: 'Open threads prioritized',
  kk: 'Open threads prioritized',
);
final _tagTwo = teacherText(
  ru: 'Announcement composer',
  en: 'Announcement composer',
  kk: 'Announcement composer',
);
final _tagThree = teacherText(
  ru: 'Repeated issues grouped',
  en: 'Repeated issues grouped',
  kk: 'Repeated issues grouped',
);
final _primaryAction = teacherText(
  ru: 'Создать объявление',
  en: 'Create announcement',
  kk: 'Хабарландыру жасау',
);
final _queueTitle = teacherText(
  ru: 'Очередь вопросов',
  en: 'Question queue',
  kk: 'Сұрақтар кезегі',
);
final _queueSubtitle = teacherText(
  ru: 'Очередь должна собирать срочность, тему, модуль и настроение студентов, а не только список сообщений.',
  en: 'The queue should capture urgency, topic, module, and learner sentiment, not just raw messages.',
  kk: 'Кезек тек хабарламалар тізімі емес, urgency, topic, module және learner sentiment-ті де көрсетуі керек.',
);
final _queueOneTitle = teacherText(
  ru: '14 threads · SQL joins module',
  en: '14 threads · SQL joins module',
  kk: '14 threads · SQL joins module',
);
final _queueOneSubtitle = teacherText(
  ru: 'Студенты путают left join и inner join. Нужен pinned answer с наглядным примером.',
  en: 'Learners keep mixing left join and inner join. A pinned answer with a concrete example would help.',
  kk: 'Студенттер left join мен inner join-ды шатастырады. Нақты мысалы бар pinned answer керек.',
);
final _queueOneStatus = teacherText(
  ru: 'High volume',
  en: 'High volume',
  kk: 'High volume',
);
final _queueTwoTitle = teacherText(
  ru: '6 threads · Frontend capstone',
  en: '6 threads · Frontend capstone',
  kk: '6 threads · Frontend capstone',
);
final _queueTwoSubtitle = teacherText(
  ru: 'Срок сдачи близко, а rubric не до конца понятен. Нужен clarifying post.',
  en: 'The deadline is close and the rubric still feels unclear. Post a clarification.',
  kk: 'Дедлайн жақын, ал rubric әлі түсініксіз. Түсіндіретін post керек.',
);
final _queueTwoStatus = teacherText(
  ru: 'Deadline risk',
  en: 'Deadline risk',
  kk: 'Deadline risk',
);
final _queueThreeTitle = teacherText(
  ru: '3 threads · Discrete Math',
  en: '3 threads · Discrete Math',
  kk: '3 threads · Discrete Math',
);
final _queueThreeSubtitle = teacherText(
  ru: 'Вопросы точечные и уже частично закрыты через existing answers.',
  en: 'These are narrow questions and mostly covered by existing answers.',
  kk: 'Бұл тар сұрақтар, олардың көбі existing answers арқылы жабылған.',
);
final _queueThreeStatus = teacherText(
  ru: 'Low urgency',
  en: 'Low urgency',
  kk: 'Low urgency',
);
final _playbookTitle = teacherText(
  ru: 'Communication playbook',
  en: 'Communication playbook',
  kk: 'Communication playbook',
);
final _playbookSubtitle = teacherText(
  ru: 'В интерфейсе преподавателя полезно сразу заложить типовые способы ответа и поддержки курса.',
  en: 'The teacher interface should already encode the default response and support patterns.',
  kk: 'Оқытушы интерфейсіне әдепкі жауап беру және курс қолдау паттерндерін бірден енгізген пайдалы.',
);
final _playbookOneTitle = teacherText(
  ru: 'Pinned clarifications',
  en: 'Pinned clarifications',
  kk: 'Pinned clarifications',
);
final _playbookOneSubtitle = teacherText(
  ru: 'Частые вопросы превращаются в pinned cards внутри конкретного урока или модуля.',
  en: 'Frequent questions become pinned cards inside the relevant lesson or module.',
  kk: 'Жиі сұрақтар тиісті lesson немесе module ішінде pinned cards-қа айналады.',
);
final _playbookOneStatus = teacherText(
  ru: 'Self-serve support',
  en: 'Self-serve support',
  kk: 'Self-serve support',
);
final _playbookTwoTitle = teacherText(
  ru: 'Targeted reminders',
  en: 'Targeted reminders',
  kk: 'Targeted reminders',
);
final _playbookTwoSubtitle = teacherText(
  ru: 'Уведомления можно отправлять не всем, а только тем, кто застрял перед дедлайном.',
  en: 'Announcements can target only the learners who are stuck before a deadline.',
  kk: 'Хабарламаларды барлығына емес, дедлайн алдында тұрып қалған студенттерге ғана жіберуге болады.',
);
final _playbookTwoStatus = teacherText(
  ru: 'Actionable',
  en: 'Actionable',
  kk: 'Actionable',
);
