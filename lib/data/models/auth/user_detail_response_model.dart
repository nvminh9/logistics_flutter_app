import 'package:nalogistics_app/core/base/base_model.dart';
import 'package:nalogistics_app/data/models/auth/detail_driver_model.dart';
import 'package:nalogistics_app/data/models/auth/detail_user_model.dart';

class UserDetailResponse extends BaseModel {
  final int statusCode;
  final String message;
  final UserDetailModel? data;

  UserDetailResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory UserDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UserDetailModel.fromJson(json['data'])
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

// ⭐ FIXED: Changed from Map to proper models
class UserDetailModel extends BaseModel {
  final DetailUserModel detailUser;
  final DetailDriverModel? detailDriver;  // ⭐ Changed from Map
  final int countOrderCompleted;

  UserDetailModel({
    required this.detailUser,
    this.detailDriver,
    required this.countOrderCompleted,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      detailUser: DetailUserModel.fromJson(json['detailUser'] ?? {}),
      detailDriver: json['detailDriver'] != null && json['detailDriver'] != ''
          ? DetailDriverModel.fromJson(json['detailDriver'])
          : null,
      countOrderCompleted: json['countOrderCompleted'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'detailUser': detailUser.toJson(),
      'detailDriver': detailDriver?.toJson(),
      'countOrderCompleted': countOrderCompleted,
    };
  }
}