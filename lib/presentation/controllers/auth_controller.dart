import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/base/base_controller.dart';
import 'package:nalogistics_app/domain/usecases/auth/login_usecase.dart';
import 'package:nalogistics_app/data/repositories/implementations/auth_repository.dart';
import 'package:nalogistics_app/data/models/auth/login_response.dart';
import 'package:nalogistics_app/core/exceptions/app_exception.dart';
import 'package:nalogistics_app/core/exceptions/network_exception.dart';

class AuthController extends BaseController {
  late final LoginUseCase _loginUseCase;
  late final AuthRepository _authRepository;

  // Login state
  LoginResponse? _loginResponse;
  String? _token;
  String? _roleName;
  bool _isAuthenticated = false;

  // Getters
  LoginResponse? get loginResponse => _loginResponse;
  String? get token => _token;
  String? get roleName => _roleName;
  bool get isAuthenticated => _isAuthenticated;

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
      _isAuthenticated = true;

      print('✅ Login successful: ${response.message}');
      print('🔑 Token: ${_token?.substring(0, 20)}...');
      print('👤 Role: $_roleName');

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
      _isAuthenticated = false;
      setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      _isAuthenticated = await _authRepository.isLoggedIn();
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      print('❌ Check auth status error: $e');
      return false;
    }
  }

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