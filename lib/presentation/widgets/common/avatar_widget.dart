import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';

class AvatarWidget extends StatelessWidget {
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const AvatarWidget({
    Key? key,
    this.name,
    this.radius = 40,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.maritimeDarkBlue,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? AppColors.maritimeDarkBlue,
        child: Text(
          _getInitial(name),
          style: TextStyle(
            fontSize: fontSize ?? (radius * 0.7),
            color: textColor ?? AppColors.primaryBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Safe way to get first character of name
  String _getInitial(String? name) {
    if (name == null || name.isEmpty) {
      return 'U'; // Default User initial
    }

    // Remove whitespace and special characters
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      return 'U';
    }

    // Try to get first letter of first word
    final words = cleanName.split(' ');
    if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0].substring(0, 1).toUpperCase();
    }

    // Fallback: just get first character
    return cleanName.substring(0, 1).toUpperCase();
  }
}