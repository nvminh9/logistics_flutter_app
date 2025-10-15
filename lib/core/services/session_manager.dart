import 'package:flutter/material.dart';
import 'package:nalogistics_app/data/services/local/storage_service.dart';
import 'package:nalogistics_app/core/constants/app_constants.dart';
import 'package:nalogistics_app/presentation/widgets/dialogs/token_expired_dialog.dart';

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

  /// ⭐ UPDATED: Use new token expired dialog
  Future<void> _showTokenExpiredDialog(
      BuildContext context, {
        String? message,
      }) async {
    return showTokenExpiredDialog(
      context,
      message: message,
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