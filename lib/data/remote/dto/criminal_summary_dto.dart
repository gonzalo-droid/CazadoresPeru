import 'package:freezed_annotation/freezed_annotation.dart';

part 'criminal_summary_dto.freezed.dart';
part 'criminal_summary_dto.g.dart';

@freezed
class CriminalSummaryDto with _$CriminalSummaryDto {
  const factory CriminalSummaryDto({
    required int idRequisitoriado,
    required String hashRequisitoriado,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String nombres,
    required int sexo,
    required double montoRecompensa,
    required String montoRecompensaSpace,
    String? foto,
    @Default([]) List<String> delitos,
    @Default('') String departamento,
    @Default('') String provincia,
  }) = _CriminalSummaryDto;

  factory CriminalSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$CriminalSummaryDtoFromJson(json);
}
