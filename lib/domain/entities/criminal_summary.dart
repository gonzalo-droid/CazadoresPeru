import 'package:freezed_annotation/freezed_annotation.dart';

part 'criminal_summary.freezed.dart';
part 'criminal_summary.g.dart';

/// Entidad unificada. Campos del listado siempre presentes;
/// campos del detalle pueden ser nulos hasta que se cargue el detalle completo.
@freezed
class CriminalSummary with _$CriminalSummary {
  const factory CriminalSummary({
    required int idRequisitoriado,
    required String hashRequisitoriado,

    /// Nombre completo del listado (ej. "hugo soria flores")
    @Default('') String nombreCompleto,

    /// Campos del detalle (GET /{hash})
    @Default('') String apellidoPaterno,
    @Default('') String apellidoMaterno,
    @Default('') String nombres,
    @Default(1) int sexo,

    required double montoRecompensa,
    @Default('') String montoRecompensaSpace,
    String? foto,

    /// Delito singular del listado
    @Default('') String delito,

    /// Delitos array del detalle
    @Default([]) List<String> delitos,

    @Default('') String departamento,
    @Default('') String provincia,
  }) = _CriminalSummary;

  factory CriminalSummary.fromJson(Map<String, dynamic> json) =>
      _$CriminalSummaryFromJson(json);
}

extension CriminalSummaryX on CriminalSummary {
  /// Nombre para mostrar en UI: usa apellidos del detalle si están disponibles,
  /// sino el nombreCompleto del listado.
  String get displayName {
    if (apellidoPaterno.isNotEmpty) {
      return '$apellidoPaterno $apellidoMaterno, $nombres'
          .toUpperCase();
    }
    return nombreCompleto.toUpperCase();
  }

  /// Lista de delitos para mostrar: usa el array del detalle si está disponible,
  /// sino el delito singular del listado.
  List<String> get allDelitos =>
      delitos.isNotEmpty ? delitos : (delito.isNotEmpty ? [delito] : []);
}
