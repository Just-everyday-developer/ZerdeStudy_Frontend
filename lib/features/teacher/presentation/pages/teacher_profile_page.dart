import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../core/common_widgets/app_user_avatar.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../courses_backend/presentation/providers/backend_course_providers.dart';
import '../teacher_text.dart';
import '../widgets/teacher_studio_widgets.dart';

class TeacherProfilePage extends ConsumerWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(demoAppControllerProvider.select((s) => s.locale));
    final demoState = ref.watch(demoAppControllerProvider);
    final user = demoState.user;

    final backendProfile = ref
        .watch(backendProfileProvider)
        .maybeWhen(data: (p) => p, orElse: () => null);

    final name = ((backendProfile?.login ?? '').trim().isNotEmpty
            ? backendProfile!.login
            : (user?.name ?? '').trim())
        .trim();
    final displayName = name.isNotEmpty ? name : 'Преподаватель';
    final email = (backendProfile?.email ?? '').isNotEmpty
        ? backendProfile!.email
        : (user?.email ?? '');
    final bio = (backendProfile?.bio ?? '').trim();
    final photoUrl =
        (backendProfile?.photoUrl ?? '').isNotEmpty ? backendProfile!.photoUrl : null;
    final avatarBase64 = user?.avatarBase64;

    final myId = ref.watch(authControllerProvider).session?.user.id ?? '';
    final courseCount = ref.watch(teacherBackendCoursesProvider).maybeWhen(
          data: (list) {
            final mine = list.where((c) => c.author.id == myId).length;
            return mine > 0 ? mine : list.length;
          },
          orElse: () => 0,
        );

    return TsPageScrollView(
      children: [
        TsPageHeader(
          eyebrow: _eyebrow.resolve(locale),
          title: _title.resolve(locale),
          subtitle: _subtitle.resolve(locale),
          actions: [
            TsButton(
              label: _editLabel.resolve(locale),
              icon: Icons.edit_rounded,
              onPressed: () => _openEditDialog(
                context,
                ref,
                locale: locale,
                name: displayName,
                email: email,
                bio: bio,
                avatarBase64: avatarBase64,
                photoUrl: photoUrl,
              ),
            ),
          ],
        ),

        // Identity card
        TsCard(
          padding: const EdgeInsets.all(20),
          child: _IdentityCard(
            name: displayName,
            email: email,
            bio: bio,
            photoUrl: photoUrl,
            avatarBase64: avatarBase64,
            courseCount: courseCount,
            locale: locale,
            onEditTap: () => _openEditDialog(
              context,
              ref,
              locale: locale,
              name: displayName,
              email: email,
              bio: bio,
              avatarBase64: avatarBase64,
              photoUrl: photoUrl,
            ),
          ),
        ),

        // Mobile logout
        if (MediaQuery.sizeOf(context).width < 600)
          _LogoutButton(locale: locale),
      ],
    );
  }

  Future<void> _openEditDialog(
    BuildContext context,
    WidgetRef ref, {
    required AppLocale locale,
    required String name,
    required String email,
    required String bio,
    String? avatarBase64,
    String? photoUrl,
  }) async {
    final result = await showDialog<_ProfileResult>(
      context: context,
      builder: (_) => _EditProfileDialog(
        initialName: name,
        initialEmail: email,
        initialBio: bio,
        initialAvatarBase64: avatarBase64,
        initialPhotoUrl: photoUrl,
        locale: locale,
      ),
    );
    if (result == null || !context.mounted) return;

    final err = await ref.read(authControllerProvider.notifier).updateProfile(
          name: result.name,
          bio: result.bio,
          avatarBase64: result.avatarBase64,
        );

    if (!context.mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_saveError.resolve(locale)}: $err')),
      );
    } else {
      ref.invalidate(backendProfileProvider);
      ref.read(demoAppControllerProvider.notifier).updateProfile(
            name: result.name,
            avatarBase64: result.avatarBase64,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_saveSuccess.resolve(locale))),
      );
    }
  }
}

// ─── Identity card ────────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.email,
    required this.bio,
    required this.photoUrl,
    required this.avatarBase64,
    required this.courseCount,
    required this.locale,
    required this.onEditTap,
  });

  final String name;
  final String email;
  final String bio;
  final String? photoUrl;
  final String? avatarBase64;
  final int courseCount;
  final AppLocale locale;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = MediaQuery.sizeOf(context).width < 600;

    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        AppUserAvatar(
          name: name,
          avatarBase64: avatarBase64,
          photoUrl: photoUrl,
          size: 80,
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: GestureDetector(
            onTap: onEditTap,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 12,
                color: Color(0xFF062623),
              ),
            ),
          ),
        ),
      ],
    );

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            TsTag(
              label: '$courseCount ${_coursesTag.resolve(locale)}',
              color: colors.primary,
              icon: Icons.menu_book_rounded,
            ),
          ],
        ),
      ],
    );

    final block = compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [avatar, const SizedBox(height: 16), identity],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: 20),
              Expanded(child: identity),
            ],
          );

    if (bio.isEmpty) return block;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        block,
        const SizedBox(height: 18),
        Divider(color: colors.divider.withValues(alpha: 0.5), height: 1),
        const SizedBox(height: 18),
        TsEyebrow(_bioEyebrow.resolve(locale)),
        const SizedBox(height: 8),
        Text(
          bio,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13.5,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ─── Edit dialog ──────────────────────────────────────────────────────────────

class _ProfileResult {
  const _ProfileResult({
    required this.name,
    required this.bio,
    required this.avatarBase64,
  });
  final String name;
  final String bio;
  final String? avatarBase64;
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.initialName,
    required this.initialEmail,
    required this.initialBio,
    required this.initialAvatarBase64,
    required this.locale,
    this.initialPhotoUrl,
  });

  final String initialName;
  final String initialEmail;
  final String initialBio;
  final String? initialAvatarBase64;
  final String? initialPhotoUrl;
  final AppLocale locale;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late String? _avatarBase64;
  bool _localAvatarSelected = false;
  bool _pickingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _bioCtrl = TextEditingController(text: widget.initialBio);
    _avatarBase64 = widget.initialAvatarBase64;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    setState(() => _pickingAvatar = true);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (!mounted || picked == null || picked.files.isEmpty) return;
      final bytes = picked.files.single.bytes;
      if (bytes == null || bytes.isEmpty) return;
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return;
      final size = math.min(decoded.width, decoded.height);
      final cropped = img.copyCrop(
        decoded,
        x: (decoded.width - size) ~/ 2,
        y: (decoded.height - size) ~/ 2,
        width: size,
        height: size,
      );
      final resized = img.copyResize(cropped, width: 320, height: 320);
      setState(() {
        _avatarBase64 = base64Encode(
          Uint8List.fromList(img.encodeJpg(resized, quality: 82)),
        );
        _localAvatarSelected = true;
      });
    } catch (_) {
      // silently fail
    } finally {
      if (mounted) setState(() => _pickingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = widget.locale;
    final trimmedName = _nameCtrl.text.trim();
    final canSave = trimmedName.isNotEmpty && !_pickingAvatar;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dialogTitle.resolve(locale),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: AppUserAvatar(
                      name: trimmedName.isEmpty ? widget.initialName : trimmedName,
                      avatarBase64: _avatarBase64,
                      photoUrl: _localAvatarSelected ? null : widget.initialPhotoUrl,
                      size: 88,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickingAvatar ? null : _pickAvatar,
                          icon: _pickingAvatar
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.photo_library_rounded, size: 16),
                          label: Text(_pickPhotoLabel.resolve(locale)),
                        ),
                        if (_avatarBase64 != null)
                          OutlinedButton.icon(
                            onPressed: () => setState(() {
                              _avatarBase64 = null;
                              _localAvatarSelected = false;
                            }),
                            icon: const Icon(Icons.delete_outline_rounded, size: 16),
                            label: Text(_removePhotoLabel.resolve(locale)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _nameCtrl,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: _nameLabel.resolve(locale),
                      helperText: widget.initialEmail,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _bioCtrl,
                    maxLength: 255,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: _bioHint.resolve(locale),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(_cancelLabel.resolve(locale)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: canSave
                              ? () => Navigator.of(context).pop(
                                    _ProfileResult(
                                      name: trimmedName,
                                      bio: _bioCtrl.text.trim(),
                                      avatarBase64: _avatarBase64,
                                    ),
                                  )
                              : null,
                          child: Text(_saveLabel.resolve(locale)),
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

// ─── Logout button ────────────────────────────────────────────────────────────

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton({required this.locale});
  final AppLocale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final label = switch (locale) {
      AppLocale.ru => 'Выйти из аккаунта',
      AppLocale.kk => 'Аккаунттан шығу',
      _ => 'Log out',
    };
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await ref.read(authControllerProvider.notifier).logout();
          if (!context.mounted) return;
          context.go(AppRoutes.welcome);
        },
        icon: Icon(Icons.logout_rounded, color: colors.danger, size: 18),
        label: Text(label, style: TextStyle(color: colors.danger)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.danger.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ─── Strings ──────────────────────────────────────────────────────────────────

final _eyebrow = teacherText(ru: 'ВЫ', en: 'YOU', kk: 'СІЗ');
final _title = teacherText(ru: 'Профиль', en: 'Profile', kk: 'Профиль');
final _subtitle = teacherText(
  ru: 'Ваш публичный профиль на платформе.',
  en: 'Your public-facing identity on the platform.',
  kk: 'Платформадағы профиліңіз.',
);
final _editLabel = teacherText(ru: 'Редактировать', en: 'Edit profile', kk: 'Өңдеу');
final _coursesTag = teacherText(ru: 'курсов', en: 'courses', kk: 'курс');
final _bioEyebrow = teacherText(ru: 'БИО', en: 'BIO', kk: 'БИО');

final _dialogTitle = teacherText(
  ru: 'Редактировать профиль',
  en: 'Edit profile',
  kk: 'Профильді өңдеу',
);
final _pickPhotoLabel = teacherText(ru: 'Выбрать фото', en: 'Pick photo', kk: 'Фото таңдау');
final _removePhotoLabel = teacherText(ru: 'Удалить фото', en: 'Remove photo', kk: 'Фотоны жою');
final _nameLabel = teacherText(ru: 'Имя', en: 'Name', kk: 'Аты');
final _bioHint = teacherText(
  ru: 'Расскажите о себе...',
  en: 'Tell us about yourself...',
  kk: 'Өзіңіз туралы айтыңыз...',
);
final _cancelLabel = teacherText(ru: 'Отмена', en: 'Cancel', kk: 'Болдырмау');
final _saveLabel = teacherText(ru: 'Сохранить', en: 'Save', kk: 'Сақтау');
final _saveSuccess = teacherText(
  ru: 'Профиль обновлён',
  en: 'Profile updated',
  kk: 'Профиль жаңартылды',
);
final _saveError = teacherText(ru: 'Ошибка', en: 'Error', kk: 'Қате');
