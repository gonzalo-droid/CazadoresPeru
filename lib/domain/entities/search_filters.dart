import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_filters.freezed.dart';
part 'search_filters.g.dart';

@freezed
class SearchFilters with _$SearchFilters {
  const factory SearchFilters({
    String? nombreCompleto,
    @Default('F') String tipoFilter,
    String? alias,
    String? idDepartamento,
    String? idProvincia,
    String? idDelito,
    String? delito,
    String? sexo,
    double? montoMin,
    double? montoMax,
    @Default(1) int page,
    @Default(20) int size,
    @Default('id') String sortBy,
    @Default('desc') String direction,
  }) = _SearchFilters;

  factory SearchFilters.fromJson(Map<String, dynamic> json) =>
      _$SearchFiltersFromJson(json);
}

extension SearchFiltersX on SearchFilters {
  bool get hasActiveFilters =>
      nombreCompleto != null ||
      alias != null ||
      idDepartamento != null ||
      idProvincia != null ||
      idDelito != null ||
      sexo != null;

  int get activeFilterCount {
    var count = 0;
    if (nombreCompleto != null) count++;
    if (alias != null) count++;
    if (idDepartamento != null) count++;
    if (idProvincia != null) count++;
    if (idDelito != null) count++;
    if (sexo != null) count++;
    return count;
  }

  SearchFilters nextPage() => copyWith(page: page + 1);
  SearchFilters resetPage() => copyWith(page: 1);
}
