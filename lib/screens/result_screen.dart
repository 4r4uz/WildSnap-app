import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String imagePath;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Resultado',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWithBoundingBox(context),
            const SizedBox(height: 24),
            _buildResultCard(),
            const SizedBox(height: 24),
            _buildDetailsCard(),
          ],
        ),
      ),
    );
  }


  Widget _buildImageWithBoundingBox(BuildContext context) {
    final hasDetection = result['bounding_box'] != null || 
                        (result['label'] != null && 
                         !result['label'].toString().contains('No se detectaron'));
    
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: Container(
        height: 250,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
              if (hasDetection) _buildBoundingBoxOverlay(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBoundingBoxOverlay() {
    final bbox = result['bounding_box'] as Map<String, dynamic>?;
    if (bbox == null) return const SizedBox.shrink();
    
    final x = (bbox['x'] as num?)?.toDouble() ?? 0.0;
    final y = (bbox['y'] as num?)?.toDouble() ?? 0.0;
    final width = (bbox['width'] as num?)?.toDouble() ?? 0.0;
    final height = (bbox['height'] as num?)?.toDouble() ?? 0.0;
    
    if (width <= 0 || height <= 0) return const SizedBox.shrink();
    
    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 3),
          borderRadius: const BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            child: Text(
              result['category'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black.withAlpha(200),
            child: Center(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildResultCard() {
    final hasDetection = result['label'] != null && 
                        !result['label'].toString().contains('No se detectaron');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análisis de IA',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          hasDetection ? _buildDetectionInfo() : _buildNoDetectionInfo(),
        ],
      ),
    );
  }


  Widget _buildDetectionInfo() {
    final label = result['label']?.toString().replaceAll('deteccion: ', '') ?? 'Desconocido';
    final confidenceStr = result['confidence']?.toString().replaceAll('%', '') ?? '0';
    final confidence = double.tryParse(confidenceStr) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Confianza: $confidenceStr%',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: confidence / 100.0,
          backgroundColor: AppColors.background,
          color: AppColors.success,
        ),
      ],
    );
  }


  Widget _buildNoDetectionInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error, color: AppColors.error, size: 24),
            SizedBox(width: 16),
            Text(
              'No se detectó ningún animal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Inténtalo de nuevo con una foto más clara o en mejor iluminación.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }


  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Estado', result['status'] ?? 'Desconocido'),
          _buildDetailRow('Categoría', result['category'] ?? 'No disponible'),
          _buildDetailRow(
            'Animal detectado',
            result['label']?.toString().replaceAll('deteccion: ', '') ?? 'No disponible',
          ),
        ],
      ),
    );
  }


  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
