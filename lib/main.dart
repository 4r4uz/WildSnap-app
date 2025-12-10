import 'package:flutter/material.dart';
import 'services/animal_service.dart';
import 'components/navigation_menu.dart';
import 'components/image_analizer.dart';
import 'components/detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar datos de animales
  final animalService = AnimalService();
  await animalService.initializeAnimalsData();

  // Cargar modelos de IA al iniciar la app
  try {
    debugPrint('🧠 Cargando modelos de IA...');
    await SpeciesClassifier().loadModel();
    debugPrint('✅ Modelo de clasificación cargado');

    await YOLOv11Detector().loadModel();
    debugPrint('✅ Modelo de detección cargado');
  } catch (e) {
    debugPrint('❌ Error al cargar modelos: $e');
  }

  runApp(MainApp()); // Inicia la app
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // Nuevo menú de navegación
        body: SafeArea(child: NavigationMenu()),
      ),
    );
  }
  
}
