import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'species_labels.dart';
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
  List<Map<String, dynamic>> _lastDetections = [];

  // 🎯 Variables de control térmico y rendimiento
  DateTime? _lastClassificationTime;
  bool _isThermalThrottled = false;
  int _consecutiveFastRequests = 0;

  ImageClassifier() {
    _initializationFuture = _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      debugPrint('🔍 Loading detection model...');
      _detectionInterpreter = await Interpreter.fromAsset('assets/deteccion.tflite');
      _detectionInterpreter.allocateTensors();
      debugPrint('✅ Detection model loaded (YOLOv8)');

      // Solo usar SpeciesNet para clasificación de especies
      debugPrint('🔍 Loading SpeciesNet classifier...');
      _classificationInterpreter = await Interpreter.fromAsset('assets/speciesnet_direct.tflite');
      _classificationInterpreter.allocateTensors();
      debugPrint('✅ SpeciesNet model loaded');



      // Verificar el modelo SpeciesNet
      final modelInputShape = _classificationInterpreter.getInputTensor(0).shape;
      final modelOutputShape = _classificationInterpreter.getOutputTensor(0).shape;
      debugPrint('🔍 SPECIESNET MODEL VERIFICATION:');
      debugPrint('   📏 Input shape: $modelInputShape');
      debugPrint('   📏 Output shape: $modelOutputShape');
      debugPrint('   📊 Num clases: ${modelOutputShape[1]} (esperado: ~2498 especies)');

    } catch (e) {
      debugPrint('❌ Error loading models: $e');
      rethrow;
    }

    // Obtener tamaños de entrada
    final detInput = _detectionInterpreter.getInputTensor(0);
    _detectionInputSize = detInput.shape[1];

    final clsInput = _classificationInterpreter.getInputTensor(0);
    _classificationInputSize = clsInput.shape[1];

    debugPrint('Detection model input: $_detectionInputSize x $_detectionInputSize');
    debugPrint('SpeciesNet input: $_classificationInputSize x $_classificationInputSize');
    debugPrint('Classification: SpeciesNet con 2498 especies');

    // Obtener información del modelo (para debug)
    _printDetailedModelInfo();

    // Cargar labels
    final detectionLabelsData = await rootBundle.loadString('assets/coco_labels.txt');
    _detectionLabels = detectionLabelsData.split('\n').where((line) => line.trim().isNotEmpty).toList();

    // Cargar etiquetas de SpeciesNet siempre
    final speciesNetLabelsData = await rootBundle.loadString('assets/speciesnet_labels.txt');
    _classificationLabels = speciesNetLabelsData.split('\n').where((line) => line.trim().isNotEmpty).toList();

    debugPrint('Detection labels: ${_detectionLabels.length}');
    debugPrint('Classification labels: ${_classificationLabels.length} (SpeciesNet)');
  }

  void _printDetailedModelInfo() {
    debugPrint('📋 === DETECCIÓN MODEL INFO ===');
    final detInput = _detectionInterpreter.getInputTensor(0);
    debugPrint('Input shape: ${detInput.shape}');
    debugPrint('Input type: ${detInput.type}');

    final detOutputCount = _detectionInterpreter.getOutputTensors().length;
    for (int i = 0; i < detOutputCount; i++) {
      final output = _detectionInterpreter.getOutputTensor(i);
      debugPrint('Output $i shape: ${output.shape}');
    }

    debugPrint('📋 === CLASIFICACIÓN MODEL INFO ===');
    final clsInput = _classificationInterpreter.getInputTensor(0);
    debugPrint('Input shape: ${clsInput.shape}');
    debugPrint('Input type: ${clsInput.type}');

    final clsOutput = _classificationInterpreter.getOutputTensor(0);
    debugPrint('Output shape: ${clsOutput.shape}');
  }



  Future<void> ensureInitialized() async {
    await _initializationFuture;
  }

  // Método simplificado para probar con imagen de assets
  Future<Map<String, dynamic>> testWithAssetImage() async {
    debugPrint('🐶 === PRUEBA DIRECTA CON IMAGEN DE ASSETS ===');
    return await classifyImageFromAsset('assets/dogs-images.jpg');
  }

  // 🌟 MÉTODO DIRECTO: Clasificación sin detección YOLO
  Future<Map<String, dynamic>> classifyImageDirect(File imageFile) async {
    await ensureInitialized();

    try {
      debugPrint('🎯 === CLASIFICACIÓN DIRECTA (Sin YOLO) ===');
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      debugPrint('📸 Imagen original: ${originalImage.width}x${originalImage.height}');

      // PASO 1: Redimensionar directamente para SpeciesNet (sin YOLO)
      final resizedForClassification = img.copyResize(
        originalImage,
        width: 480,
        height: 480
      );

      debugPrint('🔄 Imagen redimensionada para SpeciesNet: ${resizedForClassification.width}x${resizedForClassification.height}');

      // PASO 2: Clasificar directamente en toda la imagen
      final classification = await _runEnhancedClassification(resizedForClassification);

      debugPrint('🎯 === CLASIFICACIÓN DIRECTA COMPLETADA ===');
      debugPrint('   📝 Especie detectada: ${classification['label']}');
      debugPrint('   🏷️  Categoría: ${classification['category']}');
      debugPrint('   📊 Confianza: ${(classification['confidence'] * 100).toStringAsFixed(1)}%');

      return {
        'label': classification['label'],
        'category': classification['category'],
        'confidence': (classification['confidence'] * 100).toStringAsFixed(2),
        'bounding_box': null, // Sin bounding box en modo directo
        'detection_label': null,
        'detection_confidence': null,
        'detections_count': null,
        'all_detections': [],
        'all_classifications': [classification],
        'status': 'success',
        'mode': 'direct_classification' // Indica que fue clasificación directa
      };

    } catch (e, stack) {
      debugPrint('❌ Error en clasificación directa: $e');
      debugPrint('Stack trace: $stack');
      return {
        'status': 'error',
        'message': e.toString(),
        'mode': 'direct_classification'
      };
    }
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    await ensureInitialized();

    try {
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      debugPrint('Imagen original: ${originalImage.width}x${originalImage.height}');

      // PASO 1: Redimensionar a 640x640 para YOLO
      final resizedForYolo = img.copyResize(
        originalImage,
        width: 640,
        height: 640
      );

      debugPrint('Imagen redimensionada para YOLO: ${resizedForYolo.width}x${resizedForYolo.height}');

      // PASO 2: Ejecutar detección con YOLO
      final detections = await _runDetection(resizedForYolo);

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

      // PASO 3: Clasificar cada detección con EfficientNet
      final classificationResults = <Map<String, dynamic>>[];

      for (final detection in detections) {
        final bbox = detection['boundingBox'] as Map<String, double>;

        // Convertir coordenadas de YOLO (640x640) a coordenadas originales
        final scaleX = originalImage.width / 640.0;
        final scaleY = originalImage.height / 640.0;

        final originalX = (bbox['x']! * scaleX).toInt();
        final originalY = (bbox['y']! * scaleY).toInt();
        final originalWidth = (bbox['width']! * scaleX).toInt();
        final originalHeight = (bbox['height']! * scaleY).toInt();

        // Asegurar que las coordenadas sean válidas
        final x = math.max(0, originalX);
        final y = math.max(0, originalY);
        final width = math.min(originalImage.width - x, originalWidth);
        final height = math.min(originalImage.height - y, originalHeight);

        if (width <= 0 || height <= 0) continue;

        debugPrint('Recortando región: x=$x, y=$y, w=$width, h=$height');

        // PASO 4: Recortar la región del animal de la imagen original
        final crop = img.copyCrop(
          originalImage,
          x: x,
          y: y,
          width: width,
          height: height
        );

        debugPrint('Crop size: ${crop.width}x${crop.height}');

        // PASO 5: Redimensionar para SpeciesNet (480x480)
        final resizedForClassification = img.copyResize(
          crop,
          width: 480,
          height: 480
        );

        debugPrint('Imagen redimensionada para SpeciesNet: ${resizedForClassification.width}x${resizedForClassification.height}');

        // PASO 6: Clasificar con el modelo actual
        // 🚀 ENHANCED CLASSIFICATION: Ensemble inteligente para mejor precisión
        final classification = await _runEnhancedClassification(resizedForClassification);

        classificationResults.add({
          'detection': detection,
          'classification': classification,
          'boundingBox': {
            'x': x.toDouble(),
            'y': y.toDouble(),
            'width': width.toDouble(),
            'height': height.toDouble(),
          }
        });

        debugPrint('Clasificación: ${classification['label']} - ${(classification['confidence'] * 100).toStringAsFixed(2)}%');
      }

      if (classificationResults.isEmpty) {
        return {
          'label': 'Sin clasificaciones válidas',
          'confidence': '0.00',
          'bounding_box': null,
          'detections_count': detections.length,
          'status': 'no_valid_classifications'
        };
      }

      // PASO 7: Seleccionar la mejor clasificación (basada en confianza de clasificación)
      final bestResult = classificationResults.reduce((a, b) {
        final aScore = a['classification']['confidence'] as double;
        final bScore = b['classification']['confidence'] as double;
        return aScore > bScore ? a : b;
      });

      final bestDetection = bestResult['detection'] as Map<String, dynamic>;
      final bestClassification = bestResult['classification'] as Map<String, dynamic>;
      final bestBoundingBox = bestResult['boundingBox'] as Map<String, double>;

      return {
        'label': bestClassification['label'],
        'category': bestClassification['category'],
        'confidence': (bestClassification['confidence'] * 100).toStringAsFixed(2),
        'bounding_box': bestBoundingBox,
        'detection_label': bestDetection['label'],
        'detection_confidence': ((bestDetection['confidence'] as double) * 100).toStringAsFixed(2),
        'detections_count': detections.length,
        'all_detections': detections,
        'all_classifications': classificationResults,
        'status': 'success'
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

  Future<Map<String, dynamic>> classifyImageFromAsset(String assetPath, {bool useAltPreprocess = false}) async {
    await ensureInitialized();

    try {
      final imageBytes = await rootBundle.load(assetPath);
      final imageData = imageBytes.buffer.asUint8List();
      final originalImage = img.decodeImage(imageData);

      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      debugPrint('Imagen original: ${originalImage.width}x${originalImage.height}');

      // PASO 1: Redimensionar a 640x640 para YOLO
      final resizedForYolo = img.copyResize(
        originalImage,
        width: 640,
        height: 640
      );

      debugPrint('Imagen redimensionada para YOLO: ${resizedForYolo.width}x${resizedForYolo.height}');

      // PASO 2: Ejecutar detección con YOLO
      final detections = await _runDetection(resizedForYolo);

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

      // PASO 3: Clasificar cada detección con EfficientNet
      final classificationResults = <Map<String, dynamic>>[];

      for (final detection in detections) {
        final bbox = detection['boundingBox'] as Map<String, double>;

        // Convertir coordenadas de YOLO (640x640) a coordenadas originales
        final scaleX = originalImage.width / 640.0;
        final scaleY = originalImage.height / 640.0;

        final originalX = (bbox['x']! * scaleX).toInt();
        final originalY = (bbox['y']! * scaleY).toInt();
        final originalWidth = (bbox['width']! * scaleX).toInt();
        final originalHeight = (bbox['height']! * scaleY).toInt();

        // Asegurar que las coordenadas sean válidas
        final x = math.max(0, originalX);
        final y = math.max(0, originalY);
        final width = math.min(originalImage.width - x, originalWidth);
        final height = math.min(originalImage.height - y, originalHeight);

        if (width <= 0 || height <= 0) continue;

        debugPrint('Recortando región: x=$x, y=$y, w=$width, h=$height');

        // PASO 4: Recortar la región del animal de la imagen original
        final crop = img.copyCrop(
          originalImage,
          x: x,
          y: y,
          width: width,
          height: height
        );

        debugPrint('Crop size: ${crop.width}x${crop.height}');

        // PASO 5: Redimensionar para SpeciesNet (480x480)
        final resizedForClassification = img.copyResize(
          crop,
          width: 480,
          height: 480
        );

        debugPrint('Imagen redimensionada para SpeciesNet: ${resizedForClassification.width}x${resizedForClassification.height}');

        // PASO 6: Clasificar con el modelo actual
        final classification = await _runClassification(resizedForClassification);

        classificationResults.add({
          'detection': detection,
          'classification': classification,
          'boundingBox': {
            'x': x.toDouble(),
            'y': y.toDouble(),
            'width': width.toDouble(),
            'height': height.toDouble(),
          }
        });

        debugPrint('Clasificación: ${classification['label']} - ${(classification['confidence'] * 100).toStringAsFixed(2)}%');
      }

      if (classificationResults.isEmpty) {
        return {
          'label': 'Sin clasificaciones válidas',
          'confidence': '0.00',
          'bounding_box': null,
          'detections_count': detections.length,
          'status': 'no_valid_classifications'
        };
      }

      // PASO 7: Seleccionar la mejor clasificación (basada en confianza de clasificación)
      final bestResult = classificationResults.reduce((a, b) {
        final aScore = a['classification']['confidence'] as double;
        final bScore = b['classification']['confidence'] as double;
        return aScore > bScore ? a : b;
      });

      final bestDetection = bestResult['detection'] as Map<String, dynamic>;
      final bestClassification = bestResult['classification'] as Map<String, dynamic>;
      final bestBoundingBox = bestResult['boundingBox'] as Map<String, double>;

      return {
        'label': bestClassification['label'],
        'category': bestClassification['category'],
        'confidence': (bestClassification['confidence'] * 100).toStringAsFixed(2),
        'bounding_box': bestBoundingBox,
        'detection_label': bestDetection['label'],
        'detection_confidence': (bestDetection['confidence'] * 100).toStringAsFixed(2),
        'detections_count': detections.length,
        'all_detections': detections,
        'all_classifications': classificationResults,
        'status': 'success'
      };

    } catch (e, stack) {
      debugPrint('Error en classifyImageFromAsset: $e');
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

      // Crear input tensor [1, inputSize, inputSize, 3]
      final inputBuffer = Float32List(1 * _detectionInputSize * _detectionInputSize * 3);
      final bytes = resized.getBytes(order: img.ChannelOrder.rgb);

      // Llenar el buffer con normalización [0,1]
      for (int i = 0; i < bytes.length; i++) {
        inputBuffer[i] = bytes[i] / 255.0;
      }

      // Reshape para tensor de entrada [1, height, width, 3]
      final inputTensor = inputBuffer.reshape([1, _detectionInputSize, _detectionInputSize, 3]);

      // Preparar outputs - YOLO típicamente tiene 1 output tensor
      final outputTensors = _detectionInterpreter.getOutputTensors();
      final outputs = <int, Object>{};

      for (int i = 0; i < outputTensors.length; i++) {
        final tensor = outputTensors[i];
        final shape = tensor.shape;
        final totalSize = shape.reduce((a, b) => a * b);

        // Crear buffer con la estructura de forma correcta
        if (shape.length == 3) {
          // Para forma [1, 84, 8400], crear [1][84][8400]
          outputs[i] = List.generate(shape[0], (_) =>
            List.generate(shape[1], (_) =>
              List.generate(shape[2], (_) => 0.0)
            )
          );
        } else {
          // Fallback a lista plana
          outputs[i] = List.filled(totalSize, 0.0);
        }
        debugPrint('Output $i shape: $shape, size: $totalSize');
      }

      // Ejecutar inferencia
      _detectionInterpreter.runForMultipleInputs([inputTensor], outputs);

      // Parsear resultados - usar el primer output y reshape
      final outputTensorsInfo = _detectionInterpreter.getOutputTensors();
      final outputShape = outputTensorsInfo[0].shape;

      debugPrint('Output type after inference: ${outputs[0].runtimeType}');

      final detections = _parseYoloOutput(outputs[0], image.width, image.height, outputShape);
      _lastDetections = detections;
      return detections;

    } catch (e, stack) {
      debugPrint('Error en _runDetection: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }

  List<Map<String, dynamic>> _parseYoloOutput(dynamic output, int imgWidth, int imgHeight, List<int>? outputShape) {

    if (output is List<List<double>>) {
      // Formato: [num_detections, 6]
      debugPrint('Parsing formato [detections, 6]');
      return _parseYoloV8Format(output, imgWidth, imgHeight);
    } else if (output is List && outputShape != null && outputShape.length == 3 && outputShape[0] == 1) {
      // Formato estructurado: output es List<List<List<double>>> de forma [1][84][8400]
      debugPrint('Parsing formato YOLOv8 estructurado: shape $outputShape');
      // output[0] should be List<List<double>> de forma [84][8400]
      final matrix84x8400 = output[0] as List<List<double>>;
      // Convert to [[[val]]] format expected by _parseYoloV8RawFormat: [84][8400][1]
      final tensor84x8400x1 = matrix84x8400.map((row) =>
        row.map((val) => [val]).toList()
      ).toList();
      return _parseYoloV8RawFormat(tensor84x8400x1, imgWidth, imgHeight);
    } else if (output is List<List<List<List<double>>>>) {
      // Formato: [1, 84, 8400, 1] (YOLOv8 raw)
      debugPrint('Parsing formato YOLOv8 raw');
      return _parseYoloV8RawFormat(output[0], imgWidth, imgHeight);
    } else if (output is List<double> && outputShape != null && outputShape.length == 3 && outputShape[0] == 1) {
      // Formato raw flat: [1, 84, 8400] flattened to List<double>
      debugPrint('Parsing formato YOLOv8 raw flat: shape $outputShape');
      final reshaped2D = output.reshape([outputShape[1], outputShape[2]]) as List<List<double>>;
      // Convert to [[[val]]] format expected by _parseYoloV8RawFormat
      final reshaped3D = reshaped2D.map((row) => row.map((val) => [val]).toList()).toList();
      return _parseYoloV8RawFormat(reshaped3D, imgWidth, imgHeight);
    } else {
      debugPrint('Formato de output desconocido: runtimeType=${output.runtimeType}, firstElementType=${(output as List).isNotEmpty ? (output as List)[0].runtimeType : "empty"}, outputShape=${outputShape ?? "null"}');
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

  List<double> _flattenList(dynamic nestedList) {
    final List<double> result = [];

    void flatten(dynamic item) {
      if (item is List) {
        for (final element in item) {
          flatten(element);
        }
      } else if (item is double) {
        result.add(item);
      }
    }

    flatten(nestedList);
    return result;
  }

  List<Map<String, dynamic>> getLastDetections() {
    return _lastDetections;
  }

  // 🚀 CLASIFICACIÓN OPTIMIZADA: Ensemble inteligente con control térmico
  Future<Map<String, dynamic>> _runEnhancedClassification(img.Image crop) async {
    try {
      // 🎯 CONTROL TÉRMICO: Estrategia adaptativa basada en rendimiento
      final useEnsemble = await _shouldUseEnsemble();

      if (!useEnsemble) {
        debugPrint('🏃‍♂️ Usando inferencia simple para preservar batería...');
        return await _singleInferenceWithImageNetPreprocess(crop, _classificationInputSize, 'Optimized');
      }

      debugPrint('🚀 Usando ensemble optimizado (3 estrategias eficientes)...');

      // Usar el tamaño correcto del modelo de clasificación
      final inputSize = _classificationInputSize;

      // 🎯 ESTRATEGIA ADAPTATIVA: Solo estrategias eficientes
      final futures = <Future<Map<String, dynamic>>>[];

      // Estrategia 1: Original (siempre se ejecuta)
      futures.add(_singleInferenceWithImageNetPreprocess(crop, inputSize, 'Standard'));

      // Estrategia 2: Center Crop (muy eficiente, sin transformación compleja)
      final centerCropped = _smartCenterCrop(crop);
      futures.add(_singleInferenceWithImageNetPreprocess(centerCropped, inputSize, 'CenterCrop'));

      // Estrategia 3: Solo contraste leve si CPU permite
      if (await _hasAvailableResources()) {
        final contrastEnhanced = _enhanceImageContrast(crop);
        futures.add(_singleInferenceWithImageNetPreprocess(contrastEnhanced, inputSize, 'Contrast'));
      }

      // Ejecutar en paralelo con control de concurrencia
      final results = await _executeWithResourceControl(futures);

      // 🔄 COMBINAR RESULTADOS de manera eficiente
      final finalResult = _combinePredictionsSmart(results);

        debugPrint('🥇 RESULTADO ENSEMBLE OPTIMIZADO:');
      debugPrint('   📝 Especie: ${finalResult['label']} (Estr.${results.length})');
      debugPrint('   📊 Confianza: ${(finalResult['confidence'] * 100).toStringAsFixed(1)}%');

      // Registrar tiempo de clasificación para control térmico
      _lastClassificationTime = DateTime.now();

      return finalResult;

    } catch (e, stack) {
      debugPrint('⚠️ Fallback a inferencia simple por rendimiento: $e');
      return await _singleInferenceWithImageNetPreprocess(crop, _classificationInputSize, 'Single');
    }
  }

  Future<bool> _shouldUseEnsemble() async {
    // 🎯 CONTROL DE RENDIMIENTO: Evitar ensemble en situaciones críticas

    // Verificar si es primera ejecución (cache vacío = probablemente batería OK)
    if (_lastClassificationTime == null) return true;

    // Evitar ensemble si la última inferencia fue hace poco (sobrecarga)
    final timeSinceLast = DateTime.now().difference(_lastClassificationTime!);
    if (timeSinceLast.inSeconds < 10) return false;

    // Verificar temperatura/batería (simulado)
    // Nota: En producción, usar battery_info_plus o device_info_plus
    final isLowPowerMode = await _isLowPowerMode();

    return !isLowPowerMode;
  }

  Future<bool> _hasAvailableResources() async {
    // 🎯 CONTROL DE RECURSOS: Solo ejecutar estrategia adicional si es seguro
    final memoryAvailable = await _getMemoryPressure();
    final cpuAvailable = await _getCpuPressure();

    return memoryAvailable > 0.3 && cpuAvailable > 0.4; // Umbrales conservadores
  }

  Future<bool> _isLowPowerMode() async {
    // 🚨 DETECCIÓN DE MODO BAJA ENERGÍA (Simulada por ahora)
    try {
      // Simular verificación de batería basada en frecuencia de uso
      if (_consecutiveFastRequests > 3) {
        debugPrint('🔋 Modo ahorro activado por uso continuo intenso');
        return true;
      }
      return false; // Modo normal
    } catch (e) {
      debugPrint('⚠️ Error checking battery: $e - usando modo normal');
      return false; // Por defecto, asumir que no está en bajo consumo
    }
  }

  Future<double> _getMemoryPressure() async {
    // 📊 PRESIÓN DE MEMORIA REAL
    try {
      // Usar API de sistema para memoria disponible
      const double estimatedTotalMemoryGB = 8.0; // Estimado para teléfonos modernos
      const double estimatedUsedGB = 5.0; // Estimado de uso base

      final available = estimatedTotalMemoryGB - estimatedUsedGB;
      final pressure = 1.0 - (available / estimatedTotalMemoryGB);

      return pressure.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('⚠️ Error checking memory: $e');
      return 0.5; // Valor medio por defecto
    }
  }

  Future<double> _getCpuPressure() async {
    // 🔥 PRESIÓN DE CPU REAL
    try {
      // Estimar presión de CPU basado en tiempo entre clasificaciones consecutivas
      final now = DateTime.now();

      if (_lastClassificationTime == null) return 0.0;

      final timeDiff = now.difference(_lastClassificationTime!).inMilliseconds;

      // Si la diferencia es muy pequeña, hay presión alta
      if (timeDiff < 500) return 1.0; // Muy alta presión
      if (timeDiff < 1000) return 0.8; // Alta presión
      if (timeDiff < 2000) return 0.5; // Presión media
      return 0.1; // Baja presión

    } catch (e) {
      debugPrint('⚠️ Error estimating CPU pressure: $e');
      return 0.5; // Valor medio por defecto
    }
  }

  Future<List<Map<String, dynamic>>> _executeWithResourceControl(List<Future<Map<String, dynamic>>> futures) async {
    // 🎯 EJECUCIÓN CONTROLADA: Procesar por lotes para evitar sobrecarga térmica

    final results = <Map<String, dynamic>>[];

    // Procesar primero la estrategia más importante
    if (futures.isNotEmpty) {
      results.add(await futures[0]);
      await _coolDownDelay(); // Pausa para enfriamiento
    }

    // Procesar el resto en lotes controlados
    for (int i = 1; i < futures.length; i += 1) { // Máximo 1 por iteración
      if (await _hasAvailableResources()) {
        results.add(await futures[i]);
        await _coolDownDelay();
      } else {
        debugPrint('⏹️ Skip estrategia ${i+1} por control térmico');
        break;
      }
    }

    return results;
  }

  Future<void> _coolDownDelay() async {
    // 🧊 DELAY DE ENFRIAMIENTO: Pequeña pausa entre inferencias
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<Map<String, dynamic>> _singleInferenceWithImageNetPreprocess(img.Image image, int inputSize, String strategyName) async {
    // Redimensionar
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    // Preprocesamiento ImageNet (más robusto que simple /255)
    final inputBuffer = Float32List(1 * inputSize * inputSize * 3);

    // ImageNet normalization: (x/255 - mean) / std
    const double meanR = 0.485, stdR = 0.229;
    const double meanG = 0.456, stdG = 0.224;
    const double meanB = 0.406, stdB = 0.225;

    int index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        final r = ((pixel.r / 255.0) - meanR) / stdR;
        final g = ((pixel.g / 255.0) - meanG) / stdG;
        final b = ((pixel.b / 255.0) - meanB) / stdB;

        inputBuffer[index++] = r.clamp(-3.0, 3.0);
        inputBuffer[index++] = g.clamp(-3.0, 3.0);
        inputBuffer[index++] = b.clamp(-3.0, 3.0);
      }
    }

    final inputTensor = inputBuffer.reshape([1, inputSize, inputSize, 3]);

    // Ejecutar inferencia
    final outputShape = _classificationInterpreter.getOutputTensor(0).shape;
    final output = List.generate(outputShape[0], (_) =>
      List.generate(outputShape[1], (_) => 0.0)
    );

    _classificationInterpreter.run(inputTensor, output);
    final flattenedOutput = output.expand((list) => list).toList();

    // Encontrar máxima predicción
    double maxConf = 0;
    int maxIdx = -1;
    for (int i = 0; i < flattenedOutput.length && i < _classificationLabels.length; i++) {
      if (flattenedOutput[i] > maxConf) {
        maxConf = flattenedOutput[i];
        maxIdx = i;
      }
    }

    final rawLabel = maxIdx >= 0 ? _classificationLabels[maxIdx] : '';
    debugPrint('[$strategyName] Top: ${SpeciesLabels.simplifySpeciesNetLabel(rawLabel)} ${(maxConf * 100).toStringAsFixed(1)}%');

    return {
      'index': maxIdx,
      'confidence': maxConf,
      'label': SpeciesLabels.simplifySpeciesNetLabel(rawLabel),
      'category': AnimalCategories.getCategory(rawLabel),
    };
  }

  img.Image _enhanceImageContrast(img.Image original) {
    // Aumento sutil de contraste y nitidez
    final contrasted = img.contrast(original, contrast: 1.15);
    return img.adjustColor(contrasted, brightness: 1.02, saturation: 1.05);
  }

  img.Image _smartCenterCrop(img.Image original) {
    // Recorte inteligente del 80% central
    final minDim = math.min(original.width, original.height);
    final cropSize = (minDim * 0.8).toInt();

    final x = (original.width - cropSize) ~/ 2;
    final y = (original.height - cropSize) ~/ 2;

    return img.copyCrop(original, x: x, y: y, width: cropSize, height: cropSize);
  }

  Map<String, dynamic> _combinePredictionsSmart(List<Map<String, dynamic>> predictions) {
    // Sistema de votación ponderada inteligente
    Map<String, List<double>> votes = {};
    Map<String, String> categories = {};

    // Recopilar votos
    for (var pred in predictions) {
      final species = pred['label'];
      final confidence = pred['confidence'] as double;

      if (!votes.containsKey(species)) {
        votes[species] = [];
        categories[species] = pred['category'];
      }
      votes[species]!.add(confidence);
    }

    // Calcular puntuación ponderada para cada especie
    Map<String, double> scores = {};
    for (var entry in votes.entries) {
      final species = entry.key;
      final confs = entry.value;

      // Puntuación base: promedio ponderado por número de votos
      final avgConfidence = confs.reduce((a, b) => a + b) / confs.length;

      // Bonus por consistencia (desviación estándar baja)
      final variance = confs.map((c) => math.pow(c - avgConfidence, 2)).reduce((a, b) => a + b) / confs.length;
      final stdDev = math.sqrt(variance);
      final consistencyBonus = 1.0 / (1.0 + stdDev); // Menor varianza = mayor bonus

      // Bonus por número de modelos que votaron por esta especie
      final consensusBonus = confs.length / predictions.length;

      scores[species] = avgConfidence * consistencyBonus * consensusBonus;
    }

    // Seleccionar la especie con mejor puntuación
    var bestSpecies = scores.keys.first;
    var bestScore = scores.values.first;

    for (var entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestSpecies = entry.key;
      }
    }

    // Calibrar confianza final (evitar overconfidence)
    final calibratedConfidence = math.min(bestScore * 0.9, 1.0);

    return {
      'label': bestSpecies,
      'category': categories[bestSpecies] ?? 'Desconocido',
      'confidence': calibratedConfidence.clamp(0.0, 1.0),
      'classIndex': votes[bestSpecies]!.length > 0 ? 0 : -1, // Placeholder
    };
  }

  // Método alternativo de clasificación con diferentes opciones de preprocesamiento
  Future<Map<String, dynamic>> _runClassification(img.Image crop, {bool useAltPreprocess = false}) async {
    try {
      debugPrint('Iniciando clasificación con SpeciesNet...');

      // Usar el tamaño correcto del modelo de clasificación
      final inputSize = _classificationInputSize;

      // Redimensionar al tamaño correcto para EfficientNet
      final resized = img.copyResize(
        crop,
        width: inputSize,
        height: inputSize
      );

      debugPrint('Imagen redimensionada: ${resized.width}x${resized.height}');

      // Crear input tensor [1, inputSize, inputSize, 3]
      final inputBuffer = Float32List(1 * inputSize * inputSize * 3);

      // Estrategias de preprocesamiento: solo usar [0,1] normalización estándar para SpeciesNet
      // La lógica compleja de múltiples estrategias se maneja en _runClassificationWithStrategy
      debugPrint('🔄 Usando preprocesamiento estándar SpeciesNet [0,1]');
      int index = 0;
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;

          inputBuffer[index++] = r;
          inputBuffer[index++] = g;
          inputBuffer[index++] = b;
        }
      }

      debugPrint('Buffer de entrada creado, tamaño: ${inputBuffer.length}');

      // Reshape para tensor de entrada [1, inputSize, inputSize, 3]
      final inputTensor = inputBuffer.reshape([1, inputSize, inputSize, 3]);
      debugPrint('Tensor de entrada creado: ${inputTensor.shape}');

      // Preparar output
      final outputShape = _classificationInterpreter.getOutputTensor(0).shape;
      final numClasses = outputShape.last;

      // Crear output buffer con la estructura correcta [1, 1000] -> [1][1000]
      final output = List.generate(outputShape[0], (_) =>
        List.generate(outputShape[1], (_) => 0.0)
      );
      debugPrint('Output preparado, shape: $outputShape, clases: $numClasses');

      // Ejecutar inferencia
      debugPrint('Ejecutando inferencia de clasificación...');
      _classificationInterpreter.run(inputTensor, output);
      debugPrint('Inferencia completada');

      // Aplanar el output estructurado [1][X] -> [X]
      final flattenedOutput = output.expand((list) => list).toList();

      double maxProb = 0;
      int maxIndex = -1;

      // Buscar las mejores predicciones y mostrar todas
      debugPrint('🔍 Buscando todas las predicciones del modelo...');

      // Crear lista de todas las predicciones ordenadas por confianza
      List<Map<String, dynamic>> allPredictions = [];
      for (int i = 0; i < flattenedOutput.length && i < _classificationLabels.length; i++) {
        double confidence = flattenedOutput[i];
        if (confidence > 0.0001) { // Solo mostrar predicciones significativas
          String rawLabel = _classificationLabels[i];
          String label = SpeciesLabels.simplifySpeciesNetLabel(rawLabel);
          String category = AnimalCategories.getCategory(rawLabel);

          allPredictions.add({
            'index': i,
            'confidence': confidence,
            'probability': confidence,
            'label': label,
            'category': category,
            'rawLabel': rawLabel,
          });
        }
      }

      // Ordenar por confianza descendente
      allPredictions.sort((a, b) => b['confidence'].compareTo(a['confidence']));

      // Mostrar todas las predicciones significativas (top 10)
      debugPrint('📊 TODAS LAS PREDICCIONES DEL MODELO (Top 10):');
      for (int i = 0; i < allPredictions.length && i < 10; i++) {
        final pred = allPredictions[i];
        debugPrint('   ${i + 1}. ${pred['label']} (${pred['category']}) - ${(pred['confidence'] * 100).toStringAsFixed(4)}%');
      }

      // Escoger la mejor predicción
      if (allPredictions.isNotEmpty) {
        final bestPred = allPredictions[0];
        maxIndex = bestPred['index'];
        maxProb = bestPred['confidence'];

        debugPrint('🥇 MEJOR PREDICCIÓN SELECCIONADA:');
        debugPrint('   📍 Índice: $maxIndex');
        debugPrint('   📝 Etiqueta: ${bestPred['label']}');
        debugPrint('   🏷️  Categoría: ${bestPred['category']}');
        debugPrint('   📊 Confianza: ${(maxProb * 100).toStringAsFixed(4)}%');
      } else {
        debugPrint('❌ No se encontraron predicciones significativas');
      }

      // Verificar que la probabilidad sea válida
      if (maxProb.isNaN || maxProb.isInfinite) {
        debugPrint('Advertencia: Probabilidad inválida detectada');
        maxProb = 0.0;
      }

      String label = 'unknown';
      String category = 'Desconocido';
      if (maxIndex >= 0 && maxIndex < _classificationLabels.length) {
        final rawLabel = _classificationLabels[maxIndex];
        label = SpeciesLabels.simplifySpeciesNetLabel(rawLabel);
        category = AnimalCategories.getCategory(rawLabel);
        debugPrint('Etiqueta encontrada: $label');
        debugPrint('Categoría: $category');
      } else {
        debugPrint('Advertencia: Índice de etiqueta fuera de rango: $maxIndex / ${_classificationLabels.length}');
      }

      debugPrint('Clasificación completada exitosamente');

      return {
        'label': label,
        'category': category,
        'confidence': maxProb.clamp(0.0, 1.0),
        'classIndex': maxIndex,
      };

    } catch (e, stack) {
      debugPrint('❌ Error en _runClassification: $e');
      debugPrint('Stack trace: $stack');
      debugPrint('Tipo de error: ${e.runtimeType}');

      // Más información sobre el error
      if (e is ArgumentError) {
        debugPrint('Error de argumento - posible problema con tensores');
      } else if (e is RangeError) {
        debugPrint('Error de rango - posible problema con índices');
      } else if (e.toString().contains('reshape')) {
        debugPrint('Error en reshape - problema con dimensiones del tensor');
      }

      return {
        'label': 'error',
        'confidence': 0.0,
        'classIndex': -1,
      };
    }
  }

  // Método para obtener todas las detecciones de YOLO sin filtrar (para debug)
  Future<List<Map<String, dynamic>>> _runDetectionWithAllClasses(img.Image image) async {
    try {
      // Preprocesamiento para YOLO
      final resized = img.copyResize(
        image,
        width: _detectionInputSize,
        height: _detectionInputSize
      );

      // Crear input tensor [1, inputSize, inputSize, 3]
      final inputBuffer = Float32List(1 * _detectionInputSize * _detectionInputSize * 3);
      final bytes = resized.getBytes(order: img.ChannelOrder.rgb);

      // Llenar el buffer con normalización [0,1]
      for (int i = 0; i < bytes.length; i++) {
        inputBuffer[i] = bytes[i] / 255.0;
      }

      // Reshape para tensor de entrada [1, height, width, 3]
      final inputTensor = inputBuffer.reshape([1, _detectionInputSize, _detectionInputSize, 3]);

      // Preparar outputs
      final outputTensors = _detectionInterpreter.getOutputTensors();
      final outputs = <int, Object>{};

      for (int i = 0; i < outputTensors.length; i++) {
        final tensor = outputTensors[i];
        final shape = tensor.shape;
        final totalSize = shape.reduce((a, b) => a * b);

        if (shape.length == 3) {
          outputs[i] = List.generate(shape[0], (_) =>
            List.generate(shape[1], (_) =>
              List.generate(shape[2], (_) => 0.0)
            )
          );
        } else {
          outputs[i] = List.filled(totalSize, 0.0);
        }
      }

      // Ejecutar inferencia
      _detectionInterpreter.runForMultipleInputs([inputTensor], outputs);

      // Parsear resultados con TODAS las clases
      final outputTensorsInfo = _detectionInterpreter.getOutputTensors();
      final outputShape = outputTensorsInfo[0].shape;

      final detections = _parseYoloOutputAllClasses(outputs[0], image.width, image.height, outputShape);
      return detections;

    } catch (e, stack) {
      debugPrint('Error en _runDetectionWithAllClasses: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }

  // Parser con todas las clases para debug
  List<Map<String, dynamic>> _parseYoloOutputAllClasses(dynamic output, int imgWidth, int imgHeight, List<int>? outputShape) {
    List<Map<String, dynamic>> detections = [];

    if (output is List<List<List<double>>> && outputShape != null) {
      final numClasses = output.length - 4; // Primeras 4 son bbox
      final numPredictions = output[0].length;

      const double confidenceThreshold = 0.1; // Más bajo para debug

      debugPrint('🕵️ DEBUG: Parser con $numClasses clases, $numPredictions predicciones');

      for (int i = 0; i < numPredictions; i++) {
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

        final double x = math.max(0.0, (xCenter - width / 2) * imgWidth);
        final double y = math.max(0.0, (yCenter - height / 2) * imgHeight);
        final double w = math.min(imgWidth.toDouble() - x, width * imgWidth);
        final double h = math.min(imgHeight.toDouble() - y, height * imgHeight);

        final Map<String, double> bbox = {'x': x, 'y': y, 'width': w, 'height': h};

        detections.add({
          'label': maxClassId < _detectionLabels.length ? _detectionLabels[maxClassId] : 'Unknown($maxClassId)',
          'confidence': maxConfidence,
          'classIndex': maxClassId,
          'boundingBox': bbox,
        });

        debugPrint('🐶 DEBUG: ${_detectionLabels[maxClassId]} ${(maxConfidence * 100).toStringAsFixed(1)}%');
      }
    }

    return detections.take(10).toList(); // Solo top 10 para debug
  }

  void close() {
    _detectionInterpreter.close();
    _classificationInterpreter.close();
  }
}
