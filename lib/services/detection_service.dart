import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ImageAnalysisService {
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
      // 1. Crear la solicitud multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.baseUrl}${AppConstants.endpointAnalyzeImage}'),
      );
      
      // 2. Agregar la imagen
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', 
          imageFile.path,
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
