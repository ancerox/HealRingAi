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

  Future<String> get userName async => await get<String>('user_name') ?? '';
  Future<void> setUserName(String value) async =>
      await _prefs.setString('user_name', value);

  Future<String> get userSex async => await get<String>('user_sex') ?? '';
  Future<void> setUserSex(String value) async =>
      await _prefs.setString('user_sex', value);

  Future<String> get userBirthDate async =>
      await get<String>('user_birth_date') ?? '';
  Future<void> setUserBirthDate(String value) async =>
      await _prefs.setString('user_birth_date', value);

  Future<int> get userHeight async => await get<int>('user_height') ?? 0;
  Future<void> setUserHeight(int value) async =>
      await _prefs.setInt('user_height', value);

  Future<String> get userWeight async => await get<String>('user_weight') ?? '';
  Future<void> setUserWeight(String value) async =>
      await _prefs.setString('user_weight', value);

  Future<bool> get usesMetricSystem async =>
      await get<bool>('uses_metric_system') ?? false;
  Future<void> setUsesMetricSystem(bool value) async =>
      await _prefs.setBool('uses_metric_system', value);
  Future<int> get userEmojiIndex async =>
      await get<int>('user_emoji_index') ?? 0;
  Future<void> setUserEmojiIndex(int value) async =>
      await _prefs.setInt('user_emoji_index', value);
}
