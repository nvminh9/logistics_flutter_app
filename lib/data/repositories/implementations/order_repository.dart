import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/update_status_response_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/data/services/api/api_client.dart';
import 'package:nalogistics_app/core/constants/api_constants.dart';

class OrderRepository implements IOrderRepository {
  final ApiClient _apiClient = ApiClient();

  // Danh sách đơn hàng của tài xế
  @override
  Future<OrderListResponse> getOrdersForDriver({
    String order = 'desc',
    String sortBy = 'id',
    int pageSize = 13,
    int pageNumber = 1,
  }) async {
    try {
      final queryParams = {
        'order': order,
        'sortBy': sortBy,
        'pageSize': pageSize.toString(),
        'pageNumber': pageNumber.toString(),
      };

      final response = await _apiClient.get(
        ApiConstants.orders,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return OrderListResponse.fromJson(response);
    } catch (e) {
      print('❌ Order Repository Error: $e');
      rethrow;
    }
  }

  // Chi tiết đơn hàng
  @override
  Future<OrderDetailResponse> getOrderDetail({
    required String orderID,
  }) async {
    try {
      final queryParams = {
        'orderID': orderID,
      };

      final response = await _apiClient.get(
        ApiConstants.orderDetail,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return OrderDetailResponse.fromJson(response);
    } catch (e) {
      print('❌ Order Detail Repository Error: $e');
      rethrow;
    }
  }

  // Cập nhật trạng thái đơn hàng
  @override
  Future<UpdateStatusResponse> updateOrderStatus({
    required String orderID,
    required int statusValue,
  }) async {
    try {
      final queryParams = {
        'orderID': orderID,
        'statusString': statusValue.toString(),
      };

      print('📤 Updating order status: orderID=$orderID, status=$statusValue');

      final response = await _apiClient.put(
        ApiConstants.updateOrderStatus,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return UpdateStatusResponse.fromJson(response);
    } catch (e) {
      print('❌ Update Order Status Repository Error: $e');
      rethrow;
    }
  }
}