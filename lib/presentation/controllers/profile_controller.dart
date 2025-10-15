import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/data/models/auth/user_detail_response_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/auth_repository.dart';
import 'package:nalogistics_app/domain/usecases/auth/get_user_detail_usecase.dart';

class ProfileController extends BaseController {
  late final GetUserDetailUseCase _getUserDetailUseCase;
  late final AuthRepository _authRepository;

  // User detail data
  UserDetailModel? _userDetail;

  // Getters
  UserDetailModel? get userDetail => _userDetail;
  bool get hasUserDetail => _userDetail != null;

  // ============================================
  // USER GETTERS (Always available)
  // ============================================

  // String? get userName => _userDetail?.detailUser.fullName ?? 'Người dùng';
  String get userName {
    final name = _userDetail?.detailUser.fullName;
    if (name == null || name.trim().isEmpty) {
      return 'Người dùng';
    }
    return name.trim();
  }

  // String? get userId => _userDetail?.detailUser.userID.toString();
  String get userId {
    final id = _userDetail?.detailUser.userID;
    if (id == null) return 'N/A';
    return id.toString();
  }

  // String? get userNameLogin => _userDetail?.detailUser.userName;
  String get userNameLogin {
    final login = _userDetail?.detailUser.userName;
    if (login == null || login.trim().isEmpty) {
      return 'N/A';
    }
    return login.trim();
  }

  // String? get role => _userDetail?.detailUser.role;
  String get role {
    final roleStr = _userDetail?.detailUser.role;
    if (roleStr == null || roleStr.trim().isEmpty) {
      return 'Chưa xác định';
    }
    return roleStr.trim();
  }

  int? get roleId => _userDetail?.detailUser.roleID;

  bool get isActive => _userDetail?.detailUser.isActive ?? false;

  // ============================================
  // DRIVER GETTERS (Only for drivers)
  // ============================================

  bool get hasDriverInfo => _userDetail?.detailDriver != null;

  // String? get driverName => _userDetail?.detailDriver?.driverName;
  String get driverName {
    if (!hasDriverInfo) return userName; // Fallback to userName

    final name = _userDetail?.detailDriver?.driverName;
    if (name == null || name.trim().isEmpty) {
      return userName; // Fallback to userName
    }
    return name.trim();
  }

  // String? get driverId => _userDetail?.detailDriver?.driverID.toString();
  String get driverId {
    if (!hasDriverInfo) return 'N/A';

    final id = _userDetail?.detailDriver?.driverID;
    if (id == null) return 'N/A';
    return id.toString();
  }

  // String? get driverPhone => _userDetail?.detailDriver?.phone;
  String get driverPhone {
    if (!hasDriverInfo) return 'Chưa cập nhật';

    final phone = _userDetail?.detailDriver?.phone;
    if (phone == null || phone.trim().isEmpty) {
      return 'Chưa cập nhật';
    }
    return phone.trim();
  }

  // String? get driverAddress => _userDetail?.detailDriver?.address;
  String get driverAddress {
    if (!hasDriverInfo) return 'Chưa cập nhật';

    final address = _userDetail?.detailDriver?.address;
    if (address == null || address.trim().isEmpty) {
      return 'Chưa cập nhật';
    }
    return address.trim();
  }

  // String? get licenseNo => _userDetail?.detailDriver?.licenseNo;
  String get licenseNo {
    if (!hasDriverInfo) return 'N/A';

    final license = _userDetail?.detailDriver?.licenseNo;
    if (license == null || license.trim().isEmpty) {
      return 'N/A';
    }
    return license.trim();
  }

  DateTime? get licenseExpireDate => _userDetail?.detailDriver?.expireDate;

  bool get isDriverActive => _userDetail?.detailDriver?.isActive ?? false;

  int? get driverStatus => _userDetail?.detailDriver?.status;

  // ============================================
  // STATISTICS GETTERS
  // ============================================

  int get completedOrders => _userDetail?.countOrderCompleted ?? 0;

  // ============================================
  // METHODS
  // ============================================

  ProfileController() {
    _authRepository = AuthRepository();
    _getUserDetailUseCase = GetUserDetailUseCase(_authRepository);
  }

  /// Load user detail by user ID
  Future<void> loadUserDetail(String userId) async {
    try {
      setLoading(true);
      clearError();

      print('📦 ProfileController: Loading user detail for ID: $userId');

      final detail = await _getUserDetailUseCase.execute(userId: userId);
      _userDetail = detail;

      setLoading(false);
      notifyListeners();

      print('✅ ProfileController: User detail loaded successfully');
      print('   - User: $userName');
      print('   - Role: $role');
      print('   - Completed Orders: $completedOrders');

      if (hasDriverInfo) {
        print('   - Driver: $driverName');
        print('   - License: $licenseNo');
      }
    } catch (e) {
      print('❌ ProfileController Error: $e');
      setError(e.toString());
      setLoading(false);
      notifyListeners();
    }
  }

  /// Reload current user detail
  Future<void> reloadUserDetail() async {
    if (userId != null) {
      await loadUserDetail(userId!);
    } else {
      print('⚠️ Cannot reload: No user ID available');
    }
  }

  /// Clear user detail data
  void clearUserDetail() {
    _userDetail = null;
    clearError();
    notifyListeners();
    print('🗑️ ProfileController: User detail cleared');
  }

  /// Format expire date to display
  String? getFormattedExpireDate() {
    if (licenseExpireDate == null) return null;

    try {
      final date = licenseExpireDate!;
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day/$month/$year';
    } catch (e) {
      print('⚠️ Error formatting expire date: $e');
      return null;
    }
  }

  /// Check if license is expired
  bool get isLicenseExpired {
    if (licenseExpireDate == null) return false;

    try {
      return DateTime.now().isAfter(licenseExpireDate!);
    } catch (e) {
      print('⚠️ Error checking license expiration: $e');
      return false;
    }
  }

  /// Get days until license expires
  int? getDaysUntilExpire() {
    if (licenseExpireDate == null) return null;

    try {
      final difference = licenseExpireDate!.difference(DateTime.now());
      return difference.inDays;
    } catch (e) {
      print('⚠️ Error calculating days until expire: $e');
      return null;
    }
  }

  @override
  void dispose() {
    clearUserDetail();
    super.dispose();
  }
}