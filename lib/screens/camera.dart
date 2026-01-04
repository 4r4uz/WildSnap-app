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
  bool _isAttemptingConnection = false;
  Timer? _healthCheckTimer;
  XFile? _capturedImage;

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
      // Si estaba conectado y ahora no, intentar reconectar automáticamente
      if (_isAIServiceConnected && !isConnected) {
        await _autoReconnect();
      } else {
        setState(() => _isAIServiceConnected = isConnected);
      }
    }
  }

  Future<void> _autoReconnect() async {
    if (_isAttemptingConnection) return;

    setState(() => _isAttemptingConnection = true);

    try {
      debugPrint('Servidor desconectado - intentando reconectar...');

      // Intentar hasta 3 veces
      for (int attempt = 1; attempt <= 3; attempt++) {
        debugPrint('Intento $attempt/3');

        final isConnected = await ImageAnalysisService.checkServerHealth();

        if (isConnected) {
          debugPrint('Servidor reconectado exitosamente');
          if (mounted) {
            setState(() => _isAIServiceConnected = true);
          }
          return;
        }

        // Esperar antes del siguiente intento
        if (attempt < 3) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      // Si llega aquí, fallaron todos los intentos
      debugPrint('Servidor desconectado - no se pudo reconectar');
      if (mounted) {
        setState(() => _isAIServiceConnected = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servidor IA desconectado'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      debugPrint('Error al reconectar: $e');
      if (mounted) {
        setState(() => _isAIServiceConnected = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isAttemptingConnection = false);
      }
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

    try {
      // Tomar foto
      final image = await controller.takePicture();

      if (!mounted) return;

      // Mostrar overlay de carga con la imagen capturada
      setState(() {
        _capturedImage = image;
        _isProcessing = true;
      });

      // Procesar imagen en segundo plano
      debugPrint('Enviando imagen al servidor...');
      final analysisResult = await ImageAnalysisService.analyzeImage(File(image.path));
      debugPrint('Analisis completado: ${analysisResult.keys}');

      // Ir a pantalla de detalles con el resultado
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoDetailsScreen(
              result: analysisResult,
              capturedImagePath: image.path,
            )
          )
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
        setState(() {
          _isProcessing = false;
          _capturedImage = null;
        });
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
            // Cámara full screen - Solo visible cuando no está procesando
            if (!_isProcessing)
              Positioned.fill(
                child: CameraComponent(
                  onControllerReady: (controller) {
                    if (mounted) {
                      setState(() => _controller = controller);
                    }
                  },
                ),
              ),

            // Fondo negro cuando está procesando (cámara desactivada)
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white24,
                      size: 80,
                    ),
                  ),
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
                          onPressed: _isAIServiceConnected ? _takePicture : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Servidor IA desconectado. Reconectando automáticamente...'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: _isAIServiceConnected ? Colors.white : Colors.white38,
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
                          'WildSnap',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Status Indicator - Informative only
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isAIServiceConnected
                              ? Colors.green.withValues(alpha: 0.9)
                              : _isAttemptingConnection
                                  ? Colors.orange.withValues(alpha: 0.9)
                                  : Colors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isAIServiceConnected
                                ? Colors.green.withValues(alpha: 0.3)
                                : _isAttemptingConnection
                                    ? Colors.orange.withValues(alpha: 0.3)
                                    : Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isAIServiceConnected
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : _isAttemptingConnection
                                      ? Colors.orange.withValues(alpha: 0.2)
                                      : Colors.red.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon with animation when attempting connection
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isAttemptingConnection
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Icon(
                                      _isAIServiceConnected ? Icons.smart_toy : Icons.smart_toy_outlined,
                                      key: ValueKey<bool>(_isAIServiceConnected),
                                      color: Colors.white,
                                      size: 14,
                                    ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isAttemptingConnection
                                  ? 'ACTIVANDO...'
                                  : _isAIServiceConnected
                                      ? 'IA'
                                      : 'DESCONECTADO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _isAttemptingConnection ? 9 : 11,
                                fontWeight: FontWeight.w800,
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

            // Modern Loading Overlay
            if (_isProcessing && _capturedImage != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  child: Stack(
                    children: [
                      // Captured Image Background (Static)
                      Positioned.fill(
                        child: Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                          opacity: const AlwaysStoppedAnimation(0.3),
                        ),
                      ),

                      // Blur Effect Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.black.withValues(alpha: 0.5),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Loading Content
                      SafeArea(
                        child: Column(
                          children: [
                            // Top Progress Bar
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00ff88), Color(0xFF667eea)],
                                ),
                              ),
                              child: const LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                              ),
                            ),

                            const Spacer(),

                            // Center Loading Animation
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Pulsing AI Icon
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00ff88), Color(0xFF667eea)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00ff88).withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.smart_toy,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Loading Text with Animation
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 1500),
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Column(
                                          children: [
                                            Text(
                                              'Analizando imagen...',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Detectando especies con IA',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.7),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Bottom Progress Dots
                            Container(
                              margin: const EdgeInsets.only(bottom: 40),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (index) {
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.3, end: 1.0),
                                    duration: Duration(milliseconds: 600 + (index * 200)),
                                    builder: (context, value, child) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF00ff88).withValues(alpha: value),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
