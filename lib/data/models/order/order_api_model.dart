import 'package:nalogistics_app/core/base/base_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderListResponse extends BaseModel {
  final int statusCode;
  final String message;
  final List<OrderApiModel> data;

  OrderListResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => OrderApiModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data.map((order) => order.toJson()).toList(),
    };
  }

  bool get isSuccess => statusCode == 200;
}

class OrderApiModel extends BaseModel {
  final String orderID;
  final String customerName;
  final int status; // 0-6 từ API
  final DateTime orderDate;
  final double totalCost;
  final String? customerPhone;
  final String? customerAddress;
  final String? notes;

  OrderApiModel({
    required this.orderID,
    required this.customerName,
    required this.status,
    required this.orderDate,
    required this.totalCost,
    this.customerPhone,
    this.customerAddress,
    this.notes,
  });

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    return OrderApiModel(
      orderID: json['orderID']?.toString() ?? '',
      customerName: json['customerName'] ?? '',
      status: json['status'] ?? 0,
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      notes: json['notes'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'customerName': customerName,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'totalCost': totalCost,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'notes': notes,
    };
  }

  // Convert to enum
  OrderStatus get orderStatus => OrderStatusExtension.fromValue(status);
}