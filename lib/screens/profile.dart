import 'package:flutter/material.dart';
import '../components/appbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(title: 'Perfil'),
      body: Center(
        child: Text('Pestaña de perfil'),
      ),
    );
  }
}