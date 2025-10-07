import 'package:flutter/material.dart';
import 'package:frontend/screens/home.dart';

void main() {
  runApp(MainApp()); // Inicia la app
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
            ),
          ),
          actions: [
            // Botón ir a perfil
            IconButton(onPressed: () {}, icon: Icon(Icons.person)),
            // Botón ir a logros
            IconButton(onPressed: () {}, icon: Icon(Icons.star)),
            // Botón ir a ajustes
            IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
          ],
        ),
        body: HomeScreen(),
      ),
    );
  }
}
