import 'package:nalogistics_app/core/base/base_model.dart';

/// Response model cho Rmooc Search API
class RmoocListResponse extends BaseModel {
  final int statusCode;
  final String message;
  final List<RmoocItemModel> data;

  RmoocListResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory RmoocListResponse.fromJson(Map<String, dynamic> json) {
    return RmoocListResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => RmoocItemModel.fromJson(item))
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

/// Model cho từng rmooc item
class RmoocItemModel extends BaseModel {
  final int rmoocID;
  final String rmoocNo;
  final bool isActive;

  RmoocItemModel({
    required this.rmoocID,
    required this.rmoocNo,
    required this.isActive,
  });

  factory RmoocItemModel.fromJson(Map<String, dynamic> json) {
    return RmoocItemModel(
      rmoocID: json['truckID'] ?? 0,
      rmoocNo: json['truckNo'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'rmoocID': rmoocID,
      'rmoocNo': rmoocNo,
      'isActive': isActive,
    };
  }

  // Display name
  String get displayName => rmoocNo;
}