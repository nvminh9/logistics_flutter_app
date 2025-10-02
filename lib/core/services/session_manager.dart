// lib/core/services/session_manager.dart

import 'package:flutter/material.dart';
import 'package:nalogistics_app/data/services/local/storage_service.dart';
import 'package:nalogistics_app/core/constants/app_constants.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final StorageService _storage = StorageService();

  // Global navigation key để có thể navigate từ bất kỳ đâu
  static GlobalKey<NavigatorState>? navigatorKey;

  // Flag để tránh hiển thị nhiều dialog
  bool _isShowingExpiredDialog = false;

  // Callbacks
  VoidCallback? _onTokenExpired;

  // Khởi tạo với navigator key
  void initialize({
    required GlobalKey<NavigatorState> navKey,
    VoidCallback? onTokenExpired,
  }) {
    navigatorKey = navKey;
    _onTokenExpired = onTokenExpired;
  }

  // Xử lý khi token hết hạn
  Future<void> handleTokenExpired({
    String? message,
    bool showDialog = true,
  }) async {
    print('🔴 Token expired detected');

    // Tránh hiển thị nhiều dialog
    if (_isShowingExpiredDialog) {
      print('⚠️ Dialog already showing, skipping...');
      return;
    }

    _isShowingExpiredDialog = true;

    // Clear token ngay lập tức
    await _clearSession();

    // Callback nếu có
    _onTokenExpired?.call();

    // Hiển thị dialog nếu cần
    if (showDialog && navigatorKey?.currentContext != null) {
      await _showTokenExpiredDialog(
        navigatorKey!.currentContext!,
        message: message,
      );
    } else {
      // Nếu không hiển thị dialog, redirect về login luôn
      await _navigateToLogin();
    }

    _isShowingExpiredDialog = false;
  }

  // Clear session data
  Future<void> _clearSession() async {
    try {
      await _storage.remove(AppConstants.keyAccessToken);
      await _storage.remove(AppConstants.keyDriverData);
      print('✅ Session cleared');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }

  // Hiển thị dialog token hết hạn
  Future<void> _showTokenExpiredDialog(
      BuildContext context, {
        String? message,
      }) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Không cho dismiss
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Không cho back
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_clock,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Phiên đăng nhập hết hạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message ??
                    'Phiên đăng nhập của bạn đã hết hạn. '
                        'Vui lòng đăng nhập lại để tiếp tục sử dụng ứng dụng.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dữ liệu của bạn đã được bảo mật',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _navigateToLogin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đăng nhập lại',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to login page
  Future<void> _navigateToLogin() async {
    if (navigatorKey?.currentState != null) {
      // Clear navigation stack và đi về login
      navigatorKey!.currentState!.pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
      print('✅ Navigated to login');
    } else {
      print('⚠️ Navigator key not available');
    }
  }

  // Check if token is valid (optional - for manual checks)
  Future<bool> isSessionValid() async {
    try {
      final token = await _storage.getString(AppConstants.keyAccessToken);
      if (token == null || token.isEmpty) {
        return false;
      }

      // TODO: Thêm logic check expiration time nếu có lưu
      // final loginData = await _storage.getObject(AppConstants.keyDriverData);
      // if (loginData != null) {
      //   final loginTime = DateTime.parse(loginData['loginTime']);
      //   final expirationTime = loginTime.add(Duration(hours: 24)); // Example
      //   return DateTime.now().isBefore(expirationTime);
      // }

      return true;
    } catch (e) {
      print('❌ Error checking session: $e');
      return false;
    }
  }

  // Manual logout
  Future<void> logout() async {
    await _clearSession();
    await _navigateToLogin();
  }
}