import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class DataHelper {
  Future<bool> saveData(String key, dynamic value);
  dynamic getData(String key);
  Future<bool> removeData(String key);
}

class SharedPreferencesHelper implements DataHelper {
  final SharedPreferences _prefs;
  SharedPreferencesHelper(this._prefs);

  @override
  Future<bool> saveData(String key, dynamic value) async {
    if (value is String) return await _prefs.setString(key, value);
    if (value is int) return await _prefs.setInt(key, value);
    if (value is double) return await _prefs.setDouble(key, value);
    if (value is bool) return await _prefs.setBool(key, value);
    if (value is List<String>) return await _prefs.setStringList(key, value);

    // لو كانت الداتا عبارة عن Map/Model بنحولها لـ JSON String
    return await _prefs.setString(key, json.encode(value));
  }

  @override
  dynamic getData(String key) {
    return _prefs.get(key);
  }

  @override
  Future<bool> removeData(String key) async {
    return await _prefs.remove(key);
  }

  // سينيور ميثودز للتحويل السريع اللي كنت كاتبهم (fromJSON / toJSON)
  static T fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonModel,
  ) {
    return fromJsonModel(json);
  }

  static Map<String, dynamic> toJson(dynamic model) {
    return model.toJson();
  }
}
