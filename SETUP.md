# Cazadores Perú — Setup Guide

## Prerequisites

- Flutter SDK >= 3.19.0
- Dart SDK >= 3.3.0
- Android Studio / Xcode
- Google Maps API Key
- Firebase project (Analytics + Messaging)
- AdMob account (optional)

---

## 1. Clone & Install

```bash
cd cazadores-x-peru
flutter pub get
```

## 2. Code Generation

Run code generation (Freezed, JSON, Retrofit, Isar, Riverpod):

```bash
dart run build_runner build --delete-conflicting-outputs
```

To watch for changes during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 3. Firebase Setup

1. Create a Firebase project at console.firebase.google.com
2. Add Android app (`com.cazadores.cazadores_peru`)
3. Add iOS app (`com.cazadores.cazadoresPeru`)
4. Download `google-services.json` → place in `android/app/`
5. Download `GoogleService-Info.plist` → place in `ios/Runner/`
6. Enable Analytics and Cloud Messaging

## 4. Google Maps API Key

### Android
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY"/>
```

Or use `local.properties`:
```
MAPS_API_KEY=YOUR_API_KEY
```

### iOS
Edit `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps
GMSServices.provideAPIKey("YOUR_API_KEY")
```
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Usamos tu ubicación para reportes de avistamiento</string>
```

## 5. AdMob (optional)

Replace test IDs in `lib/core/constants/app_constants.dart` with your real AdMob IDs.

## 6. Update Static Assets

The app uses pre-downloaded JSON files to avoid network calls on startup.
To refresh them, run:

```bash
# Uses the MININTER API
curl https://sispasvehapp.mininter.gob.pe/api-recompensas/delitos \
  -o assets/data/delitos.json

curl https://sispasvehapp.mininter.gob.pe/api-recompensas/ubigeo/departamentos \
  -o assets/data/departamentos.json
```

For provinces (all departments), fetch each and combine into `assets/data/provincias.json`.

## 7. Run

```bash
# Debug
flutter run

# Android release
flutter build apk --release

# iOS release
flutter build ios --release
```

---

## Architecture

```
Clean Architecture + MVVM + Riverpod

Data Flow:
  API/Isar → Repository → UseCase → StateNotifier/AsyncNotifier → Screen
```

### Key directories

| Path | Role |
|------|------|
| `lib/core/` | Constants, theme, router, network utils |
| `lib/data/` | DTOs, API service (Retrofit), Isar schemas, repository impls |
| `lib/domain/` | Entities, repository interfaces, use cases |
| `lib/presentation/` | Screens, providers (Riverpod), widgets |
| `assets/data/` | Static JSON: departamentos, provincias, delitos |

---

## Deep Links

Format: `cazadores://criminal/{hash}`

Example:
```
cazadores://criminal/2C33B73D6CD5DB37AE7E644AEF8ADD52
```

---

## Offline Mode

- Isar caches last 100 search results per query (TTL: 24h)
- Favorites always available offline
- Static filter data (departments, provinces, crimes) always local

---

## Legal Notes

- All criminal data is public official data from the State of Peru
- No user accounts or PII stored
- App complies with Google Play policies for sensitive content (News category)
- Always display the 1818 disclaimer
