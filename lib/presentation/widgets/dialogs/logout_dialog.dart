import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/strings.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.logout),
      content: const Text(AppStrings.logoutConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(AppStrings.confirm),
        ),
      ],
    );
  }
}