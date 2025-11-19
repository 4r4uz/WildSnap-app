import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
        children: [
          const ListTile(
            title: Text('Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            subtitle: const Text('Editar información personal'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacidad'),
            subtitle: const Text('Configurar privacidad'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          const Divider(),
          const ListTile(
            title: Text('Aplicación', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            subtitle: const Text('Configurar alertas'),
            trailing: Switch(value: true, onChanged: (value) {}),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: const Text('Español'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Tema'),
            subtitle: const Text('Modo claro'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          const Divider(),
          const ListTile(
            title: Text('Sobre', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Versión'),
            subtitle: const Text('1.0.0'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ayuda'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {},
          ),
        ],
        ),
      ),
    );
  }
}
