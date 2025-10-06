import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/models/order/pending_image_model.dart';
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

  // Thêm vào OperatorOrderDetailController class

// ============================================
// IMAGE UPLOAD STATE & METHODS
// ============================================

  List<PendingImageModel> _pendingImages = [];
  bool _isUploadingImages = false;
  int _uploadProgress = 0;
  int _totalImagesToUpload = 0;

  List<PendingImageModel> get pendingImages => _pendingImages;
  bool get isUploadingImages => _isUploadingImages;
  int get uploadProgress => _uploadProgress;
  int get totalImagesToUpload => _totalImagesToUpload;

  double get uploadPercentage {
    if (_totalImagesToUpload == 0) return 0;
    return (_uploadProgress / _totalImagesToUpload) * 100;
  }

  /// Thêm ảnh vào danh sách pending
  void addPendingImage(File imageFile, {String description = ''}) {
    final pendingImage = PendingImageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageFile: imageFile,
      description: description,
      createdAt: DateTime.now(),
    );

    _pendingImages.add(pendingImage);
    notifyListeners();

    print('✅ Added pending image: ${pendingImage.id}');
    print('   Total pending: ${_pendingImages.length}');
  }

  /// Thêm nhiều ảnh
  void addMultiplePendingImages(List<File> imageFiles) {
    for (final file in imageFiles) {
      addPendingImage(file);
    }
  }

  /// Update description của ảnh pending
  void updatePendingImageDescription(String imageId, String description) {
    final index = _pendingImages.indexWhere((img) => img.id == imageId);
    if (index != -1) {
      _pendingImages[index] = _pendingImages[index].copyWith(
        description: description,
      );
      notifyListeners();
      print('✅ Updated description for image: $imageId');
    }
  }

  /// Xóa ảnh pending
  void removePendingImage(String imageId) {
    _pendingImages.removeWhere((img) => img.id == imageId);
    notifyListeners();
    print('✅ Removed pending image: $imageId');
    print('   Remaining: ${_pendingImages.length}');
  }

  /// Clear all pending images
  void clearPendingImages() {
    _pendingImages.clear();
    notifyListeners();
    print('✅ Cleared all pending images');
  }

  /// Upload tất cả pending images
  Future<bool> uploadAllPendingImages() async {
    if (_pendingImages.isEmpty) {
      print('⚠️ No pending images to upload');
      return false;
    }

    if (_currentOrderID == null) {
      setError('Không có thông tin đơn hàng');
      return false;
    }

    try {
      _isUploadingImages = true;
      _uploadProgress = 0;
      _totalImagesToUpload = _pendingImages.length;
      clearError();
      notifyListeners();

      print('📤 Starting upload of ${_pendingImages.length} images...');

      // Prepare data for upload
      final imagesToUpload = _pendingImages.map((img) => {
        'file': img.imageFile,
        'description': img.description.isEmpty
            ? 'Ảnh đơn hàng ${DateTime.now().toString().split('.')[0]}'
            : img.description,
      }).toList();

      // Upload
      final results = await _orderRepository.uploadMultipleImages(
        orderID: _currentOrderID!,
        images: imagesToUpload,
      );

      // Update progress
      _uploadProgress = results.length;
      notifyListeners();

      print('✅ Upload completed: ${results.length}/${_pendingImages.length} successful');

      // Check results
      final successCount = results.where((r) => r.isSuccess).length;
      final failCount = results.length - successCount;

      if (failCount > 0) {
        print('⚠️ Some uploads failed: $failCount images');
      }

      // Clear pending images after successful upload
      clearPendingImages();

      _isUploadingImages = false;
      _uploadProgress = 0;
      _totalImagesToUpload = 0;
      notifyListeners();

      return successCount > 0;

    } catch (e) {
      print('❌ Upload Images Error: $e');
      setError('Lỗi upload ảnh: ${e.toString()}');

      _isUploadingImages = false;
      _uploadProgress = 0;
      _totalImagesToUpload = 0;
      notifyListeners();

      return false;
    }
  }

  /// Get total size của tất cả pending images
  Future<double> getTotalPendingImagesSizeMB() async {
    double totalSize = 0;
    for (final img in _pendingImages) {
      totalSize += await img.getFileSizeMB();
    }
    return totalSize;
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