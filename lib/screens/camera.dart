import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:ui' as ui;
import '../components/camera_on.dart';
import '../components/image_analizer.dart';
import '../components/detection.dart';
import 'photo_details.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false;

  // --------------------------
// PROCESAMIENTO INTELIGENTE: DETECCIÓN + CLASIFICACIÓN
// --------------------------
  Future<void> _classifyCapturedImage(File capturedImage) async {
    setState(() => _isProcessing = true);

    try {
      debugPrint('🐶 Iniciando procesamiento inteligente de imagen capturada...');

      late Map<String, dynamic> finalResult;

      // MODO INTELIGENTE: Siempre intenta detección + clasificación
      debugPrint('🔍 Procesamiento inteligente: Detectando animal...');

      // Convertir imagen para detección
      final bytes = await capturedImage.readAsBytes();
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        debugPrint('❌ No se pudo decodificar imagen, fallback directo...');
        // Fallback to species classification on full image only
        final speciesResults = await SpeciesClassifier().classifyImage(capturedImage);
        if (speciesResults.isNotEmpty) {
          final species = speciesResults[0];
          finalResult = {
            'status': 'success',
            'label': species.label,
            'category': _getSpeciesCategory(species.label),
            'confidence': species.confidencePercent,
            'detection_method': 'Fallback Classification',
          };
        } else {
          finalResult = {
            'status': 'error',
            'label': 'No se pudo procesar la imagen',
          };
        }
      } else {
        // Imagen decodificada exitosamente
        try {
          final ui.Codec codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
          final ui.FrameInfo fi = await codec.getNextFrame();
          final ui.Image uiImg = fi.image;

          // Detección con YOLO
          final detections = await YOLOv11Detector().detect(uiImg);

          // Filtrar animal con mayor confianza
          DetectionResult? bestAnimal;
          double highestConf = 0.0;

          // Lista de clases de animales en COCO
          const animalLabels = {
            'dog', 'cat', 'bird', 'horse', 'cow', 'sheep', 'elephant', 'bear',
            'zebra', 'giraffe', 'monkey', 'lion', 'tiger', 'fox',
            'mouse', 'rabbit', 'squirrel', 'frog', 'fish', 'turtle'
          };

          for (var det in detections) {
            if (animalLabels.contains(det.className.toLowerCase()) && det.confidence > highestConf) {
              highestConf = det.confidence;
              bestAnimal = det;
            }
          }

          if (bestAnimal != null) {
            debugPrint('✅ Animal detectado: ${bestAnimal.className} (${(bestAnimal.confidence * 100).toStringAsFixed(1)}%)');

            // Cortar imagen alrededor del animal detectado
            final cropX = (bestAnimal.rect.left * decodedImage.width / uiImg.width).floor();
            final cropY = (bestAnimal.rect.top * decodedImage.height / uiImg.height).floor();
            final cropWidth = (bestAnimal.rect.width * decodedImage.width / uiImg.width).floor();
            final cropHeight = (bestAnimal.rect.height * decodedImage.height / uiImg.height).floor();

            final croppedImage = img.copyCrop(
              decodedImage,
              x: cropX > 0 ? cropX : 0,
              y: cropY > 0 ? cropY : 0,
              width: cropWidth > 0 ? cropWidth : 100,
              height: cropHeight > 0 ? cropHeight : 100,
            );

            // Guardar imagen cortada temporalmente
            final dir = await getTemporaryDirectory();
            final croppedFile = File('${dir.path}/cropped_animal_${DateTime.now().millisecondsSinceEpoch}.png');
            await croppedFile.writeAsBytes(img.encodePng(croppedImage));

            // Clasificar animal detectado
            debugPrint('🐾 Clasificando especie...');
            final speciesResults = await SpeciesClassifier().classifyImage(croppedFile);

            if (speciesResults.isNotEmpty) {
              final species = speciesResults[0];
              finalResult = {
                'status': 'success',
                'label': species.label,
                'category': bestAnimal.className,
                'confidence': species.confidencePercent,
                'detection_method': 'Detection + Classification',
                'bounding_box': {
                  'x': bestAnimal.rect.left.toInt(),
                  'y': bestAnimal.rect.top.toInt(),
                  'width': bestAnimal.rect.width.toInt(),
                  'height': bestAnimal.rect.height.toInt(),
                },
              };
            } else {
              finalResult = {
                'status': 'error',
                'label': 'Animal detectado pero especie no clasificada',
              };
            }
          } else {
            // No se detectó animal, clasificar imagen completa
            debugPrint('❌ No se detectó animal, clasificación directa...');
            final speciesResults = await SpeciesClassifier().classifyImage(capturedImage);

            if (speciesResults.isNotEmpty) {
              final species = speciesResults[0];
              finalResult = {
                'status': 'success',
                'label': species.label,
                'category': _getSpeciesCategory(species.label),
                'confidence': species.confidencePercent,
                'detection_method': 'Direct Classification',
              };
            } else {
              finalResult = {
                'status': 'error',
                'label': 'No se detectó contenido animal',
              };
            }
          }
        } catch (uiError) {
          debugPrint('❌ Error al procesar imagen: $uiError');
          // Fallback to species classification on full image only
          debugPrint('🔄 Fallback a clasificación directa...');
          final speciesResults = await SpeciesClassifier().classifyImage(capturedImage);
          if (speciesResults.isNotEmpty) {
            final species = speciesResults[0];
            finalResult = {
              'status': 'success',
              'label': species.label,
              'category': _getSpeciesCategory(species.label),
              'confidence': species.confidencePercent,
              'detection_method': 'Direct Classification',
            };
          } else {
            finalResult = {
              'status': 'error',
              'label': 'Error al procesar imagen',
            };
          }
        }
      }

      // Procesar resultado final...
      final status = finalResult['status'] as String?;
      debugPrint('📊 Resultado final - Status: $status, Método: ${finalResult['detection_method']}');

      if (status == 'success') {
        final label = finalResult['label'] as String?;
        final category = finalResult['category'] as String?;
        final confidence = finalResult['confidence'] as String?;

        debugPrint('✅ PROCESAMIENTO EXITOSO:');
        debugPrint('   📝 Especie: $label');
        debugPrint('   🏷️  Animal: $category');
        debugPrint('   📊 Confianza: $confidence%');

        // Ir directamente a pantalla de detalles
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoDetailsScreen(
              result: finalResult,
              capturedImagePath: capturedImage.path,
            ),
          ),
        );
      } else {
        final errorLabel = finalResult['label'] as String? ?? 'Error desconocido';
        debugPrint('❌ PROCESAMIENTO FALLIDO: $errorLabel');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ $errorLabel'),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      if (!mounted) return;
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

  String _getSpeciesCategory(String label) {
    // Simple categorization based on common species names
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('dog') || lowerLabel.contains('perro')) return 'Perro';
    if (lowerLabel.contains('cat') || lowerLabel.contains('gato')) return 'Gato';
    if (lowerLabel.contains('bird') || lowerLabel.contains('pájaro') || lowerLabel.contains('ave')) return 'Ave';
    if (lowerLabel.contains('horse') || lowerLabel.contains('caballo')) return 'Caballo';
    if (lowerLabel.contains('cow') || lowerLabel.contains('vaca')) return 'Vaca';
    if (lowerLabel.contains('elephant') || lowerLabel.contains('elefante')) return 'Elefante';
    return 'Animal';
  }

  @override
  void dispose() {
    SpeciesClassifier().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Cámara full screen
            Positioned.fill(
              child: CameraComponent(
                onControllerReady: (controller) {
                  if (mounted) {
                    setState(() => _controller = controller);
                  }
                },
              ),
            ),

            // Bottom center button
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 3,
                    ),
                  ),
                  child: _isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        )
                      : IconButton(
                          onPressed: _takePicture,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                ),
              ),
            ),

            // Title
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🧠 IA Animal Detector',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
