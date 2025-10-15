import 'package:nalogistics_app/data/models/auth/user_detail_response_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_auth_repository.dart';
import 'package:nalogistics_app/core/exceptions/app_exception.dart';

class GetUserDetailUseCase {
  final IAuthRepository _authRepository;

  GetUserDetailUseCase(this._authRepository);

  /// Execute - Lấy thông tin chi tiết user
  /// Bao gồm: detailUser, detailDriver (nếu có), countOrderCompleted
  Future<UserDetailModel> execute({required String userId}) async {
    try {
      if (userId.trim().isEmpty) {
        throw AppException('User ID không được để trống');
      }

      print('🔍 GetUserDetailUseCase: Fetching user detail for ID: $userId');

      final userDetail = await _authRepository.getUserDetail(userID: userId);

      print('✅ User detail loaded successfully');
      print('   - User ID: ${userDetail.detailUser.userID}');
      print('   - Full Name: ${userDetail.detailUser.fullName}');
      print('   - Role: ${userDetail.detailUser.role}');
      print('   - Orders Completed: ${userDetail.countOrderCompleted}');

      if (userDetail.detailDriver != null) {
        print('   - Driver Name: ${userDetail.detailDriver!.driverName}');
        print('   - License No: ${userDetail.detailDriver!.licenseNo}');
      }

      return userDetail;
    } catch (e) {
      print('❌ GetUserDetailUseCase Error: $e');

      if (e is AppException) {
        rethrow;
      } else if (e.toString().contains('404')) {
        throw AppException('Không tìm thấy thông tin người dùng');
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        throw AppException('Không có quyền truy cập thông tin người dùng');
      } else if (e.toString().contains('timeout')) {
        throw AppException('Kết nối quá chậm, vui lòng thử lại');
      } else if (e.toString().contains('SocketException')) {
        throw AppException('Không có kết nối internet');
      } else {
        throw AppException('Lỗi tải thông tin người dùng: ${e.toString()}');
      }
    }
  }
}