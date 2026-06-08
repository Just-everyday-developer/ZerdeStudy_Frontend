/// Mirrors notification-service's `dto.NotificationResponse` /
/// `dto.ListResponse` — returned by `GET /api/v1/notifications` and friends.
/// Unlike the curriculum-service DTOs, this service emits camelCase JSON keys.
class BackendNotificationDto {
  const BackendNotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.isRead,
    required this.metadata,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic> metadata;

  factory BackendNotificationDto.fromJson(Map<String, dynamic> json) {
    return BackendNotificationDto(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      body: '${json['body'] ?? ''}',
      type: '${json['type'] ?? ''}',
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isRead: json['isRead'] as bool? ?? false,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }

  BackendNotificationDto copyWith({bool? isRead}) {
    return BackendNotificationDto(
      id: id,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata,
    );
  }
}

class BackendNotificationListDto {
  const BackendNotificationListDto({
    required this.items,
    required this.unreadCount,
    required this.total,
  });

  final List<BackendNotificationDto> items;
  final int unreadCount;
  final int total;

  factory BackendNotificationListDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const <dynamic>[];
    return BackendNotificationListDto(
      items: rawItems
          .whereType<Map>()
          .map((item) => BackendNotificationDto.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      unreadCount: (json['unreadCount'] as num?)?.round() ?? 0,
      total: (json['total'] as num?)?.round() ?? 0,
    );
  }
}
