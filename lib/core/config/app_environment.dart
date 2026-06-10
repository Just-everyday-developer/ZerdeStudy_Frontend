import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  return AppEnvironment.fromPlatform();
});

class AppEnvironment {
  const AppEnvironment({
    required this.gatewayBaseUrl,
    required this.codeRunnerBaseUrl,
    required this.aiServiceBaseUrl,
    this.codeRunnerViaGateway = false,
    this.aiServiceViaGateway = false,
    this.aiServiceAuthToken = '',
  });

  static const String _deployedGatewayUrl = 'http://159.89.11.22:8090';

  final String gatewayBaseUrl;
  final String codeRunnerBaseUrl;
  final String aiServiceBaseUrl;
  final bool codeRunnerViaGateway;
  final bool aiServiceViaGateway;
  final String aiServiceAuthToken;

  factory AppEnvironment.fromPlatform() {
    const gatewayOverride = String.fromEnvironment('GATEWAY_BASE_URL');
    const codeRunnerOverride = String.fromEnvironment('CODE_RUNNER_BASE_URL');
    const aiServiceOverride = String.fromEnvironment('AI_SERVICE_BASE_URL');
    const aiServiceAuthToken = String.fromEnvironment('AI_SERVICE_AUTH_TOKEN');

    final gatewayBaseUrl = _normalizeBaseUrl(
      gatewayOverride.isNotEmpty ? gatewayOverride : _deployedGatewayUrl,
    );

    return AppEnvironment(
      gatewayBaseUrl: gatewayBaseUrl,
      codeRunnerBaseUrl: _normalizeBaseUrl(
        codeRunnerOverride.isNotEmpty ? codeRunnerOverride : gatewayBaseUrl,
      ),
      codeRunnerViaGateway: codeRunnerOverride.isEmpty,
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
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    if (codeRunnerViaGateway) {
      return Uri.parse(
        gatewayBaseUrl,
      ).resolve('/api/v1/code-runner$normalizedPath');
    }
    return Uri.parse(codeRunnerBaseUrl).resolve(normalizedPath);
  }

  static String _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
