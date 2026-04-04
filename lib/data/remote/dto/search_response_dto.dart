import 'package:freezed_annotation/freezed_annotation.dart';
import 'criminal_summary_dto.dart';

part 'search_response_dto.freezed.dart';
part 'search_response_dto.g.dart';

/// Respuesta paginada de Spring Boot.
/// Nota: `number` es 0-indexed en Spring (primera página = 0).
@freezed
class SearchResponseDto with _$SearchResponseDto {
  const factory SearchResponseDto({
    @Default([]) List<CriminalSummaryDto> content,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
    @Default(0) int number,   // 0-indexed
    @Default(false) bool last,
    @Default(false) bool first,
    @Default(0) int numberOfElements,
    @Default(false) bool empty,
  }) = _SearchResponseDto;

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseDtoFromJson(json);
}
