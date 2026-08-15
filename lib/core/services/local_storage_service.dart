import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences preferences;

  const LocalStorageService({required this.preferences});

  Future<void> saveString(String key, String value) async {
    await preferences.setString(key, value);
  }

  String? getString(String key) {
    return preferences.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await preferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return preferences.getBool(key);
  }

  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await preferences.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final value = preferences.getString(key);

    if (value == null) {
      return null;
    }

    return jsonDecode(value) as Map<String, dynamic>;
  }

  Future<void> remove(String key) async {
    await preferences.remove(key);
  }

  Future<void> clear() async {
    await preferences.clear();
  }
}
