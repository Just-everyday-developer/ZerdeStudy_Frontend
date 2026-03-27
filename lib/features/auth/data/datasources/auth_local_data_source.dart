import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/stored_auth_session_dto.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._preferences);

  static const String storageKey = 'zerdestudy_auth_session_v1';

  final SharedPreferences _preferences;

  StoredAuthSessionDto? readSession() {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return StoredAuthSessionDto.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> saveSession(StoredAuthSessionDto session) async {
    await _preferences.setString(storageKey, jsonEncode(session.toJson()));
  }

  Future<void> clearSession() async {
    await _preferences.remove(storageKey);
  }
}
