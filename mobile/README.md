# PitStop Mobile

Flutter app for discovering and reviewing places in Vietnam.

## Setup

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Structure

```
lib/
├── core/          # Config, utils, theme
├── data/          # Models, repositories, datasources
├── domain/        # Entities, use cases
└── presentation/  # Screens, widgets, providers
```
