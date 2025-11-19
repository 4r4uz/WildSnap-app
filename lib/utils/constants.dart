class AppConstants {
  static const String baseUrl = 'https://fastapi-wildsnap-production.up.railway.app';

  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int syncTimeoutSeconds = 60;

  // Configuración de cache
  static const int cacheDurationHours = 24;
  static const int speciesCacheDuration = 1;

  // Límites de paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Mensajes de error
  static const String noConnectionMessage = 'Sin conexión a internet';
  static const String serverErrorMessage = 'Error del servidor';
  static const String syncInProgressMessage = 'Sincronizando datos...';
  static const String syncSuccessMessage = 'Datos sincronizados correctamente';

  // Claves de almacenamiento local
  static const String userDataKey = 'user_data';
  static const String speciesCacheKey = 'species_cache';
  static const String offlineQueueKey = 'offline_operations';
  static const String lastSyncKey = 'last_sync_timestamp';

  // Endpoints de la API
  static const String endpointHealth = '/health';
  static const String endpointEspecies = '/especies/';
  static const String endpointAnimales = '/animales/';
  static const String endpointUsuarios = '/usuarios/';
  static const String endpointAvistamientos = '/avistamientos/';
  static const String endpointPublicaciones = '/publicaciones/';
  static const String endpointColeccion = '/coleccion/';
  static const String endpointSync = '/sync/';

  // Tipos de operaciones offline
  static const String opUserCreate = 'user_create';
  static const String opUserUpdate = 'user_update';
  static const String opAnimalCreate = 'animal_create';
  static const String opAvistamientoCreate = 'avistamiento_create';
  static const String opColeccionAdd = 'coleccion_add';
  static const String opPublicacionCreate = 'publicacion_create';
}
