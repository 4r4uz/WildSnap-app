import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraHandler {
  final CameraController controller;

  CameraHandler(this.controller);

  /// Toma una foto y devuelve el archivo capturado.
  Future<XFile?> takePicture() async {
    try {
      if (!controller.value.isInitialized) {
        debugPrint('La cámara no está lista');
        return null;
      }

      if (controller.value.isTakingPicture) return null;

      final image = await controller.takePicture();
      return image;
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
      return null;
    }
  }
}
