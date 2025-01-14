import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  final SharedPreferences _prefs;

  const PreferencesRepository(this._prefs);

  // Generic methods for basic operations
  Future<T?> get<T>(String key) async => _prefs.get(key) as T?;

  Future<bool> set<T>(String key, T value) async {
    switch (T) {
      case String:
        return await _prefs.setString(key, value as String);
      case int:
        return await _prefs.setInt(key, value as int);
      case bool:
        return await _prefs.setBool(key, value as bool);
      case double:
        return await _prefs.setDouble(key, value as double);
      default:
        throw UnimplementedError('Type ${T.toString()} not supported');
    }
  }

  // Business-specific methods
  Future<bool> get isFirstLaunch async =>
      await get<bool>('is_first_launch') ?? true;

  Future<void> setFirstLaunch(bool value) async =>
      await set('is_first_launch', value);

  Future<String?> get authToken async => await get<String>('auth_token');

  Future<bool> get isUserConnected async =>
      await get<bool>('is_user_connected') ?? false;

  Future<void> setUserConnected(bool value) async =>
      await set('is_user_connected', value);

  // ... other specific methods
}
