import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nalogistics_app/core/constants/api_constants.dart';
import 'package:nalogistics_app/core/exceptions/network_exception.dart';
import 'package:nalogistics_app/data/services/local/storage_service.dart';
import 'package:nalogistics_app/core/constants/app_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const int timeoutDuration = 30; // seconds
  final StorageService _storage = StorageService();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _storage.getString(AppConstants.keyAccessToken);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        bool requiresAuth = false,
      }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      print('🚀 API Request: POST $uri');
      print('📋 Headers: $headers');
      print('📦 Body: $body');

      final response = await http
          .post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: timeoutDuration));

      print('📨 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('❌ Network Error: $e');
      throw NetworkException('Không có kết nối internet');
    } on http.ClientException catch (e) {
      print('❌ Client Error: $e');
      throw NetworkException('Lỗi kết nối với server');
    } on FormatException catch (e) {
      print('❌ Format Error: $e');
      throw NetworkException('Dữ liệu trả về không hợp lệ');
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw NetworkException('Có lỗi xảy ra: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, String>? queryParams,
        bool requiresAuth = true,
      }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);

      print('🚀 API Request: GET $uri');
      print('📋 Headers: $headers');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: timeoutDuration));

      print('📨 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('❌ Network Error: $e');
      throw NetworkException('Không có kết nối internet');
    } on http.ClientException catch (e) {
      print('❌ Client Error: $e');
      throw NetworkException('Lỗi kết nối với server');
    } on FormatException catch (e) {
      print('❌ Format Error: $e');
      throw NetworkException('Dữ liệu trả về không hợp lệ');
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw NetworkException('Có lỗi xảy ra: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = json.decode(response.body);

      // API của bạn luôn trả về statusCode trong body
      final apiStatusCode = data['statusCode'] ?? response.statusCode;

      switch (response.statusCode) {
        case 200:
        case 201:
          return data;
        case 400:
          throw NetworkException(data['Message'] ?? 'Yêu cầu không hợp lệ');
        case 401:
          throw NetworkException(data['Message'] ?? 'Không có quyền truy cập');
        case 403:
          throw NetworkException(data['Message'] ?? 'Truy cập bị từ chối');
        case 404:
          throw NetworkException(data['Message'] ?? 'Không tìm thấy dữ liệu');
        case 500:
          throw NetworkException(data['Message'] ?? 'Lỗi server nội bộ');
        default:
        // Check API's internal status code
          if (apiStatusCode != 200) {
            throw NetworkException(data['Message'] ?? 'Có lỗi xảy ra');
          }
          return data;
      }
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException('Không thể xử lý dữ liệu từ server');
    }
  }
}