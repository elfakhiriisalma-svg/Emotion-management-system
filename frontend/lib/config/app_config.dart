class AppConfig {
  // API Configuration
  // Changez cette URL si votre backend est sur un autre serveur
  // Pour un appareil physique Android, utilisez l'IP de votre PC au lieu de localhost
  // IMPORTANT: Le backend utilise /api comme context-path, donc l'URL doit inclure /api
  // Exemple: 'http://192.168.1.100:8080/api'
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Timeouts - Augmentés pour les connexions réseau lentes
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  
  // App Info
  static const String appName = 'Emotion Monitoring';
  static const String appVersion = '1.0.0';
  
  // Debug Mode (set to false in production)
  static const bool debugMode = true;
}

