import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../styles/colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF0F172A), // Dark Background
      Color(0xFF1E293B), // Card Dark
      Color(0xFF334155), // Surface Dark
      Color(0xFF475569), // Accent Dark
      Color(0xFF10B981), // Primary Green
    ],
  });

  final Widget child;
  final List<Color> colors;

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _connectionController;
  late AnimationController _flowController;

  late Animation<double> _particleAnimation;
  late Animation<double> _connectionAnimation;
  late Animation<double> _flowAnimation;

  // Partículas del sistema
  final List<_Particle> _particles = [];
  final List<_Connection> _connections = [];

  @override
  void initState() {
    super.initState();

    // Controladores para el sistema de partículas
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _connectionController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _flowController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );

    // Animaciones con curvas suaves
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    );

    _connectionAnimation = CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeInOut,
    );

    _flowAnimation = CurvedAnimation(
      parent: _flowController,
      curve: Curves.linear,
    );

    // Inicializar partículas
    _initializeParticles();

    // Iniciar animaciones después de un pequeño delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _particleController.repeat();
        _connectionController.repeat(reverse: true);
        _flowController.repeat();
      }
    });
  }

  void _initializeParticles() {
    try {
      final random = math.Random(42); // Seed para consistencia

      // Crear menos partículas para mejor performance
      for (int i = 0; i < 8; i++) {
        _particles.add(_Particle(
          id: i,
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 2.5 + random.nextDouble() * 2.0,
          speed: 0.2 + random.nextDouble() * 0.3,
          phase: random.nextDouble() * 2 * math.pi,
          color: widget.colors.isNotEmpty ? widget.colors[random.nextInt(widget.colors.length)] : Colors.green,
        ));
      }

      // Crear conexiones más simples
      for (int i = 0; i < _particles.length; i++) {
        for (int j = i + 1; j < _particles.length; j++) {
          final p1 = _particles[i];
          final p2 = _particles[j];
          final distance = math.sqrt(
            math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2)
          );

          if (distance < 0.5) { // Distancia mayor para menos conexiones
            _connections.add(_Connection(
              particle1: p1,
              particle2: p2,
              strength: (1.0 - distance).clamp(0.0, 1.0),
            ));
          }
        }
      }
    } catch (e) {
      // Fallback en caso de error
      _particles.clear();
      _connections.clear();
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _connectionController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _particleAnimation,
        _connectionAnimation,
        _flowAnimation
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                widget.colors[0].withOpacity(0.95),
                widget.colors[1].withOpacity(0.98),
                widget.colors[2].withOpacity(0.99),
              ],
              stops: const [0.0, 0.5, 1.0],
              center: Alignment.center,
              radius: 1.0,
            ),
          ),
          child: Stack(
            children: [
              // Sistema de ecosistema natural
              Positioned.fill(
                child: CustomPaint(
                  painter: _NaturalEcosystemPainter(
                    particles: _particles,
                    connections: _connections,
                    particleAnimation: _particleAnimation.value,
                    connectionAnimation: _connectionAnimation.value,
                    flowAnimation: _flowAnimation.value,
                  ),
                ),
              ),

              // Contenido
              widget.child,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

// Clase para representar partículas
class _Particle {
  final int id;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final Color color;

  const _Particle({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

// Clase para representar conexiones entre partículas
class _Connection {
  final _Particle particle1;
  final _Particle particle2;
  final double strength;

  const _Connection({
    required this.particle1,
    required this.particle2,
    required this.strength,
  });
}

// Pintor del sistema Flowing Curtain - Efecto elegante de cortinas
class _NaturalEcosystemPainter extends CustomPainter {
  final List<_Particle> particles;
  final List<_Connection> connections;
  final double particleAnimation;
  final double connectionAnimation;
  final double flowAnimation;

  _NaturalEcosystemPainter({
    required this.particles,
    required this.connections,
    required this.particleAnimation,
    required this.connectionAnimation,
    required this.flowAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Dibujar gradientes lineales simples arriba y abajo
    _drawSimpleLinearGradients(canvas, size);
  }

  void _drawSimpleLinearGradients(Canvas canvas, Size size) {
    // Gradiente superior
    final topRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.3);
    final topGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF10B981).withOpacity(0.4 + math.sin(flowAnimation * 2 * math.pi) * 0.1), // Verde con movimiento sutil
        const Color(0xFF3B82F6).withOpacity(0.3 + math.cos(flowAnimation * 1.5 * math.pi) * 0.1), // Azul con movimiento sutil
        Colors.transparent,
      ],
    );

    final topPaint = Paint()..shader = topGradient.createShader(topRect);
    canvas.drawRect(topRect, topPaint);

    // Gradiente inferior
    final bottomRect = Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3);
    final bottomGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF475569).withOpacity(0.3 + math.sin(flowAnimation * 1.8 * math.pi + math.pi) * 0.1), // Gris con movimiento sutil
        const Color(0xFF1E293B).withOpacity(0.4 + math.cos(flowAnimation * 2.2 * math.pi + math.pi) * 0.1), // Azul oscuro con movimiento sutil
        Colors.transparent,
      ],
    );

    final bottomPaint = Paint()..shader = bottomGradient.createShader(bottomRect);
    canvas.drawRect(bottomRect, bottomPaint);
  }

  Color _getGradientColor(int gradientIndex, int colorIndex) {
    // Colores dinámicos usando paleta WildSnap
    final colorSets = [
      [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF10B981)], // Oscuro → Verde
      [const Color(0xFF1E293B), const Color(0xFF334155), const Color(0xFF3B82F6)], // Azul oscuro → Azul
      [const Color(0xFF334155), const Color(0xFF475569), const Color(0xFF10B981)], // Gris → Verde
      [const Color(0xFF475569), const Color(0xFF0F172A), const Color(0xFF3B82F6)], // Gris azulado → Azul
      [const Color(0xFF10B981), const Color(0xFF3B82F6), const Color(0xFF1E293B)], // Verde → Azul → Oscuro
      [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFF334155)], // Azul → Verde → Gris
      [const Color(0xFF1E293B), const Color(0xFF10B981), const Color(0xFF475569)], // Oscuro → Verde → Gris
      [const Color(0xFF334155), const Color(0xFF3B82F6), const Color(0xFF0F172A)], // Gris → Azul → Oscuro
    ];

    return colorSets[gradientIndex % colorSets.length][colorIndex % 3];
  }

  Offset _calculateParticlePosition(_Particle particle, Size size, double animation) {
    // Movimiento natural como viento, corrientes, etc.
    final time = animation * 2 * math.pi * particle.speed;

    // Movimiento principal (como viento suave)
    final windX = math.sin(time + particle.phase) * 0.12;
    final windY = math.cos(time * 1.2 + particle.phase) * 0.08;

    // Turbulencias menores (como brisa)
    final turbulenceX = math.sin(time * 3.7) * 0.06;
    final turbulenceY = math.cos(time * 2.3) * 0.04;

    // Movimiento vertical adicional (flotación)
    final floatY = math.sin(time * 0.8 + particle.phase * 0.5) * 0.03;

    final x = (particle.x + windX + turbulenceX).clamp(0.0, 1.0);
    final y = (particle.y + windY + turbulenceY + floatY).clamp(0.0, 1.0);

    return Offset(x * size.width, y * size.height);
  }

  Offset _getPointOnQuadraticCurve(Offset start, Offset control, Offset end, double t) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;

    return Offset(
      uu * start.dx + 2 * u * t * control.dx + tt * end.dx,
      uu * start.dy + 2 * u * t * control.dy + tt * end.dy,
    );
  }

  @override
  bool shouldRepaint(_NaturalEcosystemPainter oldDelegate) {
    return oldDelegate.particleAnimation != particleAnimation ||
           oldDelegate.connectionAnimation != connectionAnimation ||
           oldDelegate.flowAnimation != flowAnimation;
  }
}
