import 'package:flutter/material.dart';
import '../screens/camera.dart';
import '../screens/gallery.dart';
import '../screens/map.dart';
import '../screens/trivia.dart';
import '../styles/gradient_custom_button.dart';

class HomeButtons extends StatelessWidget {
  const HomeButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        children: [
          CustomButton(
            text: 'Identificar Animal',
            icon: Icons.photo_camera_rounded,
            gradientColors: [Colors.lightBlue, Colors.lightGreen],
            height: 240,
            iconSize: 150,
            width: 380,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Colección',
                  gradientColors: [Colors.deepOrange, Colors.orange],
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GalleryScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Mapa',
                  gradientColors: [Colors.orange, Colors.deepOrange],
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          CustomButton(
            text: 'Jugar Trivia',
            gradientColors: [
              Colors.deepOrange,
              Colors.orange,
              Colors.deepOrange,
            ],
            height: 180,
            width: 380,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TriviaScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
