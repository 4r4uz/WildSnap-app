import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';

class ImageClassifier {
  late Interpreter _detectionInterpreter;
  late Interpreter _classificationInterpreter;
  late List<String> _detectionLabels;
  late List<String> _classificationLabels;
  late int _detectionInputSize;
  late int _classificationInputSize;
  Future<void>? _initializationFuture;
  final List<Map<String, dynamic>> _lastDetections = [];

  ImageClassifier() {
    _initializationFuture = _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      debugPrint('Loading detection model...');
      _detectionInterpreter = await Interpreter.fromAsset('assets/deteccion.tflite');
      _detectionInterpreter.allocateTensors();
      debugPrint('✅ Detection model loaded');

      debugPrint('Loading classification model...');
      _classificationInterpreter = await Interpreter.fromAsset('assets/clasificacion.tflite');
      _classificationInterpreter.allocateTensors();
      debugPrint('✅ Classification model loaded');
    } catch (e) {
      debugPrint('❌ Error loading models: $e');
      rethrow;
    }

    // Obtener tamaños de entrada
    final detInput = _detectionInterpreter.getInputTensor(0);
    _detectionInputSize = detInput.shape[1];

    final clsInput = _classificationInterpreter.getInputTensor(0);
    _classificationInputSize = clsInput.shape[1];

    debugPrint('Detection input size: $_detectionInputSize');
    debugPrint('Classification input size: $_classificationInputSize');

    // Obtener información de los modelos (para debug)
    _printModelInfo();

    // Cargar labels
    final detectionLabelsData = await rootBundle.loadString('assets/coco_labels.txt');
    _detectionLabels = detectionLabelsData.split('\n').where((line) => line.trim().isNotEmpty).toList();

    final classificationLabelsData = await rootBundle.loadString('assets/imagenet_labels.txt');
    _classificationLabels = classificationLabelsData.split('\n').where((line) => line.trim().isNotEmpty).toList();

    debugPrint('Detection labels: ${_detectionLabels.length}');
    debugPrint('Classification labels: ${_classificationLabels.length}');
  }

  void _printModelInfo() {
    debugPrint('=== DETECTION MODEL ===');
    final detInput = _detectionInterpreter.getInputTensor(0);
    debugPrint('Input shape: ${detInput.shape}');
    debugPrint('Input type: ${detInput.type}');

    final detOutputCount = _detectionInterpreter.getOutputTensors().length;
    for (int i = 0; i < detOutputCount; i++) {
      final output = _detectionInterpreter.getOutputTensor(i);
      debugPrint('Output $i shape: ${output.shape}');
    }

    debugPrint('=== CLASSIFICATION MODEL ===');
    final clsInput = _classificationInterpreter.getInputTensor(0);
    debugPrint('Input shape: ${clsInput.shape}');
    debugPrint('Input type: ${clsInput.type}');

    final clsOutput = _classificationInterpreter.getOutputTensor(0);
    debugPrint('Output shape: ${clsOutput.shape}');
  }

  Future<void> ensureInitialized() async {
    await _initializationFuture;
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    await ensureInitialized();

    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      debugPrint('Imagen original: ${image.width}x${image.height}');

      // PRIMERO: Solo probar detección
      final detections = await _runDetection(image);

      if (detections.isEmpty) {
        return {
          'label': 'Sin animal detectado',
          'confidence': '0.00',
          'bounding_box': null,
          'detections_count': 0,
          'status': 'no_detections'
        };
      }

      debugPrint('Detecciones encontradas: ${detections.length}');

      // SEGUNDO: Solo probar clasificación con la primera detección
      if (detections.isNotEmpty) {
        final bbox = detections[0]['boundingBox'] as Map<String, dynamic>;

        // Asegurar que las coordenadas sean válidas
        final x = (bbox['x'] as double).clamp(0, image.width.toDouble());
        final y = (bbox['y'] as double).clamp(0, image.height.toDouble());
        final width = (bbox['width'] as double).clamp(1, image.width - x);
        final height = (bbox['height'] as double).clamp(1, image.height - y);

        debugPrint('Recortando: x=$x, y=$y, w=$width, h=$height');

        final crop = img.copyCrop(
          image,
          x: x.toInt(),
          y: y.toInt(),
          width: width.toInt(),
          height: height.toInt()
        );

        debugPrint('Crop size: ${crop.width}x${crop.height}');

        final classification = await _runClassification(crop);

        debugPrint('Clasificación: ${classification['label']} - ${(classification['confidence'] * 100).toStringAsFixed(2)}%');

        return {
          'label': classification['label'],
          'confidence': (classification['confidence'] * 100).toStringAsFixed(2),
          'bounding_box': bbox,
          'detection_label': detections[0]['label'],
          'detection_confidence': (detections[0]['confidence'] * 100).toStringAsFixed(2),
          'all_detections': detections,
          'status': 'success'
        };
      }

      return {
        'status': 'error',
        'message': 'No se pudo procesar las detecciones'
      };

    } catch (e, stack) {
      debugPrint('Error en classifyImage: $e');
      debugPrint('Stack trace: $stack');
      return {
        'status': 'error',
        'message': e.toString()
      };
    }
  }

  Future<List<Map<String, dynamic>>> _runDetection(img.Image image) async {
    try {
      // Preprocesamiento para YOLO
      final resized = img.copyResize(
        image,
        width: _detectionInputSize,
        height: _detectionInputSize
      );

      // Crear input en formato correcto
      final input = Float32List(1 * _detectionInputSize * _detectionInputSize * 3);
      final bytes = resized.getBytes(order: img.ChannelOrder.rgb);

      for (int i = 0; i < bytes.length; i++) {
        input[i] = bytes[i] / 255.0; // Normalizar a [0,1]
      }

      // Preparar output basado en la forma del modelo
      final outputShape = _detectionInterpreter.getOutputTensor(0).shape;
      debugPrint('Detection output shape: $outputShape');

      List<dynamic> output;
      if (outputShape.length == 2) {
        // Formato: [1, 8400] o similar
        output = List.filled(outputShape[0] * outputShape[1], 0.0)
            .reshape([outputShape[0], outputShape[1]]);
      } else if (outputShape.length == 3) {
        // Formato: [1, 84, 8400] o similar
        output = List.filled(outputShape[0] * outputShape[1] * outputShape[2], 0.0)
            .reshape([outputShape[0], outputShape[1], outputShape[2]]);
      } else if (outputShape.length == 4) {
        // Formato: [1, 84, 8400, 1] o similar
        output = List.filled(outputShape[0] * outputShape[1] * outputShape[2] * outputShape[3], 0.0)
            .reshape([outputShape[0], outputShape[1], outputShape[2], outputShape[3]]);
      } else {
        throw Exception('Formato de output no soportado: $outputShape');
      }

      // Ejecutar inferencia
      _detectionInterpreter.run(input, output);

      // Parsear resultados según el formato
      return _parseYoloOutput(output, image.width, image.height);

    } catch (e, stack) {
      debugPrint('Error en _runDetection: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }

  List<Map<String, dynamic>> _parseYoloOutput(dynamic output, int imgWidth, int imgHeight) {

    if (output is List<List<double>>) {
      // Formato: [num_detections, 6]
      debugPrint('Parsing formato [detections, 6]');
      return _parseYoloV8Format(output, imgWidth, imgHeight);
    } else if (output is List<List<List<double>>>) {
      // Formato: [1, num_detections, 6]
      debugPrint('Parsing formato [1, detections, 6]');
      return _parseYoloV8Format(output[0], imgWidth, imgHeight);
    } else if (output is List<List<List<List<double>>>>) {
      // Formato: [1, 84, 8400, 1] (YOLOv8 raw)
      debugPrint('Parsing formato YOLOv8 raw');
      return _parseYoloV8RawFormat(output[0], imgWidth, imgHeight);
    } else {
      debugPrint('Formato de output desconocido: ${output.runtimeType}');
      return [];
    }
  }

  List<Map<String, dynamic>> _parseYoloV8Format(List<List<double>> predictions, int imgWidth, int imgHeight) {
    final detections = <Map<String, dynamic>>[];
    const double confidenceThreshold = 0.25;

    for (int i = 0; i < predictions.length; i++) {
      final pred = predictions[i];
      if (pred.length < 6) continue;

      final xCenter = pred[0];
      final yCenter = pred[1];
      final width = pred[2];
      final height = pred[3];
      final confidence = pred[4];
      final classId = pred[5].toInt();

      if (confidence < confidenceThreshold) continue;
      if (classId < 0 || classId >= _detectionLabels.length) continue;

      // Solo animales (COCO classes 16-25)
      if (classId < 16 || classId > 25) continue;

      final double x = math.max(0.0, (xCenter - width / 2) * imgWidth);
      final double y = math.max(0.0, (yCenter - height / 2) * imgHeight);
      final double w = math.min(imgWidth.toDouble() - x, width * imgWidth);
      final double h = math.min(imgHeight.toDouble() - y, height * imgHeight);

      final Map<String, double> bbox = {
        'x': x,
        'y': y,
        'width': w,
        'height': h,
      };

      if (bbox['width']! < 10 || bbox['height']! < 10) continue;

      detections.add({
        'label': _detectionLabels[classId],
        'confidence': confidence,
        'classIndex': classId,
        'boundingBox': bbox,
      });

      debugPrint('Detección: ${_detectionLabels[classId]} ${(confidence * 100).toStringAsFixed(1)}%');
    }

    return _nonMaxSuppression(detections, 0.45);
  }

  List<Map<String, dynamic>> _parseYoloV8RawFormat(List<List<List<double>>> output, int imgWidth, int imgHeight) {
    // YOLOv8 formato raw: [84, 8400]
    // 84 = 4 (bbox) + 80 (classes) o similar
    List<Map<String, dynamic>> detections = [];
    const double confidenceThreshold = 0.25;

    final numClasses = output.length - 4; // Primeras 4 son bbox
    final numPredictions = output[0].length;

    debugPrint('Parsing YOLOv8 raw: $numClasses clases, $numPredictions predicciones');

    for (int i = 0; i < numPredictions; i++) {
      // Extraer bbox
      final xCenter = output[0][i][0];
      final yCenter = output[1][i][0];
      final width = output[2][i][0];
      final height = output[3][i][0];

      // Encontrar clase con mayor confianza
      double maxConfidence = 0;
      int maxClassId = -1;

      for (int c = 0; c < numClasses; c++) {
        final confidence = output[4 + c][i][0];
        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          maxClassId = c;
        }
      }

      if (maxConfidence < confidenceThreshold) continue;
      if (maxClassId < 16 || maxClassId > 25) continue; // Solo animales

      final double x = math.max(0.0, (xCenter - width / 2) * imgWidth);
      final double y = math.max(0.0, (yCenter - height / 2) * imgHeight);
      final double w = math.min(imgWidth.toDouble() - x, width * imgWidth);
      final double h = math.min(imgHeight.toDouble() - y, height * imgHeight);

      final Map<String, double> bbox = {
        'x': x,
        'y': y,
        'width': w,
        'height': h,
      };

      detections.add({
        'label': maxClassId < _detectionLabels.length ? _detectionLabels[maxClassId] : 'Unknown',
        'confidence': maxConfidence,
        'classIndex': maxClassId,
        'boundingBox': bbox,
      });
    }

    return _nonMaxSuppression(detections, 0.45);
  }

  Future<Map<String, dynamic>> _runClassification(img.Image crop) async {
    try {
      // Redimensionar
      final resized = img.copyResize(
        crop,
        width: _classificationInputSize,
        height: _classificationInputSize
      );

      // Preprocesamiento para EfficientNet
      final input = Float32List(1 * _classificationInputSize * _classificationInputSize * 3);

      // EfficientNet preprocess: (pixel/255 - mean) / std
      const List<double> mean = [0.485, 0.456, 0.406];
      const List<double> std = [0.229, 0.224, 0.225];

      int index = 0;
      for (int y = 0; y < _classificationInputSize; y++) {
        for (int x = 0; x < _classificationInputSize; x++) {
          final pixel = resized.getPixel(x, y);
          input[index++] = ((pixel.r / 255.0) - mean[0]) / std[0];
          input[index++] = ((pixel.g / 255.0) - mean[1]) / std[1];
          input[index++] = ((pixel.b / 255.0) - mean[2]) / std[2];
        }
      }

      // Preparar output
      final outputShape = _classificationInterpreter.getOutputTensor(0).shape;
      final numClasses = outputShape.last;
      final output = List.filled(numClasses, 0.0);

      // Ejecutar inferencia (CORREGIDO)
      _classificationInterpreter.run(input, output);

      // Encontrar mejor predicción
      double maxProb = 0;
      int maxIndex = -1;

      for (int i = 0; i < output.length; i++) {
        if (output[i] > maxProb) {
          maxProb = output[i];
          maxIndex = i;
        }
      }

      // Verificar que la probabilidad sea válida
      if (maxProb.isNaN || maxProb.isInfinite) {
        maxProb = 0.0;
      }

      String label = 'unknown';
      if (maxIndex >= 0 && maxIndex < _classificationLabels.length) {
        label = _classificationLabels[maxIndex];
      }

      debugPrint('Clasificación resultado: index=$maxIndex, prob=$maxProb');

      return {
        'label': label,
        'confidence': maxProb.clamp(0.0, 1.0),
        'classIndex': maxIndex,
      };

    } catch (e, stack) {
      debugPrint('Error en _runClassification: $e');
      debugPrint('Stack trace: $stack');
      return {
        'label': 'error',
        'confidence': 0.0,
        'classIndex': -1,
      };
    }
  }

  List<Map<String, dynamic>> _nonMaxSuppression(List<Map<String, dynamic>> detections, double iouThreshold) {
    if (detections.isEmpty) return [];

    detections.sort((a, b) => b['confidence'].compareTo(a['confidence']));

    final selected = <Map<String, dynamic>>[];

    for (final detection in detections) {
      bool shouldAdd = true;

      for (final selectedDetection in selected) {
        final iou = _calculateIoU(detection['boundingBox'], selectedDetection['boundingBox']);
        if (iou > iouThreshold) {
          shouldAdd = false;
          break;
        }
      }

      if (shouldAdd) {
        selected.add(detection);
      }
    }

    return selected;
  }

  double _calculateIoU(Map<String, dynamic> box1, Map<String, dynamic> box2) {
    final double x1_1 = box1['x'] as double;
    final double y1_1 = box1['y'] as double;
    final double w1 = box1['width'] as double;
    final double h1 = box1['height'] as double;

    final double x1_2 = box2['x'] as double;
    final double y1_2 = box2['y'] as double;
    final double w2 = box2['width'] as double;
    final double h2 = box2['height'] as double;

    final double x1 = math.max(x1_1, x1_2);
    final double y1 = math.max(y1_1, y1_2);
    final double x2 = math.min(x1_1 + w1, x1_2 + w2);
    final double y2 = math.min(y1_1 + h1, y1_2 + h2);

    final double intersection = math.max(0, x2 - x1) * math.max(0, y2 - y1);
    final double area1 = w1 * h1;
    final double area2 = w2 * h2;
    final double union = area1 + area2 - intersection;

    return union > 0 ? intersection / union : 0;
  }

  List<Map<String, dynamic>> getLastDetections() {
    return _lastDetections;
  }

  void close() {
    _detectionInterpreter.close();
    _classificationInterpreter.close();
  }
}
