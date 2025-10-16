import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraComponent extends StatefulWidget {
  const CameraComponent({super.key, this.onControllerReady});

  final Function(CameraController controller)? onControllerReady;

  @override
  State<CameraComponent> createState() => _CameraComponentState();
}

class _CameraComponentState extends State<CameraComponent> {
  bool isReady = false;
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      // Usar la cámara trasera si existe
      final camera = cameras.first;

      // ResolutionPreset.high para resolución nativa del teléfono
      controller = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller!.initialize();

      if (!mounted) return;

      widget.onControllerReady?.call(controller!);

      setState(() {
        isReady = true;
      });
    } catch (e) {
      debugPrint('Error al iniciar cámara: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady || controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ajuste para mantener la relación de aspecto y que no se estire la camara xd
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover, 
        alignment: Alignment.center,
        child: SizedBox(
          width: controller!.value.previewSize!.height,
          height: controller!.value.previewSize!.width,
          child: CameraPreview(controller!),
        ),
      ),
    );
  }
}
