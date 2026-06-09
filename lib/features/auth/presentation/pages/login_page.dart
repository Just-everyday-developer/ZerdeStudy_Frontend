import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend_flutter/app/routing/app_routes.dart';
import 'package:frontend_flutter/app/state/demo_app_controller.dart';
import 'package:frontend_flutter/core/common_widgets/app_notice.dart';
import 'package:frontend_flutter/core/common_widgets/locale_selector.dart';
import 'package:frontend_flutter/core/common_widgets/tech_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_flutter/core/localization/app_localizations.dart';
import 'package:frontend_flutter/core/theme/app_theme_colors.dart';

import 'package:frontend_flutter/features/auth/presentation/providers/auth_controller.dart';
import 'package:frontend_flutter/features/auth/presentation/providers/email_providers.dart';
import 'package:frontend_flutter/features/auth/presentation/providers/password_providers.dart';
import 'package:frontend_flutter/features/auth/presentation/widgets/auth_panel.dart';
import 'package:frontend_flutter/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:frontend_flutter/features/auth/presentation/widgets/tech_action_button.dart';

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

  Future<void> _submit() async {
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

    final error = await ref
        .read(authControllerProvider.notifier)
        .login(email: email, password: password);
    if (!mounted || error == null) {
      return;
    }

    AppNotice.show(context, message: error, type: AppNoticeType.error);
  }

  Future<void> _signInWithGoogle() async {
    final error = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();
    if (!mounted || error == null) {
      return;
    }
    AppNotice.show(context, message: error, type: AppNoticeType.error);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final demoState = ref.watch(demoAppControllerProvider);
    final demoController = ref.read(demoAppControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final colors = context.appColors;

    return AuthPanel(
      title: l10n.text('login_title'),
      subtitle: l10n.text('tagline'),
      topBar: Row(
        children: [
          IconButton(
            onPressed: () => context.go(AppRoutes.welcome),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.end,
                children: [
                  LocaleSelector(
                    currentLocale: demoState.locale,
                    onChanged: demoController.changeLocale,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              TechTextField(
                hint: l10n.text('email'),
                icon: Icons.alternate_email_rounded,
                controller: _emailCtrl,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TechTextField(
                hint: l10n.text('password'),
                icon: Icons.lock_outline_rounded,
                isObscure: true,
                controller: _passCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              TechActionButton(
                title: l10n.text('login'),
                isPrimary: true,
                icon: Icons.login_rounded,
                onTap: authState.isBusy ? null : _submit,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: Text(
                    l10n.text('forgot_password'),
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _DividerLabel(label: l10n.text('login_with')),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SocialAuthButton(
                      label: l10n.text('google'),
                      badgeWidget: SvgPicture.asset(
                        'assets/svgs/google_logo.svg',
                        width: 20,
                        height: 20,
                      ),
                      accent: const Color(0xFF4285F4),
                      onTap: authState.isBusy ? null : _signInWithGoogle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(child: Divider(color: colors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.divider)),
      ],
    );
  }
}
