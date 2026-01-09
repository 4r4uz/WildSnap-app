import 'package:flutter/material.dart';

class AppColors {
  // ====================
  // FONDOS NATURALES ELEGANTES
  // ====================
  static const Color backgroundPrimary = Color(0xFF0D1B2A);   // Azul noche profundo (oceano)
  static const Color backgroundSecondary = Color(0xFF1B263B); // Azul medianoche (cielo nocturno)
  static const Color surfacePrimary = Color(0xFF415A77);      // Azul grisáceo (nubes)
  static const Color surfaceSecondary = Color(0xFF778DA9);    // Azul claro (horizonte)

  // ====================
  // COLORES TEMÁTICOS
  // ====================

  // Verde IA - Tema principal
  static const Color iaPrimary = Color(0xFF00FF88);           // Verde neón IA
  static const Color iaSecondary = Color(0xFF00CCAA);         // Verde IA secundario
  static const Color iaSurface = Color(0xFF1A2E2A);           // Fondo verde IA

  // Azul navegación
  static const Color navPrimary = Color(0xFF667EEA);          // Azul navegación
  static const Color navSecondary = Color(0xFF764BA2);        // Púrpura navegación

  // Juegos - Tema vibrante
  static const Color gamePrimary = Color(0xFFFF6B6B);         // Rojo coral juegos
  static const Color gameSecondary = Color(0xFF4ECDC4);       // Turquesa juegos

  // Estadísticas
  static const Color statGold = Color(0xFFFFD93D);            // Oro estadísticas
  static const Color statGreen = Color(0xFF6BCF7F);           // Verde estadísticas
  static const Color statBlue = Color(0xFF4ECDC4);            // Azul estadísticas

  // Colores naturales temáticos
  static const Color forestGreen = Color(0xFF2D5016);         // Verde bosque profundo
  static const Color earthBrown = Color(0xFF8B4513);          // Marrón tierra
  static const Color skyBlue = Color(0xFF87CEEB);             // Azul cielo
  static const Color sunsetOrange = Color(0xFFFF8C42);        // Naranja atardecer
  static const Color riverBlue = Color(0xFF4682B4);           // Azul río
  static const Color mountainGray = Color(0xFF708090);        // Gris montaña

  // ====================
  // PALETA FUNCIONAL
  // ====================

  // Estados del servidor IA
  static const Color serverConnected = Color(0xFF00FF88);     // Verde conectado
  static const Color serverConnecting = Color(0xFFFFA500);    // Naranja conectando
  static const Color serverDisconnected = Color(0xFFFF4444);  // Rojo desconectado

  // Estados de carga
  static const Color loadingPrimary = Color(0xFF00FF88);      // Verde carga
  static const Color loadingSecondary = Color(0xFF667EEA);    // Azul carga

  // ====================
  // TEXTOS Y CONTENIDO
  // ====================
  static const Color textPrimary = Color(0xFFFFFFFF);         // Blanco principal
  static const Color textSecondary = Color(0xFFB3B3B3);       // Gris claro
  static const Color textMuted = Color(0xFF808080);           // Gris muted

  // ====================
  // BORDES Y DETALLES
  // ====================
  static const Color borderPrimary = Color(0xFF404040);       // Bordes principales
  static const Color borderSecondary = Color(0xFF303030);     // Bordes secundarios
  static const Color borderAccent = Color(0xFF505050);        // Bordes acento

  // ====================
  // GRADIENTES PREDEFINIDOS
  // ====================
  static const LinearGradient iaGradient = LinearGradient(
    colors: [iaPrimary, iaSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navGradient = LinearGradient(
    colors: [navPrimary, navSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gameGradient = LinearGradient(
    colors: [gamePrimary, gameSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient silhouetteGradient = LinearGradient(
    colors: [navPrimary, navSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient triviaGradient = LinearGradient(
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradientes naturales temáticos
  static const LinearGradient sunriseGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFF7931E), Color(0xFFFFD23F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ); // Amanecer (naranja-rojo-amarillo)

  static const LinearGradient forestGradient = LinearGradient(
    colors: [Color(0xFF2D5016), Color(0xFF4A7C59), Color(0xFF90A955)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ); // Bosque (verde oscuro a claro)

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ); // Océano profundo

  static const LinearGradient desertGradient = LinearGradient(
    colors: [Color(0xFFFFD23F), Color(0xFFFF8C42), Color(0xFF8B4513)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ); // Desierto (amarillo-naranja-marrón)

  static const LinearGradient mountainGradient = LinearGradient(
    colors: [Color(0xFF708090), Color(0xFF778DA9), Color(0xFF87CEEB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ); // Montañas (gris a azul cielo)

  // ====================
  // LEGACY COLORS (Mantener compatibilidad)
  // ====================
  static const Color darkBackground = backgroundPrimary;
  static const Color cardDark = surfacePrimary;
  static const Color surfaceDark = surfaceSecondary;
  static const Color accentDark = Color(0xFF475569);

  static const Color primary = iaPrimary;
  static const Color primaryLight = iaSecondary;
  static const Color primaryDark = Color(0xFF00AA66);

  static const Color secondary = navPrimary;
  static const Color secondaryLight = navSecondary;
  static const Color secondaryDark = Color(0xFF4C63D2);

  static const Color accentAmber = statGold;
  static const Color accentEmerald = statGreen;
  static const Color accentViolet = Color(0xFF8B5CF6);

  static const Color success = statGreen;
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = serverDisconnected;
  static const Color info = statBlue;
}
