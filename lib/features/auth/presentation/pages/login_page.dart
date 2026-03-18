import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/common_widgets/tech_text_field.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/email_providers.dart';
import '../providers/password_providers.dart';
import '../widgets/auth_background_wrapper.dart';
import '../widgets/tech_action_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();
    final validateEmail = ref.read(validateEmailProvider);
    final validatePassword = ref.read(validatePasswordProvider);

    if (!validateEmail(email)) {
      AppNotice.show(
        context,
        message: l10n.text('invalid_email'),
        type: AppNoticeType.error,
      );
      return;
    }
    if (!validatePassword(password)) {
      AppNotice.show(
        context,
        message: l10n.text('invalid_password'),
        type: AppNoticeType.error,
      );
      return;
    }

    ref.read(demoAppControllerProvider.notifier).loginWithEmail(email: email);
    context.go(AppRoutes.home);
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
                      onChanged: ref.read(demoAppControllerProvider.notifier).changeLocale,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.text('login_title'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.text('tagline'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 28),
                  TechTextField(
                    hint: l10n.text('email'),
                    icon: Icons.alternate_email_rounded,
                    controller: _emailCtrl,
                  ),
                  const SizedBox(height: 14),
                  TechTextField(
                    hint: l10n.text('password'),
                    icon: Icons.lock_outline_rounded,
                    isObscure: true,
                    controller: _passCtrl,
                  ),
                  const SizedBox(height: 20),
                  TechActionButton(
                    title: l10n.text('login'),
                    isPrimary: true,
                    icon: Icons.login_rounded,
                    onTap: _submit,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TechActionButton(
                          title: l10n.text('google'),
                          isPrimary: false,
                          icon: Icons.language_rounded,
                          onTap: () {
                            ref.read(demoAppControllerProvider.notifier).loginWithProvider('google');
                            context.go(AppRoutes.home);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TechActionButton(
                          title: l10n.text('github'),
                          isPrimary: false,
                          icon: Icons.code_rounded,
                          onTap: () {
                            ref.read(demoAppControllerProvider.notifier).loginWithProvider('github');
                            context.go(AppRoutes.home);
                          },
                        ),
                      ),
                    ],
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
