class OrderRequest {
  OrderRequest({
    required this.userId,
    required this.courseId,
    required this.amount,
    required this.currency,
  });

  final String userId;
  final String courseId;
  final int amount;
  final String currency;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'user_id': userId,
    'course_id': courseId,
    'amount': amount,
    'currency': currency,
  };
}

class OrderResponse {
  OrderResponse({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final statusValue = json['status'];

    return OrderResponse(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      courseId: json['course_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? '',
      status: _statusCode(statusValue),
    );
  }

  final String id;
  final String userId;
  final String courseId;
  final int amount;
  final String currency;
  final String status;
}

class CoursePriceResponse {
  CoursePriceResponse({
    required this.id,
    required this.courseId,
    required this.amount,
    required this.currency,
  });

  factory CoursePriceResponse.fromJson(Map<String, dynamic> json) {
    return CoursePriceResponse(
      id: json['id'] as String? ?? '',
      courseId: json['course_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? '',
    );
  }

  final String id;
  final String courseId;
  final int amount;
  final String currency;
}

String _statusCode(Object? value) {
  if (value is String) {
    return value;
  }
  if (value is Map<String, dynamic>) {
    final code = value['code'] ?? value['Code'];
    if (code is String) {
      return code;
    }
    final name = value['name'] ?? value['Name'];
    if (name is String) {
      return name;
    }
  }
  return '';
}
