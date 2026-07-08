import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:nalogistics_app/core/constants/api_constants.dart';
import 'package:nalogistics_app/core/constants/error_codes.dart';
import 'package:nalogistics_app/core/services/session_manager.dart';
import 'package:nalogistics_app/core/exceptions/network_exception.dart';
import 'package:nalogistics_app/data/services/local/storage_service.dart';
import 'package:nalogistics_app/core/constants/app_constants.dart';
import 'package:path/path.dart' as path;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const int timeoutDuration = 30; // seconds
  final StorageService _storage = StorageService();
  final SessionManager _sessionManager = SessionManager();

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
          )
          .timeout(const Duration(seconds: timeoutDuration));

      print('📨 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse(response, requiresAuth: requiresAuth);
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

      return _handleResponse(response, requiresAuth: requiresAuth);
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

  Future<Uint8List> getBytes(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    String accept = 'application/octet-stream',
  }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      headers['Accept'] = accept;
      headers.remove('Content-Type');

      print('🚀 API Request: GET $uri');
      print('📋 Headers: $headers');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 60));

      print('📨 Response Status: ${response.statusCode}');
      print('📄 Response Bytes: ${response.bodyBytes.length}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.bodyBytes;
      }

      _handleResponse(response, requiresAuth: requiresAuth);
      throw NetworkException('Không thể tải dữ liệu từ server');
    } on SocketException catch (e) {
      print('❌ Network Error: $e');
      throw NetworkException('Không có kết nối internet');
    } on http.ClientException catch (e) {
      print('❌ Client Error: $e');
      throw NetworkException('Lỗi kết nối với server');
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      print('❌ Download Error: $e');
      throw NetworkException('Có lỗi xảy ra khi tải file: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);

      print('🚀 API Request: PUT $uri');
      print('📋 Headers: $headers');
      print('📦 Body: $body');

      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(const Duration(seconds: timeoutDuration));

      print('📨 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse(response, requiresAuth: requiresAuth);
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

  /// Upload file với multipart/form-data
  /// ⚠️ Note: This is a basic implementation. Consider using Dio for better file upload support
  Future<Map<String, dynamic>> uploadMultipart(
    String endpoint, {
    required File file,
    Map<String, String>? fields,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      // Remove Content-Type from headers as multipart sets its own
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // Add file
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: path.basename(file.path),
      );
      request.files.add(multipartFile);

      // Add additional fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      print('🚀 Uploading: ${path.basename(file.path)}');
      print('📋 Fields: $fields');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      ); // Longer timeout for uploads

      final response = await http.Response.fromStream(streamedResponse);

      print('📨 Upload Response Status: ${response.statusCode}');
      print('📄 Upload Response Body: ${response.body}');

      return _handleResponse(response, requiresAuth: requiresAuth);
    } on SocketException catch (e) {
      print('❌ Network Error: $e');
      throw NetworkException('Không có kết nối internet');
    } catch (e) {
      print('❌ Upload Error: $e');
      throw NetworkException('Lỗi upload file: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(
    http.Response response, {
    required bool requiresAuth,
  }) {
    try {
      // ⚠️ CHECK TOKEN EXPIRATION
      if (requiresAuth &&
          (response.statusCode == ErrorCodes.unauthorized ||
              response.statusCode == ErrorCodes.forbidden)) {
        print('CHECK TOKEN EXPIRATION: ');
        // print(ErrorCodes.isTokenExpiredError(response.body.toString()));

        // Check if message indicates token expiration
        if (ErrorCodes.isTokenExpiredError(response.body.toString())) {
          print('🔴 Token expired detected in response');

          // Trigger session expired handler
          _sessionManager.handleTokenExpired(
            message: response.body.toString().isNotEmpty
                ? response.body.toString()
                : 'Phiên đăng nhập đã hết hạn',
          );

          throw NetworkException(
            'Token đã hết hạn. Vui lòng đăng nhập lại.',
            statusCode: ErrorCodes.tokenExpired,
          );
        }
      }

      // Nếu token không hết hạn thì xử lý response body
      final Map<String, dynamic> data = json.decode(response.body.toString());

      // API của bạn luôn trả về statusCode trong body
      final apiStatusCode = data['statusCode'] ?? response.statusCode;
      final message = data['message'] ?? data['Message'] ?? '';

      switch (response.statusCode) {
        case 200:
          return data;
        case 201:
          return data;
        case 400:
          throw NetworkException(
            message.isNotEmpty ? message : 'Yêu cầu không hợp lệ',
            statusCode: 400,
          );
        case 401:
          throw NetworkException(
            message.isNotEmpty ? message : 'Không có quyền truy cập',
            statusCode: 401,
          );
        case 403:
          throw NetworkException(
            message.isNotEmpty ? message : 'Truy cập bị từ chối',
            statusCode: 403,
          );
        case 404:
          throw NetworkException(
            message.isNotEmpty ? message : 'Không tìm thấy dữ liệu',
            statusCode: 404,
          );
        case 500:
          throw NetworkException(
            message.isNotEmpty ? message : 'Lỗi server nội bộ',
            statusCode: 500,
          );
        default:
          // Check API's internal status code
          if (apiStatusCode != 200) {
            throw NetworkException(
              message.isNotEmpty ? message : 'Có lỗi xảy ra',
              statusCode: apiStatusCode,
            );
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
