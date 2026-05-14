import 'package:flutter/foundation.dart';

@immutable
class CodeExecutionRequest {
  const CodeExecutionRequest({
    required this.language,
    required this.code,
    this.stdin = '',
    this.timeoutMs = 5000,
  });

  final String language;
  final String code;
  final String stdin;
  final int timeoutMs;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'language': language,
    'code': code,
    'stdin': stdin,
    'timeoutMs': timeoutMs,
  };
}

@immutable
class CodeExecutionResult {
  const CodeExecutionResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
    this.error = '',
    this.executionTimeMs = 0,
    this.passed = false,
  });

  final String stdout;
  final String stderr;
  final int exitCode;
  final String error;
  final int executionTimeMs;
  final bool passed;

  bool get isSuccess => passed && error.isEmpty;

  factory CodeExecutionResult.fromJson(Map<String, dynamic> json) {
    return CodeExecutionResult(
      stdout: json['output'] as String? ?? '',
      stderr: '', // Microservice combines stderr into error or output
      exitCode: (json['passed'] as bool? ?? false) ? 0 : 1,
      error: json['error'] as String? ?? '',
      passed: json['passed'] as bool? ?? false,
    );
  }

  factory CodeExecutionResult.clientError(String message) {
    return CodeExecutionResult(
      stdout: '',
      stderr: '',
      exitCode: -1,
      error: message,
    );
  }
}
