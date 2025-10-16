import 'package:flutter/material.dart';

import 'components/appbar.dart';
import 'components/bottom_bar.dart';

void main() {
  runApp(MainApp()); // Inicia la app
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // Barrita de arriba en lib/components/appbar.dart
        appBar: AppBarComponent(title: '', showActions: true),

        // Barra de abajo en lib/components/bottom_bar.dart
        body: BottomBarComponent(),       
      ),
    );
  }
}
