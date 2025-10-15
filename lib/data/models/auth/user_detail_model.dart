import 'package:nalogistics_app/core/base/base_model.dart';

class UserDetailModel extends BaseModel {
  final Map<String, dynamic> detailUser;
  final Map<String, dynamic>? detailDriver;
  final BigInt countOrderCompleted;

  UserDetailModel({
    required this.detailUser,
    this.detailDriver,
    required this.countOrderCompleted,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      detailUser: json['detailUser'] ?? {},
      detailDriver: json['detailDriver'] ?? {},
      countOrderCompleted: json['countOrderCompleted'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'detailUser': detailUser,
      'detailDriver': detailDriver,
      'countOrderCompleted': countOrderCompleted,
    };
  }
}