import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  
  static String? getUserId() {
    return _prefs?.getString('userId');
  }

  static Future<void> setUserId(String userId) async {
    await _prefs?.setString('userId', userId);
  }

  static String? getUsername() {
    return _prefs?.getString('username');
  }

  static Future<void> setUsername(String username) async {
    await _prefs?.setString('username', username);
  }

 
  static String? getAuthToken() {
    return _prefs?.getString('authToken');
  }

  static Future<void> setAuthToken(String token) async {
    await _prefs?.setString('authToken', token);
  }


  static bool isLoggedIn() {
    return getUserId() != null && getUsername() != null;
  }


  static String getServerUrl() {
    return _prefs?.getString('serverUrl') ?? 'http://IPv4address:PORT';
  }

  static Future<void> setServerUrl(String url) async {
    await _prefs?.setString('serverUrl', url);
  }

 
  static String? getLastRoomId() {
    return _prefs?.getString('lastRoomId');
  }

  static Future<void> setLastRoomId(String roomId) async {
    await _prefs?.setString('lastRoomId', roomId);
  }

  static Future<void> clearAuth() async {
    await _prefs?.remove('userId');
    await _prefs?.remove('username');
    await _prefs?.remove('authToken');
  }


  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}