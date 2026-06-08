/// Mirrors curriculum-service's `codeattempt.RunResponse` — the authoritative
/// result of running/submitting code for a practice task via
/// `POST /api/v1/practice/:id/run`.
class BackendCodeAttemptResultDto {
  const BackendCodeAttemptResultDto({
    required this.attemptId,
    required this.output,
    required this.error,
    required this.passed,
    required this.errorType,
    required this.durationMs,
    required this.xpAwarded,
  });

  final String attemptId;
  final String output;
  final String error;
  final bool passed;
  final String errorType;
  final int durationMs;
  final int xpAwarded;

  factory BackendCodeAttemptResultDto.fromJson(Map<String, dynamic> json) {
    return BackendCodeAttemptResultDto(
      attemptId: '${json['attempt_id'] ?? ''}',
      output: json['output'] as String? ?? '',
      error: json['error'] as String? ?? '',
      passed: json['passed'] as bool? ?? false,
      errorType: json['error_type'] as String? ?? '',
      durationMs: (json['duration_ms'] as num?)?.round() ?? 0,
      xpAwarded: (json['xp_awarded'] as num?)?.round() ?? 0,
    );
  }
}
