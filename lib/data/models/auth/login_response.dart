import 'package:nalogistics_app/core/base/base_model.dart';

class LoginResponse extends BaseModel {
  final int statusCode;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
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

class LoginData extends BaseModel {
  final String token;
  final String roleName;
  final int? userId;

  LoginData({
    required this.token,
    required this.roleName,
    this.userId,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] ?? '',
      roleName: json['roleName'] ?? '',
      userId: json['userId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'roleName': roleName,
      'userId': userId,
    };
  }
}