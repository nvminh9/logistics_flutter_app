// lib/data/repositories/interfaces/i_order_repository.dart

import 'dart:io';
import 'package:nalogistics_app/data/models/driver/driver_list_model.dart';
import 'package:nalogistics_app/data/models/order/assign_driver_response_model.dart';
import 'package:nalogistics_app/data/models/order/assign_rmooc_response_model.dart';
import 'package:nalogistics_app/data/models/order/assign_truck_response_model.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_operator_model.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/models/order/update_status_response_model.dart';
import 'package:nalogistics_app/data/models/order/confirm_order_response_model.dart';
import 'package:nalogistics_app/data/models/order/pending_image_model.dart';
import 'package:nalogistics_app/data/models/rmooc/rmooc_list_model.dart';
import 'package:nalogistics_app/data/models/truck/truck_list_model.dart';

abstract class IOrderRepository {
  // ========================================
  // DRIVER ROLE METHODS
  // ========================================

  /// ⭐ UPDATED: Default order='desc', sortBy='orderDate'
  Future<OrderListResponse> getOrdersForDriver({
    String order = 'desc',        // ⭐ Changed default
    String sortBy = 'orderDate',  // ⭐ Changed default
    int pageSize = 13,
    int pageNumber = 1,
    String? searchKey,
    int? status,
  });

  Future<OrderDetailResponse> getOrderDetail({
    required String orderID,
  });

  Future<UpdateStatusResponse> updateOrderStatus({
    required String orderID,
    required int statusValue,
  });

  // ========================================
  // OPERATOR ROLE METHODS
  // ========================================

  /// ⭐ UPDATED: Default order='desc', sortBy='orderDate'
  Future<OperatorOrderListResponse> getOrdersForOperator({
    String order = 'desc',        // ⭐ Changed default
    String sortBy = 'orderDate',  // ⭐ Changed default
    int pageSize = 30,
    int pageNumber = 1,
    String? fromDate,
    String? toDate,
    String? searchKey,
    int? status,
  });

  Future<OperatorOrderDetailResponse> getOperatorOrderDetail({
    required String orderID,
  });

  Future<UpdateStatusResponse> updateOperatorOrderStatus({
    required String orderID,
    required int statusValue,
  });

  Future<ConfirmOrderResponse> confirmPendingOrder({
    required String orderID,
  });

  // ========================================
  // DRIVER MANAGEMENT METHODS
  // ========================================

  Future<DriverListResponse> getDriverList({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 100,
    int pageNumber = 1,
    String? keySearch,
  });

  Future<AssignDriverResponse> assignDriverToOrder({
    required String orderID,
    required int driverID,
  });

  // ========================================
  // TRUCK MANAGEMENT METHODS
  // ========================================

  Future<TruckListResponse> getTruckList({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? keySearch,
  });

  Future<AssignTruckResponse> assignTruckToOrder({
    required String orderID,
    required int truckID,
  });

  // ========================================
  // RMOOC MANAGEMENT METHODS
  // ========================================

  Future<RmoocListResponse> getRmoocList({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? keySearch,
  });

  Future<AssignRmoocResponse> assignRmoocToOrder({
    required String orderID,
    required int rmoocID,
  });

  // ========================================
  // IMAGE UPLOAD METHODS
  // ========================================

  Future<UploadImageResponse> uploadSingleImage({
    required String orderID,
    required File imageFile,
    required String description,
  });

  Future<List<UploadImageResponse>> uploadMultipleImages({
    required String orderID,
    required List<Map<String, dynamic>> images,
    Function(int current, int total)? onProgress,
  });
}