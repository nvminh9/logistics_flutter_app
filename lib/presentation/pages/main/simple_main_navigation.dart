import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/presentation/pages/home/home_page.dart';
import 'package:nalogistics_app/presentation/pages/orders/order_list_page.dart';
import 'package:nalogistics_app/presentation/pages/profile/profile_page.dart';

class SimpleMainNavigationPage extends StatefulWidget {
  const SimpleMainNavigationPage({super.key});

  @override
  State<SimpleMainNavigationPage> createState() => _SimpleMainNavigationPageState();
}

class _SimpleMainNavigationPageState extends State<SimpleMainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const OrderListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.maritimeBlue,
        unselectedItemColor: AppColors.secondaryText,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: AppStrings.tabHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: AppStrings.tabOrders,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: AppStrings.tabProfile,
          ),
        ],
      ),
    );
  }
}