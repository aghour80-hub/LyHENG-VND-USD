import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('PreferencesService must be initialized before use.');
    }
    return _prefs!;
  }

  static Future<void> setLastSyncTimestamp(DateTime dt) async {
    await prefs.setString(AppConstants.keyCachedRateTimestamp, dt.toIso8601String());
  }

  static DateTime? getLastSyncTimestamp() {
    final str = prefs.getString(AppConstants.keyCachedRateTimestamp);
    if (str != null && str.isNotEmpty) {
      try {
        return DateTime.parse(str);
      } catch (_) {}
    }
    return null;
  }
}
