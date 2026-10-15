# Backend - Medical Emotion Monitoring System

Backend Spring Boot pour le système de monitoring d'émotions médicales.

## 🚀 Démarrage Rapide

### Prérequis
- Java 17 ou supérieur
- Maven 3.6+
- MySQL 8.0+

### Installation

1. **Créer la base de données MySQL:**
   ```sql
   CREATE DATABASE emotion_monitoring;
   ```

2. **Configurer l'application:**
   Modifiez `src/main/resources/application.properties` avec vos identifiants MySQL:
   ```properties
   spring.datasource.username=votre_username
   spring.datasource.password=votre_password
   ```

3. **Lancer l'application:**
   ```bash
   mvn spring-boot:run
   ```

L'application sera disponible sur `http://localhost:8080/api`

## 📁 Structure

```
backend/
├── src/main/java/com/medical/emotionmonitoring/
│   ├── controller/      # Contrôleurs REST
│   ├── service/         # Logique métier
│   ├── repository/      # Accès aux données
│   ├── entity/         # Entités JPA
│   ├── dto/            # Objets de transfert
│   ├── security/       # Configuration sécurité
│   └── config/         # Configuration
├── src/main/resources/
│   └── application.properties
└── pom.xml
```

## 🔐 Authentification

- **POST** `/api/auth/register` - Inscription
- **POST** `/api/auth/login` - Connexion
- **GET** `/api/auth/validate` - Valider le token

## 📊 API Endpoints

### Émotions
- **POST** `/api/emotions` - Créer une émotion
- **POST** `/api/emotions/detect` - Détecter une émotion depuis une image
- **GET** `/api/emotions/{id}` - Obtenir une émotion
- **GET** `/api/emotions/patient/{patientId}` - Historique d'un patient

### Utilisateurs
- **GET** `/api/users/me` - Utilisateur actuel
- **GET** `/api/users/{id}` - Utilisateur par ID

## 🔧 Configuration

### Variables d'environnement (optionnel)

```properties
DATABASE_URL=jdbc:mysql://localhost:3306/emotion_monitoring
DATABASE_USERNAME=root
DATABASE_PASSWORD=
JWT_SECRET=votre-secret-jwt
SERVER_PORT=8080
```

## 📚 Documentation

- Voir `TESTING_GUIDE.md` pour les tests
- Voir `DEPLOYMENT.md` pour le déploiement

## 🛠️ Technologies

- Spring Boot 3.2.0
- Spring Security
- Spring Data JPA
- MySQL
- JWT (jjwt)
- Lombok
- Maven
