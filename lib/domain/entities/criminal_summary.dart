import 'package:freezed_annotation/freezed_annotation.dart';

part 'criminal_summary.freezed.dart';
part 'criminal_summary.g.dart';

@freezed
class CriminalSummary with _$CriminalSummary {
  const factory CriminalSummary({
    required int idRequisitoriado,
    required String hashRequisitoriado,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String nombres,
    required int sexo,
    required double montoRecompensa,
    required String montoRecompensaSpace,
    String? foto,
    required List<String> delitos,
    required String departamento,
    required String provincia,
  }) = _CriminalSummary;

  factory CriminalSummary.fromJson(Map<String, dynamic> json) =>
      _$CriminalSummaryFromJson(json);
}
