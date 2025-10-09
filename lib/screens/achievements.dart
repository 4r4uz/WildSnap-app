import 'package:flutter/material.dart';
import 'package:wildsnap/components/appbar.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(title: 'Logros'),
      body: Center(
        child: Text('pestaña de logros'),
      ),
    );
  }
}