import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/tracking_repository.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class DriverLocationTrackingController extends ChangeNotifier {
  static const Duration _trackingInterval = Duration(seconds: 4);

  final TrackingRepository _trackingRepository = TrackingRepository();

  Timer? _trackingTimer;
  bool _isTracking = false;
  bool _isSending = false;
  bool _permissionDenied = false;
  String? _activeOrderId;
  String? _lastError;
  DateTime? _lastSentAt;
  double? _lastLatitude;
  double? _lastLongitude;

  bool get isTracking => _isTracking;
  bool get isSending => _isSending;
  bool get permissionDenied => _permissionDenied;
  String? get activeOrderId => _activeOrderId;
  String? get lastError => _lastError;
  DateTime? get lastSentAt => _lastSentAt;
  double? get lastLatitude => _lastLatitude;
  double? get lastLongitude => _lastLongitude;

  String get statusText {
    if (_isTracking) return 'Đang theo dõi hành trình';
    if (_permissionDenied) return 'Chưa cấp quyền định vị';
    return 'Không theo dõi hành trình';
  }

  Future<void> syncWithOrders({
    required bool isDriver,
    required Map<OrderStatus, List<OrderApiModel>> ordersByStatus,
  }) async {
    if (!isDriver) {
      stopTracking();
      return;
    }

    final activeOrder = _findActiveTrackingOrder(ordersByStatus);
    if (activeOrder == null) {
      stopTracking();
      return;
    }

    if (_isTracking && _activeOrderId == activeOrder.orderID) {
      return;
    }

    await startTracking(orderId: activeOrder.orderID);
  }

  Future<void> startTracking({required String orderId}) async {
    _trackingTimer?.cancel();
    _activeOrderId = orderId;
    _lastError = null;

    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      _isTracking = false;
      notifyListeners();
      return;
    }

    _isTracking = true;
    _permissionDenied = false;
    notifyListeners();

    await sendCurrentLocation();

    _trackingTimer = Timer.periodic(_trackingInterval, (_) {
      sendCurrentLocation();
    });
  }

  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;
    _isSending = false;
    _activeOrderId = null;
    notifyListeners();
  }

  Future<void> sendCurrentLocation() async {
    if (_isSending) return;

    try {
      _isSending = true;
      _lastError = null;
      notifyListeners();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _trackingRepository.updateDriverLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _lastLatitude = position.latitude;
      _lastLongitude = position.longitude;
      _lastSentAt = DateTime.now();
    } catch (e) {
      _lastError = e.toString();
      print('Driver location tracking failed: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _lastError = 'Dịch vụ định vị chưa được bật';
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _permissionDenied = true;
      _lastError = 'Ứng dụng chưa được cấp quyền định vị';
      return false;
    }

    return true;
  }

  OrderApiModel? _findActiveTrackingOrder(
    Map<OrderStatus, List<OrderApiModel>> ordersByStatus,
  ) {
    final inTransitOrders = ordersByStatus[OrderStatus.inTransit] ?? [];
    if (inTransitOrders.isNotEmpty) return inTransitOrders.first;

    final pickedUpOrders = ordersByStatus[OrderStatus.pickedUp] ?? [];
    if (pickedUpOrders.isNotEmpty) return pickedUpOrders.first;

    return null;
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }
}
