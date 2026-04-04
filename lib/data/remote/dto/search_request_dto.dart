import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_request_dto.freezed.dart';
part 'search_request_dto.g.dart';

@freezed
class SearchRequestDto with _$SearchRequestDto {
  const factory SearchRequestDto({
    required PageInfoDto pageInfo,
    required SearchFiltersDto search,
  }) = _SearchRequestDto;

  factory SearchRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SearchRequestDtoFromJson(json);
}

@freezed
class PageInfoDto with _$PageInfoDto {
  const factory PageInfoDto({
    @Default(1) int page,
    @Default(20) int size,
    @Default('id') String sortBy,
    @Default('desc') String direction,
  }) = _PageInfoDto;

  factory PageInfoDto.fromJson(Map<String, dynamic> json) =>
      _$PageInfoDtoFromJson(json);
}

@freezed
class SearchFiltersDto with _$SearchFiltersDto {
  const factory SearchFiltersDto({
    String? nombreCompleto,
    @Default('F') String tipoFilter,
    String? alias,
    String? idDepartamento,
    String? idProvincia,
    String? idDelito,
    String? delito,
    String? sexo,
  }) = _SearchFiltersDto;

  factory SearchFiltersDto.fromJson(Map<String, dynamic> json) =>
      _$SearchFiltersDtoFromJson(json);
}
