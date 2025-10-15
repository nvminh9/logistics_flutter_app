import 'package:nalogistics_app/data/models/auth/login_request.dart';
import 'package:nalogistics_app/data/models/auth/login_response.dart';
import 'package:nalogistics_app/data/models/auth/user_detail_response_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_auth_repository.dart';
import 'package:nalogistics_app/data/services/api/api_client.dart';
import 'package:nalogistics_app/data/services/local/storage_service.dart';
import 'package:nalogistics_app/core/constants/app_constants.dart';
import 'package:nalogistics_app/core/constants/api_constants.dart';

class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: request.toJson(),
        requiresAuth: false,
      );

      final loginResponse = LoginResponse.fromJson(response);

      // Lưu token và username nếu đăng nhập thành công
      if (loginResponse.isSuccess && loginResponse.data != null) {
        await _saveAuthData(loginResponse.data!, request.username);
      }

      return loginResponse;
    } catch (e) {
      print('❌ Login Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _storage.remove(AppConstants.keyAccessToken);
      await _storage.remove(AppConstants.keyDriverData);
    } catch (e) {
      print('❌ Logout Error: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.getString(AppConstants.keyAccessToken);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _storage.getString(AppConstants.keyAccessToken);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getRoleName() async {
    try {
      final driverData = await _storage.getObject(AppConstants.keyDriverData);
      return driverData?['roleName'];
    } catch (e) {
      return null;
    }
  }

  /// ⭐ UPDATED: Get username from storage
  Future<String?> getUsername() async {
    try {
      final driverData = await _storage.getObject(AppConstants.keyDriverData);
      return driverData?['username'];
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserDetailResponse> getUserDetail({required String username}) async {
    try {
      final queryParams = {
        'username': username,
      };

      print('📤 Fetching user detail for username: $username');

      final response = await _apiClient.get(
        ApiConstants.userDetail,
        queryParams: queryParams,
        requiresAuth: true,
      );

      print('📥 User detail response: ${response['statusCode']}');

      return UserDetailResponse.fromJson(response);
    } catch (e) {
      print('❌ Get User Detail Error: $e');
      rethrow;
    }
  }

  /// ⭐ UPDATED: Save auth data with username
  Future<void> _saveAuthData(LoginData data, String username) async {
    try {
      // Lưu token
      await _storage.saveString(AppConstants.keyAccessToken, data.token);

      // Lưu thông tin user bao gồm username
      final userData = {
        'token': data.token,
        'roleName': data.roleName,
        'username': username, // ⭐ Lưu username
        'loginTime': DateTime.now().toIso8601String(),
      };
      await _storage.saveObject(AppConstants.keyDriverData, userData);

      print('✅ Auth data saved successfully');
      print('   - Username: $username');
      print('   - Role: ${data.roleName}');
    } catch (e) {
      print('❌ Error saving auth data: $e');
      rethrow;
    }
  }
}