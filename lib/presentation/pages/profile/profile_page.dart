import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/data/models/auth/driver_model.dart';
import 'package:nalogistics_app/data/services/local/storage_service.dart';
import 'package:nalogistics_app/core/constants/app_constants.dart';
import 'package:nalogistics_app/presentation/routes/route_names.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_button.dart';
import 'package:nalogistics_app/presentation/widgets/common/app_bar_widget.dart';
import 'package:nalogistics_app/presentation/widgets/common/test_token_expiration_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  DriverModel? driver;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDriverInfo();
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

  // Helper để check debug mode
  bool _isDebugMode() {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

  Future<void> _loadDriverInfo() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    driver = DriverModel(
      id: 'DRV001',
      name: 'Nguyễn Văn Tài',
      username: 'nguyenvantai',
      email: 'nguyenvantai@example.com',
      phone: '0901234567',
      birthDate: DateTime(1985, 3, 15),
      hometown: 'An Giang',
      avatar: null,
    );

    setState(() => isLoading = false);
    _animationController.forward();
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLogoutDialog(),
    );

    if (shouldLogout == true) {
      final storageService = StorageService();
      await storageService.clear();

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
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 10),
                _buildStatsCards(),
                const SizedBox(height: 10),
                _buildProfileInfo(),
                const SizedBox(height: 10),

                // ⭐ THÊM TEST SECTION (Only in debug mode)
                // Remove this in production!
                if (_isDebugMode()) const TokenExpirationTestSection(),
                if (_isDebugMode()) const SizedBox(height: 10),

                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // gradient: AppColors.primaryGradient,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.primaryBackground.withOpacity(0.3),
        //     blurRadius: 20,
        //     offset: const Offset(0, 10),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.maritimeDarkBlue,
              shape: BoxShape.circle,
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.1),
              //     blurRadius: 10,
              //     offset: const Offset(0, 5),
              //   ),
              // ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.maritimeDarkBlue,
              child: driver?.avatar != null
                  ? ClipOval(
                child: Image.network(
                  driver!.avatar!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
                  : Text(
                driver?.name.substring(0, 1).toUpperCase() ?? 'T',
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
            driver?.name ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${driver?.username ?? ''}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black45.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_shipping_rounded,
            title: 'Đơn hàng',
            value: '24',
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_rounded,
            title: 'Đánh giá',
            value: '4.8',
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
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
              fontSize: 20,
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
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
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
          if (driver?.email?.isNotEmpty == true)
            _buildInfoItem(
              icon: Icons.email_rounded,
              label: 'Email',
              value: driver!.email!,
              color: AppColors.secondaryText,
            ),
          if (driver?.phone?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.phone_rounded,
              label: AppStrings.phoneNumber,
              value: driver!.phone!,
              color: AppColors.secondaryText,
            ),
          ],
          if (driver?.birthDate != null) ...[
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.cake_rounded,
              label: AppStrings.birthDate,
              value: DateFormatter.formatDate(driver!.birthDate!),
              color: AppColors.secondaryText,
            ),
          ],
          if (driver?.hometown?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.location_on_rounded,
              label: AppStrings.hometown,
              value: driver!.hometown!,
              color: AppColors.secondaryText,
            ),
          ],
        ],
      ),
    );
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