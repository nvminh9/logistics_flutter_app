// ⚠️ ONLY FOR TESTING - Remove in production
import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/services/session_manager.dart';
import 'package:nalogistics_app/core/constants/colors.dart';

class TestTokenExpirationButton extends StatelessWidget {
  const TestTokenExpirationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    assert(() {
      return true;
    }());

    return FloatingActionButton.extended(
      onPressed: () {
        _showTestDialog(context);
      },
      backgroundColor: Colors.red,
      icon: const Icon(Icons.bug_report),
      label: const Text('Test Token'),
    );
  }

  void _showTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🧪 Test Token Expiration'),
        content: const Text(
          'Bạn muốn test token expiration?\n\n'
              'Điều này sẽ:\n'
              '• Clear token hiện tại\n'
              '• Hiển thị dialog hết hạn\n'
              '• Redirect về login page',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger token expiration
              SessionManager().handleTokenExpired(
                message: '🧪 Test: Token đã hết hạn (Demo)',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Trigger Expiration'),
          ),
        ],
      ),
    );
  }
}

// Widget để thêm vào Profile Page (for testing)
class TokenExpirationTestSection extends StatelessWidget {
  const TokenExpirationTestSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'DEBUG MODE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Test Token Expiration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn nút bên dưới để test tính năng xử lý token hết hạn',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                SessionManager().handleTokenExpired(
                  message: '🧪 TEST: Token đã hết hạn (Demo Mode)',
                );
              },
              icon: const Icon(Icons.error_outline),
              label: const Text('Trigger Token Expiration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}