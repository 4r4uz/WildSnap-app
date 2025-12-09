import 'package:flutter/material.dart';

class LazyImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? placeholderText;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double borderRadius;
  final bool useHero;
  final String? heroTag;

  const LazyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderText,
    this.placeholder,
    this.errorWidget,
    this.borderRadius = 8.0,
    this.useHero = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              ImagePlaceholder(
                width: width,
                height: height,
                text: placeholderText ?? 'Cargando...',
                borderRadius: borderRadius,
              );
        },
        errorBuilder: (context, error, stackTrace) => errorWidget ??
            ImageErrorWidget(
              width: width,
              height: height,
              borderRadius: borderRadius,
            ),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );

    if (useHero && heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

class ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final String text;
  final double borderRadius;

  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    required this.text,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ImageErrorWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const ImageErrorWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 32,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            'Imagen no disponible',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
