import 'package:nalogistics_app/data/models/driver/driver_list_model.dart';
import 'package:nalogistics_app/data/models/order/assign_driver_response_model.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/data/models/order/order_operator_model.dart';
import 'package:nalogistics_app/data/models/order/order_detail_api_model.dart';
import 'package:nalogistics_app/data/models/order/operator_order_detail_model.dart';
import 'package:nalogistics_app/data/models/order/pending_image_model.dart';
import 'package:nalogistics_app/data/models/order/update_status_response_model.dart';
import 'package:nalogistics_app/data/models/order/confirm_order_response_model.dart';
import 'package:nalogistics_app/data/repositories/interfaces/i_order_repository.dart';
import 'package:nalogistics_app/data/services/api/api_client.dart';
import 'package:nalogistics_app/core/constants/api_constants.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class OrderRepository implements IOrderRepository {
  final ApiClient _apiClient = ApiClient();

  // ========================================
  // DRIVER ROLE METHODS
  // ========================================

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
        ApiConstants.driverOrders,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return OrderListResponse.fromJson(response);
    } catch (e) {
      print('❌ Driver Order Repository Error: $e');
      rethrow;
    }
  }

  @override
  Future<OrderDetailResponse> getOrderDetail({
    required String orderID,
  }) async {
    try {
      final queryParams = {
        'orderID': orderID,
      };

      final response = await _apiClient.get(
        ApiConstants.driverOrderDetail,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return OrderDetailResponse.fromJson(response);
    } catch (e) {
      print('❌ Order Detail Repository Error: $e');
      rethrow;
    }
  }

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

      print('📤 Updating Driver order status: orderID=$orderID, status=$statusValue');

      final response = await _apiClient.put(
        ApiConstants.driverUpdateStatus,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return UpdateStatusResponse.fromJson(response);
    } catch (e) {
      print('❌ Update Driver Order Status Error: $e');
      rethrow;
    }
  }

  // ========================================
  // OPERATOR ROLE METHODS
  // ========================================

  @override
  Future<OperatorOrderListResponse> getOrdersForOperator({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 30,
    int pageNumber = 1,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParams = {
        'order': order,
        'sortBy': sortBy,
        'pageSize': pageSize.toString(),
        'pageNumber': pageNumber.toString(),
      };

      if (fromDate != null) {
        queryParams['fromDate'] = fromDate;
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate;
      }

      print('📤 Operator fetching orders: $queryParams');

      final response = await _apiClient.get(
        ApiConstants.operatorOrders,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return OperatorOrderListResponse.fromJson(response);
    } catch (e) {
      print('❌ Operator Order Repository Error: $e');
      rethrow;
    }
  }

  @override
  Future<OperatorOrderDetailResponse> getOperatorOrderDetail({
    required String orderID,
  }) async {
    try {
      final queryParams = {
        'id': orderID,
      };

      print('📤 Operator fetching order detail: id=$orderID');

      final response = await _apiClient.get(
        ApiConstants.operatorOrderDetail,
        queryParams: queryParams,
        requiresAuth: true,
      );

      print('📥 Operator order detail response: ${response['statusCode']}');

      return OperatorOrderDetailResponse.fromJson(response);
    } catch (e) {
      print('❌ Operator Order Detail Repository Error: $e');
      rethrow;
    }
  }

  @override
  Future<UpdateStatusResponse> updateOperatorOrderStatus({
    required String orderID,
    required int statusValue,
  }) async {
    try {
      final queryParams = {
        'orderID': orderID,
        'statusString': statusValue.toString(),
      };

      print('📤 Updating Operator order status: orderID=$orderID, status=$statusValue');

      final response = await _apiClient.put(
        ApiConstants.operatorUpdateStatus,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return UpdateStatusResponse.fromJson(response);
    } catch (e) {
      print('❌ Update Operator Order Status Error: $e');
      rethrow;
    }
  }

  @override
  Future<ConfirmOrderResponse> confirmPendingOrder({
    required String orderID,
  }) async {
    try {
      final queryParams = {
        'orderID': orderID,
      };

      print('📤 Operator confirming pending order: orderID=$orderID');

      final response = await _apiClient.put(
        ApiConstants.operatorConfirmOrder,
        queryParams: queryParams,
        requiresAuth: true,
      );

      print('📥 Confirm order response: ${response['statusCode']} - ${response['message']}');

      return ConfirmOrderResponse.fromJson(response);
    } catch (e) {
      print('❌ Confirm Pending Order Error: $e');
      rethrow;
    }
  }

  /// Get list of available drivers
  Future<DriverListResponse> getDriverList({
    String order = 'asc',
    String sortBy = 'id',
    int pageSize = 100,
    int pageNumber = 1,
    String? keySearch,
  }) async {
    try {
      final queryParams = {
        'order': order,
        'sortBy': sortBy,
        'pageSize': pageSize.toString(),
        'pageNumber': pageNumber.toString(),
      };

      if (keySearch != null && keySearch.isNotEmpty) {
        queryParams['keySearch'] = keySearch;
      }

      print('📤 Fetching driver list with params: $queryParams');

      final response = await _apiClient.get(
        ApiConstants.listDrivers,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return DriverListResponse.fromJson(response);
    } catch (e) {
      print('❌ Get Driver List Error: $e');
      rethrow;
    }
  }

  /// Assign driver to order
  Future<AssignDriverResponse> assignDriverToOrder({
    required String orderID,
    required int driverID,
  }) async {
    try {
      final queryParams = {
        'orderID': orderID,
        'driverID': driverID.toString(),
      };

      print('📤 Assigning driver $driverID to order $orderID');

      final response = await _apiClient.put(
        ApiConstants.assignDriver,
        queryParams: queryParams,
        requiresAuth: true,
      );

      print('📥 Assign driver response: ${response['statusCode']}');

      return AssignDriverResponse.fromJson(response);
    } catch (e) {
      print('❌ Assign Driver Error: $e');
      rethrow;
    }
  }

  // ========================================
  // IMAGE UPLOAD METHODS
  // ========================================

  /// ⭐ NEW: Upload single image
  @override
  Future<UploadImageResponse> uploadSingleImage({
    required String orderID,
    required File imageFile,
    required String description,
  }) async {
    try {
      print('📤 Uploading single image for order $orderID');
      print('   File: ${path.basename(imageFile.path)}');
      print('   Description: $description');

      // Use ApiClient's uploadMultipart method
      final response = await _apiClient.uploadMultipart(
        ApiConstants.uploadOrderImage,
        file: imageFile,
        fields: {
          'OrderID': orderID,
          'Descrip': description.isEmpty ? 'Không có ghi chú' : description,
        },
        requiresAuth: true,
      );

      final uploadResponse = UploadImageResponse.fromJson(response);

      if (uploadResponse.isSuccess) {
        print('   ✅ Image uploaded successfully: ${uploadResponse.data?.fileName}');
      } else {
        print('   ❌ Upload failed: ${uploadResponse.message}');
      }

      return uploadResponse;

    } catch (e) {
      print('❌ Upload Single Image Error: $e');
      rethrow;
    }
  }

  /// ⭐ UPDATED: Upload multiple images one by one
  @override
  Future<List<UploadImageResponse>> uploadMultipleImages({
    required String orderID,
    required List<Map<String, dynamic>> images,
    Function(int current, int total)? onProgress,
  }) async {
    final results = <UploadImageResponse>[];

    try {
      print('📤 Starting batch upload: ${images.length} images for order $orderID');

      for (int i = 0; i < images.length; i++) {
        final imageData = images[i];
        final file = imageData['file'] as File;
        final description = imageData['description'] as String? ?? '';

        try {
          print('   📸 Uploading image ${i + 1}/${images.length}...');

          // Call progress callback BEFORE upload
          onProgress?.call(i, images.length);

          // Upload single image
          final uploadResponse = await uploadSingleImage(
            orderID: orderID,
            imageFile: file,
            description: description,
          );

          results.add(uploadResponse);

          // Call progress callback AFTER successful upload
          if (uploadResponse.isSuccess) {
            onProgress?.call(i + 1, images.length);
          }

        } catch (e) {
          print('   ❌ Failed to upload image ${i + 1}: $e');

          // Add failed response
          results.add(UploadImageResponse(
            statusCode: 500,
            message: 'Upload failed: ${e.toString()}',
            data: null,
          ));
        }

        // Small delay between uploads to avoid overwhelming the server
        if (i < images.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      final successCount = results.where((r) => r.isSuccess).length;
      final failCount = results.length - successCount;

      print('📥 Batch upload complete:');
      print('   ✅ Success: $successCount/${images.length}');
      if (failCount > 0) {
        print('   ❌ Failed: $failCount/${images.length}');
      }

      return results;

    } catch (e) {
      print('❌ Upload Multiple Images Error: $e');
      rethrow;
    }
  }
}