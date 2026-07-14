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
  bool _locationServiceDisabled = false;
  String? _activeOrderId;
  String? _lastError;
  DateTime? _lastSentAt;
  double? _lastLatitude;
  double? _lastLongitude;

  bool get isTracking => _isTracking;
  bool get isSending => _isSending;
  bool get permissionDenied => _permissionDenied;
  bool get locationServiceDisabled => _locationServiceDisabled;
  String? get activeOrderId => _activeOrderId;
  String? get lastError => _lastError;
  DateTime? get lastSentAt => _lastSentAt;
  double? get lastLatitude => _lastLatitude;
  double? get lastLongitude => _lastLongitude;

  String get statusText {
    if (_locationServiceDisabled) return 'Dịch vụ định vị đang tắt';
    if (_isTracking) return 'Đang theo dõi hành trình';
    if (_permissionDenied) return 'Chưa cấp quyền định vị';
    return 'Không theo dõi hành trình';
  }

  bool get needsLocationAction => _permissionDenied || _locationServiceDisabled;

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

      final position = await _getBestAvailablePosition();

      await _trackingRepository.updateDriverLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        accuracy: position.accuracy,
      );

      _lastLatitude = position.latitude;
      _lastLongitude = position.longitude;
      _lastSentAt = DateTime.now();
    } catch (e) {
      _lastError = e.toString();
      await _refreshLocationReadinessState();
      print('Driver location tracking failed: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) return false;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _lastError = 'Dịch vụ định vị chưa được bật';
      _locationServiceDisabled = true;
      return false;
    }

    _locationServiceDisabled = false;
    return true;
  }

  Future<bool> requestLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _permissionDenied = true;
      _lastError = 'Ứng dụng chưa được cấp quyền định vị';
      notifyListeners();
      return false;
    }

    _permissionDenied = false;
    notifyListeners();
    return true;
  }

  Future<void> openAppLocationSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openDeviceLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<Position> _getBestAvailablePosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on TimeoutException {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return lastKnownPosition;
      }
      rethrow;
    }
  }

  Future<void> _refreshLocationReadinessState() async {
    final permission = await Geolocator.checkPermission();
    _permissionDenied =
        permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever;
    _locationServiceDisabled = !await Geolocator.isLocationServiceEnabled();
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
