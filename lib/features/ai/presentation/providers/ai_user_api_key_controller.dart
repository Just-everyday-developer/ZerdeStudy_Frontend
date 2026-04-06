import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/state/demo_app_controller.dart';

final aiUserApiKeyProvider = NotifierProvider<AiUserApiKeyController, String?>(
  AiUserApiKeyController.new,
);

class AiUserApiKeyController extends Notifier<String?> {
  static const _storageKey = 'zerdestudy_ai_user_api_key_v1';

  late final SharedPreferences _preferences;

  @override
  String? build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return _normalize(_preferences.getString(_storageKey));
  }

  Future<void> saveKey(String rawValue) async {
    final normalized = _normalize(rawValue);
    if (normalized == null) {
      await clearKey();
      return;
    }

    state = normalized;
    unawaited(_preferences.setString(_storageKey, normalized));
  }

  Future<void> clearKey() async {
    state = null;
    unawaited(_preferences.remove(_storageKey));
  }

  String? _normalize(String? rawValue) {
    final trimmed = rawValue?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
