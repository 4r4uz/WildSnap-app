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
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _controller!.takePicture();

      if (!mounted) return;

      // Clasificar con IA
      final result = await _classifier.classifyImage(File(image.path));

      if (!mounted) return;

      // Verificar el tipo de resultado
      final label = result['label'] as String;

      if (label == 'Sin animal detectado') {
        // No se detectó ningún animal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sin animal detectado en la imagen'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.blue.shade700,
            action: SnackBarAction(
              label: 'Ver detalles',
              textColor: Colors.white,
              onPressed: () {
                final detections = _classifier.getLastDetections();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Sin detección'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No se encontró ningún animal en la imagen.',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Total detecciones analizadas: $detections.length',
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Posibles causas:',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const Text('• La imagen no contiene animales'),
                            const Text('• El animal no es reconocible'),
                            const Text('• Imagen de baja calidad o borrosa'),
                            const Text('• Animal muy pequeño en la imagen'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Entendido'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      } else if (label == 'Detección poco confiable') {
        // Se detectó algo pero con baja confianza
        final confidence = result['confidence'] as String;
        final bestAlternative =
            result['best_alternative'] as Map<String, dynamic>?;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Detección poco confiable ($confidence%)'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.orange.shade700,
            action: SnackBarAction(
              label: 'Ver detalles',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Detección poco confiable'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Confianza detectada: $confidence%'),
                            const SizedBox(height: 10),
                            if (bestAlternative != null)
                              Text(
                                'Animal sugerido: ${bestAlternative['label']}',
                              ),
                            const SizedBox(height: 10),
                            const Text(
                              'Esta detección tiene baja confianza. Posibles causas:',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const Text('• Animal parcialmente visible'),
                            const Text('• Imagen con poca luz'),
                            const Text('• Distancia demasiado grande'),
                            const Text('• Animal en posición inusual'),
                            const SizedBox(height: 10),
                            const Text(
                              'Intente tomar una foto más clara o más cerca del animal.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Reintentar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Mostrar pantalla de detalles de todos modos
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PhotoDetailsScreen(result: result),
                              ),
                            );
                          },
                          child: const Text('Ver de todos modos'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      } else {
        // Detección exitosa con buena confianza
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoDetailsScreen(
              result: result,
              capturedImagePath: image.path, // Pasar la ruta de la imagen capturada
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
      // Mostrar mensaje de error al usuario
      if (mounted) {
        if (e.toString().contains('No se detectó ningún animal') ||
            e.toString().contains('no tiene suficiente confianza')) {
          // Mostrar toast con información detallada de detección
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.orange.shade700,
              action: SnackBarAction(
                label: 'Detalles',
                textColor: Colors.white,
                onPressed: () {
                  // Mostrar diálogo con información real de detecciones
                  final detections = _classifier.getLastDetections();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Información de Detección'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total detecciones: $detections.length'),
                              const SizedBox(height: 10),
                              if (detections.isEmpty)
                                const Text(
                                  'No se encontraron detecciones.\n\nPosibles causas:\n• Modelo no entrenado para este animal\n• Imagen de baja calidad\n• Animal no visible claramente',
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: detections.map((det) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        '• ${det['label']}: ${(det['confidence'] * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 10),
                              const Text(
                                'Si las confianzas son muy bajas (<10%), el modelo necesita ajuste.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Entendido'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        } else {
          // Para otros errores, usar SnackBar rojo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al procesar imagen: $e'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
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
                    final zoomChange = deltaY > 0
                        ? 0.98
                        : 1.02; // Smaller increments for smoother control
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smart_toy, color: Colors.white, size: 16),
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
                      left:
                          MediaQuery.of(context).size.width / 2 -
                          72 -
                          80, // More distance from center
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
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
