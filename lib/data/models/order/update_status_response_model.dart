import 'package:nalogistics_app/core/base/base_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class UpdateStatusResponse extends BaseModel {
  final int statusCode;
  final String message;
  final UpdatedOrderData? data;

  UpdateStatusResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory UpdateStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateStatusResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UpdatedOrderData.fromJson(json['data'])
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

class UpdatedOrderData extends BaseModel {
  final int orderID;
  final DateTime orderDate;
  final int userId;
  final int customerId;
  final double totalCost;
  final String customerName;
  final int driverId;
  final String driverName;
  final int truckId;
  final int rmoocId;
  final String truckNo;
  final String rmoocNo;
  final String containerNo;
  final String containerType;
  final String billBookingNo;
  final int fromLocationId;
  final String fromLocationName;
  final int fromWhereId;
  final String fromWhereName;
  final int toLocationId;
  final String toLocationName;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int status;
  final bool isDelete;
  final String rowVersion;

  UpdatedOrderData({
    required this.orderID,
    required this.orderDate,
    required this.userId,
    required this.customerId,
    required this.totalCost,
    required this.customerName,
    required this.driverId,
    required this.driverName,
    required this.truckId,
    required this.rmoocId,
    required this.truckNo,
    required this.rmoocNo,
    required this.containerNo,
    required this.containerType,
    required this.billBookingNo,
    required this.fromLocationId,
    required this.fromLocationName,
    required this.fromWhereId,
    required this.fromWhereName,
    required this.toLocationId,
    required this.toLocationName,
    required this.createdDate,
    required this.updatedDate,
    required this.status,
    required this.isDelete,
    required this.rowVersion,
  });

  factory UpdatedOrderData.fromJson(Map<String, dynamic> json) {
    return UpdatedOrderData(
      orderID: json['orderID'] ?? 0,
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      userId: json['userId'] ?? 0,
      customerId: json['customerId'] ?? 0,
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      customerName: json['customerName'] ?? '',
      driverId: json['driverId'] ?? 0,
      driverName: json['driverName'] ?? '',
      truckId: json['truckId'] ?? 0,
      rmoocId: json['rmoocId'] ?? 0,
      truckNo: json['truckNo'] ?? '',
      rmoocNo: json['rmoocNo'] ?? '',
      containerNo: json['containerNo'] ?? '',
      containerType: json['containerType'] ?? '',
      billBookingNo: json['billBookingNo'] ?? '',
      fromLocationId: json['fromLocationId'] ?? 0,
      fromLocationName: json['fromLocationName'] ?? '',
      fromWhereId: json['fromWhereId'] ?? 0,
      fromWhereName: json['fromWhereName'] ?? '',
      toLocationId: json['toLocationId'] ?? 0,
      toLocationName: json['toLocationName'] ?? '',
      createdDate: DateTime.tryParse(json['createdDate'] ?? '') ?? DateTime.now(),
      updatedDate: DateTime.tryParse(json['updatedDate'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 0,
      isDelete: json['isDelete'] ?? false,
      rowVersion: json['rowVersion'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'orderDate': orderDate.toIso8601String(),
      'userId': userId,
      'customerId': customerId,
      'totalCost': totalCost,
      'customerName': customerName,
      'driverId': driverId,
      'driverName': driverName,
      'truckId': truckId,
      'rmoocId': rmoocId,
      'truckNo': truckNo,
      'rmoocNo': rmoocNo,
      'containerNo': containerNo,
      'containerType': containerType,
      'billBookingNo': billBookingNo,
      'fromLocationId': fromLocationId,
      'fromLocationName': fromLocationName,
      'fromWhereId': fromWhereId,
      'fromWhereName': fromWhereName,
      'toLocationId': toLocationId,
      'toLocationName': toLocationName,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'status': status,
      'isDelete': isDelete,
      'rowVersion': rowVersion,
    };
  }

  // Convert status to enum
  OrderStatus get orderStatus => OrderStatusExtension.fromValue(status);
}