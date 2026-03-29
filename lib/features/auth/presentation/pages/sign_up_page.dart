import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/common_widgets/tech_text_field.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/auth_controller.dart';
import '../providers/email_providers.dart';
import '../providers/password_providers.dart';
import '../widgets/auth_panel.dart';
import '../widgets/tech_action_button.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
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

  Future<void> _submit() async {
    final l10n = context.l10n;
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (!ref.read(validateEmailProvider)(email)) {
      AppNotice.show(
        context,
        message: l10n.text('invalid_email'),
        type: AppNoticeType.error,
      );
      return;
    }
    if (!ref.read(validatePasswordProvider)(password)) {
      AppNotice.show(
        context,
        message: l10n.text('invalid_password'),
        type: AppNoticeType.error,
      );
      return;
    }

    final error = await ref
        .read(authControllerProvider.notifier)
        .register(email: email, password: password);
    if (!mounted || error == null) {
      return;
    }

    AppNotice.show(context, message: error, type: AppNoticeType.error);
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final demoState = ref.watch(demoAppControllerProvider);
    final authState = ref.watch(authControllerProvider);

    return AuthPanel(
      title: l10n.text('signup_title'),
      subtitle: l10n.text('tagline'),
      topBar: Row(
        children: [
          IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          const Spacer(),
          LocaleSelector(
            currentLocale: demoState.locale,
            onChanged: ref
                .read(demoAppControllerProvider.notifier)
                .changeLocale,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TechTextField(
                    hint: l10n.text('email'),
                    icon: Icons.alternate_email_rounded,
                    controller: _emailCtrl,
                  ),
                  const SizedBox(height: 14),
                  TechTextField(
                    hint: l10n.text('password'),
                    icon: Icons.lock_outline_rounded,
                    controller: _passCtrl,
                    isObscure: true,
                  ),
                  const SizedBox(height: 20),
                  TechActionButton(
                    title: authState.isBusy ? '...' : l10n.text('signup'),
                    isPrimary: true,
                    icon: Icons.rocket_launch_rounded,
                    onTap: authState.isBusy ? () {} : _submit,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(l10n.text('login')),
                    ),
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
