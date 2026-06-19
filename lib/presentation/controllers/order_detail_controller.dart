import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/pending_image_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/auth_repository.dart';
import 'package:nalogistics_app/data/repositories/implementations/order_repository.dart';
import 'package:nalogistics_app/domain/usecases/order/get_order_detail_usecase.dart';
import 'package:nalogistics_app/domain/usecases/order/update_order_status_usecase.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderDetailController extends BaseController {
  late final GetOrderDetailUseCase _getOrderDetailUseCase;
  late final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  late final OrderRepository _orderRepository;
  late final AuthRepository _authRepository;

  OrderDetailModel? _orderDetail;
  bool _isUpdatingStatus = false;
  String? _currentOrderID; // Track current order ID
  bool _driverSeenSent = false;

  // Getters
  OrderDetailModel? get orderDetail => _orderDetail;
  bool get isUpdatingStatus => _isUpdatingStatus;

  OrderDetailController() {
    _orderRepository = OrderRepository();
    _getOrderDetailUseCase = GetOrderDetailUseCase(_orderRepository);
    _updateOrderStatusUseCase = UpdateOrderStatusUseCase(_orderRepository);
    _authRepository = AuthRepository();
  }

  // Load chi tiết đơn hàng
  Future<void> loadOrderDetail(String orderID) async {
    try {
      setLoading(true);
      clearError();
      _currentOrderID = orderID; // Save current order ID
      _driverSeenSent = false;

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
        // orderImageList: updatedData.orderImageList,
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

  // Xem đơn hàng (Driver Role)
  Future<void> updateDriverSeenAt() async {
    try {
      print((await _authRepository.getRoleName()).toString().toUpperCase());
      print(!((await _authRepository.getRoleName()).toString().toUpperCase() == 'DRIVER'));
      if (!((await _authRepository.getRoleName()).toString().toUpperCase() == 'DRIVER')) {
        return;
      }

      if (_driverSeenSent) {
        return;
      }

      if (_currentOrderID == null) {
        return;
      }

      _driverSeenSent = true;

      await _orderRepository.updateDriverSeenAt(
        orderID: _currentOrderID!,
      );
    } catch (e) {
      print('❌ DriverSeenAt update failed: $e');
    }
  }

  void clearOrderDetail() {
    _orderDetail = null;
    clearError();
    notifyListeners();
  }

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

  /// UPDATED: Upload tất cả pending images với progress tracking
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

      // Upload with progress callback
      final results = await _orderRepository.uploadMultipleImages(
        orderID: _currentOrderID!,
        images: imagesToUpload,
        onProgress: (current, total) {
          _uploadProgress = current;
          notifyListeners(); // Update UI with progress
        },
      );

      print('✅ Upload completed: ${results.length}/${_pendingImages.length}');

      // Check results
      final successCount = results.where((r) => r.isSuccess).length;
      final failCount = results.length - successCount;

      if (failCount > 0) {
        print('⚠️ Some uploads failed: $failCount images');
        setError('Một số ảnh upload thất bại: $failCount/$_totalImagesToUpload');
      }

      // Clear pending images only for successful uploads
      if (successCount > 0) {
        // Remove successfully uploaded images
        for (int i = results.length - 1; i >= 0; i--) {
          if (results[i].isSuccess && i < _pendingImages.length) {
            _pendingImages.removeAt(i);
          }
        }
      }

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

  /// NEW: Upload single image (for immediate upload)
  Future<bool> uploadSingleImage(PendingImageModel pendingImage) async {
    if (_currentOrderID == null) {
      setError('Không có thông tin đơn hàng');
      return false;
    }

    try {
      print('📤 Uploading single image...');

      final response = await _orderRepository.uploadSingleImage(
        orderID: _currentOrderID!,
        imageFile: pendingImage.imageFile,
        description: pendingImage.description.isEmpty
            ? 'Ảnh đơn hàng'
            : pendingImage.description,
      );

      if (response.isSuccess) {
        print('✅ Image uploaded successfully');

        // Remove from pending list
        _pendingImages.removeWhere((img) => img.id == pendingImage.id);
        notifyListeners();

        return true;
      } else {
        print('❌ Upload failed: ${response.message}');
        setError(response.message);
        return false;
      }

    } catch (e) {
      print('❌ Upload Single Image Error: $e');
      setError('Lỗi upload ảnh: ${e.toString()}');
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

  @override
  void dispose() {
    clearOrderDetail();
    super.dispose();
  }
}