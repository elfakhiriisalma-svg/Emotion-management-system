# Frontend - Medical Emotion Monitoring System

Application Flutter pour le système de monitoring d'émotions médicales.

## 🚀 Démarrage Rapide

### Prérequis
- Flutter SDK 3.38.3-stable ou supérieur
- Dart SDK 3.0.0 ou supérieur
- Backend Spring Boot en cours d'exécution

### Installation

1. **Installer les dépendances:**
   ```bash
   flutter pub get
   ```

2. **Configurer l'URL du backend:**
   Modifiez `lib/config/app_config.dart` si nécessaire:
   ```dart
   static const String baseUrl = 'http://localhost:8080/api';
   ```

3. **Lancer l'application:**
   ```bash
   flutter run
   ```

## 📁 Structure

```
frontend/
├── lib/
│   ├── main.dart
│   ├── config/          # Configuration
│   ├── models/          # Modèles de données
│   ├── providers/       # State Management (Provider)
│   ├── screens/         # Écrans
│   ├── services/        # Services API
│   └── widgets/         # Widgets réutilisables
└── pubspec.yaml
```

## 🎨 Architecture

- **Provider** pour la gestion d'état
- **Dio** pour les appels HTTP
- **SharedPreferences** pour le stockage local
- **Image Picker** pour la caméra

## 📱 Fonctionnalités

- ✅ Authentification (Login/Register)
- ✅ Enregistrement d'émotions
- ✅ Détection d'émotion depuis la caméra
- ✅ Historique des émotions
- ✅ Profil utilisateur

## 🔧 Configuration

### Permissions Android

Ajoutez dans `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

Et dans la balise `<application>`:
```xml
android:usesCleartextTraffic="true"
```

## 📚 Documentation

- Voir `ARCHITECTURE.md` pour l'architecture détaillée
- Voir `QUICK_START_FLUTTER.md` pour le démarrage rapide
- Voir `SETUP_FLUTTER.md` pour l'installation complète

## 🛠️ Technologies

- Flutter 3.38.3
- Provider (State Management)
- Dio (HTTP Client)
- SharedPreferences
- Image Picker
- Email Validator

