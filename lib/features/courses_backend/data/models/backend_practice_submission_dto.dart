class BackendPracticeSubmissionDto {
  const BackendPracticeSubmissionDto({
    required this.id,
    required this.practiceId,
    required this.studentId,
    required this.courseId,
    required this.lessonId,
    required this.status,
    required this.code,
    required this.language,
    required this.output,
    required this.error,
    required this.errorType,
    required this.exitCode,
    required this.durationMs,
    required this.teacherComment,
    required this.reviewedBy,
    required this.reviewedAt,
    required this.attemptNumber,
    required this.practiceTitle,
    required this.studentEmail,
    required this.courseTitle,
    required this.lessonTitle,
    required this.progressStatus,
    required this.progressStartedAt,
    required this.progressCompletedAt,
    required this.progressLastAttemptAt,
    required this.progressAttemptsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String practiceId;
  final String studentId;
  final String courseId;
  final String lessonId;

  /// One of: submitted, in_review, changes_requested, approved
  final String status;
  final String code;
  final String language;
  final String output;
  final String error;
  final String errorType;
  final int? exitCode;
  final int? durationMs;
  final String teacherComment;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final int attemptNumber;
  final String practiceTitle;
  final String studentEmail;
  final String courseTitle;
  final String lessonTitle;
  final String progressStatus;
  final DateTime? progressStartedAt;
  final DateTime? progressCompletedAt;
  final DateTime? progressLastAttemptAt;
  final int progressAttemptsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'submitted' || status == 'in_review';
  bool get needsChanges => status == 'changes_requested';

  factory BackendPracticeSubmissionDto.fromJson(Map<String, dynamic> json) {
    return BackendPracticeSubmissionDto(
      id: '${json['id'] ?? ''}',
      practiceId: '${json['practice_id'] ?? ''}',
      studentId: '${json['student_id'] ?? ''}',
      courseId: '${json['course_id'] ?? ''}',
      lessonId: '${json['lesson_id'] ?? ''}',
      status: '${json['status'] ?? 'submitted'}',
      code: '${json['code'] ?? ''}',
      language: '${json['language'] ?? ''}',
      output: '${json['output'] ?? ''}',
      error: '${json['error'] ?? ''}',
      errorType: '${json['error_type'] ?? ''}',
      exitCode: (json['exit_code'] as num?)?.round(),
      durationMs: (json['duration_ms'] as num?)?.round(),
      teacherComment: '${json['teacher_comment'] ?? ''}',
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: DateTime.tryParse('${json['reviewed_at'] ?? ''}'),
      attemptNumber: (json['attempt_number'] as num?)?.round() ?? 1,
      practiceTitle: '${json['practice_title'] ?? ''}',
      studentEmail: '${json['student_email'] ?? ''}',
      courseTitle: '${json['course_title'] ?? ''}',
      lessonTitle: '${json['lesson_title'] ?? ''}',
      progressStatus: '${json['progress_status'] ?? ''}',
      progressStartedAt: DateTime.tryParse('${json['progress_started_at'] ?? ''}'),
      progressCompletedAt: DateTime.tryParse('${json['progress_completed_at'] ?? ''}'),
      progressLastAttemptAt: DateTime.tryParse('${json['progress_last_attempt_at'] ?? ''}'),
      progressAttemptsCount: (json['progress_attempts_count'] as num?)?.round() ?? 0,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class BackendCreatePracticeSubmissionRequest {
  const BackendCreatePracticeSubmissionRequest({
    required this.code,
    required this.language,
    this.output = '',
    this.error = '',
    this.errorType = '',
    this.exitCode,
    this.durationMs,
  });

  final String code;
  final String language;
  final String output;
  final String error;
  final String errorType;
  final int? exitCode;
  final int? durationMs;

  Map<String, dynamic> toJson() => {
    'code': code,
    'language': language,
    'output': output,
    'error': error,
    'error_type': errorType,
    if (exitCode != null) 'exit_code': exitCode,
    if (durationMs != null) 'duration_ms': durationMs,
  };
}

class BackendReviewPracticeSubmissionRequest {
  const BackendReviewPracticeSubmissionRequest({
    required this.status,
    this.comment = '',
  });

  /// One of: approved, changes_requested, in_review
  final String status;
  final String comment;

  Map<String, dynamic> toJson() => {'status': status, 'comment': comment};
}
