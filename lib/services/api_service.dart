import 'dart:io';
import 'package:http/http.dart' as http;

/// Servicio para comunicación con la API de análisis de imágenes
class ApiService {
  final http.Client _client = http.Client();

  /// Verifica la salud del servidor
  Future<bool> checkServerHealth() async {
    // Forzamos el estado offline para pruebas con TFLite
    return false;
  }

  /// Analiza una imagen
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    throw Exception('API Desactivada: Usando modo Offline local.');
  }

  /// Libera recursos del servicio
  void dispose() {
    _client.close();
  }
}
