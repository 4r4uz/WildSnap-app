import 'package:flutter/material.dart';
import 'services/animal_service.dart';
import 'components/navigation_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar datos de animales
  final animalService = AnimalService();
  await animalService.initializeAnimalsData();

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
