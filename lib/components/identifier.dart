import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';

class ImageClassifier {
  late Interpreter _interpreter;
  late List<String> _labels;

  ImageClassifier() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    // Cargar TFLite
    _interpreter = await Interpreter.fromAsset('assets/mobilenet_v2.tflite');

    // Cargar labels
    final labelsData =
        await rootBundle.loadString('assets/labels_mobilenet.txt');
    _labels = LineSplitter.split(labelsData).toList();
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    // Decodificar la imagen
    final image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) {
      throw Exception('No se pudo leer la imagen');
    }

    // Redimensionar la imagen a 224x224
    final resized = img.copyResize(image, width: 224, height: 224);

    final input = Float32List(1 * 224 * 224 * 3);
    int bufferIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[bufferIndex++] = img.getRed(pixel) / 255.0;
        input[bufferIndex++] = img.getGreen(pixel) / 255.0;
        input[bufferIndex++] = img.getBlue(pixel) / 255.0;
      }
    }

    final inputTensor = input.reshape([1, 224, 224, 3]);
    final output = Float32List(1001).reshape([1, 1001]);
    _interpreter.run(inputTensor, output);

    // etiqueta con mayor probabilidad
    final scores = output[0];
    int maxIndex = 0;
    double maxProb = 0;
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxProb) {
        maxProb = scores[i];
        maxIndex = i;
      }
    }

    return {
      'label': _labels[maxIndex],
      'confidence': (maxProb * 100).toStringAsFixed(2),
    };
  }

  void close() {
    _interpreter.close();
  }
}
