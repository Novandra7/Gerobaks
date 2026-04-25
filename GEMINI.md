# GEMINI.md - Gerobaks Project Context

## Project Overview
**Gerobaks** is a smart waste management mobile application built with Flutter. It aims to provide efficient waste collection and sustainability solutions through a role-based ecosystem (End Users and Mitra/Partners).

### Key Technologies
- **Frontend:** Flutter 3.13.9, Dart 3.3.1
- **State Management:** BLoC (Business Logic Component)
- **Backend:** Laravel 12 (REST API)
- **AI Integration:** Google Gemini AI (Gemini 2.5-Flash) for chat assistance and content generation
- **Maps & Tracking:** Google Maps Flutter, OSRM (Open Source Routing Machine) for routing
- **Notifications:** Firebase Cloud Messaging (FCM), Local Notifications
- **Payments:** Midtrans Payment Gateway, QRIS integration

## Architecture & Structure
The project follows **Clean Architecture** and **MVVM** patterns.

### Directory Structure
- `lib/blocs/`: Centralized state management using the BLoC pattern.
- `lib/models/`: Data entities and model classes (e.g., `User`, `Activity`, `Schedule`).
- `lib/services/`: Core business logic and API interaction layers (e.g., `GeminiAiService`, `AuthApiService`).
- `lib/ui/`: UI components and pages, divided by user roles:
  - `lib/ui/pages/end_user/`: Pages for the waste generator (home, schedule, tracking, reward).
  - `lib/ui/pages/mitra/`: Pages for the collector/partner (dashboard, available schedules, navigation).
  - `lib/ui/widgets/`: Reusable UI components.
- `lib/utils/`: Helper classes and constants (e.g., `AppConfig`, `ApiRoutes`).

## Development Guidelines

### 1. State Management
Always use **BLoC** for business logic. Most blocs are exported through `lib/blocs/blocs.dart`. Use `BlocProvider` and `BlocBuilder`/`BlocListener` for UI integration.

### 2. Configuration & Environment
- Environment variables are managed via `.env`.
- `AppConfig` (in `lib/utils/app_config.dart`) handles dynamic API URL loading and initialization.
- Use `AppLogger` for consistent logging.

### 3. API Integration
- Use `ApiClient` or specific services (e.g., `AuthApiService`, `EndUserApiService`) for network calls.
- API base URLs can be dynamically changed in-app for development/testing purposes.

### 4. Language & Conventions
- The project primarily uses **Bahasa Indonesia** for user-facing strings and documentation.
- Variable and class names follow standard Dart camelCase/PascalCase conventions.

## Key Commands

### Setup & Run
```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run with specific flavor/dart-define if applicable (check scripts/)
```

### Testing
```bash
# Run unit and widget tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Assets
New assets must be registered in `pubspec.yaml`. Most images are located in the `assets/` directory.

## Documentation Reference
Comprehensive documentation is available in the `docs/` folder:
- `docs/architecture/`: System design and PRD/PSD.
- `docs/api/`: API integration details.
- `docs/README.md`: Index of all documentation.
