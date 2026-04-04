# Arquitectura y Decisiones Técnicas — Cazadores Perú

## Contexto

Aplicación móvil Flutter para consultar el Programa de Recompensas del Ministerio del Interior del Perú (MININTER). Consume la API pública de `sispasvehapp.mininter.gob.pe/api-recompensas`, la misma que usa el portal web `recompensas.pe`. La app permite buscar requisitoriados, ver detalles, guardar favoritos offline y visualizar un mapa de calor por departamento.

---

## Arquitectura General

Se adoptó **Clean Architecture** con separación en tres capas más un núcleo transversal:

```
lib/
├── core/          ← transversal: red, tema, router, constantes, utilidades
├── data/          ← DTOs, esquemas Isar, implementaciones de repositorios
├── domain/        ← entidades, interfaces de repositorios, casos de uso
└── presentation/  ← pantallas, providers Riverpod, widgets compartidos
```

El flujo de dependencias es unidireccional: `presentation → domain ← data`. La capa `data` implementa las interfaces definidas en `domain`; `presentation` solo conoce `domain`.

### Por qué Clean Architecture en un proyecto mobile

La API de MININTER no tiene documentación oficial ni SLA. Se descubrió durante el desarrollo que los endpoints reales diferían del spec inicial (ver sección API más abajo). Con repositorios abstractos, cambiar la fuente de datos (o añadir un mock para tests) no toca la capa de presentación. Adicionalmente, el requisito de modo offline obligó a tener una capa de abstracción que decide entre API e Isar sin que la UI lo sepa.

---

## Gestión de Estado — Riverpod + riverpod_generator

Se eligió **Riverpod** (con `riverpod_annotation` y `riverpod_generator`) sobre otras opciones (BLoC, Provider clásico) por tres razones:

1. **Compilación segura**: los providers son funciones tipadas generadas en `.g.dart`, no `String`-keys. Los errores de tipo se detectan en compilación.
2. **`keepAlive: true`** para providers de infraestructura (Dio, Isar, repositorios) que deben sobrevivir la navegación.
3. **`AsyncValue`** unifica los tres estados (loading / data / error) sin boilerplate manual.

Cada pantalla tiene su propio `*_provider.dart`. La pantalla de búsqueda usa un `SearchNotifier` (clase que extiende `_$SearchNotifier`) para manejar paginación incremental con `loadMore()` y reseteo con `search()`.

### Por qué no BLoC

BLoC requiere definir eventos, estados y el bloque de transformación por separado. Para una app de consulta sin lógica de negocio compleja, el overhead era injustificado.

---

## Inmutabilidad — Freezed

Todas las entidades de dominio (`CriminalSummary`, `SearchFilters`, `PaginatedResult`) y los DTOs de red son clases `@freezed`. Esto garantiza:

- `copyWith` generado automáticamente.
- Igualdad estructural sin implementar `==` a mano.
- Uniones discriminadas para `ApiException` (ver más abajo).

Los archivos `.freezed.dart` y `.g.dart` son **siempre generados** — nunca se editan a mano. Comando: `flutter pub run build_runner build --delete-conflicting-outputs`.

---

## Entidad Unificada CriminalSummary

### El problema

La API de MININTER devuelve **dos shapes diferentes** según el endpoint:

| Endpoint | Campos nombre | Delitos |
|---|---|---|
| `POST /pageandfilter` | `nombreCompleto` (string único) | `delito` (string singular) |
| `GET /{hash}` | `apellidoPaterno`, `apellidoMaterno`, `nombres` | `delitos` (array) |

### La decisión

En lugar de tener dos entidades separadas (`CriminalSummary` + `CriminalDetail`) y gestionar conversiones en la UI, se creó **una sola entidad** con todos los campos, donde los del detalle tienen valores por defecto vacíos hasta que se cargue el detalle completo.

```dart
@freezed
class CriminalSummary with _$CriminalSummary {
  const factory CriminalSummary({
    required int idRequisitoriado,
    required String hashRequisitoriado,
    @Default('') String nombreCompleto,     // listado
    @Default('') String apellidoPaterno,    // detalle
    @Default('') String apellidoMaterno,    // detalle
    @Default('') String nombres,            // detalle
    @Default('') String delito,             // listado (singular)
    @Default([]) List<String> delitos,      // detalle (array)
    ...
  }) = _CriminalSummary;
}
```

Dos extensiones resuelven la ambigüedad en la UI sin que los widgets sepan de qué endpoint vino el dato:

```dart
extension CriminalSummaryX on CriminalSummary {
  String get displayName { ... }   // usa apellidos si están, sino nombreCompleto
  List<String> get allDelitos { ... }  // usa array si está, sino el singular
}
```

**Trampas**: la extensión SOLO funciona cuando el tipo estático es `CriminalSummary`. Si el objeto está tipado como `dynamic`, Dart lanza `NoSuchMethodError` en runtime porque las extensiones no se resuelven por despacho dinámico. Esto ocurrió en `home_screen.dart` donde `_TopWantedCard.criminal` estaba declarado como `dynamic`.

---

## Capa de Red — Dio + headers de impersonación

### Descubrimiento de endpoints

La API no tiene documentación pública. Los endpoints reales se obtuvieron inspeccionando el bundle JS minificado de `recompensas.pe`:

- `POST /requisitoriados/pageandfilter` — búsqueda paginada
- `POST /requisitoriados/top5` — top 5 por recompensa
- `GET /requisitoriados/{hash}` — detalle

El endpoint original del spec (`POST /buscar`) devuelve 500 "POST not supported".

### Headers obligatorios

El servidor MININTER rechaza peticiones sin headers de origen. Se configuró Dio para impersonar al navegador de `recompensas.pe`:

```dart
headers: {
  'Origin': 'https://recompensas.pe',
  'Referer': 'https://recompensas.pe/',
  'Accept': 'application/json, text/plain, */*',
  'User-Agent': 'Mozilla/5.0 ...',
}
```

### Paginación

La API usa paginación **1-indexed**, igual que la UI. El campo `page` se envía directamente sin transformación. El campo `number` de la respuesta se mapea tal cual a `currentPage`.

### Interceptor de reintentos

`_RetryInterceptor` reintenta hasta 3 veces solo en `connectionTimeout` y `receiveTimeout`. No reintenta errores de servidor (4xx/5xx) ni errores desconocidos para no repetir peticiones que definitivamente fallarán.

---

## SSL en Android — BoringSSL vs iOS

El servidor MININTER tiene una cadena de certificados incompleta. iOS (SecureTransport) es permisivo con esto; Android (BoringSSL) lo rechaza con `DioExceptionType.unknown` + mensaje `null`.

Solución en `dio_client.dart`:

```dart
(dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => kDebugMode;
  return client;
};
```

En builds de debug se permite el certificado malo. En release se rechaza. Para producción la solución correcta es contactar a MININTER para que corrijan su cadena, o bien hacer certificate pinning con la hoja real.

---

## Manejo de Errores — ApiException (unión discriminada)

En lugar de excepciones genéricas o códigos de error, se usa una unión Freezed:

```dart
@freezed
class ApiException with _$ApiException implements Exception {
  const factory ApiException.network({required String message}) = NetworkException;
  const factory ApiException.server({required int statusCode, ...}) = ServerException;
  const factory ApiException.timeout() = TimeoutException;
  const factory ApiException.unauthorized() = UnauthorizedException;
  const factory ApiException.notFound() = NotFoundException;
  const factory ApiException.unknown({required String message}) = UnknownException;
}
```

Los repositorios devuelven `Either<ApiException, T>` (del paquete `dartz`). Los providers hacen `result.fold(onError, onSuccess)`. Esto fuerza a que cada caso de error sea manejado explícitamente en compilación — no hay errores silenciosos.

---

## Persistencia Local — Isar

Se eligió **Isar 3.1.0+1** sobre Hive o SQLite por su API reactiva (`watchFavorites()` devuelve un `Stream` que la UI escucha directamente) y su performance en móvil.

Dos colecciones:

| Colección | Uso | TTL / límite |
|---|---|---|
| `FavoriteSchema` | Criminales guardados por el usuario | Sin límite |
| `CachedCriminalSchema` | Resultados de búsqueda para modo offline | 24 h, máx 100 |

La clave de caché (`searchKey`) se construye concatenando todos los filtros activos, permitiendo cachear múltiples búsquedas independientes.

### Problema de namespace en Android

Isar 3.1.0+1 no declara `namespace` en su `build.gradle`, requerido por AGP moderno. Solución en `android/build.gradle.kts`:

```kotlin
subprojects {
  afterEvaluate {
    if (extensions.findByName("android") != null) {
      val androidExtension = extensions.getByType<BaseExtension>()
      if (androidExtension.namespace == null) {
        // leer namespace desde AndroidManifest.xml
      }
    }
  }
}
```

---

## Navegación — GoRouter

ShellRoute con bottom navigation bar para las 5 tabs principales (`/`, `/search`, `/map`, `/favorites`, `/profile`). La pantalla de detalle está fuera del shell porque no tiene bottom bar.

Deep links configurados: `cazadores://criminal/{hash}` — permite abrir directamente el detalle de un criminal desde un enlace externo (WhatsApp, SMS, etc.).

---

## Dependencias descartadas y por qué

| Paquete | Motivo de descarte |
|---|---|
| `retrofit` + `retrofit_generator` | `retrofit_generator 8.2.1` es incompatible con Dart 3.11 (genera código inválido). Se reemplazó con llamadas Dio directas en `ApiService`. |
| `riverpod_lint` + `custom_lint` | Conflicto de versión de `analyzer` con `isar_generator`. Ambos requieren versiones incompatibles. |
| Firebase Analytics / AdMob | Requieren `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) que no estaban disponibles. Los AdMob IDs en `AppConstants` son los de prueba de Google. |
| `Montserrat` (fuente) | Assets de fuente no incluidos en el repositorio. Se usa la fuente del sistema. |

---

## Notas de Seguridad

- La app solo consume datos **públicos** del Ministerio del Interior. No hay autenticación de usuario, no se almacenan datos sensibles del usuario.
- Las fotos de requisitoriados se transmiten como **Base64 en el JSON** de la API — no hay URLs de imagen externas.
- El SSL bypass en Android es **solo para debug**. En release se debe resolver la cadena de certificados del servidor o implementar certificate pinning.
- La clave de Google Maps es placeholder (`YOUR_GOOGLE_MAPS_API_KEY`) — la pantalla de mapa no funciona hasta reemplazarla.
