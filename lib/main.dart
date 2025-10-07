import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'components/appbar.dart';

void main() {
  runApp(MainApp()); // Inicia la app
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBarComponent(title: '', showActions: true,),
        body: HomeScreen()
      ),
    );
  }
}
