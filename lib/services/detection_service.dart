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

      // Comprimir a JPEG con calidad 80%
      final compressedBytes = img.encodeJpg(image, quality: AppConstants.imageCompressionQuality);

      // Crear archivo temporal para la imagen comprimida
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      debugPrint('Imagen comprimida: ${originalImage.lengthSync()} -> ${compressedFile.lengthSync()} bytes');

      return compressedFile;
    } catch (e) {
      debugPrint('Error al comprimir imagen: $e');
      // Si falla la compresión, devolver la imagen original
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
      // 1. Comprimir la imagen antes de enviar
      final compressedImage = await _compressImage(imageFile);

      // 2. Crear la solicitud multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.baseUrl}${AppConstants.endpointAnalyzeImage}'),
      );

      // 3. Agregar la imagen comprimida
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          compressedImage.path,
          filename: 'image.jpg',
        ),
      );
      
      // 3. Enviar la solicitud
      var response = await request.send();
      
      if (response.statusCode == 200) {
        // 4. Leer la respuesta
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
