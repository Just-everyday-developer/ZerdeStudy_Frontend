import 'package:flutter/foundation.dart';

import '../../app/routing/app_routes.dart';

/// Handles OAuth return URLs on Flutter web when the browser path and GoRouter disagree.
abstract final class OAuthWebBootstrap {
  static String get initialLocation {
    if (!kIsWeb) {
      return AppRoutes.welcome;
    }
    return routeFromBrowser() ?? AppRoutes.welcome;
  }

  /// If Google/GitHub returned to `/auth/.../callback?code=...` but the app shows `#/welcome`,
  /// force navigation to the callback route so [OAuthCallbackPage] runs.
  static String? redirectForGoRouter(String matchedLocation) {
    if (!kIsWeb) {
      return null;
    }

    final browser = _browserUri();
    final callbackPath = _callbackPath(browser);
    if (callbackPath == null) {
      return null;
    }

    final code = browser.queryParameters['code'];
    if (code == null || code.isEmpty) {
      return null;
    }

    if (matchedLocation == callbackPath) {
      return null;
    }

    return _locationWithQuery(callbackPath, browser.queryParameters);
  }

  static String? routeFromBrowser() {
    if (!kIsWeb) {
      return null;
    }
    final browser = _browserUri();
    final callbackPath = _callbackPath(browser);
    if (callbackPath == null) {
      return null;
    }
    final code = browser.queryParameters['code'];
    if (code == null || code.isEmpty) {
      return null;
    }
    return _locationWithQuery(callbackPath, browser.queryParameters);
  }

  static String? _callbackPath(Uri browser) {
    final path = browser.path;
    if (path.endsWith(AppRoutes.googleCallback) ||
        path == AppRoutes.googleCallback) {
      return AppRoutes.googleCallback;
    }
    if (path.endsWith(AppRoutes.githubCallback) ||
        path == AppRoutes.githubCallback) {
      return AppRoutes.githubCallback;
    }
    return null;
  }

  static Uri _browserUri() => Uri.base;

  static String _locationWithQuery(
    String path,
    Map<String, String> queryParameters,
  ) {
    if (queryParameters.isEmpty) {
      return path;
    }
    return Uri(path: path, queryParameters: queryParameters).toString();
  }
}
