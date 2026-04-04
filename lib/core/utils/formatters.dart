import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _solFormatter = NumberFormat('#,###', 'es_PE');

  /// Formatea monto como "S/ 50 000"
  static String formatReward(double amount) {
    if (amount <= 0) return 'Sin recompensa';
    final formatted = _solFormatter.format(amount).replaceAll(',', ' ');
    return 'S/ $formatted';
  }

  /// Formatea nombre completo: "ATACHI FELIX, JOSIMAR"
  static String formatFullName({
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String nombres,
  }) {
    return '$apellidoPaterno $apellidoMaterno, $nombres';
  }

  /// Primer delito para mostrar en chip
  static String firstDelito(List<String> delitos) {
    if (delitos.isEmpty) return 'Sin especificar';
    return delitos.first;
  }

  static String dateTimeDisplay(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm', 'es_PE').format(dt);
  }
}
