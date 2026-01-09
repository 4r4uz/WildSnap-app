import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CuriosityCarousel extends StatefulWidget {
  const CuriosityCarousel({super.key});

  @override
  State<CuriosityCarousel> createState() => _CuriosityCarouselState();
}

class _CuriosityCarouselState extends State<CuriosityCarousel> with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;
  bool _isVisible = true; // Asumir visible inicialmente

  final List<Map<String, dynamic>> _curiositiesAndTips = [
    {
      'type': 'fact',
      'content': 'Los elefantes pueden reconocer a más de 30 compañeros por su olor.',
      'icon': Icons.lightbulb_outline,
      'color': Color(0xFF2D5016), // Verde bosque
    },
    {
      'type': 'tip',
      'content': 'Reduce tu huella de carbono evitando plásticos de un solo uso.',
      'icon': Icons.eco,
      'color': Color(0xFF4682B4), // Azul río
    },
    {
      'type': 'fact',
      'content': 'Los leones duermen hasta 20 horas al día.',
      'icon': Icons.lightbulb_outline,
      'color': Color(0xFFFF8C42), // Naranja atardecer
    },
    {
      'type': 'tip',
      'content': 'Apoya la conservación de habitats naturales.',
      'icon': Icons.eco,
      'color': Color(0xFF708090), // Gris montaña
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_pageController.hasClients && _isVisible && mounted) {
        _currentPage = (_currentPage + 1) % _curiositiesAndTips.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    final visibleFraction = info.visibleFraction;
    final wasVisible = _isVisible;
    _isVisible = visibleFraction > 0.1; // Considerar visible si más del 10% es visible

    // Solo hacer cambios si el estado de visibilidad cambió
    if (wasVisible != _isVisible) {
      if (_isVisible) {
        debugPrint('🎠 CuriosityCarousel visible - reanudando auto-scroll');
      } else {
        debugPrint('🎠 CuriosityCarousel no visible - pausando auto-scroll');
      }
    }
  }

  Widget _buildCuriosityCard(Map<String, dynamic> item, int index) {
    final isActive = index == _currentPage;
    final isFact = item['type'] == 'fact';
    final title = isFact ? 'Dato Curioso' : 'Consejo Ecológico';
    final color = item['color'] as Color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: isActive ? 0 : 10,
      ),
      child: Transform.scale(
        scale: isActive ? 1.0 : 0.95,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.4),
                color.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isActive ? 0.3 : 0.1),
                blurRadius: isActive ? 25 : 15,
                offset: Offset(0, isActive ? 10 : 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['content'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.3,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_curiositiesAndTips.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: index == _currentPage ? 20 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == _currentPage
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('curiosity_carousel'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _curiositiesAndTips.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildCuriosityCard(_curiositiesAndTips[index], index);
              },
            ),
          ),
          _buildIndicator(),
        ],
      ),
    );
  }
}
