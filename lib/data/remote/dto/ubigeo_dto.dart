import 'package:freezed_annotation/freezed_annotation.dart';

part 'ubigeo_dto.freezed.dart';
part 'ubigeo_dto.g.dart';

@freezed
class DepartamentoDto with _$DepartamentoDto {
  const factory DepartamentoDto({
    required String departamento,
    required String provincia,
    required String descripcion,
  }) = _DepartamentoDto;

  factory DepartamentoDto.fromJson(Map<String, dynamic> json) =>
      _$DepartamentoDtoFromJson(json);
}

@freezed
class ProvinciaDto with _$ProvinciaDto {
  const factory ProvinciaDto({
    required String departamento,
    required String provincia,
    required String descripcion,
  }) = _ProvinciaDto;

  factory ProvinciaDto.fromJson(Map<String, dynamic> json) =>
      _$ProvinciaDtoFromJson(json);
}
