class BackendModuleDto {
  const BackendModuleDto({
    required this.id,
    required this.courseId,
    required this.title,
    required this.summary,
    required this.locale,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String courseId;
  final String title;
  final String summary;
  final String locale;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BackendModuleDto.fromJson(Map<String, dynamic> json) {
    return BackendModuleDto(
      id: '${json['id'] ?? ''}',
      courseId: '${json['course_id'] ?? ''}',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      locale: json['locale'] as String? ?? '',
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse('${json['updated_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
