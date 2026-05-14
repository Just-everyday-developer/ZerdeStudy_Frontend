import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/code_execution.dart';

final codeRunnerServiceProvider = Provider<CodeRunnerService>((ref) {
  return CodeRunnerService();
});

class CodeRunnerService {
  // Base URL for the code-runner microservice (Docker container)
  static const String _baseUrl = 'http://localhost:8091';

  /// Runs the provided code using the microservice
  Future<CodeExecutionResult> runCode(CodeExecutionRequest request) async {
    // Basic client-side security validation
    final securityError = _validateSecurity(request);
    if (securityError != null) {
      return CodeExecutionResult.clientError(securityError);
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/run'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'language': request.language,
          'code': request.code,
        }),
      ).timeout(Duration(milliseconds: request.timeoutMs + 1000));

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
