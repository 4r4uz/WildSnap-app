import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../styles/colors.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PhotoDetailsScreen extends StatefulWidget {
  const PhotoDetailsScreen({super.key, this.result, this.capturedImagePath});

  final Map<String, dynamic>? result;
  final String? capturedImagePath;

  @override
  State<PhotoDetailsScreen> createState() => _PhotoDetailsScreenState();
}

class _PhotoDetailsScreenState extends State<PhotoDetailsScreen> {
  Map<String, dynamic>? animalData;

  @override
  void initState() {
    super.initState();
    animalData = widget.result?['animal_data'];
  }



  Color _getConfidenceBadgeColor(String? label) {
    if (widget.result?['status'] == 'success') {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  IconData _getConfidenceBadgeIcon(String? label) {
    if (widget.result?['status'] == 'success') {
      return Icons.verified;
    } else {
      return Icons.warning;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.7) return Colors.green;
    if (confidence > 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildResultCard(Map<String, dynamic>? result) {
    if (result == null || result['status'] != 'success') {
      return Card(
        color: Colors.white.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.photo_camera, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result == null ? 'Foto capturada sin análisis IA' : (result['label'] ?? 'No se pudo clasificar'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final confidence = double.tryParse(result['confidence'].replaceAll('%', '')) ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Barra de progreso circular
            CircularPercentIndicator(
              radius: 25,
              lineWidth: 4,
              percent: confidence / 100.0,
              progressColor: _getConfidenceColor(confidence / 100.0),
              backgroundColor: Colors.grey[200]!,
              center: Text(
                '${confidence.round()}%',
                style: const TextStyle(fontSize: 10),
              ),
            ),
            const SizedBox(width: 15),

            // Información de la especie
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result['label'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: confidence / 100.0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getConfidenceColor(confidence / 100.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Para detecciones exitosas, mostrar la pantalla normal
    return _buildAnimalDetailsScreen();
  }



  Widget _buildAnimalDetailsScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkBackground,
              AppColors.cardDark,
              AppColors.surfaceDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Minimalist Header with Confidence
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceBadgeColor(
                            widget.result?['label'],
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getConfidenceBadgeColor(
                              widget.result?['label'],
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getConfidenceBadgeIcon(widget.result?['label']),
                              color: _getConfidenceBadgeColor(
                                widget.result?['label'],
                              ),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.result?['confidence'] ?? '0'}%',
                              style: TextStyle(
                                color: _getConfidenceBadgeColor(
                                  widget.result?['label'],
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Captured Image with Bounding Box
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.capturedImagePath != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              // Imagen procesada si está disponible, sino la capturada
                              if (widget.result?['processed_image'] != null)
                                Image.memory(
                                  base64Decode(widget.result!['processed_image']),
                                  fit: BoxFit.cover,
                                )
                              else
                                Image.file(
                                  File(widget.capturedImagePath!),
                                  fit: BoxFit.cover,
                                ),
                              // Bounding box si está disponible y no hay imagen procesada
                              if (widget.result?['bounding_box'] != null && widget.result?['processed_image'] == null)
                                Positioned(
                                  left: (widget.result!['bounding_box']['x'] as num).toDouble(),
                                  top: (widget.result!['bounding_box']['y'] as num).toDouble(),
                                  width: (widget.result!['bounding_box']['width'] as num).toDouble(),
                                  height: (widget.result!['bounding_box']['height'] as num).toDouble(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.green.withValues(alpha: 0.8),
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${widget.result?['label'] ?? 'Animal'}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Imagen capturada',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Result Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultado de Clasificación:',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildResultCard(widget.result),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Modern Location Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.blueAccent,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ubicación Detectada',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Geolocalización automática',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                size: 48,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Mapa interactivo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Próximamente',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.place, color: Colors.blueAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              animalData?['region'] ?? 'Región no especificada',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.gps_fixed,
                                  color: Colors.blueAccent,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'GPS',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Modern Action Buttons
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Share Button - Modern Glass Effect
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withValues(alpha: 0.3),
                                Colors.blue.withValues(alpha: 0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              'Compartir',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Save Button - Modern Glass Effect
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withValues(alpha: 0.3),
                                Colors.green.withValues(alpha: 0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.save,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              'Guardar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
