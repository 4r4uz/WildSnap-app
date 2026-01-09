import 'package:flutter/material.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFF0D1B2A), // Azul océano profundo
    this.surfaceColor = const Color(0xFF1B263B), // Azul cielo nocturno
  });

  final Widget child;
  final Color backgroundColor;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            surfaceColor,
            backgroundColor.withBlue(30), // Variación sutil
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}

// Mantenemos AnimatedGradientBackground para compatibilidad pero usando colores mate
class AnimatedGradientBackground extends StatelessWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF0F1419), // Mate oscuro
      Color(0xFF1A1F26), // Mate superficie
    ],
  });

  final Widget child;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.first, // Solo usamos el primer color (mate)
      ),
      child: child,
    );
  }
}
