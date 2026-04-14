import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Initialize your storage service here (e.g., SharedPreferences, Hive, etc.)
    return this;
  }

  bool get isFirstTimeUser => _prefs.getBool('isFirstTimeUser') ?? true;
  Future<void> setFirstTimeUser(bool value) async {
    await _prefs.setBool('isFirstTimeUser', value);
  }

  bool get isLoggedIn => _prefs.getBool('isLoggedIn') ?? false;
  Future<void> setLoggedInData(String token) async {
    await _prefs.setBool('isLoggedIn', true);
    await _prefs.setString('authToken', token);
  }

  Future<void> clearLoggedInData() async {
    await _prefs.setBool('isLoggedIn', false);
    await _prefs.remove('authToken');
  }
}