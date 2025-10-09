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
              Padding(
                padding: const EdgeInsets.only(right: 164),
                child: Row(
                  children: [
                    TextButton.icon(
                      label: Text('Perfil'),
                      icon: Icon(Icons.person),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen()),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.black87),
                    ),
                    // Botón ir a logros
                    TextButton.icon(
                      label: Text('Logros'),
                      icon: Icon(Icons.star),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AchievementsScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.black87),
                    ),
                  ],
                ),
              ),
              // Botón ir a ajustes
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                  icon: Icon(Icons.settings),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
