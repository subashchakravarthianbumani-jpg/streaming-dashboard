import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:streaming_dashboard/core/config/shared_preferences/shared_preference_service.dart';
import 'package:streaming_dashboard/core/constants/api_constants.dart';
import 'package:streaming_dashboard/core/constants/api_endpoints.dart';
import 'package:streaming_dashboard/core/constants/app_strings.dart';
import 'package:streaming_dashboard/features/views/profile/model/profile_model.dart';
import 'package:streaming_dashboard/services/api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final userGroupController = TextEditingController();
  final roleNameController = TextEditingController();

  bool isLoading = false;
  String? userId;
  String? errorMessage;
  ProfileModel? profileModel;

  Future<void> fetchUserInfo(BuildContext context) async {
    userId = await SharedPreferenceService.getUserId();
    if (!context.mounted) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // If using ChangeNotifier
    try {
      final token = await SharedPreferenceService.getInstance();
      String? accessToken = await token.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please login again.';
        notifyListeners();
        // Navigate to login
        if (context.mounted) {
          context.go('/login');
        }
        return;
      }
      ApiService.instance.setAccessToken(accessToken);
      //Cal the Get method from Apiservice
      final apiResponse = await ApiService.instance.get(
        endpoint:
            '${ApiConstants.baseUrl}${ApiEndpoints.profileInfoAPI}?IsActive=true&UserId=$userId',
        fromJson: (json) => ProfileModel.fromJson(json),
      );
      if (!context.mounted) return;
      if (apiResponse.isSuccess == true && apiResponse.data != null) {
        isLoading = false;
        profileModel = apiResponse.data;
        firstNameController.text = profileModel?.data?.first.firstName ?? '';
        lastNameController.text = profileModel?.data?.first.lastName ?? '';
        emailController.text = profileModel?.data?.first.email ?? '';
        phoneController.text = profileModel?.data?.first.mobile ?? '';
        lastNameController.text = profileModel?.data?.first.lastName ?? '';
        userGroupController.text =
            profileModel?.data?.first.userGroupName ?? '';
        roleNameController.text = profileModel?.data?.first.roleName ?? '';
        notifyListeners();
        return;
      }
      print('✅ profile data loaded successfully ${apiResponse.isSuccess}');
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to fetch user info: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  showAndroidAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(
        AppStrings.ksCancel,
        // style: GoogleFonts.lato(fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        AppStrings.ksLogout,
        // style: GoogleFonts.lato(color: kcRed, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        if (context.mounted) {
          SharedPreferenceService.getInstance().then((prefs) {
            prefs.saveLoginStatus(false);
            prefs.logout();
            // prefs.clearAll();
            context.push('/registrationform');
            // .back();
          });
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        AppStrings.ksLogout,
        // style: GoogleFonts.lato(fontSize: size_16, fontWeight: FontWeight.bold),
      ),
      content: Text(
        '${AppStrings.ksLogoutHint}?',
        // style: GoogleFonts.lato(fontSize: size_16, fontWeight: FontWeight.bold),
      ),
      actions: [cancelButton, continueButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showiOSAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            AppStrings.ksLogout,
            // style: GoogleFonts.lato(
            //   fontSize: size_16,
            //   color: kcBlack,
            //   fontWeight: FontWeight.bold,
            // ),
          ),
          content: Text(
            '${AppStrings.ksLogoutHint}?',
            // style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                AppStrings.ksCancel,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                AppStrings.ksLogout,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                if (context.mounted) {
                  SharedPreferenceService.getInstance().then((prefs) {
                    prefs.saveLoginStatus(false);
                    prefs.logout();
                    context.push('/login');
                    // .back();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
