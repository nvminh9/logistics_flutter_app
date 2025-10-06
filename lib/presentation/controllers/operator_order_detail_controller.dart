// lib/presentation/controllers/operator_order_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/order_repository.dart';
import 'package:nalogistics_app/domain/usecases/order/get_operator_order_detail_usecase.dart';
import 'package:nalogistics_app/domain/usecases/order/confirm_pending_order_usecase.dart';
import 'package:nalogistics_app/domain/usecases/order/update_order_status_usecase.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OperatorOrderDetailController extends BaseController {
  late final GetOperatorOrderDetailUseCase _getOrderDetailUseCase;
  late final ConfirmPendingOrderUseCase _confirmPendingOrderUseCase;
  late final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  late final OrderRepository _orderRepository;

  OperatorOrderDetailModel? _orderDetail;
  bool _isConfirming = false;
  bool _isUpdatingStatus = false;
  String? _currentOrderID; // Track current order ID

  // Getters
  OperatorOrderDetailModel? get orderDetail => _orderDetail;
  bool get isConfirming => _isConfirming;
  bool get isUpdatingStatus => _isUpdatingStatus;

  OperatorOrderDetailController() {
    _orderRepository = OrderRepository();
    _getOrderDetailUseCase = GetOperatorOrderDetailUseCase(_orderRepository);
    _confirmPendingOrderUseCase = ConfirmPendingOrderUseCase(_orderRepository);
    _updateOrderStatusUseCase = UpdateOrderStatusUseCase(_orderRepository);
  }

  /// Load chi tiết đơn hàng
  Future<void> loadOrderDetail(String orderID) async {
    try {
      setLoading(true);
      clearError();
      _currentOrderID = orderID; // Save current order ID

      print('📦 Loading operator order detail for ID: $orderID');

      final detail = await _getOrderDetailUseCase.execute(
        orderID: orderID,
      );

      _orderDetail = detail;

      print('✅ Operator order detail loaded successfully');
      print('   - Customer: ${detail.customerName}');
      print('   - Status: ${detail.orderStatus.displayName}');
      print('   - Driver: ${detail.driverName}');
      print('   - Total Cost: ${detail.totalCost}');

      setLoading(false);
      notifyListeners();

    } catch (e) {
      print('❌ Load Operator Order Detail Error: $e');
      setError(e.toString());
      setLoading(false);
      notifyListeners();
    }
  }

  /// ⭐ Xác nhận đơn hàng Pending → InProgress
  Future<bool> confirmPendingOrder() async {
    if (_orderDetail == null) {
      setError('Không có thông tin đơn hàng');
      return false;
    }

    if (_orderDetail!.orderStatus != OrderStatus.pending) {
      setError('Chỉ có thể xác nhận đơn hàng có trạng thái "Chờ xử lý"');
      return false;
    }

    try {
      _isConfirming = true;
      clearError();
      notifyListeners();

      // Sử dụng orderID từ createdDate như trong API
      final orderIdString = _orderDetail!.createdDate.millisecondsSinceEpoch.toString();

      print('🔄 Confirming pending order: ${_currentOrderID ?? orderIdString}');

      final confirmedOrderId = await _confirmPendingOrderUseCase.execute(
        orderID: _currentOrderID ?? orderIdString,
      );

      print('✅ Order confirmed successfully: $confirmedOrderId');

      _isConfirming = false;
      notifyListeners();

      return true;

    } catch (e) {
      print('❌ Confirm Order Error: $e');
      setError(e.toString());
      _isConfirming = false;
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật trạng thái đơn hàng (cho các status khác)
  Future<bool> updateOrderStatus(OrderStatus newStatus) async {
    if (_orderDetail == null) {
      setError('Không có thông tin đơn hàng');
      return false;
    }

    try {
      _isUpdatingStatus = true;
      clearError();
      notifyListeners();

      print('🔄 Updating operator order status to ${newStatus.displayName}');

      // Gọi API update status cho Operator
      await _orderRepository.updateOperatorOrderStatus(
        orderID: _currentOrderID ?? _orderDetail!.createdDate.millisecondsSinceEpoch.toString(),
        statusValue: newStatus.value,
      );

      print('✅ Order status updated successfully');

      _isUpdatingStatus = false;
      notifyListeners();

      return true;

    } catch (e) {
      print('❌ Update Order Status Error: $e');
      setError(e.toString());
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  /// Reload order detail với retry logic
  Future<void> reloadOrderDetail() async {
    if (_currentOrderID == null) {
      print('⚠️ No order ID to reload');
      return;
    }

    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 1);

    while (retryCount < maxRetries) {
      try {
        print('🔄 Reloading order detail (attempt ${retryCount + 1}/$maxRetries)');

        // Don't set loading state during reload to avoid UI flicker
        clearError();

        final detail = await _getOrderDetailUseCase.execute(
          orderID: _currentOrderID!,
        );

        _orderDetail = detail;
        print('✅ Order detail reloaded successfully');
        notifyListeners();
        return; // Success, exit

      } catch (e) {
        retryCount++;
        print('❌ Reload attempt $retryCount failed: $e');

        if (retryCount < maxRetries) {
          print('⏳ Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
        } else {
          // Final retry failed
          print('❌ All reload attempts failed');
          setError('Không thể tải lại thông tin đơn hàng. Vui lòng thử lại.');
          notifyListeners();
          return;
        }
      }
    }
  }

  /// Clear order detail
  void clearOrderDetail() {
    _orderDetail = null;
    _currentOrderID = null;
    clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    clearOrderDetail();
    super.dispose();
  }
}