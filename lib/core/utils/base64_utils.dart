import 'dart:convert';
import 'dart:typed_data';

class Base64Utils {
  Base64Utils._();

  /// Decodifica una foto Base64 proveniente de la API.
  /// Retorna null si el string es nulo o inválido.
  static Uint8List? decodePhoto(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      // Limpiar prefijo data URL si existe
      final clean = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  /// Genera un hash único de la imagen para usarlo como cache key
  static String cacheKey(String base64String) {
    return base64String.length > 32
        ? base64String.substring(0, 32)
        : base64String;
  }
}
