class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl =
      'https://sispasvehapp.mininter.gob.pe/api-recompensas';
  // Emergency contact
  static const String reportPhone = '0-800-40-007';
  static const String reportPhoneUri = 'tel:080040007';

  // Social / official links
  static const String mininterUrl = 'https://www.mininter.gob.pe';
  static const String pnpUrl = 'https://www.gob.pe/pnp';
  static const String recompensasUrl = 'https://recompensas.pe';

  // Local storage keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keySelectedDepartamento = 'selected_departamento';
  static const String keyLanguage = 'language';

  // Pagination
  static const int pageSize = 20;
  static const String defaultSortBy = 'id';
  static const String defaultDirection = 'desc';
  static const String defaultTipoFilter = 'F';

  // Cache
  static const int maxCachedCriminals = 100;
  static const int cacheTtlHours = 24;

  // Deep link scheme
  static const String deepLinkScheme = 'cazadores';
  static const String deepLinkHost = 'criminal';

  // AdMob IDs (replace with real ones)
  static const String admobAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const String admobAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const String admobBannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String admobBannerIdIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String admobInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String admobInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  // Peligrosidad thresholds
  static const List<String> delitosExtremos = [
    'TERRORISMO',
    'HOMICIDIO CALIFICADO',
    'ASESINATO',
    'SICARIATO',
    'FEMINICIDIO',
  ];
  static const List<String> delitosMuyAltos = [
    'ROBO AGRAVADO',
    'SECUESTRO',
    'TRATA DE PERSONAS',
    'VIOLACIÓN SEXUAL',
    'EXTORSIÓN',
  ];
}
