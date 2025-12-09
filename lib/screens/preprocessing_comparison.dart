import 'package:flutter/material.dart';

class PreprocessingComparisonScreen extends StatelessWidget {
  final Map<String, dynamic> comparisonResults;
  final String bestStrategy;

  const PreprocessingComparisonScreen({
    super.key,
    required this.comparisonResults,
    required this.bestStrategy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparación de Estrategias'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.compare_arrows,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Resultado de las 3 Estrategias',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Análisis usando la imagen capturada por cámara',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Mejor estrategia: ${_getStrategyName(bestStrategy)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resultados individuales
              _buildStrategyResult(
                '🧠 ImageNet Estándar',
                'imagenet_standard',
                Icons.memory,
                Colors.blue,
              ),

              const SizedBox(height: 16),

              _buildStrategyResult(
                '🎯 Suave para Especies',
                'species_soft',
                Icons.adjust,
                Colors.orange,
              ),

              const SizedBox(height: 16),

              _buildStrategyResult(
                '🔢 Básico [0,1]',
                'basic_norm',
                Icons.grid_3x3,
                Colors.purple,
              ),

              const SizedBox(height: 24),

              // Información adicional
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 Información Técnica:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('• YOLOv8 detector funcionando correctamente'),
                      const Text('• SpeciesNet clasificando especies usando diferentes preprocesamientos'),
                      const Text('• ImageNet Estándar: (pixel/255 - mean) / std con valores estándar'),
                      const Text('• Suave para Especies: mean/std más suaves (0.5, 0.5)'),
                      const Text('• Básico [0,1]: solo normalización sin ajuste mean/std'),
                      const SizedBox(height: 8),
                      Text(
                        'Mejor estrategia recomendada: ${_getStrategyName(bestStrategy)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyResult(String title, String key, IconData icon, Color color) {
    final result = comparisonResults[key] as Map<String, dynamic>? ?? {};
    final status = result['status'] as String? ?? 'error';

    if (status != 'success') {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.red.shade200, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.red, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Error al procesar',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.error, color: Colors.red),
            ],
          ),
        ),
      );
    }

    final label = result['label'] as String? ?? 'Desconocido';
    final confidence = result['confidence'] as String? ?? '0.00';
    final isBest = bestStrategy == key;

    return Card(
      elevation: isBest ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBest ? Colors.green.shade300 : Colors.grey.shade300,
          width: isBest ? 3 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBest ? Colors.green.shade100 : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (isBest) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'MEJOR',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Resultado: $label',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Confianza: $confidence%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getConfidenceColor(double.parse(confidence)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getConfidenceColor(double.parse(confidence)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$confidence%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getConfidenceColor(double.parse(confidence)),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStrategyName(String key) {
    switch (key) {
      case 'imagenet_standard':
        return 'ImageNet Estándar';
      case 'species_soft':
        return 'Suave para Especies';
      case 'basic_norm':
        return 'Básico [0,1]';
      default:
        return key;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 50) return Colors.green;
    if (confidence >= 25) return Colors.orange;
    return Colors.red;
  }
}
