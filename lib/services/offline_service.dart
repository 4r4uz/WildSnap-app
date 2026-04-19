import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class OfflineService {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const int _inputSize = 640;
  static const double _confThreshold = 0.4;

  bool get isModelLoaded => _interpreter != null;

  Future<void> initialize() async {
    if (_labels != null) return; // Evita re-inicialización innecesaria

    _labels = (await rootBundle.loadString(
      'assets/models/labels.txt',
    )).split('\n').where((e) => e.isNotEmpty).toList();

    _interpreter = await Interpreter.fromAsset(
      'assets/models/best_float32.tflite',
    );
  }

  void dispose() {
    _interpreter?.close();
  }

  Future<Map<String, dynamic>> analyzeImage(File file) async {
    if (_interpreter == null) {
      throw Exception('Model not initialized');
    }

    // Usa un pool de bytes para evitar asignaciones repetidas
    final bytes = await file.readAsBytes();
    final original = img.decodeImage(bytes)!;

    // Procesa a menor resolución si la imagen es muy grande
    final optimizedImage = _optimizeImageSize(original);

    final letterboxed = _letterbox(optimizedImage, _inputSize);
    final input = _imageToFloat32(letterboxed.image);

    var output = List.generate(
      1,
      (_) => List.generate(300, (_) => List.filled(6, 0.0)),
    );

    _interpreter!.run(input, output);

    return _parseDetections(
      output,
      original.width,
      original.height,
      letterboxed.scale,
      letterboxed.padX,
      letterboxed.padY,
    );
  }

  // función para optimizar tamaño de imagen
  img.Image _optimizeImageSize(img.Image image) {
    final maxSize = 1280; // Limita a 1280px en el lado más largo
    if (image.width <= maxSize && image.height <= maxSize) {
      return image;
    }

    double scale = min(maxSize / image.width, maxSize / image.height);
    int newW = (image.width * scale).round();
    int newH = (image.height * scale).round();

    return img.copyResize(image, width: newW, height: newH);
  }

  // ---------------- LETTERBOX ----------------

  _LetterboxResult _letterbox(img.Image src, int size) {
    double scale = min(size / src.width, size / src.height);
    int newW = (src.width * scale).round();
    int newH = (src.height * scale).round();

    img.Image resized = img.copyResize(src, width: newW, height: newH);

    img.Image canvas = img.Image(width: size, height: size);
    img.fill(canvas, color: img.ColorRgb8(114, 114, 114));

    int padX = ((size - newW) / 2).round();
    int padY = ((size - newH) / 2).round();

    img.compositeImage(canvas, resized, dstX: padX, dstY: padY);

    return _LetterboxResult(canvas, scale, padX, padY);
  }

  // ---------------- IMAGE → TENSOR ----------------

  List<List<List<List<double>>>> _imageToFloat32(img.Image image) {
    // Reutiliza el mismo buffer para evitar asignaciones
    final buffer = List.generate(
      _inputSize,
      (_) => List.generate(_inputSize, (_) => [0.0, 0.0, 0.0]),
    );

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final p = image.getPixel(x, y);
        buffer[y][x][0] = p.r / 255.0;
        buffer[y][x][1] = p.g / 255.0;
        buffer[y][x][2] = p.b / 255.0;
      }
    }

    return [buffer];
  }

  // ---------------- PARSE DETECTIONS ----------------

  Map<String, dynamic> _parseDetections(
    List<List<List<double>>> output,
    int imgW,
    int imgH,
    double scale,
    int padX,
    int padY,
  ) {
    List<Map<String, dynamic>> detections = [];

    for (var row in output[0]) {
      final score = row[4];
      if (score < _confThreshold) continue;

      // Coordenadas vienen normalizadas 0–1
      double x1 = (row[0] * _inputSize - padX) / scale;
      double y1 = (row[1] * _inputSize - padY) / scale;
      double x2 = (row[2] * _inputSize - padX) / scale;
      double y2 = (row[3] * _inputSize - padY) / scale;

      int classId = row[5].toInt();

      detections.add({
        'bbox': [x1, y1, x2, y2],
        'score': score,
        'classId': classId,
        'label': _labels![classId],
      });
    }

    if (detections.isEmpty) {
      return {'success': false, 'label': 'No detectado', 'confidence': 0.0};
    }

    detections.sort((a, b) => b['score'].compareTo(a['score']));
    var best = detections.first;

    return {
      'success': true,
      'label': best['label'],
      'confidence': best['score'],
      'detections': detections,
    };
  }
}

class _LetterboxResult {
  final img.Image image;
  final double scale;
  final int padX;
  final int padY;

  _LetterboxResult(this.image, this.scale, this.padX, this.padY);
}
