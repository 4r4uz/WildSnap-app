// Categorización general de animales
class AnimalCategories {
  // Mapa de clases taxonómicas a categorías generales
  static const Map<String, String> categoryMap = {
    // Mamíferos
    'Mammalia': 'Mamíferos',
    // Aves
    'Aves': 'Aves',
    // Reptiles
    'Reptilia': 'Reptiles',
    // Anfibios
    'Amphibia': 'Anfibios',
    // Peces
    'Actinopterygii': 'Peces',
    'Chondrichthyes': 'Peces',
    // Insectos y Arácnidos
    'Insecta': 'Insectos',
    'Arachnida': 'Arácnidos',
    // Moluscos
    'Mollusca': 'Moluscos',
    // Otros invertebrados
    'Annelida': 'Anélidos',
    'Cnidaria': 'Cnidarios',
  };

  // Mapa de géneros comunes a categorías (para casos donde no hay clase taxonómica)
  static const Map<String, String> genusCategoryMap = {
    // Aves comunes
    'columba': 'Aves', // palomas
    'anas': 'Aves', // patos
    'buteo': 'Aves', // halcones
    'falco': 'Aves', // halcones
    'accipiter': 'Aves', // gavilanes
    'aquila': 'Aves', // águilas
    'bubo': 'Aves', // búhos
    'strix': 'Aves', // búhos
    'tyto': 'Aves', // lechuzas
    'corvus': 'Aves', // cuervos
    'cyanocitta': 'Aves', // arrendajos

    // Mamíferos comunes
    'canis': 'Mamíferos', // perros, lobos
    'felis': 'Mamíferos', // gatos
    'ursidae': 'Mamíferos', // osos
    'vulpes': 'Mamíferos', // zorros
    'procyon': 'Mamíferos', // mapaches
    'sciurus': 'Mamíferos', // ardillas
    'tamiasciurus': 'Mamíferos', // ardillas
    'marmota': 'Mamíferos', // marmotas
    'castor': 'Mamíferos', // castores
    'lepus': 'Mamíferos', // liebres
    'oryctolagus': 'Mamíferos', // conejos
    'sylvilagus': 'Mamíferos', // conejos

    // Reptiles comunes
    'chelonoidis': 'Reptiles', // tortugas
    'crotalus': 'Reptiles', // serpientes cascabel
    'lampropeltis': 'Reptiles', // serpientes rey
    'pituophis': 'Reptiles', // serpientes toro
    'thamnophis': 'Reptiles', // serpientes de jardín
    'coluber': 'Reptiles', // culebras
    'elaphe': 'Reptiles', // serpientes
    'sceloporus': 'Reptiles', // lagartijas

    // Insectos comunes
    'apis': 'Insectos', // abejas
    'bombus': 'Insectos', // abejorros
    'papilio': 'Insectos', // mariposas
    'danaus': 'Insectos', // mariposas monarca
    'hesperidae': 'Insectos', // mariposas
    'lycaenidae': 'Insectos', // licénidos
    'nymphalidae': 'Insectos', // mariposas
    'pieridae': 'Insectos', // mariposas blancas

    // Anfibios
    'rana': 'Anfibios', // ranas
    'bufo': 'Anfibios', // sapos
  };

  static String getCategory(String rawLabel) {
    try {
      final parts = rawLabel.split(';');
      if (parts.length < 5) return 'Desconocido';

      final clase = parts[1].trim().toLowerCase();
      final orden = parts[2].trim().toLowerCase();
      final familia = parts[3].trim().toLowerCase();
      final genero = parts[4].trim().toLowerCase();

      // Primero verificar la clase taxonómica
      for (final entry in categoryMap.entries) {
        if (clase == entry.key.toLowerCase() || clase.contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }

      // Luego verificar por orden
      for (final entry in categoryMap.entries) {
        if (orden == entry.key.toLowerCase() || orden.contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }

      // Finalmente verificar por género
      if (genusCategoryMap.containsKey(genero)) {
        return genusCategoryMap[genero]!;
      }

      // Si no se encuentra categoría específica, intentar inferir
      if (genero.contains('aves') || genero.contains('bird')) return 'Aves';
      if (genero.contains('mammal') || genero.contains('mamifero')) return 'Mamíferos';
      if (genero.contains('reptile') || genero.contains('reptil')) return 'Reptiles';
      if (genero.contains('insect') || genero.contains('insecto')) return 'Insectos';
      if (genero.contains('fish') || genero.contains('pez')) return 'Peces';
      if (genero.contains('frog') || genero.contains('rana')) return 'Anfibios';

      return 'Vertebrados'; // Categoría general por defecto

    } catch (e) {
      return 'Desconocido';
    }
  }
}

// Componente para manejo de etiquetas de SpeciesNet
class SpeciesLabels {
  // Simplificar etiquetas de SpeciesNet para mostrar nombres en español
  static String simplifySpeciesNetLabel(String rawLabel) {
    try {
      // Las etiquetas están en formato: id;clase;orden;familia;género;especie;nombre_común
      final parts = rawLabel.split(';');
      if (parts.length < 7) return rawLabel; // Si no tiene el formato esperado, devolver como está

      final nombreComun = parts.last.trim(); // Último elemento es el nombre común

      // Diccionario de traducciones inglés → español (animales comunes)
      final traducciones = <String, String>{
        // Aves
        'lark sparrow': 'Gorrión llanero',
        'stimson\'s python': 'Pitón de Stimson',
        'harvey\'s duiker': 'Duiker de Harvey',
        'montezuma quail': 'Colin de Montezuma',
        'red-winged blackbird': 'Tordo alirrojo',
        'palawan bulbul': 'Bulbul de Palawan',
        'female red-breasted merganser': 'Serreta mediana',
        'ruddy turtle-dove': 'Tórtola turca',
        'black.currant': 'Grosella negra',
        'desert tortoise': 'Tortuga del desierto',
        'marbled wood-quail': 'Codorniz enmarmolada',
        'great curassow': 'Hoco común',
        'common green magpie': 'Urraca verde común',
        'clark\'s nutcracker': 'Cascanueces de Clark',
        'red-tailed hawk': 'Gavilán de cola roja',
        'american black bear': 'Oso negro americano',
        'gray fox': 'Zorro gris',
        'collared psittacula': 'Cotorra cuelliblanca',
        'american crow': 'Cuervo americano',
        'common raven': 'Cuervo común',
        'western tanager': 'Tangara occidental',
        'acorn woodpecker': 'Picamaderos acornitero',
        'california gull': 'Gaviota de California',
        'ring-necked duck': 'Pato cuyana',
        'red-breasted merganser': 'Serreta mediana',
        'european hedgehog': 'Erizo europeo',
        'african elephant': 'Elefante africano',
        'swamp wallaby': 'Ualabí de pantano',
        'northern raccoon': 'Mapache del norte',
        'northern mockingbird': 'Sinsonte norteño',
        'ruffed grouse': 'Urogallo canadiense',
        'ruby-crowned kinglet': 'Reyezuelo rubí',
        'cedar waxwing': 'Ampelis rojo',
        'purple finch': 'Pinzón morado',
        'broad-winged hawk': 'Gavilán aludo',
        'red-breasted woodpecker': 'Carpintero cara roja',
        'brown-headed cowbird': 'Tordo cabe ionic',
        'golden-crowned kinglet': 'Reyezuelo corona dorad',
        'painted turtle': 'Tortuga pintada',
        'green heron': 'Garza verde',
        'great blue heron': 'Garza azul grande',
        'great egret': 'Garceta grande',
        'brown pelican': 'Pelícano pardo',
        'american white pelican': 'Pelícano blanco americano',
        'rock pigeon': 'Paloma doméstica',
        'mourning dove': 'Paloma triste',
        'great horned owl': 'Búho cornudo',
        'barred owl': 'Búho barrado',
        'american robin': 'Petirrojo americano',
        'golden eagle': 'Águila dorada',
        'osprey': 'Águila pescadora',
        'bald eagle': 'Águila calva',
        'sharp-shinned hawk': 'Gavilán incha',
        'white-tailed kite': 'Elanio blanco',
        'barn swallow': 'Golondrina común',
        'cliff swallow': 'Golondrina rojiza',
        'violet-green swallow': 'Golondrina violácea',
        'tree swallow': 'Golondrina arborícola',
        'northern rough-winged swallow': 'Golondrina alas rugosas',
        'purple martin': 'Martín morado',
        'blue jay': 'Arrendajo azul',
        'western scrub-jay': 'Arrendajo palustre',
        'black-capped chickadee': 'Chickadee gorra negra',
        'mountain chickadee': 'Chickadee montañes',
        'chestnut-backed chickadee': 'Chickadee dorsicastaño',
        'red-breasted nuthatch': 'Trepador pecho rojizo',
        'white-breasted nuthatch': 'Trepador pecho blanco',
        'brown creeper': 'Trepador marrón',
        'carolina wren': 'Soterrey del norte',
        'house wren': 'Soterrey americano',

        // Mamíferos
        'northern short-tailed shrew': 'Musgaño cola corta del norte',
        'little brown bat': 'Murciélago café',
        'hoary bat': 'Murciélago hoary',
        'black bear': 'Oso negro',
        'grizzly熊': 'Oso grizzly',
        'polar熊': 'Oso polar',
        'long-tailed weasel': 'Comadreja de cola larga',
        'american badger': 'Tejón americano',
        'northern raccoon': 'Mapache del norte',
        'eastern cottontail': 'Conejo de Virginia',
        'antelope jackrabbit': 'Liebre antílope negra',
        'black-tailed jackrabbit': 'Liebre de cola negra',
        'desert cottontail': 'Conejo del desierto',
        'puma': 'Puma',
        'bobcat': 'Lince rojo',
        'coyote': 'Coyote',
        'gray fox': 'Zorro gris',
        'red fox': 'Zorro rojo',
        'kit fox': 'Zorro kit',
        'gray squirrel': 'Ardilla gris',
        'douglas\'s squirrel': 'Ardilla de Douglas',
        'tropical ground squirrel': 'Ardilla terrestre tropical',
        'northwestern chipmunk': 'Chipmunk noroeste',
        'least chipmunk': 'Chipmunk mínimo',
        'cascade golden-mantled ground squirrel': 'Suelo ardilla dorada en cascada',
        'california ground squirrel': 'Ardilla terrestre de California',
        'washington ground squirrel': 'Ardilla terrestre de Washington',
        'belted kingfisher': 'Martin pescador cinturón',
        'downy woodpecker': 'Picamaderos americano',
        'hairy woodpecker': 'Picamaderos velloso',
        'northern flicker': 'Carpintero norteño',
        'piledated woodpecker': 'Picamaderos pilatado',
        'western wood-pewee': 'Pewee occidental del bosque',
        'eastern wood-pewee': 'Pewee oriental del bosque',
        'least flycatcher': 'Mosquero mínimo',
        'dusky flycatcher': 'Mosquero oscuro',
        'cordilleran flycatcher': 'Mosquero cordillerano',
        'american grey flycatcher': 'Mosquero gris americano',
        'say\'s phoebe': 'Foebe de Say',
        'eastern phoebe': 'Foebe oriental',

        // Reptiles comunes
        'western fence lizard': 'Lagartija valla occidental',
        'rubber boa': 'Boa caucho',
        'racer': 'Corredor',
        'gopher snake': 'Serpiente ardilla',
        'eastern indigo snake': 'Serpiente azul índigo oriental',
        'eastern racer': 'Corredor oriental',
        'coachwhip snake': 'Látigo serpiente',
        'california kingsnake': 'Serpiente rey de Californ',
        'common kingsnake': 'Serpiente rey común',
        'long-nosed snake': 'Serpiente nariz larga',
        'blacksnake': 'Culebra negra',
        'bullsnake': 'Serpiente toro',
        'milksnake': 'Serpiente leche',
        'ringneck snake': 'Serpiente anillada',
        'rossy boa': 'Boa rosada',
        'western diamondback rattlesnake': 'Serpiente cascabel diamante occidental',
        'sidewinder': 'Serpiente sidewinder',

        // Insectos y otros
        'monarch butterfly': 'Mariposa monarca',

        // Nombres genéricos comunes
        'sparrow': 'Gorrión',
        'sparrowhawk': 'Gavilán',
        'marsh hawk': 'Halcón de pantano',
        'chicken': 'Pollo',
        'goose': 'Ganso',
        'duck': 'Pato',
        'swan': 'Cisne',
        'owl': 'Búho',
        'eagle': 'Águila',
        'hawk': 'Halcón',
        'kite': 'Elanio',
        'vulture': 'Buitre',
        'condor': 'Cóndor',
        'falcon': 'Halcón',
        'raven': 'Cuervo',
        'crow': 'Cuervo',
        'magpie': 'Urraca',
        'jay': 'Arrendajo',
        'nutcracker': 'Cascanueces',
        'tit': 'Carbonero',
        'nuthatch': 'Trepador',
        'wren': 'Sotero',
        'thrasher': 'Zorzal pardo',
        'catbird': 'Mímido gato',
        'mockingbird': 'Sinsonte',
        'thrushette common': 'Zorzal común',
        'bluebird': 'Azulejo',
        'bunting': 'Triguerillo',
        'greenfinch': 'Verderón',
        'goldfinch': 'Jilguero',
        'crossbill': 'Picogordo',
        'siskin': 'Lúgano',
        'linnet': ' Pardillo',
        'redpoll': 'Camachuelo',
        'snow bunting': 'Triguerillo nivo',
        'bobolink': 'Bobolink',
        'grosbeak': 'Picogordo',
        'cowbird': 'Tordo americano',
        'grackle': 'Quiscalo',
        'cuckoo': 'Cuco',
        'anisland': 'Ani',
        'potato': 'Papa',
        'potatoes': 'Patatas',
        'ladybug': 'Mariquita',
        'bee': 'Abeja',
        'wasp': 'Avispa',
        'ant': 'Hormiga',
        'beetle': 'Escarabajo',
        'grasshopper': 'Saltamontes',
        'cricket': 'Grillo',
        'mantis': 'Mantís',
        'dragonfly': 'Libélula',
        'fly': 'Mosca',
        'mosquito': 'Mosquito',
        'bear': 'Oso',
        'wolf': 'Lobo',
        'fox': 'Zorro',
        'dog': 'Perro',
        'cat': 'Gato',
        'lion': 'León',
        'tiger': 'Tigre',
        'leopard': 'Leopardo',
        'jaguar': 'Jaguar',
        'cheetah': 'Guepardo',
        'elephant': 'Elefante',
        'rhinoceros': 'Rinoceronte',
        'hippotamus': 'Hipopótamo',
        'horse': 'Caballo',
        'donkey': 'Burro',
        'zebra': 'Cebra',
        'pig': 'Cerdo',
        'boar': 'Jabalí',
        'deer': 'Ciervo',
        'moose': 'Alce',
        'buffalo': 'Búfalo',
        'bison': 'Bisonte',
        'monkey': 'Mono',
        'ape': 'Simio',
        'gorilla': 'Gorila',
        'chimpanzee': 'Chimpancé',
        'orangutan': 'Orangután',
        'giraffe': 'Jirafa',
        'kangaroo': 'Canguro',
        'koala': 'Koala',
        'panda': 'Panda',
        'elephant seal': 'Elefante marino',
        'walrus': 'Morsa',
        'camel': 'Camello',
        'llama': 'Llama',
        'alpaca': 'Alpaca',
        'rabbit': 'Conejo',
        'hare': 'Liebre',
        'squirrel': 'Ardilla',
        'chipmunk': 'Ardilla listada',
        'beaver': 'Castor',
        'mouse': 'Ratón',
        'rat': 'Rata',
        'hamster': 'Hámster',
        'guinea pig': 'Cobaya',
        'ferret': 'Hurón',
        'mink': 'Visón',
        'otter': 'Nutria',
        'skunk': 'Zorrillo',
        'racoon': 'Mapache',
        'badger': 'Tejón',
        'hedgehog': 'Erizo',
        'shrew': 'Musgaño',
        'mole': 'Topo',
        'bat': 'Murciélago',
        'snake': 'Serpiente',
        'lizard': 'Lagartija',
        'turtle': 'Tortuga',
        'tortoise': 'Tortuga',
        'crocodile': 'Cocodrilo',
        'alligator': 'Caimán',
        'frog': 'Rana',
        'toad': 'Sapo',
        'salamander': 'Salamandra',
        'newt': 'Tritón',
        'fish': 'Pez',
        'turtle': 'Tortuga terrestre',
        'lynx': 'Lince',
        'caracal': 'Caracal',
        'serval': 'Serval',
        'genet': 'Geneta',
        'mongoose': 'Mangosta',
        'pangolin': 'Pangolín',
        'armadillo': 'Armadillo',
        'sloth': 'Perezoso',
        'anteater': 'Hormiguero',
        'opossum': 'Zarigüeya',
        'wallaby': 'Ualabí',
        'wombat': 'Uombat',
        'platypus': 'Ornitorrinco',
        'echidna': 'Equidna',
        'whale': 'Ballena',
        'dolphin': 'Delfín',
        'porpoise': 'Marsopa',
        'manatee': 'Manatí',
        'dugong': 'Dugongo',
        'seal': 'Foca',
        'sea lion': 'León marino',

        // Géneros y especies comunes
        'american': 'americano',
        'eastern': 'oriental',
        'western': 'occidental',
        'northern': 'norteño',
        'southern': 'meridional',
        'great': 'grande',
        'little': 'pequeño',
        'common': 'común',
        'wild': 'salvaje',
        'domestic': 'doméstico',
        'red': 'rojo',
        'blue': 'azul',
        'green': 'verde',
        'yellow': 'amarillo',
        'black': 'negro',
        'white': 'blanco',
        'brown': 'marrón',
        'gray': 'gris',
        'golden': 'dorado',
        'silver': 'plateado',
      };

      // Buscar traducción exacta
      if (traducciones.containsKey(nombreComun.toLowerCase())) {
        return traducciones[nombreComun.toLowerCase()]!;
      }

      // Si no hay traducción, intentar traducir palabras comunes
      var resultado = nombreComun.toLowerCase();

      // Transformar palabras conocidas
      traducciones.forEach((ingles, espanol) {
        resultado = resultado.replaceAll(ingles, espanol);
      });

      // Capitalizar primera letra de cada palabra
      var palabras = resultado.split(' ');
      for (int i = 0; i < palabras.length; i++) {
        if (palabras[i].isNotEmpty) {
          palabras[i] = palabras[i][0].toUpperCase() + palabras[i].substring(1);
        }
      }

      return palabras.join(' ');

    } catch (e) {
      // En caso de error, devolver el label original
      return rawLabel;
    }
  }
}
