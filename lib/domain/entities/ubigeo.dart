import 'package:freezed_annotation/freezed_annotation.dart';

part 'ubigeo.freezed.dart';
part 'ubigeo.g.dart';

@freezed
class Departamento with _$Departamento {
  const factory Departamento({
    required String codigo,
    required String descripcion,
  }) = _Departamento;

  factory Departamento.fromJson(Map<String, dynamic> json) =>
      _$DepartamentoFromJson(json);
}

@freezed
class Provincia with _$Provincia {
  const factory Provincia({
    required String departamentoCodigo,
    required String codigo,
    required String descripcion,
  }) = _Provincia;

  factory Provincia.fromJson(Map<String, dynamic> json) =>
      _$ProvinciaFromJson(json);
}
