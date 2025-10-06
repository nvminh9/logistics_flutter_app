import 'package:nalogistics_app/core/base/base_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

/// Response model cho Operator Order Detail API
class OperatorOrderDetailResponse extends BaseModel {
  final int statusCode;
  final String message;
  final OperatorOrderDetailModel? data;

  OperatorOrderDetailResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory OperatorOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OperatorOrderDetailResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? OperatorOrderDetailModel.fromJson(json['data'])
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

/// Full detail model cho Operator
class OperatorOrderDetailModel extends BaseModel {
  final DateTime orderDate;
  final int customerId;
  final String customerName;
  final int? driverId;
  final String driverName;
  final int? truckId;
  final String truckNo;
  final int? rmoocId;
  final String rmoocNo;
  final String containerNo;
  final String containerType;
  final String billBookingNo;
  final int fromLocationID;
  final int fromWhereID;
  final int toLocationID;
  final String fromLocationName;
  final String fromWhereName;
  final String toLocationName;
  final int status;
  final String rowVersion;
  final DateTime createdDate;
  final List<OrderLineModel> orderLineList1;
  final List<OrderLineModel> orderLineList;
  final List<OrderImageModel> orderImageList;

  OperatorOrderDetailModel({
    required this.orderDate,
    required this.customerId,
    required this.customerName,
    this.driverId,
    required this.driverName,
    this.truckId,
    required this.truckNo,
    this.rmoocId,
    required this.rmoocNo,
    required this.containerNo,
    required this.containerType,
    required this.billBookingNo,
    required this.fromLocationID,
    required this.fromWhereID,
    required this.toLocationID,
    required this.fromLocationName,
    required this.fromWhereName,
    required this.toLocationName,
    required this.status,
    required this.rowVersion,
    required this.createdDate,
    required this.orderLineList1,
    required this.orderLineList,
    required this.orderImageList,
  });

  factory OperatorOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OperatorOrderDetailModel(
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      driverId: json['driverId'],
      driverName: json['driverName'] ?? '',
      truckId: json['truckId'],
      truckNo: json['truckNo'] ?? '',
      rmoocId: json['rmoocId'],
      rmoocNo: json['rmoocNo'] ?? '',
      containerNo: json['containerNo'] ?? '',
      containerType: json['containerType'] ?? '',
      billBookingNo: json['billBookingNo'] ?? '',
      fromLocationID: json['fromLocationID'] ?? 0,
      fromWhereID: json['fromWhereID'] ?? 0,
      toLocationID: json['toLocationID'] ?? 0,
      fromLocationName: json['fromLocationName'] ?? '',
      fromWhereName: json['fromWhereName'] ?? '',
      toLocationName: json['toLocationName'] ?? '',
      status: json['status'] ?? 0,
      rowVersion: json['rowVersion'] ?? '',
      createdDate: DateTime.tryParse(json['createdDate'] ?? '') ?? DateTime.now(),
      orderLineList1: (json['orderLineList1'] as List<dynamic>?)
          ?.map((item) => OrderLineModel.fromJson(item))
          .toList() ??
          [],
      orderLineList: (json['orderLineList'] as List<dynamic>?)
          ?.map((item) => OrderLineModel.fromJson(item))
          .toList() ??
          [],
      orderImageList: (json['orderImageList'] as List<dynamic>?)
          ?.map((item) => OrderImageModel.fromJson(item))
          .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'orderDate': orderDate.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'driverId': driverId,
      'driverName': driverName,
      'truckId': truckId,
      'truckNo': truckNo,
      'rmoocId': rmoocId,
      'rmoocNo': rmoocNo,
      'containerNo': containerNo,
      'containerType': containerType,
      'billBookingNo': billBookingNo,
      'fromLocationID': fromLocationID,
      'fromWhereID': fromWhereID,
      'toLocationID': toLocationID,
      'fromLocationName': fromLocationName,
      'fromWhereName': fromWhereName,
      'toLocationName': toLocationName,
      'status': status,
      'rowVersion': rowVersion,
      'createdDate': createdDate.toIso8601String(),
      'orderLineList1': orderLineList1.map((e) => e.toJson()).toList(),
      'orderLineList': orderLineList.map((e) => e.toJson()).toList(),
      'orderImageList': orderImageList.map((e) => e.toJson()).toList(),
    };
  }

  // Helper getters
  OrderStatus get orderStatus => OrderStatusExtension.fromValue(status);

  double get totalCost {
    return orderLineList1.fold(
      0.0,
          (sum, line) => sum + (line.itemCost > 0 ? line.itemCost : line.orderLineItem.fixedPrice),
    );
  }

  List<OrderLineModel> get activeOrderLines {
    return orderLineList1.where((line) => line.isActive).toList();
  }

  List<OrderImageModel> get activeImages {
    return orderImageList.where((img) => img.isActive).toList();
  }
}

/// Order Line (Chi phí của đơn hàng)
class OrderLineModel extends BaseModel {
  final OrderLineItemModel orderLineItem;
  final int orderLineId;
  final int orderId;
  final int itemID;
  final String itemDescription;
  final double itemCost;
  final bool hasInvoice;
  final String invoiceName;
  final String invoiceNo;
  final bool isActive;

  OrderLineModel({
    required this.orderLineItem,
    required this.orderLineId,
    required this.orderId,
    required this.itemID,
    required this.itemDescription,
    required this.itemCost,
    required this.hasInvoice,
    required this.invoiceName,
    required this.invoiceNo,
    required this.isActive,
  });

  factory OrderLineModel.fromJson(Map<String, dynamic> json) {
    return OrderLineModel(
      orderLineItem: OrderLineItemModel.fromJson(json['orderLineItem'] ?? {}),
      orderLineId: json['orderLineId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      itemID: json['itemID'] ?? 0,
      itemDescription: json['itemDescription'] ?? '',
      itemCost: (json['itemCost'] ?? 0).toDouble(),
      hasInvoice: json['hasInvoice'] ?? false,
      invoiceName: json['invoiceName'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'orderLineItem': orderLineItem.toJson(),
      'orderLineId': orderLineId,
      'orderId': orderId,
      'itemID': itemID,
      'itemDescription': itemDescription,
      'itemCost': itemCost,
      'hasInvoice': hasInvoice,
      'invoiceName': invoiceName,
      'invoiceNo': invoiceNo,
      'isActive': isActive,
    };
  }

  // Lấy giá thực tế (ưu tiên itemCost, fallback là fixedPrice)
  double get actualCost => itemCost > 0 ? itemCost : orderLineItem.fixedPrice;
}

/// Order Line Item (Master data)
class OrderLineItemModel extends BaseModel {
  final String itemName;
  final double fixedPrice;
  final int displayOrder;

  OrderLineItemModel({
    required this.itemName,
    required this.fixedPrice,
    required this.displayOrder,
  });

  factory OrderLineItemModel.fromJson(Map<String, dynamic> json) {
    return OrderLineItemModel(
      itemName: json['itemName'] ?? '',
      fixedPrice: (json['fixedPrice'] ?? 0).toDouble(),
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'fixedPrice': fixedPrice,
      'displayOrder': displayOrder,
    };
  }
}

/// Order Image (Hình ảnh đơn hàng)
class OrderImageModel extends BaseModel {
  final int imageID;
  final String fileName;
  final String url;
  final int userID;
  final String descrip;
  final DateTime created;
  final bool isActive;
  final int orderID;

  OrderImageModel({
    required this.imageID,
    required this.fileName,
    required this.url,
    required this.userID,
    required this.descrip,
    required this.created,
    required this.isActive,
    required this.orderID,
  });

  factory OrderImageModel.fromJson(Map<String, dynamic> json) {
    return OrderImageModel(
      imageID: json['imageID'] ?? 0,
      fileName: json['fileName'] ?? '',
      url: json['url'] ?? '',
      userID: json['userID'] ?? 0,
      descrip: json['descrip'] ?? 'Chưa có chú thích',
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false,
      orderID: json['orderID'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'imageID': imageID,
      'fileName': fileName,
      'url': url,
      'userID': userID,
      'descrip': descrip,
      'created': created.toIso8601String(),
      'isActive': isActive,
      'orderID': orderID,
    };
  }
}