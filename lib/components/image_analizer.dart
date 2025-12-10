import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class SpeciesClassifier {
  // Singleton
  static final SpeciesClassifier _instance = SpeciesClassifier._internal();
  factory SpeciesClassifier() => _instance;
  SpeciesClassifier._internal();

  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isLoaded = false;

  // Configuración del modelo
  final int _inputSize =
      480; 
  final int _numResults = 5; // Número de predicciones a mostrar

  // Método para cargar el modelo
  Future<void> loadModel() async {
    try {
      // Cargar etiquetas
      await _loadLabels();

      // Cargar modelo
      final modelPath = 'assets/speciesnet_direct.tflite';
      final options = InterpreterOptions();

      // Opcional: Usar delegados para aceleración (GPU/NNAPI)
      if (Platform.isAndroid) {
        // options.addDelegate(GpuDelegateV2());
      }
      if (Platform.isIOS) {
        // options.addDelegate(GpuDelegate());
      }

      _interpreter = await Interpreter.fromAsset(modelPath, options: options);

      // Verificar forma de entrada
      final inputTensor = _interpreter.getInputTensor(0);
      print('Forma de entrada: ${inputTensor.shape}');
      print('Tipo de entrada: ${inputTensor.type}');

      _isLoaded = true;
      print('Modelo SpeciesNet cargado exitosamente');
    } catch (e) {
      print('Error al cargar el modelo: $e');
      rethrow;
    }
  }

  // Cargar etiquetas desde archivo
  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString(
        'assets/speciesnet_labels.txt',
      );
      _labels = labelData.split('\n').map((label) => label.trim()).toList();
      print('${_labels.length} etiquetas cargadas');
    } catch (e) {
      print('Error al cargar etiquetas: $e');
      // Etiquetas de respaldo
      _labels = List.generate(1000, (index) => 'Especie $index');
    }
  }

  // Preprocesamiento de imagen
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize image to 480x480
    img.Image resizedImage = img.copyResize(image, width: _inputSize, height: _inputSize, interpolation: img.Interpolation.linear);

    // Create 4D tensor: [1, 480, 480, 3]
    List<List<List<List<double>>>> inputTensor = [
      List.generate(_inputSize, (y) =>
        List.generate(_inputSize, (x) {
          final pixel = resizedImage.getPixel(x, y);
          double r = pixel.r / 255.0;
          double g = pixel.g / 255.0;
          double b = pixel.b / 255.0;

          // Normalize to [-1, 1]
          r = (r - 0.5) / 0.5;
          g = (g - 0.5) / 0.5;
          b = (b - 0.5) / 0.5;

          return [r, g, b];
        })
      )
    ];

    return inputTensor;
  }

  // Clasificar imagen desde archivo
  Future<List<ClassificationResult>> classifyImage(File imageFile) async {
    if (!_isLoaded) {
      await loadModel();
    }

    try {
      // Leer y decodificar imagen
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      return _classifyImage(img.Image.from(image));
    } catch (e) {
      print('Error en classifyImage: $e');
      rethrow;
    }
  }

  // Clasificar imagen desde bytes
  Future<List<ClassificationResult>> classifyImageBytes(
    Uint8List imageBytes,
  ) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }
      return _classifyImage(img.Image.from(image));
    } catch (e) {
      print('Error en classifyImageBytes: $e');
      rethrow;
    }
  }

  // Clasificar imagen desde widget Image
  Future<List<ClassificationResult>> classifyUiImage(ui.Image uiImage) async {
    try {
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      return classifyImageBytes(bytes);
    } catch (e) {
      print('Error en classifyUiImage: $e');
      rethrow;
    }
  }

  // Método interno de clasificación
  Future<List<ClassificationResult>> _classifyImage(img.Image image) async {
    // Preprocesar
    var input = _preprocessImage(image);

    // Preparar tensor de entrada
    final outputShape = _interpreter.getOutputTensor(0).shape;
    final outputSize = outputShape.reduce((a, b) => a * b);
    final output = Float32List(outputSize);

    // Ejecutar inferencia
    _interpreter.run(input, output);

    // Postprocesar resultados
    return _postprocessResults(output);
  }

  // Postprocesamiento de resultados
  List<ClassificationResult> _postprocessResults(Float32List probabilities) {
    final results = <ClassificationResult>[];

    // Crear lista de índices y probabilidades
    final indexedProbabilities = List<MapEntry<int, double>>.generate(
      probabilities.length,
      (index) => MapEntry(index, probabilities[index]),
    );

    // Ordenar por probabilidad descendente
    indexedProbabilities.sort((a, b) => b.value.compareTo(a.value));

    // Tomar las primeras N predicciones
    for (int i = 0; i < _numResults && i < indexedProbabilities.length; i++) {
      final index = indexedProbabilities[i].key;
      final confidence = indexedProbabilities[i].value;

      // Solo incluir si la confianza es significativa
      if (confidence > 0.01) {
        final label = index < _labels.length
            ? _labels[index]
            : 'Especie desconocida ($index)';

        results.add(
          ClassificationResult(
            label: label,
            confidence: confidence,
            index: index,
          ),
        );
      }
    }

    return results;
  }

  // Liberar recursos
  void dispose() {
    if (_isLoaded) {
      _interpreter.close();
      _isLoaded = false;
    }
  }

  bool get isLoaded => _isLoaded;
}

// Clase para resultados de clasificación
class ClassificationResult {
  final String label;
  final double confidence;
  final int index;

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.index,
  });

  // Formatear confianza como porcentaje
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  // Obtener nombre común de la especie (si el label incluye científico)
  String get commonName {
    // Asumiendo formato: "Nombre común (Nombre científico)"
    final parts = label.split('(');
    return parts[0].trim();
  }

  String get scientificName {
    // Extraer nombre científico entre paréntesis
    final regex = RegExp(r'\((.*?)\)');
    final match = regex.firstMatch(label);
    return match != null ? match.group(1)! : '';
  }
}
