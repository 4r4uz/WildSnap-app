import 'package:flutter/material.dart';

class ComunityScreen extends StatefulWidget {
  const ComunityScreen({super.key});

  @override
  State<ComunityScreen> createState() => _ComunityScreenState();
}

class _ComunityScreenState extends State<ComunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Pestaña de comunidad'),
      ),
    );
  }
}