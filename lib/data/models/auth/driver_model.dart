import 'package:nalogistics_app/core/base/base_model.dart';

class DriverModel extends BaseModel {
  final String id;
  final String name;
  final String username;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? hometown;
  final String? avatar;

  DriverModel({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.phone,
    this.birthDate,
    this.hometown,
    this.avatar,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      hometown: json['hometown'],
      avatar: json['avatar'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String(),
      'hometown': hometown,
      'avatar': avatar,
    };
  }
}