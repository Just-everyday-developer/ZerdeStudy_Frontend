import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  return AppEnvironment.fromPlatform();
});

class AppEnvironment {
  const AppEnvironment({
    required this.gatewayBaseUrl,
  });

  static const String _defaultGatewayPort = '8090';

  final String gatewayBaseUrl;

  factory AppEnvironment.fromPlatform() {
    const override = String.fromEnvironment('GATEWAY_BASE_URL');
    if (override.isNotEmpty) {
      return AppEnvironment(gatewayBaseUrl: _normalizeBaseUrl(override));
    }

    if (kIsWeb) {
      return const AppEnvironment(
        gatewayBaseUrl: 'http://localhost:$_defaultGatewayPort',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const AppEnvironment(
          gatewayBaseUrl: 'http://10.0.2.2:$_defaultGatewayPort',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const AppEnvironment(
          gatewayBaseUrl: 'http://localhost:$_defaultGatewayPort',
        );
    }
  }

  Uri resolve(String path) {
    return Uri.parse(gatewayBaseUrl).resolve(path);
  }

  static String _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
