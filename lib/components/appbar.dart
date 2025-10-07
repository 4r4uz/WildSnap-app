import 'package:flutter/material.dart';

import '../screens/achievements.dart';
import '../screens/profile.dart';
import '../screens/settings.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showActions;

  const AppBarComponent({
    super.key,
    required this.title,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
        ),
      ),
      actions: showActions
          ? [
              // Botón ir a perfil
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                icon: Icon(Icons.person),
              ),
              // Botón ir a logros
              IconButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementsScreen()));
              }, icon: Icon(Icons.star)),
              // Botón ir a ajustes
              IconButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
              }, icon: Icon(Icons.settings)),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
