import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/routes/route_names.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_button.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_text_field.dart';
import 'package:nalogistics_app/presentation/controllers/auth_controller.dart';

class ApiLoginPage extends StatefulWidget {
  const ApiLoginPage({super.key});

  @override
  State<ApiLoginPage> createState() => _ApiLoginPageState();
}

class _ApiLoginPageState extends State<ApiLoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);

    final success = await authController.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              // const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  authController.loginResponse?.message ?? 'Đăng nhập thành công',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.statusDelivered,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to main screen
      context.go(RouteNames.main);
    } else {
      // Error đã được hiển thị qua Consumer
      // Có thể thêm haptic feedback
      // HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header section
                      Flexible(
                        flex: screenHeight > 700 ? 4 : 3,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight: screenHeight > 700 ? 200 : 150,
                              maxHeight: screenHeight > 700 ? 350 : 250,
                            ),
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo container
                                Container(
                                  width: screenHeight > 700 ? 120 : 90,
                                  height: screenHeight > 700 ? 80 : 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [AppColors.elevatedShadow],
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppColors.maritimeBlue,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Icon(
                                          Icons.local_shipping_rounded,
                                          size: screenHeight > 700 ? 40 : 30,
                                          color: AppColors.maritimeBlue,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: AppColors.containerOrange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight > 700 ? 24 : 16),
                                Text(
                                  'NALogistics',
                                  style: TextStyle(
                                    fontSize: screenHeight > 700 ? 32 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: screenHeight > 700 ? 8 : 4),
                                Text(
                                  'Cổng thông tin',
                                  style: TextStyle(
                                    fontSize: screenHeight > 700 ? 16 : 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Form section
                      Flexible(
                        flex: screenHeight > 700 ? 5 : 6,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                minHeight: screenHeight > 700 ? 300 : 350,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: screenHeight > 700 ? 32 : 24,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Xin chào',
                                      style: TextStyle(
                                        fontSize: screenHeight > 700 ? 28 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight > 700 ? 8 : 4),
                                    Text(
                                      'Đăng nhập để tiếp tục',
                                      style: TextStyle(
                                        fontSize: screenHeight > 700 ? 16 : 14,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight > 700 ? 40 : 32),

                                    // Username field
                                    CustomTextField(
                                      controller: _usernameController,
                                      labelText: 'Tên đăng nhập',
                                      prefixIcon: Icons.badge_outlined,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Vui lòng nhập tên đăng nhập';
                                        }
                                        return null;
                                      },
                                    ),

                                    SizedBox(height: screenHeight > 700 ? 24 : 20),

                                    // Password field
                                    CustomTextField(
                                      controller: _passwordController,
                                      labelText: 'Mật khẩu',
                                      prefixIcon: Icons.lock_outline,
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng nhập mật khẩu';
                                        }
                                        if (value.length < 3) {
                                          return 'Mật khẩu phải có ít nhất 3 ký tự';
                                        }
                                        return null;
                                      },
                                    ),

                                    SizedBox(height: screenHeight > 700 ? 32 : 24),

                                    // Login button với Consumer để listen state changes
                                    Consumer<AuthController>(
                                      builder: (context, authController, child) {
                                        return Column(
                                          children: [
                                            CustomButton(
                                              text: 'ĐĂNG NHẬP',
                                              onPressed: authController.isLoading ? null : _handleLogin,
                                              isLoading: authController.isLoading,
                                              isFullWidth: true,
                                              backgroundColor: AppColors.maritimeBlue,
                                            ),

                                            // Error message
                                            if (authController.hasError) ...[
                                              const SizedBox(height: 16),
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: AppColors.statusError.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: AppColors.statusError.withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.error_outline,
                                                      color: AppColors.statusError,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        authController.errorMessage!,
                                                        style: const TextStyle(
                                                          color: AppColors.statusError,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        );
                                      },
                                    ),

                                    SizedBox(height: screenHeight > 700 ? 24 : 16),

                                    // Help section - ẩn khi màn hình nhỏ
                                    if (screenHeight > 600) ...[
                                      Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              'Cần hỗ trợ đăng nhập?',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextButton(
                                              onPressed: () {
                                                // Show help dialog hoặc contact info
                                                _showHelpDialog();
                                              },
                                              child: Text(
                                                'Liên hệ IT Support',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.maritimeBlue,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: AppColors.maritimeBlue,
            ),
            const SizedBox(width: 8),
            const Text('Hỗ trợ đăng nhập'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nếu bạn gặp vấn đề đăng nhập, vui lòng liên hệ:'),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 18),
                SizedBox(width: 8),
                Text('Hotline: 1900-NALOG'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, size: 18),
                SizedBox(width: 8),
                Text('Email: support@nalogistics.com'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: TextStyle(color: AppColors.maritimeBlue),
            ),
          ),
        ],
      ),
    );
  }
}