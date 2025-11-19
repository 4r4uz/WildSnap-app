import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/services/animal_service.dart';

void main() async {
  // Simular SharedPreferences para testing
  SharedPreferences.setMockInitialValues({});

  print('🧪 Probando inserción de datos de animales...\n');

  final animalService = AnimalService();

  // Inicializar datos
  await animalService.initializeAnimalsData();

  // Obtener todos los animales
  final animals = await animalService.getAllAnimals();
  print('📊 Total de animales en la base de datos: ${animals.length}');

  // Mostrar información de cada animal
  for (final animal in animals) {
    print('\n🐾 ${animal['nombre_comun']} (${animal['nombre_cientifico']})');
    print('   📍 Región: ${animal['region']}');
    print('   🏞️ Hábitat: ${animal['habitat']}');
    print('   🍽️ Alimentación: ${animal['alimentacion']}');
    print('   ⚠️ Estado: ${animal['estado_conservacion']}');
    print('   📝 Descripción: ${animal['descripcion'].substring(0, 100)}...');
    print('   🎯 Curiosidades: ${animal['curiosidades'].length} datos');
  }

  // Probar búsqueda por nombre
  print('\n🔍 Probando búsqueda por nombre:');
  final puduData = await animalService.getAnimalByName('pudu');
  if (puduData != null) {
    print('✅ Pudú encontrado: ${puduData['nombre_cientifico']}');
  }

  // Obtener animales en peligro
  final endangered = await animalService.getEndangeredAnimals();
  print('\n🚨 Animales en peligro de extinción: ${endangered.length}');
  for (final animal in endangered) {
    print('   - ${animal['nombre_comun']} (${animal['estado_conservacion']})');
  }

  // Estadísticas
  final stats = await animalService.getAnimalsStats();
  print('\n📈 Estadísticas:');
  print('   Total: ${stats['total_animals']}');
  print('   En peligro: ${stats['endangered_animals']}');
  print('   Categorías: ${stats['categories']}');
  print('   Regiones: ${stats['regions']}');

  print('\n✅ Prueba completada exitosamente!');
}
