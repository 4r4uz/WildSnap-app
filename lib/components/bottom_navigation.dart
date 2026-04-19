import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/colors.dart';

/// Modelo de datos para items de navegación
class _NavItemData {
  final IconData icon;
  final String label;
  final Widget screen;

  const _NavItemData({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  // Lista de pantallas 
  late final List<_NavItemData> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = const [
      _NavItemData(
        icon: Icons.home,
        label: 'Inicio',
        screen: HomeScreen(),
      ),
      _NavItemData(
        icon: Icons.camera_alt,
        label: 'Cámara',
        screen: CameraScreen(),
      ),
      _NavItemData(
        icon: Icons.collections,
        label: 'Galería',
        screen: GalleryScreen(),
      ),
      _NavItemData(
        icon: Icons.person,
        label: 'Perfil',
        screen: ProfileScreen(),
      ),
    ];
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.background,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _navItems.length,
          (index) => _buildNavItem(index),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
