# 🏥 Medical Emotion Monitoring System

> A comprehensive healthcare application for monitoring and tracking patient emotions using AI-powered facial recognition technology, designed for both patients and healthcare providers.

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Flutter](https://img.shields.io/badge/Flutter-3.38.3-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)](https://www.mysql.com)

## 📱 Overview

The Medical Emotion Monitoring System is a full-stack healthcare application that enables patients to track their emotional well-being through AI-powered emotion detection, while providing healthcare providers with comprehensive tools to monitor, analyze, and respond to patient emotional states.

### Key Features

- 🎭 **AI-Powered Emotion Detection** - Real-time facial emotion recognition using multiple API providers
- 📊 **Comprehensive Analytics** - Weekly/monthly insights, stress indicators, and trend analysis
- 👨‍⚕️ **Doctor Dashboard** - Patient management, alerts, notes, and PDF report generation
- 📱 **Patient Dashboard** - Emotion tracking, statistics, and personalized recommendations
- 🔔 **Real-Time Alerts** - Critical emotion notifications for healthcare providers
- 🔐 **Secure Authentication** - JWT-based security with account lockout protection
- 📄 **PDF Reports** - Professional patient reports for healthcare providers
- 🎨 **Modern UI** - Material Design 3 with dark mode support

## 🏗️ Architecture

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.2.0
- **Database**: MySQL 8.0
- **Security**: Spring Security + JWT
- **ORM**: JPA/Hibernate
- **Build Tool**: Maven

### Frontend (Flutter)
- **Framework**: Flutter 3.38.3
- **State Management**: Provider
- **HTTP Client**: Dio
- **Charts**: fl_chart
- **PDF Generation**: pdf, printing

## 🚀 Quick Start

### Prerequisites

- Java 17+
- Maven 3.9+
- Flutter 3.38.3+
- MySQL 8.0+
- Android Studio / VS Code

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/youssef-za/flutter_app.git
   cd flutter_app/backend
   ```

2. **Configure database**
   ```bash
   # Update application.properties with your MySQL credentials
   spring.datasource.url=jdbc:mysql://localhost:4306/emotion_monitoring
   spring.datasource.username=root
   spring.datasource.password=your_password
   ```

3. **Build and run**
   ```bash
   mvn clean install
   mvn spring-boot:run
   ```

   Backend will be available at `http://localhost:8080/api`

### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd ../frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API configuration**
   ```dart
   // lib/config/app_config.dart
   static const String baseUrl = 'http://YOUR_IP:8080/api';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
flutter_app/
├── backend/                    # Spring Boot backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/medical/emotionmonitoring/
│   │   │   │       ├── controller/    # REST controllers
│   │   │   │       ├── service/       # Business logic
│   │   │   │       ├── repository/    # Data access
│   │   │   │       ├── entity/        # JPA entities
│   │   │   │       ├── dto/           # Data transfer objects
│   │   │   │       ├── security/      # Security configuration
│   │   │   │       └── validation/    # Custom validators
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   └── test/                      # Unit & integration tests
│   └── pom.xml
│
├── frontend/                  # Flutter frontend
│   ├── lib/
│   │   ├── config/            # App configuration
│   │   ├── models/            # Data models
│   │   ├── providers/        # State management
│   │   ├── screens/           # UI screens
│   │   ├── services/          # API & business services
│   │   └── widgets/           # Reusable widgets
│   └── pubspec.yaml
│
└── README.md
```

## 🔑 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Emotions
- `POST /api/emotions` - Create emotion record
- `POST /api/emotions/detect` - Detect emotion from image
- `GET /api/emotions` - Get user's emotions
- `GET /api/emotions/patient/{id}/statistics` - Get patient statistics

### Users
- `GET /api/users/{id}` - Get user by ID
- `PUT /api/users/profile` - Update profile
- `PUT /api/users/password` - Change password

### Patient Notes (Doctor only)
- `POST /api/patient-notes` - Create note
- `GET /api/patient-notes/patient/{id}` - Get patient notes
- `PUT /api/patient-notes/{id}` - Update note
- `DELETE /api/patient-notes/{id}` - Delete note

See [API Documentation](APPLICATION_FEATURES.md) for complete endpoint list.

## 🔐 Security Features

- ✅ JWT-based authentication
- ✅ Password validation (min 8 chars, uppercase, lowercase, number, special char)
- ✅ Account lockout after failed login attempts
- ✅ Role-based access control (Patient/Doctor)
- ✅ Secure password hashing (BCrypt)
- ✅ CORS configuration
- ✅ Input validation and sanitization

## 📊 Database Schema

### Core Entities
- **User** - Patients and doctors
- **Emotion** - Emotion records with timestamps
- **Alert** - System alerts for critical emotions
- **PatientNote** - Doctor's notes for patients
- **PatientTag** - Tags for patient organization
- **LoginAttempt** - Failed login tracking

See [Database Schema](DATABASE_SCHEMA.md) for detailed schema.

## 🧪 Testing

### Backend Tests
```bash
cd backend
mvn test
```

### Frontend Tests
```bash
cd frontend
flutter test
```

## 📦 Deployment

### Backend Deployment
1. Build JAR file:
   ```bash
   mvn clean package
   ```

2. Run with:
   ```bash
   java -jar target/emotion-monitoring-1.0.0.jar
   ```

3. Configure environment variables:
   - `DATABASE_URL`
   - `JWT_SECRET`
   - `EMOTION_API_KEY`

### Frontend Deployment
1. Build APK:
   ```bash
   flutter build apk --release
   ```

2. Build iOS:
   ```bash
   flutter build ios --release
   ```

## 🛠️ Development

### Code Style
- Backend: Follow Spring Boot conventions
- Frontend: Follow Flutter/Dart style guide

### Git Workflow
- `main` - Production branch
- `develop` - Development branch
- Feature branches for new features

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📚 Documentation

- [Application Features](APPLICATION_FEATURES.md) - Complete feature list
- [Production Readiness Analysis](PRODUCTION_READINESS_ANALYSIS.md) - Improvement recommendations
- [Advanced Features Roadmap](ADVANCED_FEATURES_ROADMAP.md) - Future features
- [Database Schema](DATABASE_SCHEMA.md) - Database structure
- [Architecture Overview](ARCHITECTURE.md) - System architecture

## 🐛 Known Issues

- Refresh token system not yet implemented
- Offline mode planned but not complete
- Some API endpoints lack pagination

See [Issues](https://github.com/youssef-za/flutter_app/issues) for current bugs and feature requests.

## 🗺️ Roadmap

See [Development Roadmap](DEVELOPMENT_ROADMAP.md) for planned features and timeline.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Spring Boot team for the excellent framework
- Flutter team for the amazing UI toolkit
- Hugging Face for emotion detection models
- All open-source contributors

## 📞 Support

For support, email support@example.com or open an issue in the repository.

## 🔗 Links

- [Backend API Documentation](backend/README.md)
- [Frontend Documentation](frontend/README.md)
- [Project Structure](PROJECT_STRUCTURE.md)

---

**Made with ❤️ for better healthcare**
