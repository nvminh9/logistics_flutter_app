import 'package:nalogistics_app/core/base/base_model.dart';

class DetailDriverModel extends BaseModel {
  final int driverID;
  final String driverName;
  final int roleID;
  final String role;
  final int userID;
  final String user;
  final String address;
  final String phone;
  final String licenseNo;
  final DateTime expireDate;
  final bool isActive;
  final int status;

  DetailDriverModel({
    required this.driverID,
    required this.driverName,
    required this.roleID,
    required this.role,
    required this.userID,
    required this.user,
    required this.address,
    required this.phone,
    required this.licenseNo,
    required this.expireDate,
    required this.isActive,
    required this.status,
  });

  factory DetailDriverModel.fromJson(Map<String, dynamic> json) {
    return DetailDriverModel(
      driverID: json['driverID'] ?? 0,
      driverName: json['driverName'] ?? '',
      roleID: json['roleID'] ?? 0,
      role: json['role'] ?? '',
      userID: json['userID'] ?? 0,
      user: json['user'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      licenseNo: json['licenseNo'] ?? '',
      expireDate: DateTime.tryParse(json['expireDate'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false,
      status: json['status'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'driverID': driverID,
      'driverName': driverName,
      'roleID': roleID,
      'role': role,
      'userID': userID,
      'user': user,
      'address': address,
      'phone': phone,
      'licenseNo': licenseNo,
      'expireDate': expireDate.toIso8601String(),
      'isActive': isActive,
      'status': status,
    };
  }
}