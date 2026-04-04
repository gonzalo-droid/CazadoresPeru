import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/criminal_repository_impl.dart';
import '../entities/criminal_summary.dart';
import '../repositories/criminal_repository.dart';

part 'toggle_favorite_usecase.g.dart';

class ToggleFavoriteUseCase {
  ToggleFavoriteUseCase(this._repository);

  final CriminalRepository _repository;

  Future<bool> call(CriminalSummary criminal) async {
    final isFav = await _repository.isFavorite(criminal.hashRequisitoriado);
    if (isFav) {
      await _repository.removeFavorite(criminal.hashRequisitoriado);
      return false;
    } else {
      await _repository.addFavorite(criminal);
      return true;
    }
  }
}

@riverpod
ToggleFavoriteUseCase toggleFavoriteUseCase(ToggleFavoriteUseCaseRef ref) {
  return ToggleFavoriteUseCase(ref.watch(criminalRepositoryProvider));
}
