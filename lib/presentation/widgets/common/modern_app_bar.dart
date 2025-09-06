import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom; // Support for TabBar
  final double? elevation;
  final Color? foregroundColor;
  final TextStyle? titleStyle;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.bottom,
    this.elevation,
    this.foregroundColor,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(elevation != null ? elevation! * 0.02 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: titleStyle ?? const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        leading: leading,
        actions: actions,
        bottom: bottom, // Support for TabBar
        foregroundColor: foregroundColor ?? AppColors.primaryText,
        iconTheme: IconThemeData(
          color: foregroundColor ?? AppColors.primaryText,
        ),
        actionsIconTheme: IconThemeData(
          color: foregroundColor ?? AppColors.primaryText,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}