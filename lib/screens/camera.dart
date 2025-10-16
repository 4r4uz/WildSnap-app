import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../components/camera_on.dart';
import '../components/appbar.dart';
import '../components/capture_photo.dart';
import '../components/identifier.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  final ImageClassifier _classifier = ImageClassifier();

  Future<void> _takePicture() async {
    if (_controller == null) return;

    final handler = CameraHandler(_controller!);
    final image = await handler.takePicture();

    if (!mounted || image == null) return;

    // Clasificar con IAAAA
    final result = await _classifier.classifyImage(File(image.path));

    // Mostrar resultado :)
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Resultado')),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(File(image.path)),
              const SizedBox(height: 20),
              Text(
                'Objeto detectado: ${result['label']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Confianza: ${result['confidence']}%',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(title: 'Cámara con IA'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: CameraComponent(
                    onControllerReady: (controller) {
                      setState(() {
                        _controller = controller;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                IconButton.filled(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_alt_sharp),
                  iconSize: 80,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
