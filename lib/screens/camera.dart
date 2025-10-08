import 'package:flutter/material.dart';
import '../components/camera_on.dart';
import '../components/appbar.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(title: 'Cámara'),
      body: Container(
        margin: const EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 180),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(8),
          child: CameraComponent(),
        ),
      ),
    );
  }
}
