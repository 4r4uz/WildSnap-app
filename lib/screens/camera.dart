import 'package:flutter/material.dart';
import 'package:frontend/core/colors.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cámara'), backgroundColor: AppColors.primary),
      body: Center(
        child: Icon(Icons.photo_camera_sharp)
      )
    );
  }
}
