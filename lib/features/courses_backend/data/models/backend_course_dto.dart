class BackendDictionaryEntryDto {
  const BackendDictionaryEntryDto({
    required this.id,
    required this.name,
    required this.code,
  });

  final String id;
  final String name;
  final String code;

  factory BackendDictionaryEntryDto.fromJson(Map<String, dynamic> json) {
    return BackendDictionaryEntryDto(
      id: '${json['id'] ?? ''}',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

class BackendCourseTagDto {
  const BackendCourseTagDto({
    required this.id,
    required this.name,
    required this.code,
  });

  final String id;
  final String name;
  final String code;

  factory BackendCourseTagDto.fromJson(Map<String, dynamic> json) {
    return BackendCourseTagDto(
      id: '${json['id'] ?? ''}',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

class BackendCourseAuthorRoleDto {
  const BackendCourseAuthorRoleDto({
    required this.id,
    required this.code,
    required this.name,
  });

  final String id;
  final String code;
  final String name;

  factory BackendCourseAuthorRoleDto.fromJson(Map<String, dynamic> json) {
    return BackendCourseAuthorRoleDto(
      id: '${json['id'] ?? ''}',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class BackendCourseAuthorDto {
  const BackendCourseAuthorDto({
    required this.id,
    required this.email,
    required this.roles,
    required this.isActive,
  });

  final String id;
  final String email;
  final List<BackendCourseAuthorRoleDto> roles;
  final bool isActive;

  factory BackendCourseAuthorDto.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'] as List<dynamic>? ?? const <dynamic>[];

    return BackendCourseAuthorDto(
      id: '${json['id'] ?? ''}',
      email: json['email'] as String? ?? '',
      roles: rawRoles
          .whereType<Map>()
          .map(
            (item) => BackendCourseAuthorRoleDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}

class BackendCourseDto {
  const BackendCourseDto({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.expectedHours,
    required this.rating,
    required this.ratingCount,
    required this.studentsCount,
    required this.lessonsCount,
    required this.hasCertificate,
    required this.coverImageUrl,
    required this.status,
    required this.level,
    required this.durationCategory,
    required this.author,
    required this.tags,
    required this.topic,
    required this.learningOutcomes,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int expectedHours;
  final double rating;
  final int ratingCount;
  final int studentsCount;
  final int lessonsCount;
  final bool hasCertificate;
  final String coverImageUrl;
  final BackendDictionaryEntryDto status;
  final BackendDictionaryEntryDto level;
  final BackendDictionaryEntryDto durationCategory;
  final BackendCourseAuthorDto author;
  final List<BackendCourseTagDto> tags;
  final BackendDictionaryEntryDto? topic;
  final List<String> learningOutcomes;
  final DateTime publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BackendCourseDto.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'] as List<dynamic>? ?? const <dynamic>[];
    final rawOutcomes =
        json['learning_outcome'] as List<dynamic>? ?? const <dynamic>[];

    return BackendCourseDto(
      id: '${json['id'] ?? ''}',
      title: json['title'] as String? ?? '',
      subtitle: json['sub_title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      expectedHours: (json['expected_hours'] as num?)?.round() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.round() ?? 0,
      studentsCount: (json['students_count'] as num?)?.round() ?? 0,
      lessonsCount: (json['lessons_count'] as num?)?.round() ?? 0,
      hasCertificate: json['has_certificate'] as bool? ?? false,
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      status: BackendDictionaryEntryDto.fromJson(
        Map<String, dynamic>.from(
          json['status'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      level: BackendDictionaryEntryDto.fromJson(
        Map<String, dynamic>.from(
          json['level'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      durationCategory: BackendDictionaryEntryDto.fromJson(
        Map<String, dynamic>.from(
          json['duration_category'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      author: BackendCourseAuthorDto.fromJson(
        Map<String, dynamic>.from(
          json['author'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      tags: rawTags
          .whereType<Map>()
          .map(
            (item) =>
                BackendCourseTagDto.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      topic: json['topic'] is Map
          ? BackendDictionaryEntryDto.fromJson(
              Map<String, dynamic>.from(json['topic'] as Map),
            )
          : null,
      learningOutcomes: rawOutcomes
          .map((item) => '$item'.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      publishedAt:
          DateTime.tryParse('${json['published_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse('${json['updated_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
