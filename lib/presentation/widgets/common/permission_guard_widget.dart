import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';
import 'package:nalogistics_app/shared/enums/user_role_enum.dart';
import 'package:nalogistics_app/core/constants/colors.dart';

/// Widget để kiểm tra permission trước khi hiển thị content
/// Sử dụng: PermissionGuard(permission: 'manage_drivers', child: ...)
class PermissionGuard extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;
  final bool showFallbackUI;

  const PermissionGuard({
    Key? key,
    required this.permission,
    required this.child,
    this.fallback,
    this.showFallbackUI = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final hasPermission = authController.canAccessFeature(permission);

        if (hasPermission) {
          return child;
        }

        // Return fallback or default unauthorized UI
        if (fallback != null) {
          return fallback!;
        }

        if (showFallbackUI) {
          return _buildUnauthorizedUI();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUnauthorizedUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: AppColors.statusError.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Không có quyền truy cập',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn không có quyền truy cập tính năng này.\nVui lòng liên hệ quản trị viên.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget để kiểm tra role cụ thể
class RoleGuard extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGuard({
    Key? key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final hasRole = allowedRoles.contains(authController.userRole);

        if (hasRole) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Conditional widget dựa trên role
class RoleConditional extends StatelessWidget {
  final Widget? driverWidget;
  final Widget? operatorWidget;
  final Widget? fallbackWidget;

  const RoleConditional({
    Key? key,
    this.driverWidget,
    this.operatorWidget,
    this.fallbackWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        switch (authController.userRole) {
          case UserRole.driver:
            return driverWidget ?? fallbackWidget ?? const SizedBox.shrink();
          case UserRole.operator:
            return operatorWidget ?? fallbackWidget ?? const SizedBox.shrink();
          default:
            return fallbackWidget ?? const SizedBox.shrink();
        }
      },
    );
  }
}

/// Badge hiển thị role của user
class RoleBadge extends StatelessWidget {
  final bool showIcon;
  final double fontSize;

  const RoleBadge({
    Key? key,
    this.showIcon = true,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final role = authController.userRole;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(role.colorValue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(role.colorValue).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Text(
                  role.icon,
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                role.displayName,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Color(role.colorValue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}