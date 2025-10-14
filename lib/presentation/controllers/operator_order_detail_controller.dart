import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/data/models/driver/driver_list_model.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/models/order/pending_image_model.dart';
import 'package:nalogistics_app/data/models/rmooc/rmooc_list_model.dart';
import 'package:nalogistics_app/data/models/truck/truck_list_model.dart';
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

      // Initialize original values after loading
      if (_orderDetail != null) {
        _initializeOriginalValues();
      }
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

  /// Clear order detail
  void clearOrderDetail() {
    _orderDetail = null;
    _currentOrderID = null;
    clearError();
    notifyListeners();
  }

  // ============================================
  // DRIVER ASSIGNMENT STATE & METHODS
  // ============================================

  List<DriverItemModel> _driverList = [];
  bool _isLoadingDrivers = false;
  bool _isAssigningDriver = false;
  String? _driverSearchQuery;

  List<DriverItemModel> get driverList => _driverList;
  bool get isLoadingDrivers => _isLoadingDrivers;
  bool get isAssigningDriver => _isAssigningDriver;
  String? get driverSearchQuery => _driverSearchQuery;

  // Filtered driver list dựa trên search query
  List<DriverItemModel> get filteredDriverList {
    if (_driverSearchQuery == null || _driverSearchQuery!.isEmpty) {
      return _driverList;
    }

    final query = _driverSearchQuery!.toLowerCase();
    return _driverList.where((driver) {
      return driver.driverName.toLowerCase().contains(query) ||
          driver.licenseNo.toLowerCase().contains(query);
    }).toList();
  }

  /// Load danh sách tài xế
  Future<void> loadDriverList({String? searchQuery}) async {
    try {
      _isLoadingDrivers = true;
      _driverSearchQuery = searchQuery;
      notifyListeners();

      print('📋 Loading driver list...');

      final response = await _orderRepository.getDriverList(
        keySearch: searchQuery,
        pageSize: 100,
        order: 'asc',
        sortBy: 'id',
      );

      if (response.isSuccess) {
        _driverList = response.data.where((d) => d.isActive).toList();
        print('✅ Loaded ${_driverList.length} active drivers');
      } else {
        print('❌ Failed to load drivers: ${response.message}');
        setError(response.message);
      }

      _isLoadingDrivers = false;
      notifyListeners();
    } catch (e) {
      print('❌ Load Driver List Error: $e');
      setError('Không thể tải danh sách tài xế');
      _isLoadingDrivers = false;
      notifyListeners();
    }
  }

  /// Chọn tài xế (chỉ update state, chưa call API)
  void selectDriver(DriverItemModel driver) {
    if (_orderDetail == null) return;

    print('🚗 Selecting driver: ${driver.driverName} (ID: ${driver.driverID})');

    // Update order detail với driver mới
    _orderDetail = OperatorOrderDetailModel(
      orderDate: _orderDetail!.orderDate,
      customerId: _orderDetail!.customerId,
      customerName: _orderDetail!.customerName,
      driverId: driver.driverID,
      driverName: driver.driverName,
      truckId: _orderDetail!.truckId,
      truckNo: _orderDetail!.truckNo,
      rmoocId: _orderDetail!.rmoocId,
      rmoocNo: _orderDetail!.rmoocNo,
      containerNo: _orderDetail!.containerNo,
      containerType: _orderDetail!.containerType,
      billBookingNo: _orderDetail!.billBookingNo,
      fromLocationID: _orderDetail!.fromLocationID,
      fromWhereID: _orderDetail!.fromWhereID,
      toLocationID: _orderDetail!.toLocationID,
      fromLocationName: _orderDetail!.fromLocationName,
      fromWhereName: _orderDetail!.fromWhereName,
      toLocationName: _orderDetail!.toLocationName,
      status: _orderDetail!.status,
      rowVersion: _orderDetail!.rowVersion,
      createdDate: _orderDetail!.createdDate,
      orderLineList1: _orderDetail!.orderLineList1,
      orderLineList: _orderDetail!.orderLineList,
      orderImageList: _orderDetail!.orderImageList,
    );

    notifyListeners();
    print('✅ Driver selected in state');
    _checkForChanges();
  }

  /// Phân công tài xế cho đơn hàng (call API)
  /// Gọi method này khi cần lưu thay đổi lên server
  Future<bool> assignDriverToOrder(int driverID) async {
    if (_currentOrderID == null) {
      setError('Không có thông tin đơn hàng');
      return false;
    }

    try {
      _isAssigningDriver = true;
      clearError();
      notifyListeners();

      print('🚗 Assigning driver $driverID to order $_currentOrderID');

      // Call API
      final response = await _orderRepository.assignDriverToOrder(
        orderID: _currentOrderID!,
        driverID: driverID,
      );

      if (response.isSuccess) {
        print('✅ Driver assigned successfully');
        _isAssigningDriver = false;
        notifyListeners();
        return true;
      } else {
        print('❌ Failed to assign driver: ${response.message}');
        setError(response.message);
        _isAssigningDriver = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Assign Driver Error: $e');
      setError('Không thể phân công tài xế: ${e.toString()}');
      _isAssigningDriver = false;
      notifyListeners();
      return false;
    }
  }

  /// Get selected driver info
  DriverItemModel? getSelectedDriver() {
    if (_orderDetail?.driverId == null) return null;

    return _driverList.firstWhere(
          (d) => d.driverID == _orderDetail!.driverId,
      orElse: () => DriverItemModel(
        driverID: _orderDetail!.driverId!,
        driverName: _orderDetail!.driverName,
        licenseNo: '',
        isActive: true,
        status: 0,
      ),
    );
  }

  /// Clear driver list
  void clearDriverList() {
    _driverList = [];
    _driverSearchQuery = null;
    notifyListeners();
  }

  // ============================================
  // TRUCK ASSIGNMENT STATE & METHODS
  // ============================================

  List<TruckItemModel> _truckList = [];
  bool _isLoadingTrucks = false;
  bool _isAssigningTruck = false;
  String? _truckSearchQuery;

  List<TruckItemModel> get truckList => _truckList;
  bool get isLoadingTrucks => _isLoadingTrucks;
  bool get isAssigningTruck => _isAssigningTruck;
  String? get truckSearchQuery => _truckSearchQuery;

  // Filtered truck list dựa trên search query
  List<TruckItemModel> get filteredTruckList {
    if (_truckSearchQuery == null || _truckSearchQuery!.isEmpty) {
      return _truckList;
    }

    final query = _truckSearchQuery!.toLowerCase();
    return _truckList.where((truck) {
      return truck.truckNo.toLowerCase().contains(query);
    }).toList();
  }

  /// Load danh sách xe
  Future<void> loadTruckList({String? searchQuery}) async {
    try {
      _isLoadingTrucks = true;
      _truckSearchQuery = searchQuery;
      notifyListeners();

      print('📋 Loading truck list...');

      final response = await _orderRepository.getTruckList(
        keySearch: searchQuery,
        pageSize: 30,
        order: 'asc',
        sortBy: 'id',
      );

      if (response.isSuccess) {
        _truckList = response.data.where((t) => t.isActive).toList();
        print('✅ Loaded ${_truckList.length} active trucks');
      } else {
        print('❌ Failed to load trucks: ${response.message}');
        setError(response.message);
      }

      _isLoadingTrucks = false;
      notifyListeners();
    } catch (e) {
      print('❌ Load Truck List Error: $e');
      setError('Không thể tải danh sách xe');
      _isLoadingTrucks = false;
      notifyListeners();
    }
  }

  /// Chọn xe (chỉ update state, chưa call API)
  void selectTruck(TruckItemModel truck) {
    if (_orderDetail == null) return;

    print('🚗 Selecting truck: ${truck.truckNo} (ID: ${truck.truckID})');

    // Update order detail với truck mới
    _orderDetail = OperatorOrderDetailModel(
      orderDate: _orderDetail!.orderDate,
      customerId: _orderDetail!.customerId,
      customerName: _orderDetail!.customerName,
      driverId: _orderDetail!.driverId,
      driverName: _orderDetail!.driverName,
      truckId: truck.truckID,
      truckNo: truck.truckNo,
      rmoocId: _orderDetail!.rmoocId,
      rmoocNo: _orderDetail!.rmoocNo,
      containerNo: _orderDetail!.containerNo,
      containerType: _orderDetail!.containerType,
      billBookingNo: _orderDetail!.billBookingNo,
      fromLocationID: _orderDetail!.fromLocationID,
      fromWhereID: _orderDetail!.fromWhereID,
      toLocationID: _orderDetail!.toLocationID,
      fromLocationName: _orderDetail!.fromLocationName,
      fromWhereName: _orderDetail!.fromWhereName,
      toLocationName: _orderDetail!.toLocationName,
      status: _orderDetail!.status,
      rowVersion: _orderDetail!.rowVersion,
      createdDate: _orderDetail!.createdDate,
      orderLineList1: _orderDetail!.orderLineList1,
      orderLineList: _orderDetail!.orderLineList,
      orderImageList: _orderDetail!.orderImageList,
    );

    notifyListeners();
    print('✅ Truck selected in state');
    _checkForChanges();
  }

  /// Phân công xe cho đơn hàng (call API)
  Future<bool> assignTruckToOrder(int truckID) async {
    if (_currentOrderID == null) {
      setError('Không có thông tin đơn hàng');
      return false;
    }

    try {
      _isAssigningTruck = true;
      clearError();
      notifyListeners();

      print('🚗 Assigning truck $truckID to order $_currentOrderID');

      final response = await _orderRepository.assignTruckToOrder(
        orderID: _currentOrderID!,
        truckID: truckID,
      );

      if (response.isSuccess) {
        print('✅ Truck assigned successfully');
        _isAssigningTruck = false;
        notifyListeners();
        return true;
      } else {
        print('❌ Failed to assign truck: ${response.message}');
        setError(response.message);
        _isAssigningTruck = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Assign Truck Error: $e');
      setError('Không thể phân công xe: ${e.toString()}');
      _isAssigningTruck = false;
      notifyListeners();
      return false;
    }
  }

  /// Get selected truck info
  TruckItemModel? getSelectedTruck() {
    if (_orderDetail?.truckId == null) return null;

    return _truckList.firstWhere(
          (t) => t.truckID == _orderDetail!.truckId,
      orElse: () => TruckItemModel(
        truckID: _orderDetail!.truckId!,
        truckNo: _orderDetail!.truckNo,
        isActive: true,
      ),
    );
  }

  /// Clear truck list
  void clearTruckList() {
    _truckList = [];
    _truckSearchQuery = null;
    notifyListeners();
  }

  // ============================================
  // RMOOC ASSIGNMENT STATE & METHODS
  // ============================================

  List<RmoocItemModel> _rmoocList = [];
  bool _isLoadingRmoocs = false;
  bool _isAssigningRmooc = false;
  String? _rmoocSearchQuery;

  List<RmoocItemModel> get rmoocList => _rmoocList;
  bool get isLoadingRmoocs => _isLoadingRmoocs;
  bool get isAssigningRmooc => _isAssigningRmooc;
  String? get rmoocSearchQuery => _rmoocSearchQuery;

  // Filtered rmooc list dựa trên search query
  List<RmoocItemModel> get filteredRmoocList {
    if (_rmoocSearchQuery == null || _rmoocSearchQuery!.isEmpty) {
      return _rmoocList;
    }

    final query = _rmoocSearchQuery!.toLowerCase();
    return _rmoocList.where((rmooc) {
      return rmooc.rmoocNo.toLowerCase().contains(query);
    }).toList();
  }

  /// Load danh sách rmooc
  Future<void> loadRmoocList({String? searchQuery}) async {
    try {
      _isLoadingRmoocs = true;
      _rmoocSearchQuery = searchQuery;
      notifyListeners();

      print('📋 Loading rmooc list...');

      final response = await _orderRepository.getRmoocList(
        keySearch: searchQuery,
        pageSize: 30,
        order: 'asc',
        sortBy: 'id',
      );

      if (response.isSuccess) {
        _rmoocList = response.data.where((t) => t.isActive).toList();
        print('✅ Loaded ${_rmoocList.length} active rmoocs');
      } else {
        print('❌ Failed to load rmoocs: ${response.message}');
        setError(response.message);
      }

      _isLoadingRmoocs = false;
      notifyListeners();
    } catch (e) {
      print('❌ Load Rmooc List Error: $e');
      setError('Không thể tải danh sách rmooc');
      _isLoadingRmoocs = false;
      notifyListeners();
    }
  }

  /// Chọn rmooc (chỉ update state, chưa call API)
  void selectRmooc(RmoocItemModel rmooc) {
    if (_orderDetail == null) return;

    print('🚗 Selecting rmooc: ${rmooc.rmoocNo} (ID: ${rmooc.rmoocID})');

    // Update order detail với rmooc mới
    _orderDetail = OperatorOrderDetailModel(
      orderDate: _orderDetail!.orderDate,
      customerId: _orderDetail!.customerId,
      customerName: _orderDetail!.customerName,
      driverId: _orderDetail!.driverId,
      driverName: _orderDetail!.driverName,
      truckId: _orderDetail!.truckId,
      truckNo: _orderDetail!.truckNo,
      rmoocId: rmooc.rmoocID,
      rmoocNo: rmooc.rmoocNo,
      containerNo: _orderDetail!.containerNo,
      containerType: _orderDetail!.containerType,
      billBookingNo: _orderDetail!.billBookingNo,
      fromLocationID: _orderDetail!.fromLocationID,
      fromWhereID: _orderDetail!.fromWhereID,
      toLocationID: _orderDetail!.toLocationID,
      fromLocationName: _orderDetail!.fromLocationName,
      fromWhereName: _orderDetail!.fromWhereName,
      toLocationName: _orderDetail!.toLocationName,
      status: _orderDetail!.status,
      rowVersion: _orderDetail!.rowVersion,
      createdDate: _orderDetail!.createdDate,
      orderLineList1: _orderDetail!.orderLineList1,
      orderLineList: _orderDetail!.orderLineList,
      orderImageList: _orderDetail!.orderImageList,
    );

    notifyListeners();
    print('✅ Truck selected in state');
    _checkForChanges();
  }

  /// Phân công rmooc cho đơn hàng (call API)
  Future<bool> assignRmoocToOrder(int rmoocID) async {
    if (_currentOrderID == null) {
      setError('Không có thông tin đơn hàng');
      return false;
    }

    try {
      _isAssigningRmooc = true;
      clearError();
      notifyListeners();

      print('🚗 Assigning rmooc $rmoocID to order $_currentOrderID');

      final response = await _orderRepository.assignRmoocToOrder(
        orderID: _currentOrderID!,
        rmoocID: rmoocID,
      );

      if (response.isSuccess) {
        print('✅ Truck assigned successfully');
        _isAssigningRmooc = false;
        notifyListeners();
        return true;
      } else {
        print('❌ Failed to assign rmooc: ${response.message}');
        setError(response.message);
        _isAssigningRmooc = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Assign Rmooc Error: $e');
      setError('Không thể phân công rmooc: ${e.toString()}');
      _isAssigningRmooc = false;
      notifyListeners();
      return false;
    }
  }

  /// Get selected rmooc info
  RmoocItemModel? getSelectedRmooc() {
    if (_orderDetail?.rmoocId == null) return null;

    return _rmoocList.firstWhere(
          (t) => t.rmoocID == _orderDetail!.rmoocId,
      orElse: () => RmoocItemModel(
        rmoocID: _orderDetail!.rmoocId!,
        rmoocNo: _orderDetail!.rmoocNo,
        isActive: true,
      ),
    );
  }

  /// Clear rmooc list
  void clearRmoocList() {
    _rmoocList = [];
    _rmoocSearchQuery = null;
    notifyListeners();
  }

  // ============================================
  // CHANGE TRACKING STATE
  // ============================================

  bool _hasUnsavedChanges = false;
  bool _isUpdatingOrder = false;
  // Store original values to track changes
  int? _originalDriverId;
  int? _originalTruckId;
  int? _originalRmoocId;
  String? _originalDriverName;
  String? _originalTruckNo;
  String? _originalRmoocNo;

  // Getters
  int? get originalDriverId => _originalDriverId;
  int? get originalTruckId => _originalTruckId;
  int? get originalRmoocId => _originalRmoocId;
  String? get originalDriverName => _originalDriverName;
  String? get originalTruckNo => _originalTruckNo;
  String? get originalRmoocNo => _originalRmoocNo;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isUpdatingOrder => _isUpdatingOrder;

  /// Initialize original values when loading order
  void _initializeOriginalValues() {
    if (_orderDetail == null) return;

    _originalDriverId = _orderDetail!.driverId;
    _originalTruckId = _orderDetail!.truckId;
    _originalRmoocId = _orderDetail!.rmoocId;
    _originalDriverName = _orderDetail!.driverName;
    _originalTruckNo = _orderDetail!.truckNo;
    _originalRmoocNo = _orderDetail!.rmoocNo;

    _hasUnsavedChanges = false;

    print('📝 Initialized original values:');
    print('   Driver: $_originalDriverId');
    print('   Truck: $_originalTruckId');
    print('   Rmooc: $_originalRmoocId');
  }

  /// Check if there are any changes
  void _checkForChanges() {
    if (_orderDetail == null) {
      _hasUnsavedChanges = false;
      return;
    }

    final hasDriverChanged = _orderDetail!.driverId != _originalDriverId;
    final hasTruckChanged = _orderDetail!.truckId != _originalTruckId;
    final hasRmoocChanged = _orderDetail!.rmoocId != _originalRmoocId;

    _hasUnsavedChanges = hasDriverChanged || hasTruckChanged || hasRmoocChanged;

    if (_hasUnsavedChanges) {
      print('⚠️ Detected unsaved changes:');
      if (hasDriverChanged) print('   - Driver: $_originalDriverId → ${_orderDetail!.driverId}');
      if (hasTruckChanged) print('   - Truck: $_originalTruckId → ${_orderDetail!.truckId}');
      if (hasRmoocChanged) print('   - Rmooc: $_originalRmoocId → ${_orderDetail!.rmoocId}');
    }

    notifyListeners();
  }

  /// Override selectDriver to track changes
  // @override
  // void selectDriver(DriverItemModel driver) {
  //   super.selectDriver(driver);
  //   _checkForChanges();
  // }

  /// Override selectTruck to track changes
  // @override
  // void selectTruck(TruckItemModel truck) {
  //   super.selectTruck(truck);
  //   _checkForChanges();
  // }

  /// Override selectRmooc to track changes
  // @override
  // void selectRmooc(RmoocItemModel rmooc) {
  //   super.selectRmooc(rmooc);
  //   _checkForChanges();
  // }

  /// Update order với changes
  Future<bool> updateOrder() async {
    if (_orderDetail == null || _currentOrderID == null) {
      setError('Không có thông tin đơn hàng');
      return false;
    }

    if (!_hasUnsavedChanges) {
      setError('Không có thay đổi nào để lưu');
      return false;
    }

    try {
      _isUpdatingOrder = true;
      clearError();
      notifyListeners();

      print('🔄 Updating order $_currentOrderID');
      print('   Changes detected: $_hasUnsavedChanges');

      // Prepare order data for update
      // final orderDTO = _orderDetail!.toJson();
      final Map<String, dynamic> orderDTO = {
        "OrderDate": _orderDetail!.orderDate.toIso8601String(),
        "CustomerId": _orderDetail!.customerId,
        "CustomerName": _orderDetail!.customerName,
        "DriverId": _orderDetail!.driverId,
        "driverName": _orderDetail!.driverName,
        "TruckId": _orderDetail!.truckId,
        "TruckNo": _orderDetail!.truckNo,
        "RmoocId": _orderDetail!.rmoocId,
        "RmoocNo": _orderDetail!.rmoocNo,
        "ContainerNo": _orderDetail!.containerNo,
        "ContainerType": _orderDetail!.containerType,
        "BillBookingNo": _orderDetail!.billBookingNo,
        "FromLocationID": _orderDetail!.fromLocationID,
        "FromWhereID": _orderDetail!.fromWhereID,
        "ToLocationID": _orderDetail!.toLocationID,
        "FromLocationName": _orderDetail!.fromLocationName,
        "FromWhereName": _orderDetail!.fromWhereName,
        "ToLocationName": _orderDetail!.toLocationName,
        "Status": _orderDetail!.status,
        "CreatedDate": _orderDetail!.createdDate.toIso8601String(),
        "OrderLineList": _orderDetail!.orderLineList1.map((e) => {
          "OrderLineId": e.orderLineId,
          "itemID": e.itemID,
          "itemName": e.orderLineItem.itemName,
          "itemDescription": e.itemDescription,
          "fixedPrice": e.orderLineItem.fixedPrice,
          "itemCost": e.itemCost.toInt(),
          "hasInvoice": e.hasInvoice,
          "invoiceNo": e.invoiceNo,
          "invoiceName": e.invoiceName,
          "isActive": e.isActive
        }).toList(),
      };

      // Call API
      final response = await _orderRepository.updateOrder(
        orderId: _currentOrderID!,
        orderDTO: orderDTO,
      );

      if (response.isSuccess) {
        print('✅ Order updated successfully');

        // Update original values to new values
        _initializeOriginalValues();

        _isUpdatingOrder = false;
        notifyListeners();
        return true;
      } else {
        print('❌ Update failed: ${response.message}');
        setError(response.message);
        _isUpdatingOrder = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Update Order Error: $e');
      setError('Không thể cập nhật đơn hàng: ${e.toString()}');
      _isUpdatingOrder = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset changes (discard)
  void discardChanges() async {
    if (_currentOrderID == null) return;

    // Reload order detail to reset to original values
    await loadOrderDetail(_currentOrderID!);
  }

  /// Update loadOrderDetail to initialize tracking
  // @override
  // Future<void> loadOrderDetail(String orderID) async {
  //   await super.loadOrderDetail(orderID);
  //
  //   // Initialize original values after loading
  //   if (_orderDetail != null) {
  //     _initializeOriginalValues();
  //   }
  // }

  @override
  void dispose() {
    clearOrderDetail();
    super.dispose();
  }
}