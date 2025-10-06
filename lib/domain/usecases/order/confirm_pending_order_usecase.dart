// lib/domain/usecases/order/confirm_pending_order_usecase.dart

import 'package:nalogistics_app/data/models/order/confirm_order_response_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/core/exceptions/app_exception.dart';

class ConfirmPendingOrderUseCase {
  final IOrderRepository _orderRepository;

  ConfirmPendingOrderUseCase(this._orderRepository);

  /// Execute - Xác nhận đơn hàng pending (chuyển sang InProgress)
  /// Operator only
  Future<int> execute({
    required String orderID,
  }) async {
    try {
      if (orderID.isEmpty) {
        throw AppException('Order ID không được để trống');
      }

      print('✅ ConfirmPendingOrderUseCase: Confirming order $orderID');
      print('📤 API URL: ${_buildApiUrl(orderID)}');

      final response = await _orderRepository.confirmPendingOrder(
        orderID: orderID,
      );

      print('📥 API Response:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Message: ${response.message}');
      print('   - Data: ${response.data}');

      if (!response.isSuccess) {
        print('❌ API returned error: ${response.message}');
        throw AppException(response.message.isNotEmpty
            ? response.message
            : 'Không thể xác nhận đơn hàng');
      }

      if (response.data == null) {
        print('❌ API returned null data');
        throw AppException('Dữ liệu phản hồi không hợp lệ');
      }

      print('✅ Order confirmed successfully: ${response.data}');
      return response.data!;
    } catch (e) {
      print('❌ ConfirmPendingOrderUseCase Error: $e');

      // Better error messages
      if (e is AppException) {
        rethrow;
      } else if (e.toString().contains('404')) {
        throw AppException('Không tìm thấy đơn hàng');
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        throw AppException('Không có quyền xác nhận đơn hàng');
      } else if (e.toString().contains('timeout')) {
        throw AppException('Kết nối quá chậm, vui lòng thử lại');
      } else if (e.toString().contains('SocketException')) {
        throw AppException('Không có kết nối internet');
      } else {
        throw AppException('Lỗi xác nhận đơn hàng: ${e.toString()}');
      }
    }
  }

  /// Helper to show API URL for debugging
  String _buildApiUrl(String orderID) {
    return '/api/Order/updateStatusOrderForOperator?orderID=$orderID';
  }
}