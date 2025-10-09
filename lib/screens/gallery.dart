import 'package:flutter/material.dart';
import 'package:wildsnap/components/appbar.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(title: 'Colección'),
      body: Center(child: Text('Pantalla de Galería')),
    );
  }
}