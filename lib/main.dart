import 'package:flutter/material.dart';
import 'package:frontend/core/colors.dart';
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
          title: Text(
            'Reconocer Animales',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
        ),
        body: HomeScreen(),
      ),
    );
  }
}
