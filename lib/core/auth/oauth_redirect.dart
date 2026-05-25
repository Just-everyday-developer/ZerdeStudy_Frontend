import 'package:flutter/foundation.dart';

import '../../app/routing/app_routes.dart';

/// Return URL sent to the API as [redirect_uri]. Must match IdP / backend allow-list exactly.
///
/// - **Web**: current origin + hash route (default Flutter web) or path route if no fragment.
/// - **Mobile / desktop**: custom scheme so the OS re-opens this app after the browser step.
abstract final class OAuthRedirectConfig {
  static String google() => _build(AppRoutes.googleCallback);

  static String github() => _build(AppRoutes.githubCallback);

  static String _build(String routePath) {
    final normalized = routePath.startsWith('/') ? routePath : '/$routePath';
    if (kIsWeb) {
      return _webReturnUrl(normalized);
    }
    final segments = normalized
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    final host = segments.isEmpty ? 'auth' : segments.first;
    final pathSegments = segments.length <= 1
        ? const <String>[]
        : segments.skip(1).toList(growable: false);
    return Uri(
      scheme: 'zerdestudy',
      host: host,
      pathSegments: pathSegments,
    ).toString();
  }

  static String _webReturnUrl(String normalizedRoute) {
    final base = Uri.base;
    // Path-based URL (usePathUrlStrategy): http://localhost:3000/auth/google/callback
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: normalizedRoute,
    ).toString();
  }
}
