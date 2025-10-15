import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/routes/route_names.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';

class TokenExpiredDialog extends StatelessWidget {
  final String? message;

  const TokenExpiredDialog({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Không cho back
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_clock,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Phiên đăng nhập hết hạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ??
                  'Phiên đăng nhập của bạn đã hết hạn. '
                      'Vui lòng đăng nhập lại để tiếp tục sử dụng ứng dụng.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.purple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 24,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dữ liệu của bạn luôn được bảo mật',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
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
            height: 50,
            child: ElevatedButton(
              onPressed: () => _handleLoginRedirect(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maritimeBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Đăng nhập lại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ⭐ NEW: Handle login redirect
  Future<void> _handleLoginRedirect(BuildContext context) async {
    try {
      // Close dialog first
      Navigator.of(context).pop();

      // Clear auth state
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      await authController.logout();

      // Navigate to login page
      if (context.mounted) {
        context.go(RouteNames.login);
      }

      print('✅ Redirected to login page');
    } catch (e) {
      print('❌ Error during login redirect: $e');

      // Force redirect even if logout fails
      if (context.mounted) {
        context.go(RouteNames.login);
      }
    }
  }
}

// Utility function để show dialog
Future<void> showTokenExpiredDialog(
    BuildContext context, {
      String? message,
    }) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => TokenExpiredDialog(
      message: message,
    ),
  );
}