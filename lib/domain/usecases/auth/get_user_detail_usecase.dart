import 'package:nalogistics_app/data/models/auth/user_detail_response_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_auth_repository.dart';
import 'package:nalogistics_app/core/exceptions/app_exception.dart';

class GetUserDetailUseCase {
  final IAuthRepository _authRepository;

  GetUserDetailUseCase(this._authRepository);

  /// Execute - Lấy thông tin chi tiết user theo id
  Future<UserDetailModel> execute({required int id}) async {
    try {
      if (id <= 0) {
        throw AppException('User ID không hợp lệ');
      }

      print('🔍 GetUserDetailUseCase: Fetching detail for id: $id');

      final response = await _authRepository.getUserDetail(id: id);

      if (!response.isSuccess) {
        throw AppException(response.message.isNotEmpty
            ? response.message
            : 'Không thể lấy thông tin người dùng');
      }

      if (response.data == null) {
        throw AppException('Dữ liệu người dùng không hợp lệ');
      }

      final userDetail = response.data!;

      print('✅ User detail loaded successfully');
      print('   - User ID: ${userDetail.detailUser.userID}');
      print('   - Full Name: ${userDetail.detailUser.fullName}');
      print('   - Username: ${userDetail.detailUser.userName}');
      print('   - Role ID: ${userDetail.detailUser.roleID}');
      print('   - Orders Completed: ${userDetail.countOrderCompleted}');

      if (userDetail.detailDriver != null) {
        print('   - Driver Name: ${userDetail.detailDriver!.driverName}');
        print('   - License No: ${userDetail.detailDriver!.licenseNo}');
        print('   - Phone: ${userDetail.detailDriver!.phone}');
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