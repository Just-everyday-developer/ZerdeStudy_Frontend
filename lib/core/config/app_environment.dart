import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  return AppEnvironment.fromPlatform();
});

class AppEnvironment {
  const AppEnvironment({
    required this.gatewayBaseUrl,
    required this.codeRunnerBaseUrl,
    required this.aiServiceBaseUrl,
    this.aiServiceViaGateway = false,
    this.aiServiceAuthToken = '',
  });

  static const String _defaultGatewayPort = '8090';
  static const String _defaultCodeRunnerPort = '8091';

  final String gatewayBaseUrl;
  final String codeRunnerBaseUrl;
  final String aiServiceBaseUrl;
  final bool aiServiceViaGateway;
  final String aiServiceAuthToken;

  factory AppEnvironment.fromPlatform() {
    const gatewayOverride = String.fromEnvironment('GATEWAY_BASE_URL');
    const codeRunnerOverride = String.fromEnvironment('CODE_RUNNER_BASE_URL');
    const aiServiceOverride = String.fromEnvironment('AI_SERVICE_BASE_URL');
    const aiServiceAuthToken = String.fromEnvironment('AI_SERVICE_AUTH_TOKEN');

    final gatewayBaseUrl = _normalizeBaseUrl(
      gatewayOverride.isNotEmpty
          ? gatewayOverride
          : _defaultBaseUrlForPort(_defaultGatewayPort),
    );

    return AppEnvironment(
      gatewayBaseUrl: gatewayBaseUrl,
      codeRunnerBaseUrl: _normalizeBaseUrl(
        codeRunnerOverride.isNotEmpty
            ? codeRunnerOverride
            : _sameHostWithPort(gatewayBaseUrl, _defaultCodeRunnerPort),
      ),
      aiServiceBaseUrl: _normalizeBaseUrl(
        aiServiceOverride.isNotEmpty ? aiServiceOverride : gatewayBaseUrl,
      ),
      aiServiceViaGateway: aiServiceOverride.isEmpty,
      aiServiceAuthToken: aiServiceAuthToken.trim(),
    );
  }

  Uri resolve(String path) {
    return Uri.parse(gatewayBaseUrl).resolve(path);
  }

  Uri resolveAiService(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    if (aiServiceViaGateway) {
      final gatewayPath = normalizedPath.startsWith('/v1/')
          ? normalizedPath.substring('/v1'.length)
          : normalizedPath;
      return Uri.parse(gatewayBaseUrl).resolve('/api/v1/ai$gatewayPath');
    }
    return Uri.parse(aiServiceBaseUrl).resolve(normalizedPath);
  }

  Uri resolveCodeRunner(String path) {
    return Uri.parse(codeRunnerBaseUrl).resolve(path);
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

  static String _sameHostWithPort(String baseUrl, String port) {
    final uri = Uri.tryParse(baseUrl);
    final parsedPort = int.tryParse(port);
    if (uri == null ||
        parsedPort == null ||
        uri.scheme.isEmpty ||
        uri.host.isEmpty) {
      return _defaultBaseUrlForPort(port);
    }

    return Uri(scheme: uri.scheme, host: uri.host, port: parsedPort).toString();
  }
}
