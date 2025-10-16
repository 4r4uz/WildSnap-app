import 'package:flutter/material.dart';
import '../components/appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(title: 'Ajustes'),
      body: Center(
        child: Text('Aquí van los ajustes de la aplicación'),
      ),
    );
  }
}