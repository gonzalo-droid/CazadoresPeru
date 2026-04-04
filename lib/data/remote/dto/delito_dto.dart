import 'package:freezed_annotation/freezed_annotation.dart';

part 'delito_dto.freezed.dart';
part 'delito_dto.g.dart';

@freezed
class DelitoDto with _$DelitoDto {
  const factory DelitoDto({
    required int idDelito,
    required String descripcion,
  }) = _DelitoDto;

  factory DelitoDto.fromJson(Map<String, dynamic> json) =>
      _$DelitoDtoFromJson(json);
}
