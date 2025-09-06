import 'package:nalogistics_app/core/base/base_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderModel extends BaseModel {
  final String orderID;
  final String customerName;
  final DateTime orderDate;
  final double totalCost;
  final OrderStatus status;
  final String? customerPhone;
  final String? customerAddress;
  final String? notes;

  OrderModel({
    required this.orderID,
    required this.customerName,
    required this.orderDate,
    required this.totalCost,
    required this.status,
    this.customerPhone,
    this.customerAddress,
    this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderID: json['orderID'] ?? '',
      customerName: json['customer_name'] ?? '',
      orderDate: DateTime.parse(json['order_date'] ?? ''),
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      status: _parseStatus(json['status']),
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      notes: json['notes'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'customer_name': customerName,
      'order_date': orderDate.toIso8601String(),
      'total_cost': totalCost,
      'status': status.value,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'notes': notes,
    };
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return OrderStatus.inProgress;
      case 'pickedUp':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.inProgress;
    }
  }
}