// lib/core/theme/cubit/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/data_helper.dart';

/// Cubit مسؤول عن حالة الثيم الحالية (System / Light / Dark) وحفظها محليًا
/// عشان تفضل ثابتة بعد إغلاق التطبيق وإعادة فتحه
class ThemeCubit extends Cubit<ThemeMode> {
  final DataHelper _dataHelper;
  static const String _themeKey = 'app_theme_mode';

  ThemeCubit({required DataHelper dataHelper})
    : _dataHelper = dataHelper,
      super(ThemeMode.system) {
    _loadSavedTheme();
  }

  // تحميل الاختيار المحفوظ عند بدء التطبيق (لو موجود)، وإلا نفضل على System
  void _loadSavedTheme() {
    final savedValue = _dataHelper.getData(_themeKey);
    if (savedValue is String) {
      emit(_mapStringToThemeMode(savedValue));
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await _dataHelper.saveData(_themeKey, _mapThemeModeToString(mode));
  }

  String _mapThemeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _mapStringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
