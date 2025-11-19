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
  bool hasError = false;
  String errorMessage = '';
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No se encontraron cámaras disponibles');
      }

      // Usar la cámara trasera si existe
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // ResolutionPreset.high para buena calidad
      controller = CameraController(
        camera,
        ResolutionPreset.high,
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
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt,
                color: Colors.white54,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al acceder a la cámara',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasError = false;
                    isReady = false;
                  });
                  _initCamera();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (!isReady || controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Iniciando cámara...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
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
