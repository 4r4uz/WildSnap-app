import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import '../services/animal_service.dart';

class ImageClassifier {
  late Interpreter _interpreter;
  late List<String> _labels;

  ImageClassifier() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/modelo_animales.tflite');
    final labelsData = await rootBundle.loadString('assets/label_map.json');
    final Map<String, dynamic> labelsMap = json.decode(labelsData);
    _labels = List<String>.from(labelsMap.values);
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    final resized = img.copyResize(image, width: 224, height: 224);
    final input = Float32List(1 * 224 * 224 * 3);
    int bufferIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[bufferIndex++] = pixel.r / 255.0;
        input[bufferIndex++] = pixel.g / 255.0;
        input[bufferIndex++] = pixel.b / 255.0;
      }
    }

    // Reshape input to [1, 224, 224, 3] for the model
    final inputTensor = input.reshape([1, 224, 224, 3]);
    var output = List.filled(6, 0.0).reshape([1, 6]);
    _interpreter.run(inputTensor, output);

    final scores = output[0];
    int maxIndex = 0;
    double maxProb = 0;

    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxProb) {
        maxProb = scores[i];
        maxIndex = i;
      }
    }

    if (maxIndex >= _labels.length) {
      throw Exception('Índice de label fuera de rango');
    }

    final label = _labels[maxIndex];

    // Obtener información detallada del animal desde el servicio
    final animalService = AnimalService();
    final animalData = await animalService.getAnimalByName(label);

    return {
      'label': label,
      'confidence': (maxProb * 100).toStringAsFixed(2),
      'index': maxIndex,
      'animal_data': animalData, // Información completa del animal
    };
  }

  void close() {
    _interpreter.close();
  }
}
