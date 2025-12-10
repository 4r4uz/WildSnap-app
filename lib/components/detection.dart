import 'dart:typed_data';
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class YOLOv11Detector {
  // Singleton
  static final YOLOv11Detector _instance = YOLOv11Detector._internal();
  factory YOLOv11Detector() => _instance;
  YOLOv11Detector._internal();

  late Interpreter _interpreter;
  late List<int> _inputShape;
  late List<int> _outputShape;
  late int _numClasses;
  late List<String> _labels;
  final int _inputSize = 640; // Ajusta según tu modelo
  bool _isLoaded = false;

  Future<void> loadModel() async {
    if (_isLoaded) return; // Already loaded

    try {
      // Load labels first
      _labels = await _loadLabels('assets/yolo11_labels.txt');
      _numClasses = _labels.length;

      // Carga el modelo
      _interpreter = await Interpreter.fromAsset('assets/best_float32.tflite');

      // Obtiene las formas de entrada/salida
      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;

      _isLoaded = true;
      print('Modelo YOLO cargado: entrada $_inputShape, salida $_outputShape, clases $_numClasses');
    } catch (e) {
      print('Error al cargar modelo YOLO: $e');
      rethrow;
    }
  }

  Future<List<String>> _loadLabels(String path) async {
    String content = await rootBundle.loadString(path);
    return content.split('\n').where((line) => line.isNotEmpty).toList();
  }
  
  Future<List<DetectionResult>> detect(ui.Image image) async {
    if (!_isLoaded) {
      await loadModel();
    }

    // Preprocesamiento
    var input = await _preprocess(image);

    // Ejecuta inferencia
    final outputSize = _outputShape.reduce((a, b) => a * b);
    var output = Float32List(outputSize);

    // Run inference - output is linearized, so we need to reshape it during postprocessing
    _interpreter.run(input, output);
    // Output will be flattened from [1, 10000] to [10000]

    // Postprocesamiento
    return _postprocess(output, image.width, image.height);
  }

  Future<List<List<List<List<double>>>>> _preprocess(ui.Image image) async {
    // Convertir ui.Image a img.Image
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) throw Exception('Failed to convert ui.Image to ByteData');

    // Decode to img.Image (RGBA)
    final inputImageRaw = img.decodeImage(Uint8List.view(byteData.buffer));
    if (inputImageRaw == null) throw Exception('Failed to decode image');

    // Crop to square
    int cropSize = min(inputImageRaw.width, inputImageRaw.height);
    int offsetX = (inputImageRaw.width - cropSize) ~/ 2;
    int offsetY = (inputImageRaw.height - cropSize) ~/ 2;
    final inputImage = img.copyCrop(inputImageRaw, x: offsetX, y: offsetY, width: cropSize, height: cropSize);

    // Resize to 640x640
    final resizedImage = img.copyResize(inputImage, width: _inputSize, height: _inputSize, interpolation: img.Interpolation.linear);

    // Create 4D tensor: [1, 640, 640, 3]
    List<List<List<List<double>>>> inputTensor = [
      List.generate(_inputSize, (y) =>
        List.generate(_inputSize, (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            pixel.r / 255.0,  // R
            pixel.g / 255.0,  // G
            pixel.b / 255.0,  // B
          ];
        })
      )
    ];

    return inputTensor;
  }
  
  List<DetectionResult> _postprocess(
    Float32List output,
    int originalWidth,
    int originalHeight,
  ) {
    List<DetectionResult> results = [];

    // Handle different YOLO model output formats
    if (_outputShape.length >= 2 && _outputShape.reduce((a, b) => a * b) == output.length) {
      print('YOLO output shape: [${_outputShape.join(', ')}]');
      print('Flattened output length: ${output.length}');

      // Try to infer the structure
      if (_outputShape.length == 2 && _outputShape[0] == 1) {
        // This is likely [1, N] flattened output
        // Common YOLO format assumes N can be divided into boxes and values
        return _parseShapedOutput(output, _outputShape, originalWidth, originalHeight);
      } else if (_outputShape.length == 3) {
        // Standard [1, numBoxes, valuesPerBox] format
        return _parseStandardYOLOOutput(output, _outputShape, originalWidth, originalHeight);
      }
    }

    // Standard YOLO output format [1, numBoxes, valuesPerBox]
    final numBoxes = _outputShape[1];
    final numValuesPerBox = _outputShape[2];
    final outputData = output;

    double confidenceThreshold = 0.3; // Lower threshold for testing
    double iouThreshold = 0.5;

    List<DetectionResult> rawDetections = [];

    for (int i = 0; i < numBoxes && i * numValuesPerBox < outputData.length; i++) {
      int offset = i * numValuesPerBox;

      double confidence = outputData[offset + 4];

      if (confidence > confidenceThreshold) {
        // Encuentra la clase con mayor score
        int classId = 0;
        double maxClassScore = 0;

        for (int j = 0; j < _numClasses && (offset + 5 + j) < outputData.length; j++) {
          double classScore = outputData[offset + 5 + j];
          if (classScore > maxClassScore) {
            maxClassScore = classScore;
            classId = j;
          }
        }

        double finalScore = confidence * maxClassScore;

        if (finalScore > confidenceThreshold) {
          // Coordenadas normalizadas
          double x = outputData[offset];
          double y = outputData[offset + 1];
          double width = outputData[offset + 2];
          double height = outputData[offset + 3];

          // Convierte a coordenadas de imagen original
          double left = (x - width / 2) * originalWidth;
          double top = (y - height / 2) * originalHeight;
          double right = (x + width / 2) * originalWidth;
          double bottom = (y + height / 2) * originalHeight;

          rawDetections.add(DetectionResult(
            rect: ui.Rect.fromLTRB(left, top, right, bottom),
            confidence: finalScore,
            classId: classId,
            className: _getClassName(classId),
          ));
        }
      }
    }

    print('Found ${rawDetections.length} raw detections');
    // Aplicar NMS (Non-Maximum Suppression)
    results = _nonMaximumSuppression(rawDetections, iouThreshold);

    return results;
  }
  
  List<DetectionResult> _nonMaximumSuppression(
    List<DetectionResult> detections,
    double iouThreshold,
  ) {
    // Ordena por confianza descendente
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    List<DetectionResult> selected = [];
    
    while (detections.isNotEmpty) {
      DetectionResult current = detections.removeAt(0);
      selected.add(current);
      
      detections.removeWhere((detection) {
        double iou = _calculateIoU(current.rect, detection.rect);
        return iou > iouThreshold;
      });
    }
    
    return selected;
  }
  
  double _calculateIoU(ui.Rect a, ui.Rect b) {
    double intersectionLeft = max(a.left, b.left);
    double intersectionTop = max(a.top, b.top);
    double intersectionRight = min(a.right, b.right);
    double intersectionBottom = min(a.bottom, b.bottom);
    
    if (intersectionRight < intersectionLeft || 
        intersectionBottom < intersectionTop) {
      return 0;
    }
    
    double intersectionArea = 
        (intersectionRight - intersectionLeft) * 
        (intersectionBottom - intersectionTop);
    
    double areaA = a.width * a.height;
    double areaB = b.width * b.height;
    
    double unionArea = areaA + areaB - intersectionArea;
    
    return intersectionArea / unionArea;
  }
  
  String _getClassName(int classId) {
    return classId < _labels.length ? _labels[classId] : 'unknown';
  }
  
  // Parse [1, N] shaped output where N is total flattened size
  List<DetectionResult> _parseShapedOutput(
    Float32List output,
    List<int> shape,
    int originalWidth,
    int originalHeight,
  ) {
    // For now, assume this is class probabilities, not full YOLO detections
    // We'll implement proper parsing once we understand the model format
    print('Parsing shaped output: First 20 values: ${output.take(20).join(', ')}');

    // For debugging, look for high confidence values that might indicate detections
    List<int> potentialDetections = [];
    for (int i = 0; i < output.length; i++) {
      if (output[i] > 0.5) { // High confidence threshold
        potentialDetections.add(i);
      }
    }

    print('Found ${potentialDetections.length} high-confidence indices');

    // Return empty for now - need model documentation to understand output format
    // When we understand the format, we can implement proper parsing
    return [];
  }

  // Parse standard [1, numBoxes, valuesPerBox] YOLO output
  List<DetectionResult> _parseStandardYOLOOutput(
    Float32List output,
    List<int> shape,
    int originalWidth,
    int originalHeight,
  ) {
    final numBoxes = shape[1];
    final numValuesPerBox = shape[2];

    double confidenceThreshold = 0.3;
    List<DetectionResult> rawDetections = [];

    for (int i = 0; i < numBoxes && i * numValuesPerBox < output.length; i++) {
      int offset = i * numValuesPerBox;

      double confidence = output[offset + 4];

      if (confidence > confidenceThreshold) {
        int classId = 0;
        double maxClassScore = 0;

        for (int j = 0; j < _numClasses && (offset + 5 + j) < output.length; j++) {
          double classScore = output[offset + 5 + j];
          if (classScore > maxClassScore) {
            maxClassScore = classScore;
            classId = j;
          }
        }

        double finalScore = confidence * maxClassScore;

        if (finalScore > confidenceThreshold) {
          double x = output[offset];
          double y = output[offset + 1];
          double width = output[offset + 2];
          double height = output[offset + 3];

          double left = (x - width / 2) * originalWidth;
          double top = (y - height / 2) * originalHeight;
          double right = (x + width / 2) * originalWidth;
          double bottom = (y + height / 2) * originalHeight;

          rawDetections.add(DetectionResult(
            rect: ui.Rect.fromLTRB(left, top, right, bottom),
            confidence: finalScore,
            classId: classId,
            className: _getClassName(classId),
          ));
        }
      }
    }

    print('Parsed ${rawDetections.length} detections from standard YOLO output');
    return _nonMaximumSuppression(rawDetections, 0.5);
  }

  void dispose() {
    _interpreter.close();
  }
}

class DetectionResult {
  final ui.Rect rect;
  final double confidence;
  final int classId;
  final String className;

  DetectionResult({
    required this.rect,
    required this.confidence,
    required this.classId,
    required this.className,
  });
}
