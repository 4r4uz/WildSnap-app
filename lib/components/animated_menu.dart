import 'package:flutter/material.dart';

class FloatingNavButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback onPanStart;
  final VoidCallback onPanUpdate;
  final VoidCallback onPanEnd;
  final bool isHighlighted;

  const FloatingNavButton({
    super.key,
    required this.onPressed,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    this.isHighlighted = false,
  });

  @override
  State<FloatingNavButton> createState() => _FloatingNavButtonState();
}

class _FloatingNavButtonState extends State<FloatingNavButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      onPanStart: (_) {
        setState(() => _isPressed = true);
        widget.onPanStart();
      },
      onPanUpdate: (_) => widget.onPanUpdate(),
      onPanEnd: (_) {
        setState(() => _isPressed = false);
        widget.onPanEnd();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: _isPressed ? 38 : 40,
        height: _isPressed ? 38 : 40,
        decoration: BoxDecoration(
          gradient: widget.isHighlighted
              ? LinearGradient(
                  colors: [
                    Colors.blueAccent.withAlpha(150),
                    Colors.lightBlueAccent.withAlpha(150)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withAlpha(200),
                    Colors.grey[100]!.withAlpha(200)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.isHighlighted 
                ? Colors.blue[400]!.withAlpha(150)
                : Colors.grey[300]!.withAlpha(100),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(_isPressed ? 30 : 60),
              blurRadius: _isPressed ? 6 : 12,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Icon(
          Icons.menu,
          color: widget.isHighlighted 
              ? Colors.white
              : Colors.grey[700]!.withAlpha(200),
          size: 18,
        ),
      ),
    );
  }
}