import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/common_widgets/tech_text_field.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../providers/email_providers.dart';
import '../widgets/auth_panel.dart';
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
    super.dispose();
  }

  String get _enteredCode =>
      _controllers.map((controller) => controller.text).join();

  bool get _isCodeComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);

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

  void _continue() {
    final l10n = context.l10n;
    final email = _emailController.text.trim();

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

    context.push(
      AppRoutes.resetPasswordWithPayload(email: email, code: _enteredCode),
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
    final colors = context.appColors;

    return AuthPanel(
      title: l10n.text('verification_code_title'),
      subtitle: l10n.format('verification_code_subtitle', <String, Object>{
        'email': _emailController.text.trim().isEmpty
            ? l10n.text('email')
            : _emailController.text.trim(),
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
            hint: l10n.text('email'),
            icon: Icons.alternate_email_rounded,
            controller: _emailController,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final fieldWidth = ((constraints.maxWidth - (gap * 5)) / 6).clamp(
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
          TechActionButton(
            title: l10n.text('continue_to_password_reset'),
            isPrimary: true,
            icon: Icons.arrow_forward_rounded,
            onTap: _continue,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(l10n.text('change_email')),
            ),
          ),
        ],
      ),
    );
  }
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
