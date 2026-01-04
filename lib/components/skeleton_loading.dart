import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final Widget? child;
  final bool isLoading;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final bool enableShimmer;

  const SkeletonLoading({
    super.key,
    this.child,
    this.isLoading = true,
    this.decoration,
    this.padding,
    this.margin,
    this.borderRadius = 8.0,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1000),
    this.enableShimmer = true,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child ?? const SizedBox.shrink();
    }

    return Container(
      padding: widget.padding,
      margin: widget.margin,
      decoration: widget.decoration ??
          BoxDecoration(
            color: widget.baseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
      child: widget.enableShimmer
          ? AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        widget.baseColor,
                        widget.highlightColor,
                        widget.baseColor,
                      ],
                      stops: [
                        0.0,
                        _animation.value * 0.5 + 0.5,
                        1.0,
                      ],
                    ).createShader(bounds);
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                );
              },
            )
          : Container(
              decoration: BoxDecoration(
                color: widget.baseColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
    );
  }
}

// Componentes específicos para diferentes tipos de contenido
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final int lines;
  final double lineSpacing;
  final Color baseColor;
  final Color highlightColor;
  final double borderRadius;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 12.0,
    this.lines = 1,
    this.lineSpacing = 8.0,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        return Container(
          margin: EdgeInsets.only(bottom: index < lines - 1 ? lineSpacing : 0),
          child: SkeletonLoading(
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: SizedBox(
              width: index == lines - 1 && lines > 1
                  ? width * 0.7 // Última línea más corta
                  : width,
              height: height,
            ),
          ),
        );
      }),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double radius;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonCircle({
    super.key,
    this.radius = 24.0,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      decoration: BoxDecoration(
        color: baseColor,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
      ),
    );
  }
}

class SkeletonRectangle extends StatelessWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final double borderRadius;

  const SkeletonRectangle({
    super.key,
    this.width = double.infinity,
    this.height = 100.0,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: SizedBox(
        width: width,
        height: height,
      ),
    );
  }
}

// Skeleton especializado para tarjetas de detalles de animales
class AnimalDetailSkeleton extends StatelessWidget {
  const AnimalDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header con botones
          Row(
            children: [
              SkeletonCircle(radius: 16),
              const Spacer(),
              SkeletonRectangle(width: 60, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 20),

          // Imagen principal
          SkeletonRectangle(height: 280, borderRadius: 20),
          const SizedBox(height: 24),

          // Información del animal
          SkeletonRectangle(height: 120, borderRadius: 20),
          const SizedBox(height: 16),

          // Habitat
          SkeletonRectangle(height: 100, borderRadius: 12),
          const SizedBox(height: 12),

          // Conservación
          SkeletonRectangle(height: 100, borderRadius: 12),
          const SizedBox(height: 16),

          // Datos curiosos
          SkeletonRectangle(height: 80, borderRadius: 12),
          const SizedBox(height: 20),

          // Mapa
          SkeletonRectangle(height: 200, borderRadius: 24),
          const SizedBox(height: 20),

          // Botones de acción
          Row(
            children: [
              Expanded(child: SkeletonRectangle(height: 60, borderRadius: 20)),
              const SizedBox(width: 16),
              Expanded(child: SkeletonRectangle(height: 60, borderRadius: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget que maneja carga con skeleton automático
class LoadableContent extends StatefulWidget {
  final Future<void> Function() loader;
  final Widget skeleton;
  final Widget content;
  final Widget? errorWidget;
  final Duration? timeout;

  const LoadableContent({
    super.key,
    required this.loader,
    required this.skeleton,
    required this.content,
    this.errorWidget,
    this.timeout,
  });

  @override
  State<LoadableContent> createState() => _LoadableContentState();
}

class _LoadableContentState extends State<LoadableContent> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      await widget.loader();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ??
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text('Error al cargar datos'),
              ],
            ),
          );
    }

    return _isLoading ? widget.skeleton : widget.content;
  }
}
