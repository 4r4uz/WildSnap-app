import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: highlighted ? 1.18 : 1.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: highlighted ? 1.0 : 0.55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: highlighted ? 0.14 : 0.06,
                ),
                boxShadow: highlighted
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
