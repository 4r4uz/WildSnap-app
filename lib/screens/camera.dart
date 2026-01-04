import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../components/camera_on.dart';
import '../services/detection_service.dart';
import 'photo_details.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  bool _isAIServiceConnected = false;
  Timer? _healthCheckTimer;

  @override
  void initState() {
    super.initState();
    _startHealthCheck();
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    super.dispose();
  }

  void _startHealthCheck() {
    // Check health immediately
    _checkAIServiceHealth();

    // Then check every 30 seconds
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAIServiceHealth();
    });
  }

  Future<void> _checkAIServiceHealth() async {
    final isConnected = await ImageAnalysisService.checkServerHealth();
    if (mounted) {
      setState(() => _isAIServiceConnected = isConnected);
    }
  }

  // --------------------------
  // CAPTURA + ANÁLISIS DE IMAGEN
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

      // Enviar imagen al servicio de análisis
      debugPrint('📤 Enviando imagen al servidor...');
      final analysisResult = await ImageAnalysisService.analyzeImage(File(image.path));
      debugPrint('✅ Análisis completado: ${analysisResult.keys}');

      // Ir a pantalla de detalles con el resultado
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoDetailsScreen(
              result: analysisResult,
              capturedImagePath: image.path,
            ),
          ),
        );
      }

    } catch (e) {
      debugPrint('Error al procesar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar imagen: $e'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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

            // Modern Status Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          '📸 WildSnap',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Status Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _isAIServiceConnected
                              ? Colors.green.withValues(alpha: 0.9)
                              : Colors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isAIServiceConnected
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isAIServiceConnected
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isAIServiceConnected ? Icons.smart_toy : Icons.smart_toy_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isAIServiceConnected ? 'IA' : 'OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
