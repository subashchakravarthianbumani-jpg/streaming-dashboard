import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_dashboard/features/views/login/model/login_model.dart';

class SharedPreferenceService {
  static SharedPreferenceService? _instance;
  static SharedPreferences? _preferences;

  //Private Constructor
  SharedPreferenceService._internal();

  //Singleton pattern
  static Future<SharedPreferenceService> getInstance() async {
    _instance ??= SharedPreferenceService._internal();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  //Keys for storing data
  static const String _keyIsLoggedIn = 'is_logged_in';

  static const String _keyPrivileges = 'privileges';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'userId';

  static const String _keyRememberMe = 'remember_me';
  static const String _keyUserName = 'saved_username';
  static const String _keyPassword = 'saved_password';

  // ==================== Login Status ====================
  //Save Login status
  Future<bool> saveLoginStatus(bool isLoggedIn) async {
    return await _preferences!.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  //Get Login status
  bool getLoginStatus() {
    return _preferences!.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<bool> saveUserDataToPreferences(Data userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('accessToken', userData.accessToken ?? '');
      await prefs.setString('refreshToken', userData.refreshToken ?? '');
      await prefs.setString('userId', userData.userId ?? '');
      await prefs.setString('userName', userData.userName ?? '');
      await prefs.setString('email', userData.email ?? '');
      await prefs.setString('firstName', userData.firstName ?? '');
      await prefs.setString('lastName', userData.lastName ?? '');
      await prefs.setBool(_keyIsLoggedIn, true);

      /*Bearer eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9lbWFpbGFkZHJlc3MiOiJBZG1pbkB0ZXN0bWFpbC5jb20iLCJVc2VySUQiOiIyMDU5NGFlNy00YThjLTExZWUtYjgxOC0wMDA5MGZmZTAwMDEiLCJMb2dpbklEIjoiM2FjODNhNzMtNGE4Yy0xMWVlLWI4MTgtMDAwOTBmZmUwMDAxIiwiTmFtZSI6IkFkbWluIEFkbWluIiwiUm9sZUlkIjoiZjE2ODJiNTUtZWZlMC1hMWNkLTA2OGYtZGJhYWViNWM3MGFkIiwiRGl2aXNpb25JZCI6IjdiYjZkYmM0LTU3ODEtNDhiNS04YzZlLTU1MjA2ODBjZGU5MSwxYjEzMWQyZS1kMTAwLTQxMzYtYWQzYy0xMGM4NGU0NzliZDIsOGZhZDJkNmEtNDUxZi00ZTc2LTk4NTgtOTRiMDc3NjY4ZjNjLDUyNjczY2YxLTI0ZjgtNDFmZi05NjFjLTBiZTFlNDAwODEzOCw1NDNmODJkMC05NDI5LTQ0YWItOTlhZS00YWRkNjYzYjliMjMsMzE0ODdjZDQtZWNjZC00ZGI0LTk4MjItNTUzYzFhNjE1YTk4LGQ5NDM1MWJlLTlkZGItNDUxYy1iNzFjLTcxYzM2YWVjNDYxMyxmNjQwODU1OS0wYjIyLTRhMTctYTYyMS1hMmM4M2RjNjAxNDYsMThmODRhNGItMzE2ZC00NTNjLWIxZWMtYjA4YTdlZjk3NzI5IiwiTW9iaWxlIjoiMzQ1NjY2NTY1NiIsIlJvbGVDb2RlIjoiQURNIiwiRGVwYXJ0bWVudElkIjoiNmFmMTBlMjEtZjczZC00N2RhLThmMjEtY2I1OTQ2MmQ1MTYyLDQ2YTc3MjJhLTIxMWQtNDAzYi05NmM4LTk1OGFmNGUyOGVjNSxjMWM3MDllYy03N2IyLTExZWUtYjYxZS1mYTE2M2UxNDExNmUsYTI4YzRlMzQtZjY4MC00YTg1LWE3YjQtMGQ4NzcxY2VkMmU0LDEzMDA1ZmQ0LTNhZGEtYmQ1OC01ZTkzLTI0MzgyYmNkYjQ5MSIsIlVzZXJHcm91cCI6IjY4OWY4Y2QwLTdiMDgtMTFlZS1iMzYzLWZhMTYzZTE0MTE2ZSIsIlVzZXJHcm91cE5hbWUiOiJDb250cmFjdG9yIiwibmFtZWlkIjoiQURNSU4iLCJleHAiOjE3NjUzNjcyMDYsImlzcyI6Imh0dHA6Ly90aW1lLnZzYXBwcy5pbi8iLCJhdWQiOiJodHRwOi8vdGltZS52c2FwcHMuaW4vIn0.ydqfmqson8G-TJsNRgnzMNMESSZERYZ30_obcD2icIo",
*/
      if (userData.privillage != null) {
        await prefs.setString('privileges', jsonEncode(userData.privillage));
      }

      print('✅ User data saved to SharedPreferences');
      return true;
    } catch (e) {
      print('Error saving login data: $e');
      return false;
    }
  }

  // Get privileges
  static Future<List<String>> getPrivileges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final privilegesJson = prefs.getString(_keyPrivileges);

      if (privilegesJson != null) {
        final List<dynamic> decoded = jsonDecode(privilegesJson);
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error getting privileges: $e');
      return [];
    }
  }

  // Check if user has a specific privilege
  static Future<bool> hasPrivilege(String privilege) async {
    final privileges = await getPrivileges();
    return privileges.contains(privilege);
  }

  // Save access token
  Future<bool> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyAccessToken, token);
  }

  // Get access token
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  // Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyRefreshToken, token);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  // Save user name
  Future<bool> saveUserName(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserName, token);
  }

  // Get user name
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  // Save password
  Future<bool> savePassword(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyPassword, token);
  }

  // Get password
  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPassword);
  }

  // Save remember me
  Future<bool> saveRememberMe(bool token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyRememberMe, token);
  }

  // Get remember me
  bool getRememberMe() {
    return _preferences!.getBool(_keyRememberMe) ?? false;
  }

  Future<bool> clearAll() async {
    return await _preferences!.clear();
  }

  /// Clear all user data (logout)
  Future<bool> logout() async {
    try {
      await _preferences!.remove(_keyIsLoggedIn);
      await _preferences!.remove(_keyPrivileges);
      await _preferences!.remove(_keyAccessToken);
      await _preferences!.remove(_keyRefreshToken);
      await _preferences!.remove(_keyUserId);

      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }
}
