import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/constants/strings.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryText,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? AppStrings.loading,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}