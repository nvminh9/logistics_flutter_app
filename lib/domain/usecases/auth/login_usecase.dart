import 'package:nalogistics_app/data/models/auth/login_request.dart';
import 'package:nalogistics_app/data/models/auth/login_response.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_auth_repository.dart';
import 'package:nalogistics_app/core/exceptions/app_exception.dart';

class LoginUseCase {
  final IAuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<LoginResponse> execute({
    required String username,
    required String password,
  }) async {
    try {
      // Validate input
      if (username.trim().isEmpty) {
        throw AppException('Vui lòng nhập tên đăng nhập');
      }

      if (password.trim().isEmpty) {
        throw AppException('Vui lòng nhập mật khẩu');
      }

      if (password.length < 3) {
        throw AppException('Mật khẩu phải có ít nhất 3 ký tự');
      }

      // Create request
      final request = LoginRequest(
        username: username.trim(),
        password: password,
      );

      print("CONCAK NÈ");
      
      // Call repository
      final response = await _authRepository.login(request);

      print("CONCAK NÈ CAI DMM");
      print(response);

      // Validate response
      if (!response.isSuccess) {
        throw AppException(response.message.isNotEmpty
            ? response.message
            : 'Đăng nhập thất bại');
      }

      if (response.data == null) {
        throw AppException('Dữ liệu đăng nhập không hợp lệ');
      }

      if (response.data!.token.isEmpty) {
        throw AppException('Token không hợp lệ');
      }

      print("CONCAK NÈ NÈ CLM");

      return response;
    } catch (e) {
      print('❌ LoginUseCase Error: $e');
      rethrow;
    }
  }
}