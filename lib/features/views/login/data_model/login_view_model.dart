import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:streaming_dashboard/core/config/shared_preferences/shared_preference_service.dart';
import 'package:streaming_dashboard/core/config/toast_service/toast_service.dart';
import 'package:streaming_dashboard/core/constants/api_endpoints.dart';
import 'package:streaming_dashboard/services/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  bool rememberMe = false;

  LoginViewModel() {
    _initService();
  }

  Future<void> _initService() async {
    await _loadSavedCredentials();
  }

  // Load saved credentials if remember me was checked
  Future<void> _loadSavedCredentials() async {
    try {
      final service = await SharedPreferenceService.getInstance();
      rememberMe = service.getRememberMe();

      if (rememberMe) {
        final savedUsername = await service.getUserName();
        final savedPassword = await service.getPassword();

        if (savedUsername != null && savedUsername.isNotEmpty) {
          userNameController.text = savedUsername;
        }
        if (savedPassword != null && savedPassword.isNotEmpty) {
          passwordController.text = savedPassword;
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  // Check if user is already logged in
  static Future<bool> isUserLoggedIn() async {
    try {
      final service = await SharedPreferenceService.getInstance();
      return service.getLoginStatus();
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Toggle remember me checkbox
  void toggleRememberMe() {
    rememberMe = !rememberMe;
    notifyListeners();
  }

  // Save credentials if remember me is checked
  Future<void> _saveCredentials() async {
    try {
      final service = await SharedPreferenceService.getInstance();

      // Save remember me preference
      await service.saveRememberMe(rememberMe);

      if (rememberMe) {
        // Save username and password
        await service.saveUserName(userNameController.text);
        await service.savePassword(passwordController.text);
      } else {
        // Clear saved credentials if remember me is unchecked
        await service.saveUserName('');
        await service.savePassword('');
      }
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  // Clear saved credentials (call this on logout)
  static Future<void> clearSavedCredentials() async {
    try {
      final service = await SharedPreferenceService.getInstance();
      await service.logout();
      await service.saveRememberMe(false);
      await service.saveUserName('');
      await service.savePassword('');
    } catch (e) {
      print('Error clearing credentials: $e');
    }
  }

  Future<void> submitForm(BuildContext context) async {
    // Validate inputs
    if (userNameController.text.isEmpty || passwordController.text.isEmpty) {
      ToastService.showError('Please enter username and password');
      return;
    }
    Map<String, String> loginData = {
      "username": userNameController.text.trim(),
      "password": passwordController.text.trim(),
    };
    isLoading = true;
    notifyListeners();

    try {
      // Call API
      final response = await ApiService.instance.formLoginAPI(
        endpoint: ApiEndpoints.login,
        data: loginData,
      );
      if (response.data != null) {
        // ✅ SUCCESS - Extract data
        debugPrint('✅ LOGIN SUCCESSFUL');
        final prefService = await SharedPreferenceService.getInstance();

        final saved = await prefService.saveUserDataToPreferences(
          response.data!.data!,
        );
        await prefService.saveAccessToken(
          response.data!.data!.accessToken ?? '',
        );
        await prefService.saveRefreshToken(
          response.data!.data!.refreshToken ?? '',
        );
        await _saveCredentials();

        // Navigate to home
        if (saved && context.mounted) {
          await prefService.saveLoginStatus(true);
          context.go('/maintabbar');
        }
      } else {
        // ❌ FAILED - Show error
        debugPrint('❌ LOGIN FAILED');
        debugPrint('Response: $response');

        if (context.mounted) {
          ToastService.showError(
            'Login failed. Please check your credentials.',
          );
        }
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ToastService.showError('Login failed: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
