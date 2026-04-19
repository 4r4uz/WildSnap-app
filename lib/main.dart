import 'package:flutter/material.dart';
import 'components/bottom_navigation.dart';
import 'utils/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WildSnapApp());
}

class WildSnapApp extends StatelessWidget {
  const WildSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildSnap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const BottomNavigation(),
    );
  }
}
