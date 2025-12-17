import 'package:flutter/material.dart';
import 'package:streaming_dashboard/core/constants/app_asset_images.dart';
import 'package:streaming_dashboard/features/views/dashboard/presentation/home_view.dart';
import 'package:streaming_dashboard/features/views/profile/presentation/profile_view.dart';
import '../../camera/presentation/camera_page.dart';

class MaintabbarView extends StatefulWidget {
  const MaintabbarView({super.key});

  @override
  State<MaintabbarView> createState() => _MaintabbarViewState();
}

class _MaintabbarViewState extends State<MaintabbarView> {
  int _selectedIndex = 0;

  // List of pages/classes for each tab
  final List<Widget> _pages = [
    const HomeView(),
    const CameraView(),
    const ProfileView(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = shortestSide >= 600;
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: _pages[_selectedIndex], // Display selected page
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2a2a2a),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: isTablet ? 80 : 60,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40 : 20,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(index: 0, assetPath: homeImg, isTablet: isTablet),
                _buildTabItem(
                  index: 1,
                  assetPath: cameraImg,
                  isTablet: isTablet,
                ),
                _buildTabItem(index: 2, assetPath: menuImg, isTablet: isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String assetPath,
    required bool isTablet,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 18 : 14,
              vertical: isTablet ? 12 : 6,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: isSelected
                  ? Border.all(color: Color(0xFFB1B2B2), width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: Image.asset(
              assetPath,
              color: isSelected ? Colors.white : Colors.grey,
              width: isTablet ? 32.0 : 24.0,
              height: isTablet ? 32.0 : 24.0,
            ),
          ),
        ],
      ),
    );
  }
}
