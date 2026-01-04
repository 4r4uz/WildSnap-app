import 'package:flutter/material.dart';
import 'components/navigation_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
