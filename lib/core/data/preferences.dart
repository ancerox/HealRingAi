import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  final SharedPreferences _prefs;

  const PreferencesRepository(this._prefs);

  // Generic methods for basic operations
  Future<T?> get<T>(String key) async {
    if (T == bool) {
      return _prefs.getBool(key) as T?;
    } else if (T == String) {
      return _prefs.getString(key) as T?;
    } else if (T == int) {
      return _prefs.getInt(key) as T?;
    } else if (T == double) {
      return _prefs.getDouble(key) as T?;
    }
    return null;
  }

  // Business-specific methods
  Future<bool> get isFirstLaunch async =>
      await get<bool>('is_first_launch') ?? true;

  Future<void> setFirstLaunch(bool value) async =>
      await _prefs.setBool('is_first_launch', value);

  Future<String?> get authToken async => await get<String>('auth_token');

  Future<bool> get isUserConnected async =>
      await get<bool>('is_user_connected') ?? false;

  Future<void> setUserConnected(bool value) async =>
      await _prefs.setBool('is_user_connected', value);
}
