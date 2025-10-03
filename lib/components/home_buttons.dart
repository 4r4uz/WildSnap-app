import 'package:flutter/material.dart';
import 'package:frontend/core/colors.dart';
import 'package:frontend/core/text_style.dart';
import 'package:frontend/screens/camera.dart';
import 'package:frontend/screens/gallery.dart';

class HomeButtons extends StatefulWidget {
  const HomeButtons({super.key});

  @override
  State<HomeButtons> createState() => _HomeButtonsState();
}

class _HomeButtonsState extends State<HomeButtons> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón Cámara
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ElevatedButton(
              onPressed: () {
                //ir a cámara
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraScreen()));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Acceder a cámara', style: TextStyles.buttonTextStyle),
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 10),
            child: ElevatedButton(
              onPressed: () {
                //ir a galería
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen()));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Acceder a galería', style: TextStyles.buttonTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}
