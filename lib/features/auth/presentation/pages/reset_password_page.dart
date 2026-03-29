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

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.email, required this.code});

  final String? email;
  final String? code;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final email = widget.email?.trim() ?? '';
    final code = widget.code?.trim() ?? '';
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!ref.read(validateEmailProvider)(email)) {
      AppNotice.show(
        context,
        message: l10n.text('invalid_email'),
        type: AppNoticeType.error,
      );
      return;
    }
    if (code.isEmpty) {
      AppNotice.show(
        context,
        message: l10n.text('enter_six_digit_code'),
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
    if (password != confirmPassword) {
      AppNotice.show(
        context,
        message: l10n.text('passwords_do_not_match'),
        type: AppNoticeType.error,
      );
      return;
    }

    final authController = ref.read(authControllerProvider.notifier);
    final resetError = await authController.resetPassword(
      email: email,
      code: code,
      newPassword: password,
    );
    if (!mounted) {
      return;
    }
    if (resetError != null) {
      AppNotice.show(context, message: resetError, type: AppNoticeType.error);
      return;
    }

    final loginError = await authController.login(
      email: email,
      password: password,
    );
    if (!mounted) {
      return;
    }
    if (loginError != null) {
      AppNotice.show(
        context,
        message: l10n.text('password_reset_success_login_required'),
        type: AppNoticeType.success,
        duration: const Duration(seconds: 3),
      );
      context.go(AppRoutes.login);
      return;
    }

    AppNotice.show(
      context,
      message: l10n.text('password_reset_success'),
      type: AppNoticeType.success,
      duration: const Duration(seconds: 3),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(demoAppControllerProvider);
    final authState = ref.watch(authControllerProvider);

    return AuthPanel(
      title: l10n.text('set_new_password_title'),
      subtitle: l10n.format('set_new_password_subtitle', <String, Object>{
        'email': widget.email?.trim().isNotEmpty == true
            ? widget.email!.trim()
            : l10n.text('email'),
      }),
      topBar: Row(
        children: [
          IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          const Spacer(),
          LocaleSelector(
            currentLocale: state.locale,
            onChanged: ref
                .read(demoAppControllerProvider.notifier)
                .changeLocale,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechTextField(
            hint: l10n.text('password'),
            icon: Icons.lock_outline_rounded,
            isObscure: true,
            controller: _passwordController,
          ),
          const SizedBox(height: 14),
          TechTextField(
            hint: l10n.text('confirm_password'),
            icon: Icons.verified_rounded,
            isObscure: true,
            controller: _confirmPasswordController,
          ),
          const SizedBox(height: 20),
          TechActionButton(
            title: authState.isBusy ? '...' : l10n.text('save_new_password'),
            isPrimary: true,
            icon: Icons.lock_reset_rounded,
            onTap: authState.isBusy ? () {} : _submit,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(l10n.text('back_to_code')),
            ),
          ),
        ],
      ),
    );
  }
}
