import 'package:freezed_annotation/freezed_annotation.dart';

part 'criminal_summary_dto.freezed.dart';
part 'criminal_summary_dto.g.dart';

/// DTO para ítems de la lista (POST /requisitoriados/pageandfilter y /top5).
/// Campos que entrega la API: id, idRequisitoriado, hashRequisitoriado,
/// nombreCompleto, foto, montoRecompensa, montoRecompensaSpace, delito.
@freezed
class CriminalSummaryDto with _$CriminalSummaryDto {
  const factory CriminalSummaryDto({
    int? id,
    required int idRequisitoriado,
    required String hashRequisitoriado,
    @Default('') String nombreCompleto,
    String? foto,
    @Default(0.0) double montoRecompensa,
    @Default('') String montoRecompensaSpace,
    @Default('') String delito,
  }) = _CriminalSummaryDto;

  factory CriminalSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$CriminalSummaryDtoFromJson(json);
}

/// DTO para el detalle (GET /requisitoriados/{hash}).
/// Incluye apellidos, sexo, departamento, provincia y delitos (array).
@freezed
class CriminalDetailDto with _$CriminalDetailDto {
  const factory CriminalDetailDto({
    required int idRequisitoriado,
    required String hashRequisitoriado,
    @Default('') String apellidoPaterno,
    @Default('') String apellidoMaterno,
    @Default('') String nombres,
    @Default(1) int sexo,
    @Default(0.0) double montoRecompensa,
    @Default('') String montoRecompensaSpace,
    String? foto,
    @Default([]) List<String> delitos,
    @Default('') String departamento,
    @Default('') String provincia,
  }) = _CriminalDetailDto;

  factory CriminalDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CriminalDetailDtoFromJson(json);
}
