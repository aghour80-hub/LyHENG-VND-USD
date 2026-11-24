import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Supported Locales in LyHENG VND-USD:
/// 1. Vietnamese (vi) - Default
/// 2. Khmer (km)
/// 3. English (en)
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  static const List<Locale> supportedLocales = [
    Locale(AppConstants.localeVietnamese),
    Locale(AppConstants.localeKhmer),
    Locale(AppConstants.localeEnglish),
  ];

  @override
  Locale build() {
    _loadSavedLocale();
    return const Locale(AppConstants.localeVietnamese);
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(AppConstants.keySelectedLocale);
      if (savedCode != null) {
        final matched = supportedLocales.firstWhere(
          (loc) => loc.languageCode == savedCode,
          orElse: () => const Locale(AppConstants.localeVietnamese),
        );
        state = matched;
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!supportedLocales.contains(newLocale)) return;
    state = newLocale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keySelectedLocale, newLocale.languageCode);
    } catch (_) {}
  }
}

/// Theme Mode Provider (Light, Dark, System)
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(AppConstants.keyThemeMode);
      if (modeString == 'light') {
        state = ThemeMode.light;
      } else if (modeString == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyThemeMode, mode.name);
    } catch (_) {}
  }
}
