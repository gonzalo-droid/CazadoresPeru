# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Flutter is installed at `/Users/gonzalo/DocsNeko/claude-code/flutter/bin`. Add it to PATH first if needed:
```bash
export PATH="$PATH:/Users/gonzalo/DocsNeko/claude-code/flutter/bin"
```

```bash
# Run on Android emulator
flutter run -d emulator-5554

# Run on iOS Simulator
flutter run -d "iPhone 16"

# Regenerate all code-gen files (freezed, json_serializable, riverpod_generator, isar_generator)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
flutter pub run build_runner watch --delete-conflicting-outputs

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze
flutter analyze

# Clean build
flutter clean && flutter pub get
```

## Architecture

Clean Architecture with MVVM, three layers:

```
lib/
  core/           – cross-cutting: constants, theme, router, network, utils
  data/           – API DTOs, Isar schemas, repository implementations
  domain/         – abstract repository interfaces, entities (Freezed), use cases
  presentation/   – screens + providers (Riverpod), shared widgets
```

### Data flow

`Screen → Provider (Riverpod) → UseCase → Repository interface → RepositoryImpl → ApiService (Dio) + IsarService`

- **API**: `ApiService` (`lib/data/remote/api_service.dart`) wraps plain Dio calls. Base URL: `https://sispasvehapp.mininter.gob.pe/api-recompensas`. Key endpoints: `POST /requisitoriados/pageandfilter`, `POST /requisitoriados/top5`, `GET /requisitoriados/{hash}`.
- **Local DB**: Isar 3.1.0+1 via `IsarService` (`lib/data/local/isar_service.dart`). Two collections: `FavoriteSchema` (saved criminals) and `CachedCriminalSchema` (search cache, max 100 items, 24 h TTL).
- **Offline**: `CriminalRepositoryImpl` checks connectivity first; falls back to Isar cache on network failure.

### Pagination

The MININTER API uses Spring Boot **0-indexed** pagination. The UI is **1-indexed**. The translation happens in `CriminalRepositoryImpl`: `page: filters.page - 1` on request, `currentPage: response.number + 1` on response.

### CriminalSummary entity

One unified entity (`lib/domain/entities/criminal_summary.dart`) covers both list results and detail. List responses populate `nombreCompleto` + `delito` (singular). Detail responses populate `apellidoPaterno/Materno/nombres` + `delitos` (array). Use the extension methods `displayName` and `allDelitos` everywhere in the UI — never read the raw fields directly.

### Code generation

All files ending in `.freezed.dart` and `.g.dart` are generated — do not edit them manually. After changing any `@freezed`, `@JsonSerializable`, `@riverpod`, or `@collection` annotated class, run `build_runner build`.

### State management

Riverpod with `riverpod_generator` (`@riverpod` / `@Riverpod(keepAlive: true)`). Each screen has a corresponding `*_provider.dart`. Providers that must survive navigation (router, Dio, Isar, repositories) use `keepAlive: true`.

### Navigation

GoRouter via `appRouterProvider`. Routes defined in `AppRoutes` constants. Detail screen is outside the shell: `'${AppRoutes.detail}/:hash'`. Deep links: `cazadores://criminal/{hash}`.

## Known issues / quirks

- **Android SSL**: The MININTER server has an incomplete TLS certificate chain that Android's BoringSSL rejects. `dio_client.dart` installs a custom `HttpClient` with `badCertificateCallback` that returns `true` in `kDebugMode` only.
- **isar_flutter_libs namespace**: isar 3.1.0+1 doesn't declare an Android `namespace`. Patched in `android/build.gradle.kts` with an `afterEvaluate` block that injects the namespace from `AndroidManifest.xml`.
- **`retrofit_generator`**: Broken with Dart 3.11. Do not add it back. Use plain Dio calls in `ApiService`.
- **`riverpod_lint` / `custom_lint`**: Incompatible with `isar_generator` due to conflicting `analyzer` version constraints. Do not add them back.
- **Google Maps API key**: Placeholder `YOUR_GOOGLE_MAPS_API_KEY` in both `AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`. The map screen will not render until replaced with a real key.
