import 'package:flutter/material.dart';
import '../components/animated_gradient_background.dart';
import '../styles/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: AppColors.navGradient,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.textPrimary,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.backgroundPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Juan Pérez',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '@juan_nature',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
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
                      Text(
                        'Sobre mí',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Apasionado por la naturaleza y la fotografía de vida silvestre. Me encanta compartir mis avistamientos con la comunidad.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.iaPrimary,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: const Text('Editar Perfil'),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Logros',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
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
          color: achievement['unlocked'] ? AppColors.statGold.withValues(alpha: 0.3) : AppColors.surfaceSecondary,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  achievement['icon'],
                  size: 40,
                  color: achievement['unlocked'] ? AppColors.statGold : AppColors.textMuted,
                ),
                const SizedBox(height: 8),
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: achievement['unlocked'] ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: achievement['unlocked'] ? AppColors.textSecondary : AppColors.textMuted,
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
