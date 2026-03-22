import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../widgets/auth_background_wrapper.dart';
import '../widgets/tech_action_button.dart';

class ForgotPasswordCodePage extends ConsumerStatefulWidget {
  const ForgotPasswordCodePage({
    super.key,
    this.email,
  });

  final String? email;

  @override
  ConsumerState<ForgotPasswordCodePage> createState() =>
      _ForgotPasswordCodePageState();
}

class _ForgotPasswordCodePageState
    extends ConsumerState<ForgotPasswordCodePage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      6,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(
      6,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _enteredCode =>
      _controllers.map((controller) => controller.text).join();

  bool get _isCodeComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);

  void _submitCode() {
    final l10n = context.l10n;
    if (!_isCodeComplete) {
      AppNotice.show(
        context,
        message: l10n.text('enter_six_digit_code'),
        type: AppNoticeType.error,
      );
      return;
    }

    ref.read(demoAppControllerProvider.notifier).loginWithEmail(
          email: widget.email ?? 'reset@zerdestudy.app',
        );
    AppNotice.show(
      context,
      message: l10n.text('code_verified'),
      type: AppNoticeType.success,
    );
    context.go(AppRoutes.home);
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
                    l10n.format(
                      'verification_code_subtitle',
                      <String, Object>{
                        'email': widget.email ?? l10n.text('email'),
                      },
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List<Widget>.generate(
                      6,
                      (index) => _CodeDigitField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) => _onDigitChanged(index, value),
                      ),
                    ),
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
                  TechActionButton(
                    title: l10n.text('verify_and_continue'),
                    isPrimary: true,
                    icon: Icons.verified_user_outlined,
                    onTap: _submitCode,
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

class _CodeDigitField extends StatelessWidget {
  const _CodeDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 48,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        maxLength: 1,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
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
