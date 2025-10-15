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

      // Lưu token nếu đăng nhập thành công
      if (loginResponse.isSuccess && loginResponse.data != null) {
        await _saveAuthData(loginResponse.data!);
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
      // Clear local storage
      await _storage.remove(AppConstants.keyAccessToken);
      await _storage.remove(AppConstants.keyDriverData);

      // Có thể gọi API logout nếu cần
      // await _apiClient.post('/api/logout', requiresAuth: true);
    } catch (e) {
      print('❌ Logout Error: $e');
      // Không throw error cho logout để đảm bảo user luôn logout được
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

  Future<void> _saveAuthData(LoginData data) async {
    try {
      // Lưu token
      await _storage.saveString(AppConstants.keyAccessToken, data.token);

      // Lưu thông tin driver
      final driverData = {
        'token': data.token,
        'roleName': data.roleName,
        'loginTime': DateTime.now().toIso8601String(),
      };
      await _storage.saveObject(AppConstants.keyDriverData, driverData);

      print('✅ Auth data saved successfully');
    } catch (e) {
      print('❌ Error saving auth data: $e');
      rethrow;
    }
  }

  @override
  Future<UserDetailModel> getUserDetail({
    required String userID,
  }) async {
    try {
      final queryParams = {
        'id': userID,
      };

      final response = await _apiClient.get(
        ApiConstants.detailUser,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return UserDetailModel.fromJson(response);
    } catch (e) {
      print('❌ Order Detail Repository Error: $e');
      rethrow;
    }
  }
}