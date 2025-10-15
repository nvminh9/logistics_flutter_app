import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/core/constants/app_constants.dart';
import 'package:nalogistics_app/data/services/local/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/routes/route_names.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_button.dart';
import 'package:nalogistics_app/presentation/widgets/common/app_bar_widget.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';
import 'package:nalogistics_app/presentation/controllers/profile_controller.dart';
import 'package:nalogistics_app/shared/enums/user_role_enum.dart';
import 'package:nalogistics_app/presentation/widgets/common/avatar_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserInfo();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      // Get auth controller
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      // Get profile controller
      final profileController = Provider.of<ProfileController>(
        context,
        listen: false,
      );

      // ⭐ Get userId - Priority:
      // 1. From AuthController if available
      // 2. From storage
      // 3. Hardcoded fallback for testing
      String? userId = authController.userId;

      if (userId == null || userId.isEmpty) {
        // Try to get from storage
        final storage = StorageService();
        final driverData = await storage.getObject(AppConstants.keyDriverData);
        userId = driverData?['userId']?.toString();
      }

      // Fallback for testing
      userId ??= '21';

      print('📱 Loading profile for user ID: $userId');

      // Load user detail
      await profileController.loadUserDetail(userId);

      // ⭐ Save userId to AuthController for future use
      if (profileController.hasUserDetail && profileController.userId != null) {
        authController.setUserId(profileController.userId);
      }

      // Start animations after data loaded
      if (mounted) {
        _animationController.forward();
      }
    } catch (e) {
      print('❌ Error loading user info: $e');
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLogoutDialog(),
    );

    if (shouldLogout == true) {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      await authController.logout();

      if (!mounted) return;
      context.go(RouteNames.login);
    }
  }

  Widget _buildLogoutDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.statusError.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.logout_rounded,
              color: AppColors.statusError,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            AppStrings.logout,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        AppStrings.logoutConfirm,
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            AppStrings.cancel,
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
        CustomButton(
          text: AppStrings.confirm,
          onPressed: () => Navigator.of(context).pop(true),
          backgroundColor: AppColors.statusError,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: const AppBarWidget(
        title: AppStrings.profile,
      ),
      body: Consumer<ProfileController>(
        builder: (context, profileController, child) {
          // Loading state
          if (profileController.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.maritimeBlue),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải thông tin...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          // Error state
          if (profileController.hasError) {
            return _buildErrorState(profileController);
          }

          // No data state
          if (!profileController.hasUserDetail) {
            return _buildNoDataState(profileController);
          }

          // Success state with animations
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: RefreshIndicator(
                onRefresh: () => profileController.reloadUserDetail(),
                color: AppColors.maritimeBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileHeader(profileController),
                      const SizedBox(height: 16),
                      _buildRoleBadge(profileController),
                      const SizedBox(height: 16),
                      _buildStatsCards(profileController),
                      const SizedBox(height: 16),
                      _buildProfileInfo(profileController),
                      const SizedBox(height: 16),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ProfileController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.statusError,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải thông tin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? 'Có lỗi xảy ra',
              style: const TextStyle(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maritimeBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState(ProfileController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: AppColors.hintText,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không có thông tin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Không tìm thấy thông tin người dùng',
              style: TextStyle(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maritimeBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileController controller) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final displayName = controller.userName ?? 'Người dùng';
        final displayId = controller.userId ?? 'N/A';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // ⭐ Use AvatarWidget
              AvatarWidget(
                name: displayName,
                radius: 40,
                backgroundColor: AppColors.maritimeDarkBlue,
                textColor: AppColors.primaryBackground,
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'ID: $displayId',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(ProfileController controller) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final role = authController.userRole;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black26, width: 1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [AppColors.cardShadow],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(role.colorValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(role.colorValue).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    role.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vai trò',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(role.colorValue),
                      ),
                    ),
                    // const SizedBox(height: 2),
                    // Text(
                    //   controller.role ?? role.apiName,
                    //   style: const TextStyle(
                    //     fontSize: 13,
                    //     color: AppColors.hintText,
                    //   ),
                    // ),
                  ],
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 6,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Color(role.colorValue),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Text(
              //     'ID: ${role.id}',
              //     style: const TextStyle(
              //       fontSize: 11,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(ProfileController controller) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final role = authController.userRole;

        if (role.isDriver && controller.hasDriverInfo) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  title: 'Đơn hoàn thành',
                  value: controller.completedOrders.toString(),
                  color: AppColors.statusDelivered,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_shipping_rounded,
                  title: 'Tổng đơn hàng',
                  value: controller.completedOrders.toString(),
                  color: AppColors.statusInTransit,
                ),
              ),
            ],
          );
        } else {
          // Operator stats
          return Row(
            children: [
              // Expanded(
              //   child: _buildStatCard(
              //     icon: Icons.assignment_rounded,
              //     title: 'Quản lý',
              //     value: 'Toàn quyền',
              //     color: AppColors.oceanTeal,
              //     isText: true,
              //   ),
              // ),
              // const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  title: 'Đơn hoàn thành',
                  value: controller.completedOrders.toString(),
                  color: AppColors.statusDelivered,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26, width: 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isText ? 14 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(ProfileController controller) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final role = authController.userRole;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black26, width: 1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [AppColors.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin cá nhân',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              if (role.isDriver && controller.hasDriverInfo)
                ..._buildDriverInfo(controller)
              else
                ..._buildOperatorInfo(controller),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDriverInfo(ProfileController controller) {
    if (!controller.hasDriverInfo) {
      return [
        const Text(
          'Không có thông tin tài xế',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
        ),
      ];
    }

    return [
      _buildInfoItem(
        icon: Icons.badge_rounded,
        label: 'Mã tài xế',
        value: controller.driverId ?? 'N/A',
        color: AppColors.maritimeBlue,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.person_rounded,
        label: 'Họ tên',
        value: controller.driverName ?? controller.userName ?? 'N/A',
        color: AppColors.maritimeBlue,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.phone_rounded,
        label: 'Số điện thoại',
        value: controller.driverPhone ?? 'Chưa cập nhật',
        color: AppColors.oceanTeal,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.location_on_rounded,
        label: 'Địa chỉ',
        value: controller.driverAddress ?? 'Chưa cập nhật',
        color: AppColors.statusInTransit,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.credit_card_rounded,
        label: 'Số GPLX',
        value: controller.licenseNo ?? 'N/A',
        color: AppColors.containerOrange,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.event_rounded,
        label: 'Ngày hết hạn GPLX',
        value: controller.getFormattedExpireDate() ?? 'Không có thông tin',
        color: controller.isLicenseExpired
            ? AppColors.statusError
            : AppColors.statusDelayed,
        trailing: controller.isLicenseExpired
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.statusError.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'HẾT HẠN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.statusError,
            ),
          ),
        )
            : null,
      ),
      if (controller.getDaysUntilExpire() != null &&
          !controller.isLicenseExpired) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getExpirationWarningColor(
                controller.getDaysUntilExpire()!
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getExpirationWarningColor(
                  controller.getDaysUntilExpire()!
              ).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: _getExpirationWarningColor(
                    controller.getDaysUntilExpire()!
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getExpirationMessage(controller.getDaysUntilExpire()!),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getExpirationWarningColor(
                        controller.getDaysUntilExpire()!
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildOperatorInfo(ProfileController controller) {
    return [
      _buildInfoItem(
        icon: Icons.badge_rounded,
        label: 'Mã người dùng',
        value: controller.userId ?? 'N/A',
        color: AppColors.oceanTeal,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.person_rounded,
        label: 'Họ tên',
        value: controller.userName ?? 'N/A',
        color: AppColors.oceanTeal,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.account_circle_rounded,
        label: 'Tên đăng nhập',
        value: controller.userNameLogin ?? 'N/A',
        color: AppColors.maritimeBlue,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.check_circle_rounded,
        label: 'Đơn đã hoàn thành',
        value: controller.completedOrders.toString(),
        color: AppColors.statusDelivered,
      ),
    ];
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }

  Color _getExpirationWarningColor(int daysUntilExpire) {
    if (daysUntilExpire <= 30) {
      return AppColors.statusError;
    } else if (daysUntilExpire <= 90) {
      return AppColors.statusDelayed;
    } else {
      return AppColors.statusDelivered;
    }
  }

  String _getExpirationMessage(int daysUntilExpire) {
    if (daysUntilExpire <= 30) {
      return 'GPLX sắp hết hạn trong $daysUntilExpire ngày';
    } else if (daysUntilExpire <= 90) {
      return 'GPLX còn $daysUntilExpire ngày hết hạn';
    } else {
      return 'GPLX còn hiệu lực $daysUntilExpire ngày';
    }
  }

  Widget _buildLogoutButton() {
    return CustomButton(
      text: AppStrings.logout,
      onPressed: _logout,
      backgroundColor: AppColors.maritimeBlue,
      isFullWidth: true,
      icon: Icons.logout_rounded,
    );
  }
}