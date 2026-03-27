import '../../../../core/network/json_http_client.dart';
import '../models/auth_tokens_dto.dart';
import '../models/auth_user_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final JsonHttpClient _client;

  Future<AuthTokensDto> register({
    required String email,
    required String password,
  }) async {
    final json = await _client.postJson(
      '/api/v1/auth/register',
      body: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );
    return AuthTokensDto.fromJson(json);
  }

  Future<AuthTokensDto> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.postJson(
      '/api/v1/auth/login',
      body: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );
    return AuthTokensDto.fromJson(json);
  }

  Future<AuthTokensDto> refresh({
    required String refreshToken,
  }) async {
    final json = await _client.postJson(
      '/api/v1/auth/refresh',
      body: <String, dynamic>{
        'refresh_token': refreshToken,
      },
    );
    return AuthTokensDto.fromJson(json);
  }

  Future<void> logout({
    required String refreshToken,
  }) {
    return _client.postEmpty(
      '/api/v1/auth/logout',
      body: <String, dynamic>{
        'refresh_token': refreshToken,
      },
    );
  }

  Future<AuthUserDto> me({
    required String accessToken,
  }) async {
    final json = await _client.getJson(
      '/api/v1/auth/me',
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );
    return AuthUserDto.fromJson(json);
  }
}
