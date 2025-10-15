import 'package:nalogistics_app/data/models/auth/login_request.dart';
import 'package:nalogistics_app/data/models/auth/login_response.dart';
import 'package:nalogistics_app/data/models/auth/user_detail_response_model.dart';

abstract class IAuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
  Future<String?> getRoleName();
  Future<UserDetailResponse> getUserDetail({required String username});
}