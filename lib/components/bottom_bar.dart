import 'package:flutter/material.dart';
import '../screens/home.dart';
import '../screens/comunity.dart';

class BottomBarComponent extends StatefulWidget {
  const BottomBarComponent({super.key});

  @override
  State<BottomBarComponent> createState() => _BottomBarComponentState();
}

class _BottomBarComponentState extends State<BottomBarComponent> {
  int myIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),     // tu pantalla principal
    ComunityScreen(), // o el nombre real de tu pantalla de comunidad
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[myIndex], // muestra la pantalla actual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account),
            label: 'Comunidad',
          ),
        ],
        iconSize: 32,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
