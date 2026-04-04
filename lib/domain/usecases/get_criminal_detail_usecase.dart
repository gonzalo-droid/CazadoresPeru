import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/api_exception.dart';
import '../../data/repositories/criminal_repository_impl.dart';
import '../entities/criminal_summary.dart';
import '../repositories/criminal_repository.dart';

part 'get_criminal_detail_usecase.g.dart';

class GetCriminalDetailUseCase {
  GetCriminalDetailUseCase(this._repository);

  final CriminalRepository _repository;

  Future<Either<ApiException, CriminalSummary>> call(String hash) =>
      _repository.getCriminalByHash(hash);
}

@riverpod
GetCriminalDetailUseCase getCriminalDetailUseCase(
  GetCriminalDetailUseCaseRef ref,
) {
  return GetCriminalDetailUseCase(ref.watch(criminalRepositoryProvider));
}
