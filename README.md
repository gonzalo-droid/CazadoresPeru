# Cazadores Perú

Aplicación móvil open source para consultar el **Programa de Recompensas del Ministerio del Interior del Perú (MININTER)**. Permite a cualquier ciudadano buscar requisitoriados, ver detalles, guardar favoritos para acceso offline y visualizar un mapa de concentración por departamento.

> Los datos son públicos y provienen directamente de la API oficial de MININTER (`sispasvehapp.mininter.gob.pe/api-recompensas`), la misma que usa el portal [recompensas.pe](https://recompensas.pe).

---

## Capturas

> _Próximamente — se aceptan PRs con screenshots._

---

## Funcionalidades

- **Buscador** — búsqueda por nombre, alias, departamento, provincia, tipo de delito y sexo con paginación infinita
- **Top buscados** — los 5 requisitoriados con mayor recompensa en la pantalla de inicio
- **Detalle** — foto, nombre completo, delitos, ubicación, nivel de peligrosidad y monto de recompensa
- **Favoritos** — guarda criminales localmente con Isar para acceso offline
- **Mapa de calor** — concentración de requisitoriados por departamento con Google Maps
- **Modo offline** — caché automático de búsquedas recientes (24 h, hasta 100 registros)
- **Tema oscuro/claro** — persistido en preferencias del usuario
- **Deep links** — `cazadores://criminal/{hash}` abre directamente el detalle
- **Línea de denuncia** — acceso rápido al 1818 con un tap

---

## Stack tecnológico

| Categoría | Tecnología |
|---|---|
| Framework | Flutter 3.41+ / Dart 3.11+ |
| Estado | Riverpod 2 + riverpod_generator |
| Inmutabilidad | Freezed + json_serializable |
| Red | Dio 5 + PrettyDioLogger |
| Base de datos local | Isar 3 |
| Navegación | GoRouter 13 |
| Mapas | Google Maps Flutter |

---

## Estructura del proyecto

```
lib/
├── core/
│   ├── constants/        # AppColors, AppConstants (URLs, keys, thresholds)
│   ├── network/          # DioClient, ApiException (unión Freezed)
│   ├── router/           # GoRouter, AppRoutes
│   ├── theme/            # AppTheme light/dark
│   └── utils/            # Formatters, Base64Utils, PeligrosidadHelper
│
├── data/
│   ├── local/
│   │   ├── schemas/      # FavoriteSchema, CachedCriminalSchema (Isar)
│   │   └── isar_service.dart
│   ├── remote/
│   │   ├── dto/          # CriminalSummaryDto, CriminalDetailDto, SearchRequestDto, ...
│   │   └── api_service.dart
│   └── repositories/     # CriminalRepositoryImpl, UbigeoRepositoryImpl
│
├── domain/
│   ├── entities/         # CriminalSummary, SearchFilters, PaginatedResult, ...
│   ├── repositories/     # CriminalRepository, UbigeoRepository (interfaces)
│   └── usecases/         # SearchCriminalsUseCase, GetCriminalDetailUseCase, ...
│
└── presentation/
    ├── home/             # HomeScreen + homeProvider, topWantedProvider
    ├── search/           # SearchScreen + SearchNotifier (paginación)
    ├── detail/           # DetailScreen + criminalDetailProvider
    ├── favorites/        # FavoritesScreen + favoritesStreamProvider
    ├── map/              # HeatMapScreen + mapProvider
    ├── profile/          # ProfileScreen (tema, notificaciones, info)
    ├── onboarding/       # OnboardingScreen (primera apertura)
    ├── report/           # ReportBottomSheet (denuncia anónima)
    └── shared/widgets/   # CriminalPhoto, RewardBadge, ShimmerCard, OfflineBanner
```

---

## Primeros pasos

### Requisitos

- Flutter 3.19+
- Dart 3.3+
- Android Studio / Xcode (para emuladores)
- Una clave de [Google Maps API](https://console.cloud.google.com/) con las APIs **Maps SDK for Android** y **Maps SDK for iOS** habilitadas

### Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/cazadores-x-peru.git
cd cazadores-x-peru

# 2. Instalar dependencias
flutter pub get

# 3. Regenerar archivos de código generado
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Configurar Google Maps (ver sección abajo)

# 5. Correr en Android
flutter run -d emulator-5554

# 6. Correr en iOS
flutter run -d "iPhone 16"
```

### Configurar Google Maps

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_CLAVE_AQUI"/>
```

**iOS** — `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("TU_CLAVE_AQUI")
```

---

## Comandos frecuentes

```bash
# Regenerar código (freezed, json, riverpod, isar)
flutter pub run build_runner build --delete-conflicting-outputs

# Modo watch durante desarrollo
flutter pub run build_runner watch --delete-conflicting-outputs

# Tests
flutter test

# Análisis estático
flutter analyze

# Build APK debug
flutter build apk --debug

# Build iOS release
flutter build ios --release
```

---

## Cómo contribuir

El proyecto está **abierto a contribuciones**. Hay varias áreas donde se puede colaborar:

### Ideas de funcionalidades

- [ ] Notificaciones push cuando se captura un requisitoriado guardado en favoritos
- [ ] Compartir ficha del criminal como imagen (screenshot + share_plus ya están integrados)
- [ ] Filtro por rango de recompensa (montoMin / montoMax ya están en `SearchFilters`)
- [ ] Widget de estadísticas en la pantalla de inicio con datos históricos
- [ ] Soporte para tablets con layout adaptativo
- [ ] Tests unitarios para use cases y repositorios
- [ ] Tests de widget para pantallas principales
- [ ] Internacionalización (i18n) — la app está en español, se podría agregar inglés

### Flujo de contribución

1. Haz un fork del repositorio
2. Crea una rama: `git checkout -b feature/nombre-de-la-feature`
3. Realiza tus cambios y asegúrate de que `flutter analyze` pasa sin errores
4. Abre un Pull Request describiendo qué resuelve o mejora

### Convenciones

- Toda lógica de negocio va en `domain/usecases` — no en providers ni en la UI
- Los providers solo llaman use cases o repositorios; no hacen HTTP directamente
- Los widgets obtienen datos a través de `ConsumerWidget` / `ref.watch` — no a través de constructores con datos pre-cargados
- Usar `criminal.displayName` y `criminal.allDelitos` en la UI — nunca acceder a `apellidoPaterno` o `delito` directamente (los campos varían según el endpoint)
- Después de modificar cualquier clase `@freezed`, `@riverpod` o `@collection`, correr `build_runner`

---

## Arquitectura

Ver [ARCHITECTURE.md](./ARCHITECTURE.md) para una descripción detallada de las decisiones técnicas, el modelo de datos, el manejo de errores y las particularidades de la API de MININTER.

---

## Aviso legal

Esta aplicación consume datos **públicos** del Ministerio del Interior del Perú. No almacena información personal de los usuarios. Las fotos e información de requisitoriados son de dominio público conforme al Programa de Recompensas del Estado Peruano.

Esta es una herramienta informativa. Para realizar denuncias, utilizar el canal oficial: **línea 0-800-40-007** (gratuita, 24/7).

---

## Licencia

MIT — ver [LICENSE](./LICENSE) para más detalles.
