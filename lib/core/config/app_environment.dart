import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  return AppEnvironment.fromPlatform();
});

class AppEnvironment {
  const AppEnvironment({
    required this.gatewayBaseUrl,
    required this.aiServiceBaseUrl,
    this.aiServiceAuthToken = '',
  });

  static const String _defaultGatewayPort = '8090';
  static const String _defaultAiServicePort = '8088';

  final String gatewayBaseUrl;
  final String aiServiceBaseUrl;
  final String aiServiceAuthToken;

  factory AppEnvironment.fromPlatform() {
    const gatewayOverride = String.fromEnvironment('GATEWAY_BASE_URL');
    const aiServiceOverride = String.fromEnvironment('AI_SERVICE_BASE_URL');
    const aiServiceAuthToken = String.fromEnvironment('AI_SERVICE_AUTH_TOKEN');

    return AppEnvironment(
      gatewayBaseUrl: _normalizeBaseUrl(
        gatewayOverride.isNotEmpty
            ? gatewayOverride
            : _defaultBaseUrlForPort(_defaultGatewayPort),
      ),
      aiServiceBaseUrl: _normalizeBaseUrl(
        aiServiceOverride.isNotEmpty
            ? aiServiceOverride
            : _defaultBaseUrlForPort(_defaultAiServicePort),
      ),
      aiServiceAuthToken: aiServiceAuthToken.trim(),
    );
  }

  Uri resolve(String path) {
    return Uri.parse(gatewayBaseUrl).resolve(path);
  }

  Uri resolveAiService(String path) {
    return Uri.parse(aiServiceBaseUrl).resolve(path);
  }

  static String _defaultBaseUrlForPort(String port) {
    if (kIsWeb) {
      return 'http://localhost:$port';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:$port';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:$port';
    }
  }

  static String _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
