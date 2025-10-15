import 'package:nalogistics_app/core/base/base_model.dart';

class DetailUserModel extends BaseModel {
  final int userID;
  final String userName;
  final String fullName;
  final int roleID;
  final bool isActive;

  DetailUserModel({
    required this.userID,
    required this.userName,
    required this.fullName,
    required this.roleID,
    required this.isActive,
  });

  factory DetailUserModel.fromJson(Map<String, dynamic> json) {
    return DetailUserModel(
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      fullName: json['fullName'] ?? '',
      roleID: json['roleID'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'userName': userName,
      'fullName': fullName,
      'roleID': roleID,
      'isActive': isActive,
    };
  }
}