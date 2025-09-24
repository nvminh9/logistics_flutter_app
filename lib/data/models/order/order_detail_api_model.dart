import 'package:nalogistics_app/core/base/base_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderDetailResponse extends BaseModel {
  final int statusCode;
  final String message;
  final OrderDetailModel? data;

  OrderDetailResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? OrderDetailModel.fromJson(json['data'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => statusCode == 200;
}

class OrderDetailModel extends BaseModel {
  final int orderID;
  final String customerName;
  final String fromLocationName;
  final String fromWhereName;
  final String toLocationName;
  final String containerNo;
  final String truckNo;
  final String rmoocNo;
  final int status;
  final DateTime orderDate;

  OrderDetailModel({
    required this.orderID,
    required this.customerName,
    required this.fromLocationName,
    required this.fromWhereName,
    required this.toLocationName,
    required this.containerNo,
    required this.truckNo,
    required this.rmoocNo,
    required this.status,
    required this.orderDate,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      orderID: json['orderID'] ?? 0,
      customerName: json['customerName'] ?? '',
      fromLocationName: json['fromLocationName'] ?? '',
      fromWhereName: json['fromWhereName'] ?? '',
      toLocationName: json['toLocationName'] ?? '',
      containerNo: json['containerNo'] ?? '',
      truckNo: json['truckNo'] ?? '',
      rmoocNo: json['rmoocNo'] ?? '',
      status: json['status'] ?? 0,
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'customerName': customerName,
      'fromLocationName': fromLocationName,
      'fromWhereName': fromWhereName,
      'toLocationName': toLocationName,
      'containerNo': containerNo,
      'truckNo': truckNo,
      'rmoocNo': rmoocNo,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
    };
  }

  // Convert status to enum
  OrderStatus get orderStatus => OrderStatusExtension.fromValue(status);
}