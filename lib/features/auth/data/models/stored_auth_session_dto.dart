import '../../domain/entities/auth_session.dart';
import 'auth_user_dto.dart';

class StoredAuthSessionDto {
  const StoredAuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUserDto? user;

  bool get hasTokens {
    return accessToken.trim().isNotEmpty && refreshToken.trim().isNotEmpty;
  }

  AuthSession? toDomain() {
    if (!hasTokens || user == null) {
      return null;
    }

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user!.toDomain(),
    );
  }

  StoredAuthSessionDto copyWith({
    String? accessToken,
    String? refreshToken,
    AuthUserDto? user,
  }) {
    return StoredAuthSessionDto(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
    };
  }

  factory StoredAuthSessionDto.fromJson(Map<String, dynamic> json) {
    return StoredAuthSessionDto(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      user: json['user'] is Map<String, dynamic>
          ? AuthUserDto.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
