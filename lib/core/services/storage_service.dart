import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  static const String _firstTimeUserKey = 'isFirstTimeUser';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _legacyAuthTokenKey = 'authToken';
  static const String _appLocaleKey = 'appLocale';

  bool get isFirstTimeUser => _prefs.getBool(_firstTimeUserKey) ?? true;

  Future<void> setFirstTimeUser(bool value) async {
    await _prefs.setBool(_firstTimeUserKey, value);
  }

  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;

  Future<void> setLoggedInData([String? _]) async {
    await _prefs.setBool(_isLoggedInKey, true);
    await _prefs.remove(_legacyAuthTokenKey);
  }

  Future<void> clearLoggedInData() async {
    await _prefs.setBool(_isLoggedInKey, false);
    await _prefs.remove(_legacyAuthTokenKey);
  }

  String? get savedAppLocale => _prefs.getString(_appLocaleKey);

  Future<void> saveAppLocale(String localeLabel) async {
    await _prefs.setString(_appLocaleKey, localeLabel);
  }

  Future<void> clearAppLocale() async {
    await _prefs.remove(_appLocaleKey);
  }


  String? readString(String key) {
    return _prefs.getString(key);
  }

  Future<void> writeString(String key, String value) async {
    await _prefs.setString(key, value);
  }
}
