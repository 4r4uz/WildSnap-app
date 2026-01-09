import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';

class ImageAnalysisService {
  static Future<File> _compressImage(File originalImage) async {
    try {
      // Leer la imagen original
      final bytes = await originalImage.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar la imagen manteniendo la relación de aspecto
      final resizedImage = img.copyResize(
        image,
        width: AppConstants.maxImageWidth,
        height: AppConstants.maxImageHeight,
        interpolation: img.Interpolation.linear,
      );

      // Comprimir a JPEG con calidad 80%
      final compressedBytes = img.encodeJpg(resizedImage, quality: AppConstants.imageCompressionQuality);

      // Crear archivo temporal para la imagen comprimida
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      debugPrint('Imagen optimizada: ${originalImage.lengthSync()} -> ${compressedFile.lengthSync()} bytes (${resizedImage.width}x${resizedImage.height})');

      return compressedFile;
    } catch (e) {
      debugPrint('Error al optimizar imagen: $e');
      // Si falla la optimización, devolver la imagen original
      return originalImage;
    }
  }

  static Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      // Optimizar la imagen (redimensionar y comprimir)
      final optimizedImage = await _compressImage(imageFile);

      // Crear la solicitud multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.baseUrl}${AppConstants.endpointAnalyzeImage}'),
      );

      // Agregar la imagen optimizada
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          optimizedImage.path,
          filename: 'image.jpg',
        ),
      );

      // Enviar la solicitud
      var response = await request.send();

      if (response.statusCode == 200) {
        // Leer la respuesta
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);

        return jsonResponse;
      } else {
        throw Exception('Error en el servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al enviar imagen: $e');
    }
  }
}
