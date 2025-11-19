import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../components/camera_on.dart';
import '../components/image_analizer.dart';
import 'photo_details.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  final ImageClassifier _classifier = ImageClassifier();
  bool _isProcessing = false;
  FlashMode _flashMode = FlashMode.auto;
  double _zoomLevel = 1.0;

  void _toggleFlash() {
    setState(() {
      switch (_flashMode) {
        case FlashMode.off:
          _flashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _flashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _flashMode = FlashMode.off;
          break;
        case FlashMode.torch:
          _flashMode = FlashMode.off;
          break;
      }
    });
    _controller?.setFlashMode(_flashMode);
  }



  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_auto;
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _controller!.takePicture();

      if (!mounted) return;

      // Clasificar con IA
      final result = await _classifier.classifyImage(File(image.path));

      // Verificar confianza
      final confidence = double.tryParse(result['confidence'] ?? '0') ?? 0.0;

      if (!mounted) return;

      if (confidence < 90.0) { // Umbral bajo para considerar no identificado
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sin Animal Detectado'),
              content: const Text('No se pudo identificar ningún animal en la imagen. Inténtalo de nuevo con una imagen más clara donde se vea mejor el animal.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            );
          },
        );
      } else {
        // Mostrar resultado
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoDetailsScreen(result: result),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
      // Mostrar mensaje de error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar imagen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              // Camera preview - full screen with vertical drag zoom
              Positioned.fill(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (!mounted) return;
                    // Vertical drag: up = zoom in, down = zoom out
                    final deltaY = details.delta.dy;
                    // Negative deltaY means dragging up (zoom in), positive means dragging down (zoom out)
                    final zoomChange = deltaY > 0 ? 0.98 : 1.02; // Smaller increments for smoother control
                    setState(() {
                      _zoomLevel = (_zoomLevel * zoomChange).clamp(1.0, 5.0);
                    });
                    _controller?.setZoomLevel(_zoomLevel);
                  },
                  child: CameraComponent(
                    onControllerReady: (controller) {
                      if (mounted) {
                        setState(() {
                          _controller = controller;
                        });
                      }
                    },
                  ),
                ),
              ),

              // IA Activa badge - positioned lower
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'IA Activa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom controls
              Positioned(
                bottom: 80, // Moved higher up
                left: 20,
                right: 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Flash control - moved further to the left
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 - 72 - 80, // More distance from center
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _toggleFlash,
                          icon: Icon(
                            _getFlashIcon(),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Capture button - perfectly centered with integrated status
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 3,
                        ),
                        color: _isProcessing
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      child: _isProcessing
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                                // Status text inside the circle
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Analizando...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : IconButton(
                              onPressed: _takePicture,
                              icon: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
