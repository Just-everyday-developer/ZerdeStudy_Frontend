import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_environment.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/models/code_execution.dart';

final codeRunnerServiceProvider = Provider<CodeRunnerService>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final accessToken =
      ref
          .watch(
            authControllerProvider.select(
              (state) => state.session?.accessToken,
            ),
          )
          ?.trim() ??
      '';
  return CodeRunnerService(
    uriResolver: environment.resolveCodeRunner,
    authToken: accessToken,
  );
});

class CodeRunnerService {
  CodeRunnerService({
    required Uri Function(String path) uriResolver,
    required String authToken,
  }) : _uriResolver = uriResolver,
       _authToken = authToken;

  final Uri Function(String path) _uriResolver;
  final String _authToken;

  /// Runs the provided code using the microservice
  Future<CodeExecutionResult> runCode(CodeExecutionRequest request) async {
    // Basic client-side security validation
    final securityError = _validateSecurity(request);
    if (securityError != null) {
      return CodeExecutionResult.clientError(securityError);
    }

    try {
      final response = await http
          .post(
            _uriResolver('/run'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              if (_authToken.isNotEmpty) 'Authorization': 'Bearer $_authToken',
            },
            body: jsonEncode({
              'language': request.language,
              'code': request.code,
            }),
          )
          .timeout(Duration(milliseconds: request.timeoutMs + 1000));

      if (response.statusCode == 200) {
        return CodeExecutionResult.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        return CodeExecutionResult.clientError(
          'Server returned error: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      return CodeExecutionResult.clientError('Connection failed: $e');
    }
  }

  /// Basic security checks to prevent obviously malicious code from being sent
  String? _validateSecurity(CodeExecutionRequest request) {
    final code = request.code;

    if (request.language == 'java') {
      final maliciousPatterns = [
        'System.exit',
        'Runtime.getRuntime',
        'ProcessBuilder',
        'java.io.File',
        'java.net.',
        'ClassLoader',
      ];

      for (final pattern in maliciousPatterns) {
        if (code.contains(pattern)) {
          return 'Security Violation: Usage of "$pattern" is not allowed in this environment.';
        }
      }
    }

    if (code.length > 50000) {
      return 'Code is too large (max 50KB)';
    }

    return null;
  }
}
