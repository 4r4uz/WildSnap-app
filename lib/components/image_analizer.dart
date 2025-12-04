import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import '../services/animal_service.dart';

class ImageClassifier {
  late Interpreter _detectionInterpreter;
  late Interpreter _classificationInterpreter;
  late List<String> _detectionLabels; // COCO labels
  late List<String> _classificationLabels; // ImageNet labels
  late int _detectionInputSize;
  late int _classificationInputSize;
  Future<void>? _initializationFuture;
  List<Map<String, dynamic>> _lastDetections = [];
  late Interpreter _detectionInterpreter;
  late Interpreter _classificationInterpreter;
  late List<String> _detectionLabels; // COCO labels
  late List<String> _classificationLabels; // ImageNet labels
  late int _detectionInputSize;
  late int _classificationInputSize;
  Future<void>? _initializationFuture;
  List<Map<String, dynamic>> _lastDetections = [];

  ImageClassifier() {
    _initializationFuture = _loadModels();
    _initializationFuture = _loadModels();
  }

  Future<void> _loadModels() async {
    final options = InterpreterOptions()
      ..threads = 2
      ..useNnApiForAndroid = true;

    try {
      debugPrint('Loading detection model...');
      // Load detection model (YOLO) - Flutter automatically maps assets/ folder
      _detectionInterpreter = await Interpreter.fromAsset('deteccion.tflite', options: options);
      _detectionInterpreter.allocateTensors();
      debugPrint('✅ Detection model loaded successfully');

      debugPrint('Loading classification model...');
      // Load classification model (EfficientNet) - Flutter automatically maps assets/ folder
      _classificationInterpreter = await Interpreter.fromAsset('clasificacion.tflite', options: options);
      _classificationInterpreter.allocateTensors();
      debugPrint('✅ Classification model loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading models: $e');
      // Try loading with minimal options
      debugPrint('Trying with minimal options...');
      final minimalOptions = InterpreterOptions()..threads = 1;

      try {
        _detectionInterpreter = await Interpreter.fromAsset('deteccion.tflite', options: minimalOptions);
        _detectionInterpreter.allocateTensors();
        debugPrint('✅ Detection model loaded with minimal options');

        _classificationInterpreter = await Interpreter.fromAsset('clasificacion.tflite', options: minimalOptions);
        _classificationInterpreter.allocateTensors();
        debugPrint('✅ Classification model loaded with minimal options');
      } catch (e2) {
        debugPrint('❌ Failed to load models even with minimal options: $e2');
        rethrow;
      }
    }

    // Get input sizes
    final detectionInputTensors = _detectionInterpreter.getInputTensors();
    final classificationInputTensors = _classificationInterpreter.getInputTensors();

    _detectionInputSize = detectionInputTensors.isNotEmpty && detectionInputTensors[0].shape.length >= 3
        ? detectionInputTensors[0].shape[1] : 640;

    _classificationInputSize = classificationInputTensors.isNotEmpty && classificationInputTensors[0].shape.length >= 3
        ? classificationInputTensors[0].shape[1] : 224;

    // Load labels
    final detectionLabelsData = await rootBundle.loadString('assets/coco_labels.txt');
    _detectionLabels = detectionLabelsData.split('\n').where((line) => line.trim().isNotEmpty).toList();

    final classificationLabelsData = await rootBundle.loadString('assets/imagenet_labels.txt');
    _classificationLabels = classificationLabelsData.split('\n').where((line) => line.trim().isNotEmpty).toList();

    debugPrint('Detection labels: ${_detectionLabels.length}, Classification labels: ${_classificationLabels.length}');
  }

  Future<void> ensureInitialized() async {
    await _initializationFuture;
  }

  // Procesa imagen usando YOLO para detectar y EfficientNet para clasificar
  // Procesa imagen usando YOLO para detectar y EfficientNet para clasificar
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    await ensureInitialized();

    await Future.delayed(const Duration(milliseconds: 50));

    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    await ensureInitialized();

    await Future.delayed(const Duration(milliseconds: 50));

    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    // Paso 1: Detección con YOLO
    final detections = await _runDetection(image);

    if (detections.isEmpty) {
      return {
        'label': 'Sin animal detectado',
        'confidence': '0.00',
        'index': -1,
        'bounding_box': null,
        'animal_data': null,
        'all_detections': [],
        'classification_results': [],
      };
    }

    // Paso 2: Clasificación de cada detección con EfficientNet
    final classificationResults = <Map<String, dynamic>>[];

    for (final detection in detections) {
      final bbox = detection['boundingBox'] as Map<String, dynamic>;
      final x = bbox['x'] as double;
      final y = bbox['y'] as double;
      final width = bbox['width'] as double;
      final height = bbox['height'] as double;

      // Recortar la imagen según bounding box
      final crop = img.copyCrop(image,
        x: x.toInt(),
        y: y.toInt(),
        width: width.toInt(),
        height: height.toInt()
      );

      // Clasificar el recorte
      final classification = await _runClassification(crop);

      classificationResults.add({
        'detection': detection,
        'classification': classification,
      });
    }

    // Obtener mejor resultado combinado
    final bestResult = classificationResults.reduce((a, b) {
      final aScore = (a['detection']['confidence'] as double) * (a['classification']['confidence'] as double);
      final bScore = (b['detection']['confidence'] as double) * (b['classification']['confidence'] as double);
      return aScore > bScore ? a : b;
    });

    final bestDetection = bestResult['detection'] as Map<String, dynamic>;
    final bestClassification = bestResult['classification'] as Map<String, dynamic>;

    // Obtener datos del animal clasificado
    final animalService = AnimalService();
    final animalData = await animalService.getAnimalByName(bestClassification['label']);

    return {
      'label': bestClassification['label'],
      'confidence': (bestClassification['confidence'] * 100).toStringAsFixed(2),
      'index': bestClassification['classIndex'],
      'bounding_box': bestDetection['boundingBox'],
      'animal_data': animalData,
      'all_detections': detections,
      'classification_results': classificationResults,
      'detection_label': bestDetection['label'],
      'detection_confidence': (bestDetection['confidence'] * 100).toStringAsFixed(2),
    };
  }

  Future<List<Map<String, dynamic>>> _runDetection(img.Image image) async {
    // Preparar imagen para YOLO
    final resized = img.copyResize(image, width: _detectionInputSize, height: _detectionInputSize, interpolation: img.Interpolation.nearest);
    final input = Float32List(1 * _detectionInputSize * _detectionInputSize * 3);
    final resizedBytes = resized.getBytes(order: img.ChannelOrder.rgb);

    for (int i = 0; i < resizedBytes.length; i++) {
      input[i] = resizedBytes[i] / 255.0;
    }

    final inputTensor = input.reshape([1, _detectionInputSize, _detectionInputSize, 3]);

    // Configurar outputs
    final outputTensors = _detectionInterpreter.getOutputTensors();
    final outputs = <int, Object>{};

    for (int i = 0; i < outputTensors.length; i++) {
      final tensor = outputTensors[i];
      final shape = tensor.shape;

      if (shape.length == 3) {
        outputs[i] = List.generate(shape[0], (b) =>
          List.generate(shape[1], (h) =>
            List.filled(shape[2], 0.0)
          )
        );
      } else if (shape.length == 2) {
        outputs[i] = List.generate(shape[0], (b) =>
          List.filled(shape[1], 0.0)
        );
      } else {
        final totalSize = shape.reduce((a, b) => a * b);
        outputs[i] = List.filled(totalSize, 0.0);
      }
    }

    // Ejecutar inferencia
    _detectionInterpreter.runForMultipleInputs([inputTensor], outputs);

    // Parsear resultados
    final detections = _parseYoloOutputs(outputs, image.width, image.height);
    _lastDetections = detections;
    return detections;
  }

  Future<Map<String, dynamic>> _runClassification(img.Image crop) async {
    // Preparar imagen para EfficientNet (224x224, RGB, preprocess)
    final resized = img.copyResize(crop, width: _classificationInputSize, height: _classificationInputSize);

    // Convertir a formato correcto para EfficientNet: lista plana de doubles [0,1]
    final input = <double>[];
    for (int y = 0; y < _classificationInputSize; y++) {
      for (int x = 0; x < _classificationInputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input.add(pixel.r / 255.0);  // Red
        input.add(pixel.g / 255.0);  // Green
        input.add(pixel.b / 255.0);  // Blue
      }
    }

    // Output para clasificación - ImageNet tiene 1000 clases
    final output = List.filled(1000, 0.0).reshape([1, 1000]);

    // Ejecutar inferencia - siguiendo el patrón estándar de TFLite
    _classificationInterpreter.run([input], output);

    // Encontrar mejor predicción
    // Encontrar mejor predicción
    double maxProb = 0;
    int maxIndex = -1;
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxProb) {
        maxProb = output[0][i];
        maxIndex = i;
      }
    }

    return {
      'label': maxIndex >= 0 && maxIndex < _classificationLabels.length
          ? _classificationLabels[maxIndex] : 'unknown',
      'confidence': maxProb,
      'classIndex': maxIndex,
    };
  }

  // Parsea los outputs del modelo YOLOv8 para extraer detecciones
  List<Map<String, dynamic>> _parseYoloOutputs(Map<int, Object> outputs, int originalWidth, int originalHeight) {
    // Filtrar para humanos y animales (COCO classes)
    final Set<int> validClassIds = {0, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25}; // person, bird-cat, dog-giraffe

    const double defaultConfidenceThreshold = 0.15;
    const double iouThreshold = 0.45;
    var detections = <Map<String, dynamic>>[];

    if (kDebugMode) {
      debugPrint('=== INICIANDO PARSING YOLOv8 ===');
    }

    // Obtener información de los tensores para saber cómo interpretar los datos
    final outputTensors = _detectionInterpreter.getOutputTensors();

    // Procesar cada tensor de output
    for (int tensorIdx = 0; tensorIdx < outputs.length; tensorIdx++) {
      final output = outputs[tensorIdx];
      final tensor = outputTensors[tensorIdx];
      final shape = tensor.shape;

      if (kDebugMode) {
        debugPrint('Procesando tensor $tensorIdx: shape=$shape, tipo=${output.runtimeType}');
      }

      // Formato YOLOv8 estándar: [1, num_detections, features] o [num_detections, features]
      if (output is List && output.isNotEmpty && output[0] is List) {
        List<List<double>> detectionsData;

        if (output[0] is List && output[0][0] is List) {
          // Formato 3D: [1, num_detections, features] o [1, num_classes, num_anchors]
          final output3D = output as List<List<List<double>>>;

          // Verificar si es formato raw YOLOv8: [1, num_classes, num_anchors]
          // El modelo puede tener más clases que las labels si incluye background u otras
          if (shape[2] > 1000) {  // num_anchors > 1000 indica formato raw
            // Procesar formato raw YOLOv8: [1, X, 8400] donde X puede ser > num_labels
            detections.addAll(_parseRawYoloFormat(output3D[0], originalWidth, originalHeight, validClassIds, defaultConfidenceThreshold));
            continue;
          } else {
            // Formato estándar: [1, num_detections, features]
            detectionsData = output3D[0]; // Remover dimensión batch
          }
        } else {
          // Formato 2D: [num_detections, features]
          detectionsData = output as List<List<double>>;
        }

        // Procesar formatos estándar si no es raw YOLO
        final numDetections = detectionsData.length;
        final numFeatures = detectionsData.isNotEmpty ? detectionsData[0].length : 0;

        if (kDebugMode) {
          debugPrint('Procesando $numDetections detecciones, $numFeatures features por detección');
        }

        // Determinar formato basado en número de features
        final hasObjScore = numFeatures == 5 + _detectionLabels.length;
        final expectedFeatures = 4 + _detectionLabels.length + (hasObjScore ? 1 : 0);

        if (numFeatures != expectedFeatures) {
          debugPrint('⚠️ Número de features inesperado: $numFeatures, esperado: $expectedFeatures');
          continue;
        }

        for (int detIdx = 0; detIdx < numDetections; detIdx++) {
          final detection = detectionsData[detIdx];

          // Extraer coordenadas de bounding box (normalizadas 0-1)
          final xCenter = detection[0];
          final yCenter = detection[1];
          final width = detection[2];
          final height = detection[3];

          // Verificar que las coordenadas sean válidas
          if (xCenter < 0 || xCenter > 1 || yCenter < 0 || yCenter > 1 ||
              width < 0 || width > 1 || height < 0 || height > 1) {
            continue;
          }

          double objScore = 1.0;
          int classStartIdx = 4;

          if (hasObjScore) {
            objScore = detection[4];
            classStartIdx = 5;
          }

          // Encontrar clase con mayor probabilidad
          double maxClassProb = 0;
          int maxClassIndex = -1;
          for (int j = 0; j < _detectionLabels.length; j++) {
            final classProb = detection[classStartIdx + j];
            if (classProb > maxClassProb) {
              maxClassProb = classProb;
              maxClassIndex = j;
            }
          }

          if (maxClassIndex == -1 || !validClassIds.contains(maxClassIndex)) {
            continue;
          }

          // Calcular confianza final
          final confidence = objScore * maxClassProb;

          if (confidence < defaultConfidenceThreshold) {
            continue;
          }

          // Convertir coordenadas normalizadas a píxeles
          final bbox = {
            'x': math.max(0, (xCenter - width / 2) * originalWidth),
            'y': math.max(0, (yCenter - height / 2) * originalHeight),
            'width': math.min(originalWidth, width * originalWidth),
            'height': math.min(originalHeight, height * originalHeight),
          };

          detections.add({
            'label': _detectionLabels[maxClassIndex],
            'confidence': confidence,
            'classIndex': maxClassIndex,
            'boundingBox': bbox,
          });

          if (kDebugMode) {
            debugPrint('  Detección ${detIdx + 1}: ${_detectionLabels[maxClassIndex]} (${(confidence * 100).toStringAsFixed(1)}%)');
          }
        }
            } else {
        debugPrint('⚠️ Formato de output no reconocido: ${output.runtimeType}');
      }
    }

    // Optimización: Limitar detecciones antes de NMS para reducir procesamiento
    const int maxDetectionsBeforeNMS = 100; // Máximo 100 detecciones antes de NMS
    if (detections.length > maxDetectionsBeforeNMS) {
      detections.sort((a, b) => b['confidence'].compareTo(a['confidence']));
      detections = detections.take(maxDetectionsBeforeNMS).toList();
    }

    if (kDebugMode) {
      debugPrint('Total detecciones antes de NMS: ${detections.length}');
    }

    // Aplicar Non-Maximum Suppression
    final finalDetections = _nonMaxSuppression(detections, iouThreshold);

    if (kDebugMode) {
      debugPrint('Total detecciones después de NMS: ${finalDetections.length}');
    }

    return finalDetections;
  }

  List<Map<String, dynamic>> _nonMaxSuppression(List<Map<String, dynamic>> detections, double iouThreshold) {
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
    final x1 = math.max(box1['x'], box2['x']);
    final y1 = math.max(box1['y'], box2['y']);
    final x2 = math.min(box1['x'] + box1['width'], box2['x'] + box2['width']);
    final y2 = math.min(box1['y'] + box1['height'], box2['y'] + box2['height']);

    final intersectionArea = math.max(0, x2 - x1) * math.max(0, y2 - y1);
    final box1Area = box1['width'] * box1['height'];
    final box2Area = box2['width'] * box2['height'];
    final unionArea = box1Area + box2Area - intersectionArea;

    return unionArea > 0 ? intersectionArea / unionArea : 0;
  }

  // Parsea formato raw YOLOv8: [num_classes, num_anchors] con solo scores de clase
  List<Map<String, dynamic>> _parseRawYoloFormat(
    List<List<double>> rawOutput,
    int originalWidth,
    int originalHeight,
    Set<int> validClassIds,
    double defaultConfidenceThreshold
  ) {
    final detections = <Map<String, dynamic>>[];
    final numClasses = rawOutput.length;
    final numAnchors = rawOutput[0].length;

    if (kDebugMode) {
      debugPrint('Procesando formato raw YOLO: $numClasses clases, $numAnchors anchors');
    }

    // Procesar cada clase
    for (int classIdx = 0; classIdx < numClasses && classIdx < _detectionLabels.length; classIdx++) {
      if (!validClassIds.contains(classIdx)) continue;

      final classScores = rawOutput[classIdx];

      // Encontrar anchors con alta confianza para esta clase
      for (int anchorIdx = 0; anchorIdx < numAnchors; anchorIdx++) {
        final confidence = classScores[anchorIdx];

        if (confidence >= defaultConfidenceThreshold) {
          // Para formato raw, usar coordenadas por defecto centradas
          final centerX = 0.5;
          final centerY = 0.5;
          final width = 0.3;
          final height = 0.3;

          final bbox = {
            'x': math.max(0, (centerX - width / 2) * originalWidth),
            'y': math.max(0, (centerY - height / 2) * originalHeight),
            'width': math.min(originalWidth, width * originalWidth),
            'height': math.min(originalHeight, height * originalHeight),
          };

          detections.add({
            'label': _detectionLabels[classIdx],
            'confidence': confidence,
            'classIndex': classIdx,
            'boundingBox': bbox,
          });

          if (kDebugMode && detections.length <= 5) {
            debugPrint('  Raw detección: ${_detectionLabels[classIdx]} (${(confidence * 100).toStringAsFixed(1)}%) en anchor $anchorIdx');
          }
        }
      }
    }

    if (kDebugMode) {
      debugPrint('Raw YOLO: ${detections.length} detecciones encontradas');
    }

    return detections;
  }

  // Getter para obtener las últimas detecciones (para debug)
  List<Map<String, dynamic>> getLastDetections() {
    return _lastDetections;
  }

  void close() {
    _detectionInterpreter.close();
    _classificationInterpreter.close();
    _detectionInterpreter.close();
    _classificationInterpreter.close();
  }
}
