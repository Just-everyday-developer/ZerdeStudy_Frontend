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
import '../../../../core/theme/app_theme_colors.dart';
import '../providers/auth_controller.dart';
import '../providers/email_providers.dart';
import '../providers/password_providers.dart';
import '../widgets/auth_background_wrapper.dart';
import '../widgets/tech_action_button.dart';

class ForgotPasswordCodePage extends ConsumerStatefulWidget {
  const ForgotPasswordCodePage({super.key, this.email});

  final String? email;

  @override
  ConsumerState<ForgotPasswordCodePage> createState() =>
      _ForgotPasswordCodePageState();
}

class _ForgotPasswordCodePageState
    extends ConsumerState<ForgotPasswordCodePage> {
  late final TextEditingController _emailController;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
    _emailController.addListener(_handleEmailChanged);
    _controllers = List<TextEditingController>.generate(
      6,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController
      ..removeListener(_handleEmailChanged)
      ..dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _passwordController.dispose();
    super.dispose();
  }

  String get _enteredCode =>
      _controllers.map((controller) => controller.text).join();

  bool get _isCodeComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);

  Future<void> _submitCode() async {
    final l10n = context.l10n;
    final email = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();

    if (!ref.read(validateEmailProvider)(email)) {
      AppNotice.show(
        context,
        message: l10n.text('invalid_email'),
        type: AppNoticeType.error,
      );
      return;
    }
    if (!_isCodeComplete) {
      AppNotice.show(
        context,
        message: l10n.text('enter_six_digit_code'),
        type: AppNoticeType.error,
      );
      return;
    }
    if (!ref.read(validatePasswordProvider)(newPassword)) {
      AppNotice.show(
        context,
        message: l10n.text('invalid_password'),
        type: AppNoticeType.error,
      );
      return;
    }

    final authController = ref.read(authControllerProvider.notifier);
    final resetError = await authController.resetPassword(
      email: email,
      code: _enteredCode,
      newPassword: newPassword,
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
      password: newPassword,
    );
    if (!mounted) {
      return;
    }
    if (loginError != null) {
      AppNotice.show(
        context,
        message: _passwordResetLoginRequiredMessage(context.l10n.locale),
        type: AppNoticeType.info,
        duration: const Duration(seconds: 3),
      );
      context.go(AppRoutes.login);
      return;
    }

    AppNotice.show(
      context,
      message: _passwordResetSuccessMessage(context.l10n.locale),
      type: AppNoticeType.success,
      duration: const Duration(seconds: 3),
    );
  }

  void _handleEmailChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onDigitChanged(int index, String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized != value) {
      _controllers[index].value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    if (normalized.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(demoAppControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final colors = context.appColors;

    return AuthBackgroundWrapper(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
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
                    l10n.text('verification_code_title'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.format('verification_code_subtitle', <String, Object>{
                      'email': _emailController.text.trim().isEmpty
                          ? l10n.text('email')
                          : _emailController.text.trim(),
                    }),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 28),
                  TechTextField(
                    hint: l10n.text('email'),
                    icon: Icons.alternate_email_rounded,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 10.0;
                      final fieldWidth =
                          ((constraints.maxWidth - (gap * 5)) / 6).clamp(
                            42.0,
                            56.0,
                          );
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List<Widget>.generate(
                          6,
                          (index) => _CodeDigitField(
                            width: fieldWidth,
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            onChanged: (value) => _onDigitChanged(index, value),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      _enteredCode.isEmpty ? '------' : _enteredCode,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  TechTextField(
                    hint: _newPasswordLabel(state.locale),
                    icon: Icons.lock_outline_rounded,
                    isObscure: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 22),
                  TechActionButton(
                    title: authState.isBusy
                        ? '...'
                        : l10n.text('verify_and_continue'),
                    isPrimary: true,
                    icon: Icons.verified_user_outlined,
                    onTap: authState.isBusy ? () {} : _submitCode,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.go(AppRoutes.forgotPassword),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(l10n.text('change_email')),
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

String _newPasswordLabel(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Новый пароль',
    AppLocale.en => 'New password',
    AppLocale.kk => 'Жаңа құпиясөз',
  };
}

String _passwordResetSuccessMessage(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Пароль обновлён. Открываем приложение.',
    AppLocale.en => 'Password updated. Opening the app.',
    AppLocale.kk => 'Құпиясөз жаңартылды. Қосымша ашылып жатыр.',
  };
}

String _passwordResetLoginRequiredMessage(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Пароль обновлён. Войдите с новым паролем.',
    AppLocale.en => 'Password updated. Sign in with the new password.',
    AppLocale.kk => 'Құпиясөз жаңартылды. Жаңа құпиясөзбен кіріңіз.',
  };
}

// ignore: unused_element
String _passwordResetGenericError(AppLocale locale) {
  return switch (locale) {
    AppLocale.ru => 'Не удалось продолжить восстановление пароля.',
    AppLocale.en => 'Unable to continue the password reset flow.',
    AppLocale.kk => 'Құпиясөзді қалпына келтіруді жалғастыру мүмкін болмады.',
  };
}

class _CodeDigitField extends StatelessWidget {
  const _CodeDigitField({
    required this.width,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final double width;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        maxLength: 1,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: colors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.primary, width: 1.6),
          ),
        ),
      ),
    );
  }
}
