import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AnimalService {
  static final AnimalService _instance = AnimalService._internal();
  factory AnimalService() => _instance;
  AnimalService._internal();

  static const String _animalsCacheKey = 'animals_data';

  // Datos de los animales que identifica el modelo
  final List<Map<String, dynamic>> _animalsData = [
    {
      'id': 1,
      'nombre_comun': 'Perro',
      'nombre_cientifico': 'Canis lupus familiaris',
      'descripcion': 'El perro doméstico es un mamífero carnívoro de la familia de los cánidos. Es uno de los animales más antiguos domesticados por el ser humano.',
      'habitat': 'Doméstico, urbano y rural',
      'alimentacion': 'Omnívoro - carne, vegetales, alimentos procesados',
      'estado_conservacion': 'Doméstico',
      'region': 'Global',
      'curiosidades': [
        'Los perros tienen más de 300 razas diferentes',
        'Pueden detectar olores a distancias increíbles',
        'Tienen un sentido del olfato 10,000 veces más agudo que los humanos'
      ],
      'imagen_url': null,
      'categoria': 'Mamífero doméstico'
    },
    {
      'id': 2,
      'nombre_comun': 'Gato',
      'nombre_cientifico': 'Felis catus',
      'descripcion': 'El gato doméstico es un mamífero carnívoro de la familia Felidae. Es uno de los animales de compañía más populares del mundo.',
      'habitat': 'Doméstico, urbano y rural',
      'alimentacion': 'Carnívoro - carne, pescado, alimentos procesados para gatos',
      'estado_conservacion': 'Doméstico',
      'region': 'Global',
      'curiosidades': [
        'Los gatos pasan aproximadamente el 70% de su vida durmiendo',
        'Pueden saltar hasta 6 veces la longitud de su cuerpo',
        'Tienen más de 500 músculos esqueléticos'
      ],
      'imagen_url': null,
      'categoria': 'Mamífero doméstico'
    },
    {
      'id': 3,
      'nombre_comun': 'Pájaro',
      'nombre_cientifico': 'Aves',
      'descripcion': 'Los pájaros son aves que pertenecen a la clase Aves. Son vertebrados endotérmicos con plumas y pico córneo.',
      'habitat': 'Terrestre, aéreo, acuático según la especie',
      'alimentacion': 'Varía según la especie - semillas, insectos, frutas, peces',
      'estado_conservacion': 'Varía por especie',
      'region': 'Global',
      'curiosidades': [
        'Existen más de 10,000 especies de pájaros en el mundo',
        'Los pájaros son los únicos animales con plumas',
        'Algunos pájaros pueden volar a altitudes de más de 8,000 metros'
      ],
      'imagen_url': null,
      'categoria': 'Ave'
    },
    {
      'id': 4,
      'nombre_comun': 'Cóndor',
      'nombre_cientifico': 'Vultur gryphus',
      'descripcion': 'El cóndor andino es una de las aves voladoras más grandes del mundo. Es un ave carroñera que habita en la cordillera de los Andes.',
      'habitat': 'Regiones montañosas de los Andes, alturas de 3,000-5,000 metros',
      'alimentacion': 'Carroñero - se alimenta de animales muertos',
      'estado_conservacion': 'Vulnerable',
      'region': 'Sudamérica (Chile, Argentina, Perú, Ecuador, Colombia)',
      'curiosidades': [
        'Es el ave voladora más pesada del mundo',
        'Puede tener una envergadura de hasta 3.3 metros',
        'Puede vivir hasta 50 años en estado salvaje'
      ],
      'imagen_url': null,
      'categoria': 'Ave carroñera'
    },
    {
      'id': 5,
      'nombre_comun': 'Pudú',
      'nombre_cientifico': 'Pudu puda',
      'descripcion': 'El pudú es el ciervo más pequeño del mundo. Es un mamífero rumiante que habita en los bosques templados del sur de Chile y Argentina.',
      'habitat': 'Bosques templados húmedos, matorrales densos',
      'alimentacion': 'Hervívoro - hojas, brotes, frutas, hongos',
      'estado_conservacion': 'Vulnerable',
      'region': 'Chile y Argentina (región sur)',
      'curiosidades': [
        'Es el ciervo más pequeño del mundo, mide solo 30-40 cm de altura',
        'Su nombre significa "trueno" en mapudungun',
        'Es un excelente saltador y trepador'
      ],
      'imagen_url': null,
      'categoria': 'Mamífero rumiante'
    },
    {
      'id': 6,
      'nombre_comun': 'Huemul',
      'nombre_cientifico': 'Hippocamelus bisulcus',
      'descripcion': 'El huemul del sur es un ciervo endémico de la Patagonia chilena y argentina. Es un símbolo nacional de Chile y se encuentra en peligro de extinción.',
      'habitat': 'Bosques patagónicos, áreas montañosas, valles fluviales',
      'alimentacion': 'Hervívoro - pastos, arbustos, líquenes, corteza de árboles',
      'estado_conservacion': 'En peligro crítico',
      'region': 'Chile y Argentina (Patagonia)',
      'curiosidades': [
        'Es el símbolo nacional de Chile',
        'Es un excelente nadador y puede cruzar ríos caudalosos',
        'Su población en estado salvaje es de menos de 2,000 individuos'
      ],
      'imagen_url': null,
      'categoria': 'Mamífero rumiante'
    }
  ];

  Future<void> initializeAnimalsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_animalsCacheKey);

      if (existingData == null) {
        // Si no hay datos, insertar los datos iniciales
        await prefs.setString(_animalsCacheKey, json.encode(_animalsData));
        print('✅ Datos de animales inicializados correctamente');
      } else {
        // Verificar si necesitamos actualizar datos
        final List<dynamic> currentData = json.decode(existingData);
        if (currentData.length != _animalsData.length) {
          await prefs.setString(_animalsCacheKey, json.encode(_animalsData));
          print('🔄 Datos de animales actualizados');
        }
      }
    } catch (e) {
      print('❌ Error inicializando datos de animales: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllAnimals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_animalsCacheKey);

      if (data != null) {
        final List<dynamic> animals = json.decode(data);
        return animals.map((animal) => Map<String, dynamic>.from(animal)).toList();
      }
    } catch (e) {
      print('❌ Error obteniendo datos de animales: $e');
    }

    return [];
  }

  Future<Map<String, dynamic>?> getAnimalByName(String name) async {
    final animals = await getAllAnimals();
    try {
      return animals.firstWhere(
        (animal) => animal['nombre_comun'].toString().toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAnimalById(int id) async {
    final animals = await getAllAnimals();
    try {
      return animals.firstWhere((animal) => animal['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAnimalsByCategory(String category) async {
    final animals = await getAllAnimals();
    return animals.where((animal) => animal['categoria'] == category).toList();
  }

  Future<List<Map<String, dynamic>>> getEndangeredAnimals() async {
    final animals = await getAllAnimals();
    return animals.where((animal) =>
      animal['estado_conservacion'] == 'En peligro crítico' ||
      animal['estado_conservacion'] == 'Vulnerable'
    ).toList();
  }

  Future<void> updateAnimalData(int id, Map<String, dynamic> updates) async {
    try {
      final animals = await getAllAnimals();
      final index = animals.indexWhere((animal) => animal['id'] == id);

      if (index != -1) {
        animals[index].addAll(updates);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_animalsCacheKey, json.encode(animals));
        print('✅ Datos del animal actualizados');
      }
    } catch (e) {
      print('❌ Error actualizando datos del animal: $e');
    }
  }

  Future<void> clearAnimalsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_animalsCacheKey);
      print('🗑️ Datos de animales eliminados');
    } catch (e) {
      print('❌ Error eliminando datos de animales: $e');
    }
  }

  // Método para obtener estadísticas
  Future<Map<String, dynamic>> getAnimalsStats() async {
    final animals = await getAllAnimals();
    final endangered = await getEndangeredAnimals();

    return {
      'total_animals': animals.length,
      'endangered_animals': endangered.length,
      'categories': animals.map((a) => a['categoria']).toSet().length,
      'regions': animals.map((a) => a['region']).toSet().toList(),
    };
  }
}
