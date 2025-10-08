import 'package:nalogistics_app/core/base/base_model.dart';

/// Response model cho Truck List API
class TruckListResponse extends BaseModel {
  final int statusCode;
  final String message;
  final List<TruckItemModel> data;

  TruckListResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory TruckListResponse.fromJson(Map<String, dynamic> json) {
    return TruckListResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => TruckItemModel.fromJson(item))
          .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  bool get isSuccess => statusCode == 200;
}

/// Model cho từng truck item
class TruckItemModel extends BaseModel {
  final int truckID;
  final String truckNo;
  final bool isActive;

  TruckItemModel({
    required this.truckID,
    required this.truckNo,
    required this.isActive,
  });

  factory TruckItemModel.fromJson(Map<String, dynamic> json) {
    return TruckItemModel(
      truckID: json['truckID'] ?? 0,
      truckNo: json['truckNo'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'truckID': truckID,
      'truckNo': truckNo,
      'isActive': isActive,
    };
  }

  // Display name
  String get displayName => truckNo;
}