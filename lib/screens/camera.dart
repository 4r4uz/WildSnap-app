import 'package:flutter/material.dart';
import 'package:frontend/components/appbar.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(title: 'Cámara', showActions: false,),
      body: Center(child: Icon(Icons.photo_camera_sharp)),
    );
  }
}
