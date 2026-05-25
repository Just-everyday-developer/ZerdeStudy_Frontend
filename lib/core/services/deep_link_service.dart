import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend_flutter/app/routing/app_routes.dart';
import 'package:frontend_flutter/app/routing/router_keys.dart';
import 'package:frontend_flutter/features/auth/presentation/providers/auth_controller.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class DeepLinkService {
  DeepLinkService(this._ref);

  final Ref _ref;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  void initialize() {
    _appLinks = AppLinks();

    unawaited(_consumeInitialLink());

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => unawaited(_handleDeepLink(uri)),
      onError: (Object e, StackTrace st) =>
          debugPrint('Deep link stream error: $e\n$st'),
    );
  }

  Future<void> _consumeInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        await _handleDeepLink(uri);
      }
    } catch (e, st) {
      debugPrint('getInitialLink failed: $e\n$st');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('Deep link received: $uri');

    if (uri.scheme != 'zerdestudy') {
      return;
    }

    final routeParts = <String>[
      if (uri.host.isNotEmpty) uri.host,
      ...uri.pathSegments,
    ];
    if (!routeParts.contains('auth')) {
      return;
    }

    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      debugPrint('OAuth deep link missing code');
      return;
    }

    final provider = routeParts.contains('github') ? 'github' : 'google';
    final notifier = _ref.read(authControllerProvider.notifier);
    final String? error = provider == 'github'
        ? await notifier.handleGithubCallback(code)
        : await notifier.handleGoogleCallback(code);

    if (error != null) {
      debugPrint('OAuth deep link exchange failed: $error');
    }

    _goPostOAuth();
  }

  void _goPostOAuth() {
    final ctx = appRootNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) {
      return;
    }
    GoRouter.of(ctx).go(AppRoutes.home);
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
