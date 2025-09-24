import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/order_repository.dart';
import 'package:nalogistics_app/domain/usecases/order/get_order_detail_usecase.dart';
import 'package:nalogistics_app/domain/usecases/order/update_order_status_usecase.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderDetailController extends BaseController {
  late final GetOrderDetailUseCase _getOrderDetailUseCase;
  late final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  late final OrderRepository _orderRepository;

  OrderDetailModel? _orderDetail;
  bool _isUpdatingStatus = false;

  // Getters
  OrderDetailModel? get orderDetail => _orderDetail;
  bool get isUpdatingStatus => _isUpdatingStatus;

  OrderDetailController() {
    _orderRepository = OrderRepository();
    _getOrderDetailUseCase = GetOrderDetailUseCase(_orderRepository);
    _updateOrderStatusUseCase = UpdateOrderStatusUseCase(_orderRepository);
  }

  Future<void> loadOrderDetail(String orderID) async {
    try {
      setLoading(true);
      clearError();

      print('📦 Loading order detail for ID: $orderID');

      final detail = await _getOrderDetailUseCase.execute(
        orderID: orderID,
      );

      _orderDetail = detail;

      print('✅ Order detail loaded successfully');
      print('   - Customer: ${detail.customerName}');
      print('   - Status: ${detail.orderStatus.displayName}');
      print('   - Container: ${detail.containerNo}');

      setLoading(false);
      notifyListeners();

    } catch (e) {
      print('❌ Load Order Detail Error: $e');
      setError(e.toString());
      setLoading(false);
    }
  }

  Future<bool> updateOrderStatus(OrderStatus newStatus) async {
    try {
      if (_orderDetail == null) {
        throw Exception('No order detail loaded');
      }

      _isUpdatingStatus = true;
      clearError();
      notifyListeners();

      print('🔄 Updating order ${_orderDetail!.orderID} to ${newStatus.displayName}');

      // Gọi API update status
      final updatedData = await _updateOrderStatusUseCase.execute(
        orderID: _orderDetail!.orderID.toString(),
        newStatus: newStatus,
      );

      // Update local order detail với data mới từ API
      _orderDetail = OrderDetailModel(
        orderID: updatedData.orderID,
        customerName: updatedData.customerName,
        fromLocationName: updatedData.fromLocationName,
        fromWhereName: updatedData.fromWhereName,
        toLocationName: updatedData.toLocationName,
        containerNo: updatedData.containerNo,
        truckNo: updatedData.truckNo,
        rmoocNo: updatedData.rmoocNo,
        status: updatedData.status,
        orderDate: updatedData.orderDate,
      );

      _isUpdatingStatus = false;
      notifyListeners();

      print('✅ Order status updated successfully to ${newStatus.displayName}');
      return true;

    } catch (e) {
      print('❌ Update Order Status Error: $e');
      setError(e.toString());
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  // Reload order detail after update
  Future<void> reloadOrderDetail() async {
    if (_orderDetail != null) {
      await loadOrderDetail(_orderDetail!.orderID.toString());
    }
  }

  void clearOrderDetail() {
    _orderDetail = null;
    clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    clearOrderDetail();
    super.dispose();
  }
}