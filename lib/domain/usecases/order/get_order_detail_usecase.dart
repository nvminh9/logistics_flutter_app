import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/core/exceptions/app_exception.dart';

class GetOrderDetailUseCase {
  final IOrderRepository _orderRepository;

  GetOrderDetailUseCase(this._orderRepository);

  Future<OrderDetailModel> execute({
    required String orderID,
  }) async {
    try {
      if (orderID.isEmpty) {
        throw AppException('Order ID không được để trống');
      }

      final response = await _orderRepository.getOrderDetail(
        orderID: orderID,
      );

      if (!response.isSuccess) {
        throw AppException(response.message.isNotEmpty
            ? response.message
            : 'Không thể lấy thông tin đơn hàng');
      }

      if (response.data == null) {
        throw AppException('Dữ liệu đơn hàng không hợp lệ');
      }

      return response.data!;
    } catch (e) {
      print('❌ GetOrderDetailUseCase Error: $e');
      rethrow;
    }
  }
}