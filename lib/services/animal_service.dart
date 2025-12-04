import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnimalService {
  static final AnimalService _instance = AnimalService._internal();
  factory AnimalService() => _instance;
  AnimalService._internal();

  static const String _animalsCacheKey = 'animals_data';

  // Datos de los animales que identifica el modelo YOLO
  final List<Map<String, dynamic>> _animalsData = [
    {
      'id': 1,
      'nombre_comun': 'Puma',
      'nombre_cientifico': 'Puma concolor',
      'descripcion': 'El puma es un felino grande y solitario, también conocido como león de montaña. Es uno de los félidos más ampliamente distribuidos en América.',
      'habitat': 'Bosques, montañas, desiertos y áreas abiertas',
      'alimentacion': 'Carnívoro - caza ciervos, guanacos y otros mamíferos medianos',
      'estado_conservacion': 'Preocupación menor',
      'region': 'América (desde Canadá hasta el sur de Chile y Argentina)',
      'curiosidades': [
        'Puede saltar hasta 6 metros de distancia',
        'Es un excelente trepador de árboles',
        'Puede vivir hasta 20 años en estado salvaje'
      ],
      'imagen_url': null,
      'categoria': 'Felino'
    },
    {
      'id': 2,
      'nombre_comun': 'Zorro',
      'nombre_cientifico': 'Lycalopex culpaeus',
      'descripcion': 'El zorro culpeo es una especie de cánido nativo de América del Sur. Es el zorro más grande del continente.',
      'habitat': 'Regiones montañosas, bosques y áreas abiertas',
      'alimentacion': 'Omnívoro - pequeños mamíferos, aves, frutas e insectos',
      'estado_conservacion': 'Preocupación menor',
      'region': 'Sudamérica (Chile, Argentina, Perú, Ecuador)',
      'curiosidades': [
        'Es un excelente cazador nocturno',
        'Puede vivir en altitudes de hasta 4,800 metros',
        'Su pelaje cambia de color según la temporada'
      ],
      'imagen_url': null,
      'categoria': 'Cánido'
    },
    {
      'id': 3,
      'nombre_comun': 'Guanaco',
      'nombre_cientifico': 'Lama guanicoe',
      'descripcion': 'El guanaco es un camélido salvaje nativo de América del Sur. Es el antepasado silvestre de la llama.',
      'habitat': 'Regiones áridas y semiáridas de la Patagonia',
      'alimentacion': 'Hervívoro - pastos, arbustos y vegetación dura',
      'estado_conservacion': 'Preocupación menor',
      'region': 'Sudamérica (Chile, Argentina, Perú, Bolivia)',
      'curiosidades': [
        'Puede vivir sin beber agua por largos períodos',
        'Corre a velocidades de hasta 56 km/h',
        'Vive en manadas organizadas jerárquicamente'
      ],
      'imagen_url': null,
      'categoria': 'Camélido'
    },
    {
      'id': 4,
      'nombre_comun': 'Chinchilla',
      'nombre_cientifico': 'Chinchilla lanigera',
      'descripcion': 'La chinchilla es un roedor pequeño nativo de los Andes. Es conocida por su pelaje extremadamente suave.',
      'habitat': 'Regiones rocosas y montañosas de los Andes',
      'alimentacion': 'Hervívoro - hierbas, semillas y corteza de árboles',
      'estado_conservacion': 'Preocupación menor',
      'region': 'Sudamérica (Chile, Bolivia, Perú)',
      'curiosidades': [
        'Su pelaje es 30 veces más denso que el de un humano',
        'Puede saltar hasta 2 metros de altura',
        'Se comunica mediante sonidos agudos'
      ],
      'imagen_url': null,
      'categoria': 'Roedor'
    },
    {
      'id': 5,
      'nombre_comun': 'Huemul',
      'nombre_cientifico': 'Hippocamelus bisulcus',
      'descripcion': 'El huemul del sur es un ciervo endémico de la Patagonia chilena y argentina. Es un símbolo nacional de Chile.',
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
      'categoria': 'Cérvido'
    },
    {
      'id': 6,
      'nombre_comun': 'Quirquincho',
      'nombre_cientifico': 'Chaetophractus villosus',
      'descripcion': 'El quirquincho o piche es un armadillo mediano nativo de la Patagonia. Es conocido por su capacidad de enrollarse en una bola.',
      'habitat': 'Regiones áridas y semiáridas de la Patagonia',
      'alimentacion': 'Omnívoro - insectos, pequeños vertebrados, frutas y vegetales',
      'estado_conservacion': 'Preocupación menor',
      'region': 'Sudamérica (Chile, Argentina)',
      'curiosidades': [
        'Puede enrollarse completamente en una bola para protegerse',
        'Tiene una coraza ósea cubierta de placas',
        'Es un excelente excavador'
      ],
      'imagen_url': null,
      'categoria': 'Xenartro'
    },
    {
      'id': 7,
      'nombre_comun': 'Monito del monte',
      'nombre_cientifico': 'Dromiciops gliroides',
      'descripcion': 'El monito del monte es un marsupial pequeño endémico de Chile. Es el único marsupial viviente en el hemisferio norte.',
      'habitat': 'Bosques templados del centro-sur de Chile',
      'alimentacion': 'Omnívoro - insectos, frutas, néctar y pequeños vertebrados',
      'estado_conservacion': 'Preocupación menor',
      'region': 'Chile (región centro-sur)',
      'curiosidades': [
        'Es el único marsupial viviente fuera de Australasia',
        'Puede planear cortas distancias entre árboles',
        'Es un importante dispersor de semillas'
      ],
      'imagen_url': null,
      'categoria': 'Marsupial'
    },
    {
      'id': 8,
      'nombre_comun': 'Pudú',
      'nombre_cientifico': 'Pudu puda',
      'descripcion': 'El pudú es el ciervo más pequeño del mundo. Es un mamífero rumiante que habita en los bosques templados del sur.',
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
      'categoria': 'Cérvido'
    },
    {
      'id': 9,
      'nombre_comun': 'Cóndor',
      'nombre_cientifico': 'Vultur gryphus',
      'descripcion': 'El cóndor andino es una de las aves voladoras más grandes del mundo. Es un ave carroñera que habita en los Andes.',
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
      'id': 10,
      'nombre_comun': 'Flamenco',
      'nombre_cientifico': 'Phoenicopterus chilensis',
      'descripcion': 'El flamenco chileno es una ave zancuda conocida por su color rosado y sus patas largas. Habita en lagunas y salares.',
      'habitat': 'Lagunas, salares y humedales costeros',
      'alimentacion': 'Filtrador - algas, crustáceos y pequeños invertebrados',
      'estado_conservacion': 'Preocupación menor',
      'region': 'Sudamérica (Chile, Perú, Bolivia, Argentina)',
      'curiosidades': [
        'Su color rosado proviene de los carotenoides en su dieta',
        'Puede filtrar hasta 50 litros de agua por hora',
        'Vive en colonias de miles de individuos'
      ],
      'imagen_url': null,
      'categoria': 'Ave zancuda'
    }
  ];

  Future<void> initializeAnimalsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_animalsCacheKey);

      if (existingData == null) {
        // Si no hay datos, insertar los datos iniciales
        await prefs.setString(_animalsCacheKey, json.encode(_animalsData));
      } else {
        // Verificar si necesitamos actualizar datos
        final List<dynamic> currentData = json.decode(existingData);
        if (currentData.length != _animalsData.length) {
          await prefs.setString(_animalsCacheKey, json.encode(_animalsData));
        }
      }
    } catch (e) {
      // Error al inicializar datos
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
      // Error al obtener datos
    }

    return [];
  }

  Future<Map<String, dynamic>?> getAnimalByName(String name) async {
    final animals = await getAllAnimals();
    try {
      // Mapeo específico para labels del modelo YOLO que no coinciden exactamente
      final labelMapping = {
        'raton': 'Chinchilla',      // raton -> Chinchilla
        'condor': 'Cóndor',         // condor -> Cóndor
        'monito_monte': 'Monito del monte',  // monito_monte -> Monito del monte
        'quirquincho': 'Quirquincho',  // ya coincide
        'pudu': 'Pudú',             // pudu -> Pudú
      };

      // Aplicar mapeo si existe, sino usar el nombre original
      final mappedName = labelMapping[name.toLowerCase()] ?? name;

      // Normalize the input name for better matching
      final normalizedName = mappedName.toLowerCase()
          .replaceAll('_', ' ')  // Convert underscores to spaces
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .trim();

      return animals.firstWhere(
        (animal) {
          final animalName = animal['nombre_comun'].toString().toLowerCase()
              .replaceAll('á', 'a')
              .replaceAll('é', 'e')
              .replaceAll('í', 'i')
              .replaceAll('ó', 'o')
              .replaceAll('ú', 'u')
              .trim();
          return animalName == normalizedName;
        },
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
      }
    } catch (e) {
      // Error al actualizar datos
    }
  }

  Future<void> clearAnimalsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_animalsCacheKey);
    } catch (e) {
      // Error al eliminar datos
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
