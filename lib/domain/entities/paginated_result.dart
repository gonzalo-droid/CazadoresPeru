import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_result.freezed.dart';

@freezed
class PaginatedResult<T> with _$PaginatedResult<T> {
  const factory PaginatedResult({
    required List<T> items,
    required int totalElements,
    required int totalPages,
    required int currentPage,
    required bool isLast,
  }) = _PaginatedResult<T>;
}
