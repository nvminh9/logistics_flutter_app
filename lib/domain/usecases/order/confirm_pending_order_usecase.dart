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

      final response = await _orderRepository.confirmPendingOrder(
        orderID: orderID,
      );

      if (!response.isSuccess) {
        throw AppException(response.message.isNotEmpty
            ? response.message
            : 'Không thể xác nhận đơn hàng');
      }

      if (response.data == null) {
        throw AppException('Dữ liệu phản hồi không hợp lệ');
      }

      print('✅ Order confirmed successfully: ${response.data}');
      return response.data!;
    } catch (e) {
      print('❌ ConfirmPendingOrderUseCase Error: $e');
      rethrow;
    }
  }
}