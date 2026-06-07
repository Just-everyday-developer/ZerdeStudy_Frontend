import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

class AppUserAvatar extends StatelessWidget {
  const AppUserAvatar({
    super.key,
    required this.name,
    this.avatarBase64,
    this.photoUrl,
    required this.size,
    this.enableHero = false,
    this.heroTag = 'shell-profile-avatar',
  });

  final String name;
  final String? avatarBase64;
  /// Presigned URL from Minio/backend. Takes priority over [avatarBase64].
  final String? photoUrl;
  final double size;
  final bool enableHero;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effectiveUrl = photoUrl?.trim();
    final hasNetworkImage = effectiveUrl != null && effectiveUrl.isNotEmpty;
    final imageBytes = hasNetworkImage ? null : _decodeAvatarBytes(avatarBase64);
    final hasLocalImage = imageBytes != null;
    final hasImage = hasNetworkImage || hasLocalImage;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: !hasImage
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary.withValues(alpha: 0.28),
                  colors.surfaceSoft.withValues(alpha: 0.94),
                ],
              )
            : null,
        color: hasImage ? colors.surfaceSoft : null,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.34),
          width: size >= 72 ? 2.2 : 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.12),
            blurRadius: size >= 72 ? 22 : 14,
            offset: Offset(0, size >= 72 ? 10 : 6),
          ),
        ],
      ),
      child: ClipOval(
        child: hasNetworkImage
            ? Image.network(
                effectiveUrl,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) {
                  final bytes = imageBytes;
                  return bytes != null
                      ? Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true)
                      : _initialsWidget(name, colors);
                },
              )
            : hasLocalImage
                ? Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) => Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: colors.primary,
                        size: size * 0.42,
                      ),
                    ),
                  )
                : _initialsWidget(name, colors),
      ),
    );

    if (!enableHero) {
      return avatar;
    }

    return Hero(tag: heroTag, child: avatar);
  }

  Widget _initialsWidget(String name, AppThemeColors colors) {
    return Center(
      child: Text(
        _initials(name),
        style: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.3,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static Uint8List? _decodeAvatarBytes(String? avatarBase64) {
    final normalized = avatarBase64?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    try {
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'Z';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts[1].substring(0, 1).toUpperCase();
    return '$first$second';
  }
}
