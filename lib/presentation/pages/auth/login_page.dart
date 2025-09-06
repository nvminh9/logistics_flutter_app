import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/routes/route_names.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_button.dart';
import 'package:nalogistics_app/presentation/widgets/common/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      if (!mounted) return;
      context.go(RouteNames.main);
    } else {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.loginFailed),
          backgroundColor: AppColors.statusError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - MediaQuery.of(context).padding.top - keyboardHeight;

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
                      // Header với flexible height
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
                                // Container icon với responsive size
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
                                  'Cổng thông tin tài xế',
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

                      // Form section với flexible height
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

                                    // Form fields
                                    CustomTextField(
                                      controller: _usernameController,
                                      labelText: 'Tài khoản',
                                      prefixIcon: Icons.badge_outlined,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Chưa nhập tài khoản';
                                        }
                                        return null;
                                      },
                                    ),

                                    SizedBox(height: screenHeight > 700 ? 24 : 20),

                                    CustomTextField(
                                      controller: _passwordController,
                                      labelText: 'Mật khẩu',
                                      prefixIcon: Icons.lock_outlined,
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Chưa nhập mật khẩu';
                                        }
                                        return null;
                                      },
                                    ),

                                    SizedBox(height: screenHeight > 700 ? 32 : 24),

                                    // Login button
                                    CustomButton(
                                      text: 'ĐĂNG NHẬP',
                                      onPressed: _isLoading ? null : _login,
                                      isLoading: _isLoading,
                                      isFullWidth: true,
                                      backgroundColor: AppColors.maritimeBlue,
                                    ),

                                    SizedBox(height: screenHeight > 700 ? 24 : 16),

                                    // Help section - ẩn khi màn hình nhỏ
                                    if (screenHeight > 600) ...[
                                      Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              'Bạn có cần hỗ trợ đăng nhập?',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextButton(
                                              onPressed: () {
                                                // Contact IT support
                                              },
                                              child: Text(
                                                'Liên hệ hỗ trợ',
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
}