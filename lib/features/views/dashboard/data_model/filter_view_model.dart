import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:streaming_dashboard/core/config/shared_preferences/shared_preference_service.dart';
import 'package:streaming_dashboard/core/constants/api_constants.dart';
import 'package:streaming_dashboard/core/constants/api_endpoints.dart';
import 'package:streaming_dashboard/features/views/camera/model/district_list_model.dart';
import 'package:streaming_dashboard/features/views/camera/model/division_list_model.dart';
import 'package:streaming_dashboard/features/views/camera/model/sub_work_type_model.dart';
import 'package:streaming_dashboard/features/views/camera/model/tender_number_model.dart';
import 'package:streaming_dashboard/features/views/camera/model/work_status_model.dart';
import 'package:streaming_dashboard/features/views/camera/model/work_type_model.dart';
import 'package:streaming_dashboard/features/views/dashboard/model/camera_live_model.dart';
import 'package:streaming_dashboard/services/api_service.dart';

class FilterViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  String? selectedDivision;
  String? selectedDivisionId;

  String? selectedDistrict;
  String? selectedDistrictId;

  String? selectedWorkType;

  String? selectedSubType;

  String? selectedSubWorkType;

  String? selectedWorkStatus;

  String? selectedTenderNumber;
  String? selectedTenderNumberId;

  bool isLoading = false;
  String? errorMessage;

  DivisionListModel? divisionList;
  DistrictListModel? districtList;
  WorkTypeModel? workTypeList;
  SubWorkTypeModel? subWorkTypeList;
  WorkStatusModel? workStatusList;
  TenderNumberModel? tenderNumberList;

  List<DivisionData> _allDivisionList = [];
  List<DivisionData> get allDivisionList => _allDivisionList;

  List<DistrictData> _allDistrictList = [];
  List<DistrictData> get allDistrictList => _allDistrictList;

  List<WorkTypeData> _allWorkTypeList = [];
  List<WorkTypeData> get allWorkTypeList => _allWorkTypeList;

  List<SubWorkTypeData> _allSubWorkTypeList = [];
  List<SubWorkTypeData> get allSubWorkTypeList => _allSubWorkTypeList;

  List<WorkStatusData> _allWorkStatusList = [];
  List<WorkStatusData> get allWorkStatusList => _allWorkStatusList;

  List<TenderNumberData> _allTenderNumberList = [];
  List<TenderNumberData> get allTenderNumberList => _allTenderNumberList;

  // Keep the string arrays for dropdown display
  List<String> get allDivisionListArray => _allDivisionList
      .map((e) => e.divisionName ?? '')
      .where((name) => name.isNotEmpty)
      .toSet() // Add this
      .toList();

  List<String> get allDistrictListArray => _allDistrictList
      .map((e) => e.districtName ?? '')
      .where((name) => name.isNotEmpty)
      .toSet() // Add this
      .toList();

  List<String> get allWorkListArray => _allWorkTypeList
      .map((e) => e.mainCategory ?? '')
      .where((name) => name.isNotEmpty)
      .toSet() // Add this
      .toList();

  List<String> get allSubWorkListArray {
    final result = _allSubWorkTypeList
        .map((e) => e.subCategory ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    print('📋 allSubWorkListArray: $result');
    print('📋 Selected SubWorkType: $selectedSubWorkType');
    return result;
  }

  List<String> get allWorkStatusListArray => _allWorkStatusList
      .map((e) => e.workStatus ?? '')
      .where((name) => name.isNotEmpty)
      .toSet() // Add this
      .toList();

  List<String> get allTenderNumberListArray => _allTenderNumberList
      .map((e) => e.tenderNumber ?? '')
      .where((name) => name.isNotEmpty)
      .toSet() // Add this
      .toList();

  Future<void> fetchAllDivisionList(BuildContext context) async {
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
      final apiResponse = await ApiService.instance.post(
        endpoint: '${ApiConstants.baseUrl}${ApiEndpoints.getAllDivisionAPI}',
        data: {},
        fromJson: (json) => DivisionListModel.fromJson(json),
      );
      if (!context.mounted) return;
      if (apiResponse.isSuccess == true && apiResponse.data != null) {
        isLoading = false;
        divisionList = apiResponse.data;
        print('all divison ${divisionList?.data?.length}');

        // ✅ ADD THIS: Populate the dropdown array
        _allDivisionList = divisionList?.data ?? [];

        print('all divisionlist length ${_allDivisionList.length}}');
        print('Division dropdown array: ${allDivisionListArray.length} items');

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

  // In FilterViewModel class

  Future<void> divisionBasedDistrictAPI(
    BuildContext context,
    String? districtId,
  ) async {
    if (!context.mounted) return;
    isLoading = true;
    errorMessage = null;

    // ✅ Reset all dependent selections when division changes
    selectedDistrict = null;
    selectedDistrictId = null;
    selectedWorkType = null;
    selectedSubWorkType = null;
    selectedWorkStatus = null;
    selectedTenderNumber = null;
    selectedTenderNumberId = null;

    // Clear dependent lists
    _allDistrictList = [];
    _allWorkTypeList = [];
    _allSubWorkTypeList = [];
    _allWorkStatusList = [];
    _allTenderNumberList = [];

    notifyListeners();

    try {
      final token = await SharedPreferenceService.getInstance();
      String? accessToken = await token.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please login again.';
        notifyListeners();
        if (context.mounted) {
          context.go('/login');
        }
        return;
      }

      print('districtId $districtId');
      ApiService.instance.setAccessToken(accessToken);

      final apiResponse = await ApiService.instance.post(
        endpoint: '${ApiConstants.baseUrl}${ApiEndpoints.getDistrictAPI}',
        data: {
          "divisionIds": [districtId],
        },
        fromJson: (json) => DistrictListModel.fromJson(json),
      );

      if (!context.mounted) return;

      if (apiResponse.isSuccess == true && apiResponse.data != null) {
        isLoading = false;
        districtList = apiResponse.data;
        print('districtList ${districtList!.data!.length}');
        _allDistrictList = districtList?.data ?? [];
        print('_allDistrictListArray ${_allDistrictList.length}');
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

  Future<void> divisionDistrictBasedWorkTypeAPI(
    BuildContext context,
    String? districtId,
    String? divisionId,
  ) async {
    if (!context.mounted) return;
    isLoading = true;
    errorMessage = null;

    // ✅ Reset all dependent selections when district changes
    selectedWorkType = null;
    selectedSubWorkType = null;
    selectedWorkStatus = null;
    selectedTenderNumber = null;
    selectedTenderNumberId = null;

    // Clear dependent lists
    _allWorkTypeList = [];
    _allSubWorkTypeList = [];
    _allWorkStatusList = [];
    _allTenderNumberList = [];

    notifyListeners();

    try {
      final token = await SharedPreferenceService.getInstance();
      String? accessToken = await token.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please login again.';
        notifyListeners();
        if (context.mounted) {
          context.go('/login');
        }
        return;
      }

      ApiService.instance.setAccessToken(accessToken);

      final apiResponse = await ApiService.instance.post(
        endpoint:
            '${ApiConstants.baseUrl}${ApiEndpoints.getWorkTypeAPI}?divisionId=$divisionId&districtId=$districtId',
        fromJson: (json) => WorkTypeModel.fromJson(json),
      );

      if (!context.mounted) return;

      if (apiResponse.isSuccess == true && apiResponse.data != null) {
        isLoading = false;
        workTypeList = apiResponse.data;
        print('workTypeList ${workTypeList!.data!.length}');
        _allWorkTypeList = workTypeList?.data ?? [];
        print('_allWorkTypeListArray ${_allWorkTypeList.length}');
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

  Future<void> subWorkTypeAPI(
    BuildContext context,
    String? districtId,
    String? divisionId,
    String? workType,
  ) async {
    if (!context.mounted) return;
    isLoading = true;
    errorMessage = null;

    // ✅ Reset all dependent selections when work type changes
    selectedSubWorkType = null;
    selectedWorkStatus = null;
    selectedTenderNumber = null;
    selectedTenderNumberId = null;

    // Clear dependent lists
    _allSubWorkTypeList = [];
    _allWorkStatusList = [];
    _allTenderNumberList = [];

    notifyListeners();

    try {
      final token = await SharedPreferenceService.getInstance();
      String? accessToken = await token.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please login again.';
        notifyListeners();
        if (context.mounted) {
          context.go('/login');
        }
        return;
      }

      ApiService.instance.setAccessToken(accessToken);

      final apiResponse = await ApiService.instance.post(
        endpoint:
            '${ApiConstants.baseUrl}${ApiEndpoints.getSubWorkTypeAPI}?divisionId=$divisionId&districtId=$districtId&mainCategory=$workType',
        fromJson: (json) => SubWorkTypeModel.fromJson(json),
      );

      if (!context.mounted) return;

      if (apiResponse.isSuccess == true && apiResponse.data != null) {
        isLoading = false;
        subWorkTypeList = apiResponse.data;
        print('workTypeList ${subWorkTypeList!.data!.length}');
        _allSubWorkTypeList = subWorkTypeList?.data ?? [];
        print('_allWorkTypeListArray ${_allSubWorkTypeList.length}');
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

  Future<void> workStatusAPI(
    BuildContext context,
    String? districtId,
    String? divisionId,
    String? workType,
    String? subWorkType,
  ) async {
    if (!context.mounted) return;
    isLoading = true;
    errorMessage = null;

    // ✅ Reset all dependent selections when sub work type changes
    selectedWorkStatus = null;
    selectedTenderNumber = null;
    selectedTenderNumberId = null;

    // Clear dependent lists
    _allWorkStatusList = [];
    _allTenderNumberList = [];

    notifyListeners();

    try {
      final token = await SharedPreferenceService.getInstance();
      String? accessToken = await token.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please login again.';
        notifyListeners();
        if (context.mounted) {
          context.go('/login');
        }
        return;
      }

      ApiService.instance.setAccessToken(accessToken);

      final apiResponse = await ApiService.instance.post(
        endpoint:
            '${ApiConstants.baseUrl}${ApiEndpoints.getWorkStatusAPI}?divisionId=$divisionId&districtId=$districtId&mainCategory=$workType&subCategory=$subWorkType',
        fromJson: (json) => WorkStatusModel.fromJson(json),
      );

      if (!context.mounted) return;

      if (apiResponse.isSuccess == true && apiResponse.data != null) {
        isLoading = false;
        workStatusList = apiResponse.data;
        print('workTypeList ${workStatusList!.data!.length}');
        _allWorkStatusList = workStatusList?.data ?? [];
        print('_allWorkTypeListArray ${_allWorkStatusList.length}');
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

  Future<void> tenderNumberAPI(
    BuildContext context,
    String? districtId,
    String? divisionId,
    String? workType,
    String? subWorkType,
    String? workStatus,
  ) async {
    if (!context.mounted) return;
    isLoading = true;
    errorMessage = null;

    // ✅ Reset tender selection when work status changes
    selectedTenderNumber = null;
    selectedTenderNumberId = null;

    // Clear tender list
    _allTenderNumberList = [];

    notifyListeners();

    try {
      final token = await SharedPreferenceService.getInstance();
      String? accessToken = await token.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please login again.';
        notifyListeners();
        if (context.mounted) {
          context.go('/login');
        }
        return;
      }

      ApiService.instance.setAccessToken(accessToken);

      final apiResponse = await ApiService.instance.post(
        endpoint:
            '${ApiConstants.baseUrl}${ApiEndpoints.getTenderNumber}?divisionId=$divisionId&districtId=$districtId&mainCategory=$workType&subCategory=$subWorkType&workStatus=$workStatus',
        fromJson: (json) => TenderNumberModel.fromJson(json),
      );

      if (!context.mounted) return;

      if (apiResponse.isSuccess == true && apiResponse.data != null) {
        isLoading = false;
        tenderNumberList = apiResponse.data;
        print('workTypeList ${tenderNumberList!.data!.length}');
        _allTenderNumberList = tenderNumberList?.data ?? [];
        print('_allWorkTypeListArray ${_allTenderNumberList.length}');
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

  // Fetch camera data using ApiService with POST method
  Future<void> fetchCameraData(BuildContext context) async {
    if (!context.mounted) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners(); // If using ChangeNotifier

    try {
      print('📡 Starting camera data fetch...');

      // Get the Bearer token from SharedPreferences
      final token = await SharedPreferenceService.getInstance();
      String? accessToken = await token.getAccessToken();

      // 🔍 DEBUG: Print token details
      print('🔑 Token exists: ${accessToken != null}');
      print('🔑 Token length: ${accessToken?.length ?? 0}');
      print(
        '🔑 Token preview: ${accessToken?.substring(0, min(20, accessToken.length))}...',
      );

      if (accessToken == null || accessToken.isEmpty) {
        isLoading = false;
        errorMessage = 'Authentication token not found. Please login again.';
        print('❌ No token found');
        notifyListeners();
        // Navigate to login
        if (context.mounted) {
          AlertDialog(
            title: const Text('Session Expired'),
            content: const Text(
              'Your session has expired. Please login again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigate to login screen
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('Login'),
              ),
            ],
          );
        }
        return;
      }
      ApiService.instance.setAccessToken(accessToken);

      // Prepare request parameters
      final requestData = {
        "divisionIds": [selectedDivisionId],
        "districtIds": [selectedDistrictId],
        "tenderId": selectedTenderNumberId,
        "divisionName": '',
        "districtName": '',
        "mainCategory": selectedWorkType,
        "subcategory": selectedSubWorkType,
        "workStatus": selectedWorkStatus,
        "tenderNumber": selectedTenderNumberId,
        "channel": "",
        "rtspUrl": "",
        "liveUrl": "",
        "type": "Report",
        "skip": 0,
        "take": 25,
        "SearchString": "",
        "sorting": {"fieldName": "tenderNumber", "sort": "ASC"},
      };

      // Call the POST method from ApiService
      final apiResponse = await ApiService.instance.post<CameraLiveModel>(
        endpoint: ApiConstants.baseUrl + ApiEndpoints.dashBoardCameraLiveAPI,
        data: requestData,
        fromJson: (json) => CameraLiveModel.fromJson(json),
      );

      if (!context.mounted) return;

      if (apiResponse.isSuccess && apiResponse.data != null) {
        // cameraData = apiResponse.data;
        isLoading = false;
        errorMessage = null;

        print('✅ Camera data loaded successfully');
        print('Total cameras: ${apiResponse.data?.data?.length ?? 0}');
        notifyListeners();
      } else {
        isLoading = false;
        errorMessage = apiResponse.error ?? 'Failed to load camera data';
        // Handle 401 specifically
        if (errorMessage!.contains('Authentication failed') ||
            errorMessage!.contains('401')) {
          // Navigate to login or show re-login dialog
          if (context.mounted) {
            // Show dialog or navigate
            // _handleAuthError(context);
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
}
