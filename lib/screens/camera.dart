import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../components/camera_on.dart';
import '../components/image_analizer.dart';
import 'photo_details.dart';
import 'preprocessing_comparison.dart';

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

  // --------------------------
  // FLASH
  // --------------------------
  void _toggleFlash() {
    if (_controller == null) return;

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

  // --------------------------
// MODO CLASIFICACIÓN: NORMAL vs DIRECTA
// --------------------------
  bool _useDirectClassification = false; // Alternar entre modos

  void _toggleClassificationMode() {
    setState(() => _useDirectClassification = !_useDirectClassification);
    final mode = _useDirectClassification ? 'DIRECTA' : 'NORMAL';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔄 Modo cambiado a: $mode'),
        duration: const Duration(seconds: 2),
        backgroundColor: _useDirectClassification ? Colors.blue.shade700 : Colors.green.shade700,
      ),
    );
  }

  // --------------------------
// CLASIFICACIÓN SOBRE IMAGEN CAPTURADA (MODO NORMAL vs DIRECTA)
// --------------------------
  Future<void> _classifyCapturedImage(File capturedImage) async {
    setState(() => _isProcessing = true);

    try {
      final modeText = _useDirectClassification ? 'DIRECTA' : 'NORMAL';
      debugPrint('🐶 Iniciando clasificación de imagen capturada (Modo: $modeText)...');

      // Elegir método según el modo seleccionado
      final classificationResult = _useDirectClassification
          ? await _classifier.classifyImageDirect(capturedImage) // Clasificación directa
          : await _classifier.classifyImage(capturedImage);       // Detección + clasificación

      if (!mounted) return;

      final status = classificationResult['status'] as String?;
      debugPrint('📊 Resultado de clasificación - Status: $status');

      if (status == 'success') {
        final label = classificationResult['label'] as String?;
        final category = classificationResult['category'] as String?;
        final confidence = classificationResult['confidence'] as String?;

        debugPrint('✅ CLASIFICACIÓN EXITOSA:');
        debugPrint('   📝 Etiqueta: $label');
        debugPrint('   🏷️  Categoría: $category');
        debugPrint('   📊 Confianza: $confidence%');

        // Mostrar mensaje con resultados
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🐾 Detectado: $label ($category)\nConfianza: $confidence%'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green.shade700,
          ),
        );

        // Navegar a pantalla de detalles con la imagen capturada
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoDetailsScreen(
              result: classificationResult,
              capturedImagePath: capturedImage.path,
            ),
          ),
        );
      } else {
        final errorLabel = classificationResult['label'] as String? ?? 'Error desconocido';
        debugPrint('❌ CLASIFICACIÓN FALLIDA: $errorLabel');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ $errorLabel'),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('💥 ERROR CRÍTICO en clasificación: $e');
      debugPrint('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚨 Error crítico: $e'),
            backgroundColor: Colors.red.shade900,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // --------------------------
  // CAPTURA + IA
  // --------------------------
  Future<void> _takePicture() async {
    final controller = _controller;

    // Validación estricta de cámara
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        _isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Tomar foto
      final image = await controller.takePicture();

      if (!mounted) return;

      // Ejecutar clasificación simple directa sobre la imagen capturada
      await _classifyCapturedImage(File(image.path));

    } catch (e) {
      debugPrint('Error al tomar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar imagen: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _isProcessing = false);
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
              // Cámara
              Positioned.fill(
                child: CameraComponent(
                  onControllerReady: (controller) {
                    if (mounted) {
                      setState(() => _controller = controller);
                    }
                  },
                ),
              ),

              // Controles inferior
              Positioned(
                bottom: 80,
                left: 20,
                right: 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Botón Flash (izquierda)
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 - 152,
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

                    // Botón Modo Clasificación (derecha)
                    Positioned(
                      right: MediaQuery.of(context).size.width / 2 - 152,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _useDirectClassification
                              ? Colors.blue.withValues(alpha: 0.6)
                              : Colors.green.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _toggleClassificationMode,
                          icon: Icon(
                            _useDirectClassification
                                ? Icons.psychology // Modo directo
                                : Icons.search,     // Modo normal
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Botón de captura (centro)
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              Colors.white.withValues(alpha: 0.8),
                          width: 3,
                        ),
                        color: _isProcessing
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                              strokeWidth: 2,
                            )
                          : IconButton(
                              onPressed: _takePicture,
                              icon: const Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // Leyendas de los botones
              Positioned(
                bottom: 160,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flash (izquierda)
                    SizedBox(
                      width: 72,
                      child: Text(
                        'Flash',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Central (cámara) - Ahora el botón principal
                    SizedBox(
                      width: 72,
                      child: Column(
                        children: [
                          Text(
                            '📸 IA Análisis',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            _useDirectClassification ? 'DIRECTA' : 'NORMAL',
                            style: TextStyle(
                              color: _useDirectClassification ? Colors.blue.shade300 : Colors.green.shade300,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Modo clasificación (derecha)
                    SizedBox(
                      width: 72,
                      child: Text(
                        _useDirectClassification ? '🔄 Normal' : '⚡ Directa',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Información adicional sobre los modos
              Positioned(
                bottom: 210,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _useDirectClassification
                        ? '🎯 MODO DIRECTO: Clasifica toda la imagen (más rápido, ignora detección)'
                        : '🔍 MODO NORMAL: Detecta animal + clasifica especie (más preciso)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
