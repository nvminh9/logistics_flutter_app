import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/domain/usecases/auth/login_usecase.dart';
import 'package:nalogistics_app/data/repositories/implementations/auth_repository.dart';
import 'package:nalogistics_app/data/models/auth/login_response.dart';
import 'package:nalogistics_app/core/exceptions/app_exception.dart';
import 'package:nalogistics_app/core/exceptions/network_exception.dart';
import 'package:nalogistics_app/shared/enums/user_role_enum.dart';

class AuthController extends BaseController {
  late final LoginUseCase _loginUseCase;
  late final AuthRepository _authRepository;

  // Login state
  LoginResponse? _loginResponse;
  String? _token;
  String? _roleName;
  UserRole _userRole = UserRole.unknown;
  bool _isAuthenticated = false;

  // Getters
  LoginResponse? get loginResponse => _loginResponse;
  String? get token => _token;
  String? get roleName => _roleName;
  UserRole get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;

  // Role-specific getters
  bool get isDriver => _userRole.isDriver;
  bool get isOperator => _userRole.isOperator;
  bool get hasFullAccess => _userRole.hasFullAccess;

  AuthController() {
    _authRepository = AuthRepository();
    _loginUseCase = LoginUseCase(_authRepository);
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      _isAuthenticated = await _authRepository.isLoggedIn();
      if (_isAuthenticated) {
        _token = await _authRepository.getToken();
        _roleName = await _authRepository.getRoleName();

        // Parse role từ roleName
        if (_roleName != null) {
          _userRole = UserRoleExtension.fromString(_roleName);
          print('✅ User role loaded: ${_userRole.displayName} (${_userRole.apiName})');
        }
      }
      notifyListeners();
    } catch (e) {
      print('❌ Auth initialization error: $e');
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      setLoading(true);
      clearError();

      final response = await _loginUseCase.execute(
        username: username,
        password: password,
      );

      _loginResponse = response;
      _token = response.data?.token;
      _roleName = response.data?.roleName;

      // ⭐ Parse role từ roleName
      if (_roleName != null) {
        _userRole = UserRoleExtension.fromString(_roleName);
        print('🔐 Login successful!');
        print('   - Role: ${_userRole.displayName}');
        print('   - API Name: ${_userRole.apiName}');
        print('   - Role ID: ${_userRole.id}');
        print('   - Permissions:');
        print('     • Can view orders: ${_userRole.canViewOrders}');
        print('     • Can update status: ${_userRole.canUpdateOrderStatus}');
        print('     • Can manage drivers: ${_userRole.canManageDrivers}');
        print('     • Can view reports: ${_userRole.canViewReports}');
      } else {
        _userRole = UserRole.unknown;
        print('⚠️ Warning: No role name in response');
      }

      _isAuthenticated = true;

      setLoading(false);
      notifyListeners();
      return true;

    } on AppException catch (e) {
      print('❌ App Exception: ${e.message}');
      setError(e.message);
      setLoading(false);
      return false;
    } on NetworkException catch (e) {
      print('❌ Network Exception: ${e.message}');
      setError(e.message);
      setLoading(false);
      return false;
    } catch (e) {
      print('❌ Unknown Exception: $e');
      setError('Có lỗi không xác định xảy ra');
      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      setLoading(true);

      await _authRepository.logout();

      // Clear state
      _loginResponse = null;
      _token = null;
      _roleName = null;
      _userRole = UserRole.unknown;
      _isAuthenticated = false;

      clearError();
      setLoading(false);
      notifyListeners();

      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
      // Force logout even if API call fails
      _loginResponse = null;
      _token = null;
      _roleName = null;
      _userRole = UserRole.unknown;
      _isAuthenticated = false;
      setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      _isAuthenticated = await _authRepository.isLoggedIn();

      if (_isAuthenticated) {
        // Reload role info
        _token = await _authRepository.getToken();
        _roleName = await _authRepository.getRoleName();

        if (_roleName != null) {
          _userRole = UserRoleExtension.fromString(_roleName);
        }
      }

      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      print('❌ Check auth status error: $e');
      return false;
    }
  }

  // ⭐ Permission checking methods
  bool canAccessFeature(String feature) {
    return PermissionHelper.canAccessFeature(_userRole, feature);
  }

  bool get canViewOrders => _userRole.canViewOrders;
  bool get canUpdateOrderStatus => _userRole.canUpdateOrderStatus;
  bool get canManageDrivers => _userRole.canManageDrivers;
  bool get canViewReports => _userRole.canViewReports;
  bool get canManageCustomers => _userRole.canManageCustomers;
  bool get canViewAllOrders => _userRole.canViewAllOrders;

  void clearLoginData() {
    _loginResponse = null;
    clearError();
    notifyListeners();
  }



  @override
  void dispose() {
    super.dispose();
  }
}