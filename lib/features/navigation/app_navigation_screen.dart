import 'package:flutter/material.dart';
import 'package:local_govt_mw/features/home/screens/homepage_screen.dart';
import 'package:local_govt_mw/features/profile/screens/profile_screen.dart';

class AppNavigationScreen extends StatefulWidget {
  const AppNavigationScreen({super.key});

  @override
  State<AppNavigationScreen> createState() => _AppNavigationScreenState();
}

class _AppNavigationScreenState extends State<AppNavigationScreen> {
  int _currentIndex = 0;

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kInactiveGrey = Color(0xFF9CA3AF);

  final List<Widget> _pages = [
    const HomepageScreen(),
    const ProfilePage(),
    const ProfilePage(),
  ];

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,

          // ✅ Important
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,

          selectedItemColor: kPrimaryGreen,
          unselectedItemColor: kInactiveGrey,

          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.report_outlined),
              activeIcon: Icon(Icons.report),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}