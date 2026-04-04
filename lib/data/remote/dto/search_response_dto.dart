import 'package:freezed_annotation/freezed_annotation.dart';
import 'criminal_summary_dto.dart';

part 'search_response_dto.freezed.dart';
part 'search_response_dto.g.dart';

@freezed
class SearchResponseDto with _$SearchResponseDto {
  const factory SearchResponseDto({
    @Default([]) List<CriminalSummaryDto> content,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
    @Default(1) int number,
    @Default(false) bool last,
    @Default(false) bool first,
  }) = _SearchResponseDto;

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseDtoFromJson(json);
}
