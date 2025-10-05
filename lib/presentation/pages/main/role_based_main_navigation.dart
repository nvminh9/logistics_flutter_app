import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';
import 'package:nalogistics_app/presentation/pages/home/home_page.dart';
import 'package:nalogistics_app/presentation/pages/orders/order_list_with_tabs_page.dart';
import 'package:nalogistics_app/presentation/pages/profile/profile_page.dart';
import 'package:nalogistics_app/shared/enums/user_role_enum.dart';

class RoleBasedMainNavigation extends StatefulWidget {
  const RoleBasedMainNavigation({super.key});

  @override
  State<RoleBasedMainNavigation> createState() => _RoleBasedMainNavigationState();
}

class _RoleBasedMainNavigationState extends State<RoleBasedMainNavigation> {
  int _currentIndex = 0;

  // ⭐ Pages cho Driver
  final List<Widget> _driverPages = [
    const HomePage(),
    const OrderListWithTabsPage(),
    const ProfilePage(),
  ];

  // ⭐ Pages cho Operator (có thêm Reports/Management)
  final List<Widget> _operatorPages = [
    // const HomePage(),
    const OrderListWithTabsPage(), // Operator sees all orders
    // TODO: Add Reports page
    // const Center(child: Text('📊 Reports Page (Coming Soon)')),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final userRole = authController.userRole;

        // ⭐ Select pages based on role
        final pages = userRole.isOperator ? _operatorPages : _driverPages;

        // Ensure current index is valid
        if (_currentIndex >= pages.length) {
          _currentIndex = 0;
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildNavItems(userRole),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ⭐ Build navigation items based on role
  List<Widget> _buildNavItems(UserRole role) {
    if (role.isOperator) {
      return [
        // _buildNavItem(0, Icons.home_rounded, 'Trang chủ'),
        _buildNavItem(0, Icons.assignment_rounded, 'Đơn hàng'),
        // _buildNavItem(2, Icons.analytics_rounded, 'Báo cáo'),
        _buildNavItem(1, Icons.person_rounded, 'Hồ sơ'),
      ];
    } else {
      // Driver - 3 tabs only
      return [
        _buildNavItem(0, Icons.home_rounded, AppStrings.tabHome),
        _buildNavItem(1, Icons.assignment_rounded, AppStrings.tabOrders),
        _buildNavItem(2, Icons.person_rounded, AppStrings.tabProfile),
      ];
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.maritimeBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.maritimeBlue
                  : AppColors.secondaryText,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.maritimeBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}