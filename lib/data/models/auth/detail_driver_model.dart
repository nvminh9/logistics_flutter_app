import 'package:nalogistics_app/core/base/base_model.dart';

class DetailDriverModel extends BaseModel {
  final int driverID;
  final String driverName;
  final String address;
  final String phone;
  final String licenseNo;
  final DateTime expireDate;
  final bool isActive;
  final int status;

  DetailDriverModel({
    required this.driverID,
    required this.driverName,
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
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      licenseNo: json['licenseNo'] ?? '',
      expireDate: _parseExpireDate(json['expireDate']),
      isActive: json['isActive'] ?? false,
      status: json['status'] ?? 0,
    );
  }

  static DateTime _parseExpireDate(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();

    try {
      // Handle format: "2026-12-1 00:00:00"
      final cleaned = dateStr.toString().trim();

      // Try parsing with DateTime.parse first
      try {
        return DateTime.parse(cleaned);
      } catch (_) {
        // If fails, try manual parsing
        final parts = cleaned.split(' ');
        if (parts.isEmpty) return DateTime.now();

        final dateParts = parts[0].split('-');
        if (dateParts.length < 3) return DateTime.now();

        final year = int.tryParse(dateParts[0]) ?? DateTime.now().year;
        final month = int.tryParse(dateParts[1]) ?? 1;
        final day = int.tryParse(dateParts[2]) ?? 1;

        return DateTime(year, month, day);
      }
    } catch (e) {
      print('⚠️ Error parsing expire date: $e');
      return DateTime.now();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'driverID': driverID,
      'driverName': driverName,
      'address': address,
      'phone': phone,
      'licenseNo': licenseNo,
      'expireDate': expireDate.toIso8601String(),
      'isActive': isActive,
      'status': status,
    };
  }
}