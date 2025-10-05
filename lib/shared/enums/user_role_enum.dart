enum UserRole {
  driver,   // id = 3
  operator, // id = 6
  unknown,  // Fallback
}

extension UserRoleExtension on UserRole {
  // Role ID từ backend
  int get id {
    switch (this) {
      case UserRole.driver:
        return 3;
      case UserRole.operator:
        return 6;
      case UserRole.unknown:
        return -1;
    }
  }

  // Role name để hiển thị
  String get displayName {
    switch (this) {
      case UserRole.driver:
        return 'Tài xế';
      case UserRole.operator:
        return 'Điều hành';
      case UserRole.unknown:
        return 'Không xác định';
    }
  }

  // Role name từ API (case-insensitive)
  String get apiName {
    switch (this) {
      case UserRole.driver:
        return 'Driver';
      case UserRole.operator:
        return 'Operator';
      case UserRole.unknown:
        return 'Unknown';
    }
  }

  // Icon cho từng role
  String get icon {
    switch (this) {
      case UserRole.driver:
        return '🚛';
      case UserRole.operator:
        return '📋';
      case UserRole.unknown:
        return '❓';
    }
  }

  // Màu sắc cho role
  int get colorValue {
    switch (this) {
      case UserRole.driver:
        return 0xFF0066CC; // Blue
      case UserRole.operator:
        return 0xFF006B7D; // Teal
      case UserRole.unknown:
        return 0xFF9E9E9E; // Grey
    }
  }

  // Parse từ API response (roleName string)
  static UserRole fromString(String? roleName) {
    if (roleName == null) return UserRole.unknown;

    final normalized = roleName.trim().toLowerCase();

    switch (normalized) {
      case 'driver':
        return UserRole.driver;
      case 'operator':
        return UserRole.operator;
      default:
        return UserRole.unknown;
    }
  }

  // Parse từ role ID
  static UserRole fromId(int? id) {
    switch (id) {
      case 3:
        return UserRole.driver;
      case 6:
        return UserRole.operator;
      default:
        return UserRole.unknown;
    }
  }

  // Check permissions
  bool get canViewOrders => this == UserRole.driver || this == UserRole.operator;
  bool get canUpdateOrderStatus => this == UserRole.driver || this == UserRole.operator;
  bool get canManageDrivers => this == UserRole.operator;
  bool get canViewReports => this == UserRole.operator;
  bool get canManageCustomers => this == UserRole.operator;
  bool get canViewAllOrders => this == UserRole.operator;

  // Driver specific permissions
  bool get isDriver => this == UserRole.driver;
  bool get canOnlyViewOwnOrders => this == UserRole.driver;

  // Operator specific permissions
  bool get isOperator => this == UserRole.operator;
  bool get hasFullAccess => this == UserRole.operator;
}

// Helper class để check permissions
class PermissionHelper {
  static bool canAccessFeature(UserRole role, String feature) {
    switch (feature) {
      case 'view_orders':
        return role.canViewOrders;
      case 'update_status':
        return role.canUpdateOrderStatus;
      case 'manage_drivers':
        return role.canManageDrivers;
      case 'view_reports':
        return role.canViewReports;
      case 'manage_customers':
        return role.canManageCustomers;
      default:
        return false;
    }
  }
}