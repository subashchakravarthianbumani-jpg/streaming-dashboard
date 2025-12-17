import 'package:dio/dio.dart';
import 'package:streaming_dashboard/core/constants/api_constants.dart';
import 'package:streaming_dashboard/features/views/login/model/login_model.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;
  late Dio _dio;

  // Store the access token
  String? _accessToken;
  // Singleton pattern
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // You can add authorization headers or logging here
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = '$_accessToken';
            print('🔑 Token Added to Request ${options.headers}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // You can log responses here
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // You can handle errors globally here
          if (error.response?.statusCode == 401) {
            print('🔒 Token Expired - User needs to login again');
            // You can add logout logic here or trigger a callback
          }
          return handler.next(error);
        },
      ),
    );
  }
  // Set the access token (call this after successful login)
  void setAccessToken(String token) {
    _accessToken = token;
  }

  // Get the current access token
  String? getAccessToken() {
    return _accessToken;
  }

  // Clear the access token (call this on logout)
  void clearAccessToken() {
    _accessToken = null;
  }

  // Check if user is authenticated
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  // Login API
  Future<ApiResponse<LoginModel>> formLoginAPI({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginModel = LoginModel.fromJson(response.data);
        return ApiResponse<LoginModel>(data: loginModel, error: null);
      } else {
        print('❌ API Error: Status ${response.statusCode}');
        return ApiResponse<LoginModel>(
          data: null,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException Caught');
      print('Error Message: ${e.message}');
      String errorMessage = _handleDioError(e);
      return ApiResponse<LoginModel>(data: null, error: errorMessage);
    } catch (e, _) {
      print('❌ Unexpected Error');
      print('Error: $e');
      return ApiResponse<LoginModel>(data: null, error: 'Unexpected error: $e');
    }
  }

  // Generic GET method
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      print('🔵 GET Request Started');
      print('Endpoint: $endpoint');
      print('Query Parameters: $queryParameters');
      print('═══════════════════════════════════');

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      print('🟢 GET Response Received');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('═══════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = fromJson(response.data);
        print('✅ Parsing Successful');
        return ApiResponse<T>(data: data, error: null);
      } else {
        print('❌ API Error: Status ${response.statusCode}');
        return ApiResponse<T>(
          data: null,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException Caught');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('═══════════════════════════════════');

      String errorMessage = _handleDioError(e);
      return ApiResponse<T>(data: null, error: errorMessage);
    } catch (e, stackTrace) {
      print('❌ Unexpected Error');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('═══════════════════════════════════');

      return ApiResponse<T>(data: null, error: 'Unexpected error: $e');
    }
  }

  // Generic POST method with optional headers
  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) fromJson,
    // Option to disable auth for specific calls
  }) async {
    try {
      print('🔵 POST Request Started');
      print('Endpoint: $endpoint');
      print('Request Data: $data');
      print('═══════════════════════════════════');

      final response = await _dio.post(endpoint, data: data);

      print('🟢 POST Response Received');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('═══════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = fromJson(response.data);
        print('✅ Parsing Successful');
        return ApiResponse<T>(data: responseData, error: null);
      } else {
        print('❌ API Error: Status ${response.statusCode}');
        return ApiResponse<T>(
          data: null,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException Caught');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('═══════════════════════════════════');

      String errorMessage = _handleDioError(e);
      return ApiResponse<T>(data: null, error: errorMessage);
    } catch (e, stackTrace) {
      print('❌ Unexpected Error');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('═══════════════════════════════════');

      return ApiResponse<T>(data: null, error: 'Unexpected error: $e');
    }
  }

  // Generic PUT method (token automatically added via interceptor)
  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    required T Function(Map<String, dynamic>) fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      if (requiresAuth && !isAuthenticated) {
        return ApiResponse<T>(
          data: null,
          error: 'Authentication required. Please login.',
        );
      }

      print('🔵 PUT Request Started');
      print('Endpoint: $endpoint');
      print('Request Data: $data');
      print('═══════════════════════════════════');

      final response = await _dio.put(
        endpoint,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
      );

      print('🟢 PUT Response Received');
      print('Status Code: ${response.statusCode}');
      print('═══════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = fromJson(response.data);
        print('✅ Parsing Successful');
        return ApiResponse<T>(data: responseData, error: null);
      } else {
        print('❌ API Error: Status ${response.statusCode}');
        return ApiResponse<T>(
          data: null,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = _handleDioError(e);
      return ApiResponse<T>(data: null, error: errorMessage);
    } catch (e) {
      return ApiResponse<T>(data: null, error: 'Unexpected error: $e');
    }
  }

  // Generic DELETE method (token automatically added via interceptor)
  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      if (requiresAuth && !isAuthenticated) {
        return ApiResponse<T>(
          data: null,
          error: 'Authentication required. Please login.',
        );
      }

      print('🔵 DELETE Request Started');
      print('Endpoint: $endpoint');
      print('═══════════════════════════════════');

      final response = await _dio.delete(endpoint, data: data);

      print('🟢 DELETE Response Received');
      print('Status Code: ${response.statusCode}');
      print('═══════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = fromJson(response.data);
        print('✅ Parsing Successful');
        return ApiResponse<T>(data: responseData, error: null);
      } else {
        print('❌ API Error: Status ${response.statusCode}');
        return ApiResponse<T>(
          data: null,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = _handleDioError(e);
      return ApiResponse<T>(data: null, error: errorMessage);
    } catch (e) {
      return ApiResponse<T>(data: null, error: 'Unexpected error: $e');
    }
  }

  // Helper method to get Bearer token header
  static Map<String, dynamic> getBearerHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Helper method to handle Dio errors
  String _handleDioError(DioException e) {
    try {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Please check your internet connection.';

        case DioExceptionType.sendTimeout:
          return 'Request timeout. Please try again.';

        case DioExceptionType.receiveTimeout:
          return 'Server response timeout. Please try again.';

        case DioExceptionType.badResponse:
          // Handle 401 specifically
          if (e.response?.statusCode == 401) {
            return 'Authentication failed. Please login again.';
          }

          // Safely access response data
          final responseData = e.response?.data;
          if (responseData != null) {
            // If response is a Map, try to get error message
            if (responseData is Map<String, dynamic>) {
              return responseData['message'] ??
                  responseData['error'] ??
                  'Server error: ${e.response?.statusCode}';
            }
            // If response is a String
            if (responseData is String) {
              return responseData.isNotEmpty
                  ? responseData
                  : 'Server error: ${e.response?.statusCode}';
            }
          }
          return 'Server error: ${e.response?.statusCode ?? 'Unknown'}';

        case DioExceptionType.cancel:
          return 'Request cancelled.';

        case DioExceptionType.connectionError:
          return 'Connection error. Please check your internet connection.';

        case DioExceptionType.badCertificate:
          return 'Security certificate error.';

        case DioExceptionType.unknown:
        default:
          return e.message ?? 'Unknown error occurred.';
      }
    } catch (error) {
      print('❌ Error in _handleDioError: $error');
      return 'An unexpected error occurred.';
    }
  }
}

// Response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;

  ApiResponse({this.data, this.error});

  bool get isSuccess => data != null && error == null;
  bool get isError => error != null;
}
