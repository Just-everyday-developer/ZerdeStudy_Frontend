import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/common_widgets/tech_text_field.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/email_providers.dart';
import '../widgets/auth_background_wrapper.dart';
import '../widgets/tech_action_button.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _sendCode() {
    final l10n = context.l10n;
    final locale = ref.read(demoAppControllerProvider).locale;
    final email = _emailCtrl.text.trim();
    if (!ref.read(validateEmailProvider)(email)) {
      AppNotice.show(
        context,
        message: l10n.text('invalid_email'),
        type: AppNoticeType.error,
      );
      return;
    }

    AppNotice.show(
      context,
      message: _pendingResetMessage(locale),
      type: AppNoticeType.info,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(demoAppControllerProvider);

    return AuthBackgroundWrapper(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: LocaleSelector(
                      currentLocale: state.locale,
                      onChanged: ref
                          .read(demoAppControllerProvider.notifier)
                          .changeLocale,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.text('forgot_password_title'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _forgotPasswordSubtitle(state.locale),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 28),
                  TechTextField(
                    hint: l10n.text('email'),
                    icon: Icons.alternate_email_rounded,
                    controller: _emailCtrl,
                  ),
                  const SizedBox(height: 20),
                  TechActionButton(
                    title: l10n.text('send_code'),
                    isPrimary: true,
                    icon: Icons.mark_email_read_outlined,
                    onTap: _sendCode,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.go(AppRoutes.welcome),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(l10n.text('back_to_login')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _forgotPasswordSubtitle(AppLocale locale) {
  switch (locale) {
    case AppLocale.ru:
      return 'Экран восстановления пароля пока не подключен к реальному backend-потоку. На этой задаче мы подключили только register, login, me, refresh и logout.';
    case AppLocale.en:
      return 'Password reset is not wired to the real backend flow yet. This task only connects register, login, me, refresh, and logout.';
    case AppLocale.kk:
      return 'Құпиясөзді қалпына келтіру әзірше нақты backend ағынына қосылған жоқ. Бұл тапсырмада тек register, login, me, refresh және logout қосылды.';
  }
}

String _pendingResetMessage(AppLocale locale) {
  switch (locale) {
    case AppLocale.ru:
      return 'Восстановление пароля вынесем в следующую backend-задачу.';
    case AppLocale.en:
      return 'Password reset will be connected in the next backend task.';
    case AppLocale.kk:
      return 'Құпиясөзді қалпына келтіру келесі backend тапсырмасында қосылады.';
  }
}
