import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/camera.dart';
import '../screens/gallery.dart';
import '../screens/home.dart';
import '../screens/map.dart';
import '../screens/profile.dart';
import '../screens/settings.dart';
import 'floating_nav_button.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> with TickerProviderStateMixin {
  int currentIndex = 0;
  bool _isMenuOpen = false;
  late PageController _pageController;

  final List<Widget> screens = [
    const HomeScreen(),
    const CameraScreen(),
    const GalleryScreen(),
    const MapScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  final List<String> menuLabels = const [
    'Home',
    'Camara',
    'Coleccion',
    'Mapa',
    'Perfil',
    'Ajustes',
  ];

  final List<IconData> menuIcons = const [
    Icons.home,
    Icons.camera,
    Icons.collections,
    Icons.map,
    Icons.person,
    Icons.settings,
  ];

  final List<int> screenIndices = const [0, 1, 2, 3, 4, 5];

  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  int _highlightedIndex = -1;
  late AnimationController _menuAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _menuAnimationController.dispose();
    _hideMenu();
    super.dispose();
  }

  void _showMenu() {
    if (_isMenuOpen) return;
    
    _isMenuOpen = true;
    _highlightedIndex = -1;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _MenuOverlay(
          animationController: _menuAnimationController,
          onDismiss: _hideMenu,
          currentIndex: currentIndex,
          menuLabels: menuLabels,
          menuIcons: menuIcons,
          screenIndices: screenIndices,
          onItemSelected: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            _hideMenu();
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _menuAnimationController.forward();
  }

  void _hideMenu() {
    if (!_isMenuOpen) return;
    
    _menuAnimationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isMenuOpen = false;
      _highlightedIndex = -1;
    });
  }

  void _handleLongPress() {
    _showMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(), // Deshabilitar swipe, solo navegación por botones
          children: screens,
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.45,
          right: 0,
          child: Container(
            key: _buttonKey,
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300]!.withValues(alpha: 38 / 255.0),
              shape: BoxShape.circle,
            ),
            child: Center(
            child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    1, // Camera index
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                onLongPress: _handleLongPress,
                child: FloatingNavButton(
                  isHighlighted: _highlightedIndex >= 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuOverlay extends StatefulWidget {
  final AnimationController animationController;
  final VoidCallback onDismiss;
  final int currentIndex;
  final List<String> menuLabels;
  final List<IconData> menuIcons;
  final List<int> screenIndices;
  final Function(int) onItemSelected;

  const _MenuOverlay({
    required this.animationController,
    required this.onDismiss,
    required this.currentIndex,
    required this.menuLabels,
    required this.menuIcons,
    required this.screenIndices,
    required this.onItemSelected,
  });

  @override
  State<_MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<_MenuOverlay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss, // Cerrar menú al tocar fuera
      child: Material(
        color: Colors.black54,
        child: Stack(
          children: [
            // Botones del menú sin animaciones complejas
            ...List.generate(6, (index) {
              return Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45 + (index * 70),
                right: 60,
                child: _MenuItem(
                  label: widget.menuLabels[index],
                  icon: widget.menuIcons[index],
                  isCurrent: widget.screenIndices[index] == widget.currentIndex,
                  isHighlighted: false,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onItemSelected(widget.screenIndices[index]);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCurrent;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    required this.icon,
    required this.isCurrent,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 64,
      decoration: BoxDecoration(
        color: isCurrent ? Colors.white.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? const Color(0xFF2196F3).withValues(alpha: 0.6) : Colors.grey[200]!.withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
          highlightColor: const Color(0xFF2196F3).withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isCurrent ? const Color(0xFF2D3748) : Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: isCurrent ? const Color(0xFF2D3748) : Colors.grey[700],
                          fontSize: 16,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Activo',
                            style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF2196F3),
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
