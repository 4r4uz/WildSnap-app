import 'package:flutter/material.dart';
import '../styles/text_style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final List<Color> gradientColors;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final double iconSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.gradientColors,
    required this.onPressed,
    this.icon,
    this.height = 200,
    this.width,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: const Color.fromARGB(255, 46, 46, 46),
              ),
            if (icon != null) const SizedBox(height: 10),
            Text(text, style: TextStyles.buttonTextStyle),
          ],
        ),
      ),
    );
  }
}
