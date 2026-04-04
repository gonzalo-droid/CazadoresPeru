import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/api_exception.dart';
import '../../data/repositories/criminal_repository_impl.dart';
import '../entities/criminal_summary.dart';
import '../entities/paginated_result.dart';
import '../entities/search_filters.dart';
import '../repositories/criminal_repository.dart';

part 'search_criminals_usecase.g.dart';

class SearchCriminalsUseCase {
  SearchCriminalsUseCase(this._repository);

  final CriminalRepository _repository;

  Future<Either<ApiException, PaginatedResult<CriminalSummary>>> call(
    SearchFilters filters,
  ) =>
      _repository.searchCriminals(filters);
}

@riverpod
SearchCriminalsUseCase searchCriminalsUseCase(SearchCriminalsUseCaseRef ref) {
  return SearchCriminalsUseCase(ref.watch(criminalRepositoryProvider));
}
