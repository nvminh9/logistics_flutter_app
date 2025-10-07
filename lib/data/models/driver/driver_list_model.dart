import 'package:nalogistics_app/core/base/base_model.dart';

/// Response model cho Driver List API
class DriverListResponse extends BaseModel {
  final int statusCode;
  final String message;
  final List<DriverItemModel> data;

  DriverListResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory DriverListResponse.fromJson(Map<String, dynamic> json) {
    return DriverListResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => DriverItemModel.fromJson(item))
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

/// Model cho từng driver item
class DriverItemModel extends BaseModel {
  final int driverID;
  final String licenseNo;
  final String driverName;
  final bool isActive;
  final int status;

  DriverItemModel({
    required this.driverID,
    required this.licenseNo,
    required this.driverName,
    required this.isActive,
    required this.status,
  });

  factory DriverItemModel.fromJson(Map<String, dynamic> json) {
    return DriverItemModel(
      driverID: json['driverID'] ?? 0,
      licenseNo: json['licenseNo'] ?? '',
      driverName: json['driverName'] ?? '',
      isActive: json['isActive'] ?? false,
      status: json['status'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'driverID': driverID,
      'licenseNo': licenseNo,
      'driverName': driverName,
      'isActive': isActive,
      'status': status,
    };
  }

  // Display name với license number
  String get displayNameWithLicense => '$driverName ($licenseNo)';
}