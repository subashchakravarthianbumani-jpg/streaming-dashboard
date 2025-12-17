import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:streaming_dashboard/core/config/shared_preferences/shared_preference_service.dart';
import 'package:streaming_dashboard/core/constants/api_constants.dart';
import 'package:streaming_dashboard/core/constants/api_endpoints.dart';
import 'package:streaming_dashboard/features/views/dashboard/model/camera_live_model.dart';
import 'package:streaming_dashboard/services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  bool showGridView = true;
  bool isLoading = false;
  String? errorMessage;
  CameraLiveModel? cameraData;
  List<String>? privileges;
  bool showFilterOptions = false;
  String? selectedFilter; // null means show all

  // Track if filters are applied
  bool isFilterApplied = false;

  Future<void> fetchCameraData(BuildContext context) async {
    if (!context.mounted) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print('📡 Starting camera data fetch...');

      final token = await SharedPreferenceService.getInstance();
      String? accessToken = await token.getAccessToken();

      print('🔐 Token exists: ${accessToken != null}');
      print('🔐 Token length: ${accessToken?.length ?? 0}');
      print(
        '🔐 Token preview: ${accessToken?.substring(0, min(20, accessToken.length))}...',
      );

      if (accessToken == null || accessToken.isEmpty) {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please login again.';
        print('❌ No token found');
        notifyListeners();
        if (context.mounted) {
          _handleAuthError(context);
        }
        return;
      }
      ApiService.instance.setAccessToken(accessToken);

      final requestData = {
        "divisionIds": null,
        "districtIds": null,
        "tenderId": "",
        "divisionName": "",
        "districtName": "",
        "mainCategory": "",
        "subcategory": "",
        "workStatus": "",
        "tenderNumber": "",
        "channel": "",
        "rtspUrl": "",
        "liveUrl": "",
        "type": "Camera",
        "skip": 0,
        "take": 100,
        "SearchString": "",
        "sorting": {"fieldName": "tenderNumber", "sort": "ASC"},
      };

      final apiResponse = await ApiService.instance.post<CameraLiveModel>(
        endpoint: ApiConstants.baseUrl + ApiEndpoints.dashBoardCameraLiveAPI,
        data: requestData,
        fromJson: (json) => CameraLiveModel.fromJson(json),
      );

      if (!context.mounted) return;

      if (apiResponse.isSuccess && apiResponse.data != null) {
        cameraData = apiResponse.data;
        isLoading = false;
        errorMessage = null;
        isFilterApplied = false;

        print('✅ Camera data loaded successfully');
        print('Total cameras: ${cameraData?.data?.length ?? 0}');
        notifyListeners();
      } else {
        isLoading = false;
        errorMessage = apiResponse.error ?? 'Failed to load camera data';
        if (errorMessage!.contains('Authentication failed') ||
            errorMessage!.contains('401')) {
          if (context.mounted) {
            _handleAuthError(context);
          }
        }
        notifyListeners();
      }
    } catch (e, stackTrace) {
      if (context.mounted) {
        isLoading = false;
        errorMessage = 'Unexpected error: $e';
        print('❌ Exception in fetchCameraData: $e');
        print('Stack trace: $stackTrace');
        notifyListeners();
      }
    }
  }

  // In home_view_model.dart - Add this method:
  Future<void> fetchFilteredCameraData(
    BuildContext context,
    Map<String, String?> filterParams,
  ) async {
    if (!context.mounted) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print('📡 Starting filtered camera data fetch...');

      final token = await SharedPreferenceService.getInstance();
      String? accessToken = await token.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please login again.';
        notifyListeners();
        if (context.mounted) {
          _handleAuthError(context);
        }
        return;
      }

      ApiService.instance.setAccessToken(accessToken);

      // Prepare filtered request data
      final requestData = {
        "divisionIds": filterParams['divisionId'] != null
            ? [filterParams['divisionId']]
            : null,
        "districtIds": filterParams['districtId'] != null
            ? [filterParams['districtId']]
            : null,
        "tenderId": filterParams['tenderId'] ?? "",
        "divisionName": filterParams['divisionName'] ?? "",
        "districtName": filterParams['districtName'] ?? "",
        "mainCategory": filterParams['mainCategory'] ?? "",
        "subcategory": filterParams['subCategory'] ?? "",
        "workStatus": filterParams['workStatus'] ?? "",
        "tenderNumber": filterParams['tenderNumber'] ?? "",
        "channel": "",
        "rtspUrl": "",
        "liveUrl": "",
        "type": "Camera",
        "skip": 0,
        "take": 100,
        "SearchString": filterParams['searchText'] ?? "",
        "sorting": {"fieldName": "tenderNumber", "sort": "ASC"},
      };

      print('🔍 Filter request data: $requestData');

      final apiResponse = await ApiService.instance.post<CameraLiveModel>(
        endpoint: ApiConstants.baseUrl + ApiEndpoints.dashBoardCameraLiveAPI,
        data: requestData,
        fromJson: (json) => CameraLiveModel.fromJson(json),
      );

      if (!context.mounted) return;

      if (apiResponse.isSuccess && apiResponse.data != null) {
        cameraData = apiResponse.data;
        isLoading = false;
        errorMessage = null;
        isFilterApplied = true;

        print('✅ Filtered camera data loaded successfully');
        print('Filtered cameras: ${cameraData?.data?.length ?? 0}');
        notifyListeners();
      } else {
        isLoading = false;
        errorMessage =
            apiResponse.error ?? 'Failed to load filtered camera data';
        notifyListeners();
      }
    } catch (e, stackTrace) {
      if (context.mounted) {
        isLoading = false;
        errorMessage = 'Unexpected error: $e';
        print('❌ Exception in fetchFilteredCameraData: $e');
        print('Stack trace: $stackTrace');
        notifyListeners();
      }
    }
  }

  // Method to apply filtered data from FilterViewModel
  // In home_view_model.dart - Update the existing method:
  void applyFilteredData(CameraLiveModel filteredData) {
    cameraData = filteredData;
    isFilterApplied = true; // Make sure this is set
    isLoading = false;
    errorMessage = null;
    print('✅ Applied filtered data: ${cameraData?.data?.length ?? 0} cameras');
    notifyListeners();
  }

  // Method to clear filters and reload all data
  Future<void> clearFiltersAndReload(BuildContext context) async {
    isFilterApplied = false;
    selectedFilter = null;
    await fetchCameraData(context);
  }

  void _handleAuthError(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              context.go('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  int getStatusCount(String status) {
    if (cameraData?.data == null) return 0;
    return cameraData!.data!
        .where(
          (camera) => camera.workStatus?.toLowerCase() == status.toLowerCase(),
        )
        .length;
  }

  // Get invalid camera count
  int getInvalidCameraCount() {
    if (cameraData?.data == null) return 0;
    return cameraData!.data!
        .where((camera) => camera.isRtspValid == false)
        .length;
  }

  // Get total camera count
  int getTotalCameraCount() {
    return cameraData?.data?.length ?? 0;
  }
}
