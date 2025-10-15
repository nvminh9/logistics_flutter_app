import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/data/models/auth/user_detail_response_model.dart';
import 'package:nalogistics_app/data/repositories/implementations/auth_repository.dart';
import 'package:nalogistics_app/presentation/routes/route_names.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_button.dart';
import 'package:nalogistics_app/presentation/widgets/common/app_bar_widget.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';
import 'package:nalogistics_app/shared/enums/user_role_enum.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  UserDetailModel? userDetail;
  bool isLoading = true;
  String? error;
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
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final authRepo = AuthRepository();

      // Get current user ID from token/storage
      // For now, using hardcoded ID - you should get this from your auth state
      final userId = '21'; // TODO: Get from auth state

      final detail = await authRepo.getUserDetail(userID: userId);

      setState(() {
        userDetail = detail;
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('❌ Load User Info Error: $e');
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLogoutDialog(),
    );

    if (shouldLogout == true) {
      final authController = Provider.of<AuthController>(context, listen: false);
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? _buildErrorState()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 16),
                _buildRoleBadge(),
                const SizedBox(height: 16),
                _buildStatsCards(),
                const SizedBox(height: 16),
                _buildProfileInfo(),
                const SizedBox(height: 16),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
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
              error ?? 'Có lỗi xảy ra',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final role = authController.userRole;
        final  displayName;
        if (role.isDriver) {
          displayName = userDetail?.detailDriver != null?['driverName'] ?? 'Tài xế'
            : userDetail?.detailUser['fullName'] ?? 'Người dùng';
        } else {
          displayName = 'Người dùng';
        }

        final  userId;
        if (role.isDriver) {
          userId = userDetail?.detailDriver != null?['driverID']?.toString() ?? ''
            : userDetail?.detailUser['userID']?.toString() ?? '';
        } else {
          userId = '';
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.maritimeDarkBlue,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.maritimeDarkBlue,
                  child: Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      color: AppColors.primaryBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: $userId',
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

  Widget _buildRoleBadge() {
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
                    const SizedBox(height: 2),
                    Text(
                      role.apiName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.hintText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Color(role.colorValue),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ID: ${role.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final role = authController.userRole;

        if (role.isDriver) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  title: 'Đơn hoàn thành',
                  value: userDetail?.countOrderCompleted.toString() ?? '0',
                  color: AppColors.statusDelivered,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_shipping_rounded,
                  title: 'Đơn hàng',
                  value: '0', // Can be calculated if needed
                  color: AppColors.statusInTransit,
                ),
              ),
            ],
          );
        } else {
          // Operator stats
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.assignment_rounded,
                  title: 'Quản lý',
                  value: 'Toàn quyền',
                  color: AppColors.oceanTeal,
                  isText: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_rounded,
                  title: 'Tài xế',
                  value: '0', // Can fetch from API
                  color: AppColors.maritimeBlue,
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

  Widget _buildProfileInfo() {
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

              if (role.isDriver) ..._buildDriverInfo()
              else ..._buildOperatorInfo(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDriverInfo() {
    final driver = userDetail?.detailDriver;
    if (driver == null) return [];

    return [
      _buildInfoItem(
        icon: Icons.badge_rounded,
        label: 'Mã tài xế',
        value: driver['driverID']?.toString() ?? '',
        color: AppColors.maritimeBlue,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.person_rounded,
        label: 'Họ tên',
        value: driver['driverName'] ?? '',
        color: AppColors.maritimeBlue,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.phone_rounded,
        label: 'Số điện thoại',
        value: driver['phone'] ?? '',
        color: AppColors.oceanTeal,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.location_on_rounded,
        label: 'Địa chỉ',
        value: driver['address'] ?? '',
        color: AppColors.statusInTransit,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.credit_card_rounded,
        label: 'Số GPLX',
        value: driver['licenseNo'] ?? '',
        color: AppColors.containerOrange,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.event_rounded,
        label: 'Ngày hết hạn GPLX',
        value: _formatExpireDate(driver['expireDate']),
        color: AppColors.statusDelayed,
      ),
    ];
  }

  List<Widget> _buildOperatorInfo() {
    final user = userDetail?.detailUser;
    if (user == null) return [];

    return [
      _buildInfoItem(
        icon: Icons.badge_rounded,
        label: 'Mã người dùng',
        value: user['userID']?.toString() ?? '',
        color: AppColors.oceanTeal,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.person_rounded,
        label: 'Họ tên',
        value: user['fullName'] ?? '',
        color: AppColors.oceanTeal,
      ),
      const SizedBox(height: 16),
      _buildInfoItem(
        icon: Icons.account_circle_rounded,
        label: 'Tên đăng nhập',
        value: user['userName'] ?? '',
        color: AppColors.maritimeBlue,
      ),
    ];
  }

  String _formatExpireDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Không có thông tin';

    try {
      // Parse "2026-12-1 00:00:00" format
      final parts = dateStr.split(' ')[0].split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = parts[1].padLeft(2, '0');
        final day = parts[2].padLeft(2, '0');
        return '$day/$month/$year';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
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
      ],
    );
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