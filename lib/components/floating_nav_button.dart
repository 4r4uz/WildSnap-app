import 'package:flutter/material.dart';

class FloatingNavButton extends StatefulWidget {
  final bool isHighlighted;

  const FloatingNavButton({
    super.key,
    this.isHighlighted = false,
  });

  @override
  State<FloatingNavButton> createState() => _FloatingNavButtonState();
}

class _FloatingNavButtonState extends State<FloatingNavButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    if (widget.isHighlighted) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  void didUpdateWidget(FloatingNavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _scaleController.forward();
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
      builder: (context, child) {
        final pulseValue = _pulseAnimation.value;
        final scaleValue = _scaleAnimation.value;

        return Transform.scale(
          scale: scaleValue,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: widget.isHighlighted
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF2196F3).withValues(alpha: 0.9 + pulseValue * 0.1),
                        const Color(0xFF21CBF3).withValues(alpha: 0.8 + pulseValue * 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isHighlighted
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.black.withValues(alpha: 0.1),
                width: 2,
              ),
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.4 + pulseValue * 0.3),
                        blurRadius: 20 + pulseValue * 10,
                        spreadRadius: 2 + pulseValue * 3,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFF21CBF3).withValues(alpha: 0.2 + pulseValue * 0.2),
                        blurRadius: 10 + pulseValue * 5,
                        spreadRadius: 1 + pulseValue * 2,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Efecto de brillo
                if (widget.isHighlighted)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3 + pulseValue * 0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),

                // Icono principal
                Icon(
                  Icons.camera_alt,
                  color: widget.isHighlighted
                      ? Colors.white
                      : const Color(0xFF2D3748),
                  size: 22,
                ),

                // Indicador de menú disponible
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: AnimatedOpacity(
                    opacity: widget.isHighlighted ? 0.0 : 0.7,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF48BB78),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
