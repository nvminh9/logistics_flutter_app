import 'package:nalogistics_app/data/models/order/update_status_response_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/core/exceptions/app_exception.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class UpdateOrderStatusUseCase {
  final IOrderRepository _orderRepository;

  UpdateOrderStatusUseCase(this._orderRepository);

  Future<UpdatedOrderData> execute({
    required String orderID,
    required OrderStatus newStatus,
  }) async {
    try {
      if (orderID.isEmpty) {
        throw AppException('Order ID không được để trống');
      }

      print('🔄 Updating order $orderID to status: ${newStatus.displayName}');

      final response = await _orderRepository.updateOrderStatus(
        orderID: orderID,
        statusValue: newStatus.value,
      );

      if (!response.isSuccess) {
        throw AppException(response.message.isNotEmpty
            ? response.message
            : 'Không thể cập nhật trạng thái đơn hàng');
      }

      if (response.data == null) {
        throw AppException('Dữ liệu phản hồi không hợp lệ');
      }

      print('✅ Order status updated successfully');
      return response.data!;
    } catch (e) {
      print('❌ UpdateOrderStatusUseCase Error: $e');
      rethrow;
    }
  }
}