import 'package:nalogistics_app/core/base/base_model.dart';

class DetailUserModel extends BaseModel {
  final int userID;
  final String userName;
  // final String password;
  final String fullName;
  final int roleID;
  final String role;
  final bool isActive;
  final String customer;
  final String driver;
  // final List<String> images;
  // final List<String> activities;

  DetailUserModel({
    required this.userID,
    required this.userName,
    // required this.password,
    required this.fullName,
    required this.roleID,
    required this.role,
    required this.isActive,
    required this.customer,
    required this.driver,
  });

  factory DetailUserModel.fromJson(Map<String, dynamic> json) {
    return DetailUserModel(
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      // password: json['password'] ?? '',
      fullName: json['fullName'] ?? '',
      roleID: json['roleID'] ?? 0,
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? false,
      customer: json['customer'] ?? '',
      driver: json['driver'] ?? '',
      // images: json['images'] ?? [],
      // activities: json['activities'] ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'userName': userName,
      // 'password': password,
      'fullName': fullName,
      'roleID': roleID,
      'role': role,
      'isActive': isActive,
      'customer': customer,
      'driver': driver,
      // 'images': images,
      // 'activities': activities,
    };
  }
}