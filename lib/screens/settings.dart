import 'package:flutter/material.dart';
import '../components/animated_gradient_background.dart';
import '../styles/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Configuración',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Settings List
              Expanded(
                child: ListView(
                  children: [
                    // Account Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.navGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cuenta',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.person,
                              color: AppColors.iaPrimary,
                            ),
                            title: Text(
                              'Perfil',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              'Editar información personal',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            onTap: () {},
                          ),
                          Divider(
                            color: AppColors.borderPrimary,
                            height: 1,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.lock,
                              color: AppColors.iaPrimary,
                            ),
                            title: Text(
                              'Privacidad',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              'Configurar privacidad',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.gameGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Aplicación',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: AppColors.statGold,
                            ),
                            title: Text(
                              'Notificaciones',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              'Configurar alertas',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            trailing: Switch(
                              value: true,
                              onChanged: (value) {},
                              activeThumbColor: AppColors.iaPrimary,
                            ),
                          ),
                          Divider(
                            color: AppColors.borderPrimary,
                            height: 1,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.language,
                              color: AppColors.statGold,
                            ),
                            title: Text(
                              'Idioma',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              'Español',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            onTap: () {},
                          ),
                          Divider(
                            color: AppColors.borderPrimary,
                            height: 1,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.dark_mode,
                              color: AppColors.statGold,
                            ),
                            title: Text(
                              'Tema',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              'Modo claro',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // About Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.triviaGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Sobre',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.info,
                              color: AppColors.riverBlue,
                            ),
                            title: Text(
                              'Versión',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              '1.0.0',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            onTap: () {},
                          ),
                          Divider(
                            color: AppColors.borderPrimary,
                            height: 1,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.help,
                              color: AppColors.riverBlue,
                            ),
                            title: Text(
                              'Ayuda',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            onTap: () {},
                          ),
                          Divider(
                            color: AppColors.borderPrimary,
                            height: 1,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.logout,
                              color: AppColors.serverDisconnected,
                            ),
                            title: Text(
                              'Cerrar Sesión',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
