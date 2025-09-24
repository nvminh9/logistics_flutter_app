import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/update_status_response_model.dart';

abstract class IOrderRepository {
  // Danh sách đơn hàng của tài xế
  Future<OrderListResponse> getOrdersForDriver({
    String order = 'desc',
    String sortBy = 'id',
    int pageSize = 13,
    int pageNumber = 1,
  });

  // Chi tiết đơn hàng
  Future<OrderDetailResponse> getOrderDetail({
    required String orderID,
  });

  // Cập nhật trạng thái đơn hàng
  Future<UpdateStatusResponse> updateOrderStatus({
    required String orderID,
    required int statusValue,
  });
}
