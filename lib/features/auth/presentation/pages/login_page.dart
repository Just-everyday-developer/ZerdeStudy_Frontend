import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_experience.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/common_widgets/locale_selector.dart';
import '../../../../core/common_widgets/tech_text_field.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../providers/auth_controller.dart';
import '../providers/email_providers.dart';
import '../providers/password_providers.dart';
import '../widgets/auth_experience_selector.dart';
import '../widgets/auth_panel.dart';
import '../widgets/social_auth_button.dart';
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

  Future<void> _submit(AppExperience experience) async {
    final l10n = context.l10n;
    if (experience == AppExperience.admin) {
      _showAdminUnavailable();
      return;
    }

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

  Future<void> _signInWithProvider({
    required String provider,
    required AppExperience experience,
  }) async {
    if (experience == AppExperience.admin) {
      _showAdminUnavailable();
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signInWithMockProvider(
          provider: provider,
          roleCode: switch (experience) {
            AppExperience.student => 'student',
            AppExperience.teacher => 'teacher',
            AppExperience.moderator => 'manager',
            AppExperience.admin => 'admin',
          },
        );

    if (!mounted) {
      return;
    }

    AppNotice.show(
      context,
      message: context.l10n.text('social_login_mock_notice'),
      type: AppNoticeType.info,
      duration: const Duration(seconds: 2),
    );
  }

  void _showAdminUnavailable() {
    AppNotice.show(
      context,
      message: context.l10n.text('admin_portal_unavailable'),
      type: AppNoticeType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final demoState = ref.watch(demoAppControllerProvider);
    final demoController = ref.read(demoAppControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final colors = context.appColors;
    final selectedExperience = demoState.activeExperience;

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
          const Spacer(),
          LocaleSelector(
            currentLocale: demoState.locale,
            onChanged: demoController.changeLocale,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: l10n.text('login_as'),
            subtitle: l10n.text('login_as_hint'),
          ),
          const SizedBox(height: 14),
          AuthExperienceSelector(
            locale: demoState.locale,
            selectedExperience: selectedExperience,
            onChanged: demoController.setActiveExperience,
          ),
          const SizedBox(height: 26),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    isObscure: true,
                    controller: _passCtrl,
                  ),
                  const SizedBox(height: 20),
                  TechActionButton(
                    title: authState.isBusy ? '...' : l10n.text('login'),
                    isPrimary: true,
                    icon: Icons.login_rounded,
                    onTap: authState.isBusy
                        ? () {}
                        : () => _submit(selectedExperience),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        child: Text(l10n.text('forgot_password')),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push(AppRoutes.signup),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: Text(l10n.text('signup')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _DividerLabel(label: l10n.text('login_with')),
                  const SizedBox(height: 14),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SocialAuthButton(
                          label: l10n.text('google'),
                          badgeText: 'G',
                          accent: const Color(0xFF4285F4),
                          onTap: authState.isBusy
                              ? null
                              : () => _signInWithProvider(
                                  provider: 'google',
                                  experience: selectedExperience,
                                ),
                        ),
                        SocialAuthButton(
                          label: l10n.text('github'),
                          badgeText: 'GH',
                          accent: colors.textPrimary,
                          onTap: authState.isBusy
                              ? null
                              : () => _signInWithProvider(
                                  provider: 'github',
                                  experience: selectedExperience,
                                ),
                        ),
                      ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
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
