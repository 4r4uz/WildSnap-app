import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              color: Colors.blue[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Juan Pérez',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('@juan_nature'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat('Avistamientos', '42'),
                      _buildStat('Especies', '15'),
                      _buildStat('Logros', '8'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sobre mí',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Apasionado por la naturaleza y la fotografía de vida silvestre. Me encanta compartir mis avistamientos con la comunidad.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Editar Perfil'),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Logros',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildAchievementsGrid(),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    final List<Map<String, dynamic>> achievements = [
      {'icon': Icons.camera, 'title': 'Primer Avistamiento', 'description': 'Toma tu primera foto', 'unlocked': true},
      {'icon': Icons.group, 'title': 'Comunidad', 'description': 'Comparte 5 publicaciones', 'unlocked': true},
      {'icon': Icons.star, 'title': 'Explorador', 'description': 'Visita 10 ubicaciones', 'unlocked': true},
      {'icon': Icons.eco, 'title': 'Protector', 'description': 'Identifica 20 especies', 'unlocked': false},
      {'icon': Icons.photo_album, 'title': 'Fotógrafo', 'description': 'Sube 50 fotos', 'unlocked': false},
      {'icon': Icons.leaderboard, 'title': 'Experto', 'description': 'Alcanza nivel 10', 'unlocked': false},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Card(
          color: achievement['unlocked'] ? Colors.yellow[100] : Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  achievement['icon'],
                  size: 40,
                  color: achievement['unlocked'] ? Colors.amber : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: achievement['unlocked'] ? Colors.black : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: achievement['unlocked'] ? Colors.black54 : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
