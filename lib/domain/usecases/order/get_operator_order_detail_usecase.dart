import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/core/exceptions/app_exception.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class GetOperatorOrderDetailUseCase {
  final IOrderRepository _orderRepository;

  GetOperatorOrderDetailUseCase(this._orderRepository);

  /// Execute - Lấy chi tiết đơn hàng FULL cho Operator
  /// Bao gồm: order lines, images, driver info, vehicle info, etc.
  Future<OperatorOrderDetailModel> execute({
    required String orderID,
  }) async {
    try {
      if (orderID.isEmpty) {
        throw AppException('Order ID không được để trống');
      }

      print('🔍 GetOperatorOrderDetailUseCase: Fetching order $orderID');

      final response = await _orderRepository.getOperatorOrderDetail(
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

      print('✅ Order detail loaded successfully');
      print('   - Customer: ${response.data!.customerName}');
      print('   - Driver: ${response.data!.driverName}');
      print('   - Status: ${response.data!.orderStatus.displayName}');
      print('   - Order Lines: ${response.data!.orderLineList1.length}');
      print('   - Images: ${response.data!.orderImageList.length}');
      print('   - Total Cost: ${response.data!.totalCost}');

      return response.data!;
    } catch (e) {
      print('❌ GetOperatorOrderDetailUseCase Error: $e');
      rethrow;
    }
  }
}