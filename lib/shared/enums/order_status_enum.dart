import 'dart:ui';

enum OrderStatus {
  inProgress,    // 0
  pickedUp,      // 1
  inTransit,     // 2
  delivered,     // 3
  completed,     // 4
  cancelled,     // 5
  failedDelivery // 6
}

extension OrderStatusExtension on OrderStatus {

  // Lấy tên hiển thị của trạng thái
  String get displayName {
    switch (this) {
      case OrderStatus.inProgress:
        return 'Đang xử lý';
      case OrderStatus.pickedUp:
        return 'Đã lấy hàng';
      case OrderStatus.inTransit:
        return 'Đang vận chuyển';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.failedDelivery:
        return 'Giao thất bại';
    }
  }

  // Lấy tên viết tắt của trạng thái
  String get shortName {
    switch (this) {
      case OrderStatus.inProgress:
        return 'Xử lý';
      case OrderStatus.pickedUp:
        return 'Lấy hàng';
      case OrderStatus.inTransit:
        return 'Vận chuyển';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.failedDelivery:
        return 'Thất bại';
    }
  }

  // Màu sắc cho từng status
  Color get color {
    switch (this) {
      case OrderStatus.inProgress:
        return const Color(0xFFFF9800); // Orange
      case OrderStatus.pickedUp:
        return const Color(0xFF2196F3); // Blue
      case OrderStatus.inTransit:
        return const Color(0xFF673AB7); // Purple
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50); // Green
      case OrderStatus.completed:
        return const Color(0xFF009688); // Teal
      case OrderStatus.cancelled:
        return const Color(0xFF9E9E9E); // Grey
      case OrderStatus.failedDelivery:
        return const Color(0xFFF44336); // Red
    }
  }

  // Lấy giá trị của trạng thái
  int get value {
    return index; // 0, 1, 2, 3, 4, 5, 6
  }

  static OrderStatus fromValue(int value) {
    if (value >= 0 && value < OrderStatus.values.length) {
      return OrderStatus.values[value];
    }
    return OrderStatus.inProgress; // Default fallback
  }
}