import 'dart:math' as math;
import 'package:flutter/material.dart';
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
    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
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
          highlightedIndex: _highlightedIndex,
          menuLabels: menuLabels,
          menuIcons: menuIcons,
          screenIndices: screenIndices,
          buttonKey: _buttonKey,
          onItemSelected: (index) {
            setState(() {
              currentIndex = index;
            });
            _hideMenu();
          },
          onHighlightChanged: (index) {
            setState(() {
              _highlightedIndex = index;
            });
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

  void _handlePanStart(DragStartDetails details) {
    _showMenu();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Sistema de Zonas de Atracción Magnética
    final RenderBox buttonBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final buttonCenter = buttonPosition + const Offset(25, 25); // Centro del botón (50x50 / 2)

    // Calcular distancia y dirección desde el botón
    final deltaX = details.globalPosition.dx - buttonCenter.dx;
    final deltaY = details.globalPosition.dy - buttonCenter.dy;
    final distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);
    final angle = math.atan2(deltaY, deltaX);

    // Sistema de atracción magnética
    if (distance > 30) { // Solo activar fuera del botón
      // Calcular velocidad del gesto para determinar si usar atracción
      final velocity = details.delta.distance;
      final useMagneticZones = velocity < 2.0; // Gestos lentos usan atracción

      if (useMagneticZones) {
        // Zonas magnéticas inteligentes basadas en ángulos
        int targetIndex = -1;

        if (angle >= -math.pi/2 && angle < -math.pi/6) {
          targetIndex = 0; // Home (arriba-derecha)
        } else if (angle >= -math.pi/6 && angle < math.pi/6) {
          targetIndex = 1; // Camera (derecha)
        } else if (angle >= math.pi/6 && angle < math.pi/2) {
          targetIndex = 2; // Gallery (abajo-derecha)
        } else if (angle >= math.pi/2 && angle < 5*math.pi/6) {
          targetIndex = 3; // Map (abajo)
        } else if ((angle >= 5*math.pi/6 && angle <= math.pi) ||
                   (angle >= -math.pi && angle < -5*math.pi/6)) {
          targetIndex = 4; // Profile (izquierda)
        } else if (angle >= -5*math.pi/6 && angle < -math.pi/2) {
          targetIndex = 5; // Settings (arriba-izquierda)
        }

        if (targetIndex >= 0 && targetIndex < screenIndices.length) {
          setState(() {
            _highlightedIndex = targetIndex;
          });
        }
      } else {
        // Para gestos rápidos, usar detección posicional tradicional
        final menuTop = buttonPosition.dy - (6 * 70);
        final menuHeight = 6 * 70;
        final localY = details.globalPosition.dy - menuTop;
        if (localY >= 0 && localY <= menuHeight) {
          final itemIndex = (localY / 70).floor().clamp(0, 5);
          setState(() {
            _highlightedIndex = itemIndex;
          });
        } else {
          setState(() {
            _highlightedIndex = -1;
          });
        }
      }
    } else {
      setState(() {
        _highlightedIndex = -1;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_highlightedIndex >= 0 && _highlightedIndex < screenIndices.length) {
      setState(() {
        currentIndex = screenIndices[_highlightedIndex];
      });
    }
    _hideMenu();
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentIndex.clamp(0, screens.length - 1);

    return Stack(
      children: [
        IndexedStack(
          index: safeIndex,
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
                  setState(() {
                    currentIndex = 1; // Camera
                  });
                },
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
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
  final int highlightedIndex;
  final List<String> menuLabels;
  final List<IconData> menuIcons;
  final List<int> screenIndices;
  final GlobalKey buttonKey;
  final Function(int) onItemSelected;
  final Function(int) onHighlightChanged;

  const _MenuOverlay({
    required this.animationController,
    required this.onDismiss,
    required this.currentIndex,
    required this.highlightedIndex,
    required this.menuLabels,
    required this.menuIcons,
    required this.screenIndices,
    required this.buttonKey,
    required this.onItemSelected,
    required this.onHighlightChanged,
  });

  @override
  State<_MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<_MenuOverlay> {
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOut,
    ));
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox buttonBox = widget.buttonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonPosition = buttonBox.localToGlobal(Offset.zero);

    // Calcular área del menú
    final menuTop = buttonPosition.dy - (6 * 70); // 6 items * 70px cada uno
    final menuHeight = 6 * 70;
    
    // Verificar si el dedo está sobre algún item del menú
    final localY = details.globalPosition.dy - menuTop;
    if (localY >= 0 && localY <= menuHeight) {
      final itemIndex = (localY / 70).floor().clamp(0, 5);
      widget.onHighlightChanged(itemIndex);
    } else {
      widget.onHighlightChanged(-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: (_) {
        if (widget.highlightedIndex >= 0) {
          widget.onItemSelected(widget.screenIndices[widget.highlightedIndex]);
        }
      },
      child: Material(
        color: Colors.black54,
        child: Stack(
          children: [
            // Botones del menú con animación
            ...List.generate(6, (index) {
              return Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45 + (index * 70),
                right: 60,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: _MenuItem(
                        label: widget.menuLabels[index],
                        icon: widget.menuIcons[index],
                        isCurrent: widget.screenIndices[index] == widget.currentIndex,
                        isHighlighted: index == widget.highlightedIndex,
                        onTap: () {
                          widget.onItemSelected(widget.screenIndices[index]);
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
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
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _updateAnimations();
  }

  @override
  void didUpdateWidget(_MenuItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isHighlighted != widget.isHighlighted) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isHighlighted) {
      _scaleController.forward();
      _glowController.repeat(reverse: true);
    } else {
      _scaleController.reverse();
      _glowController.stop();
      _glowController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        final scaleValue = _scaleAnimation.value;
        final glowValue = _glowAnimation.value;

        return Transform.scale(
          scale: scaleValue,
          child: Container(
            width: 220,
            height: 64,
            decoration: BoxDecoration(
              gradient: widget.isHighlighted
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF2196F3).withOpacity(0.98),
                        const Color(0xFF21CBF3).withOpacity(0.95),
                        const Color(0xFF1976D2).withOpacity(0.92),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : widget.isCurrent
                      ? LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.95),
                            Colors.grey[50]!.withOpacity(0.9),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.grey[50]!.withOpacity(0.8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isHighlighted
                    ? Colors.white.withOpacity(0.9)
                    : widget.isCurrent
                        ? const Color(0xFF2196F3).withOpacity(0.6)
                        : Colors.grey[200]!.withOpacity(0.8),
                width: widget.isHighlighted ? 3 : 2,
              ),
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2196F3).withOpacity(0.4 + glowValue * 0.3),
                        blurRadius: 25 + glowValue * 10,
                        spreadRadius: 2 + glowValue * 2,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: const Color(0xFF21CBF3).withOpacity(0.2 + glowValue * 0.2),
                        blurRadius: 15 + glowValue * 5,
                        spreadRadius: 1 + glowValue * 1,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : widget.isCurrent
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                splashColor: const Color(0xFF2196F3).withOpacity(0.1),
                highlightColor: const Color(0xFF2196F3).withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Row(
                    children: [
                      // Icono con efecto de brillo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.isHighlighted
                                    ? [
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.7),
                                      ]
                                    : [
                                        Colors.white.withOpacity(0.8),
                                        Colors.grey[100]!.withOpacity(0.6),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isHighlighted
                                      ? Colors.white.withOpacity(0.4)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),

                          // Efecto de brillo para items destacados
                          if (widget.isHighlighted)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.4 + glowValue * 0.3),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 1.0],
                                ),
                              ),
                            ),

                          Icon(
                            widget.icon,
                            color: widget.isHighlighted
                                ? const Color(0xFF2196F3)
                                : widget.isCurrent
                                    ? const Color(0xFF2D3748)
                                    : Colors.grey[600],
                            size: 20,
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // Texto mejorado
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.label,
                              style: TextStyle(
                                color: widget.isHighlighted
                                    ? Colors.white
                                    : widget.isCurrent
                                        ? const Color(0xFF2D3748)
                                        : Colors.grey[700],
                                fontSize: 16,
                                fontWeight: widget.isCurrent ? FontWeight.w700 : FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            if (widget.isCurrent)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Activo',
                                  style: TextStyle(
                                    color: const Color(0xFF2196F3),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Indicador mejorado
                      if (widget.isCurrent)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2196F3).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            color: const Color(0xFF2196F3),
                            size: 14,
                          ),
                        ),

                      // Indicador de atracción magnética
                      if (widget.isHighlighted)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.touch_app,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
