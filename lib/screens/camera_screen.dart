import 'dart:io';
import 'package:flutter/material.dart';
import '../components/camera_widget.dart';
import '../services/offline_service.dart';
import '../utils/colors.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final OfflineService _offlineService = OfflineService();

  bool _isProcessing = false;
  bool _isModelReady = false;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    await _offlineService.initialize();

    if (!mounted) return;

    setState(() {
      _isModelReady = true;
    });
  }

  @override
  void dispose() {
    _offlineService.dispose();
    super.dispose();
  }

  Future<void> _onImageCaptured(File imageFile) async {
    if (_isProcessing || !_isModelReady) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _offlineService.analyzeImage(imageFile);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            imagePath: imageFile.path,
          ),
        ),
      );
    } catch (e) {
      // opcional: log
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraWidget(
              onImageCaptured: _onImageCaptured,
            ),
          ),

          if (!_isModelReady)
            const Center(child: CircularProgressIndicator()),

          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}