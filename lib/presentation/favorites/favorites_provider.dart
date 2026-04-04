import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/criminal_summary.dart';
import '../../data/repositories/criminal_repository_impl.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

part 'favorites_provider.g.dart';

@riverpod
Stream<List<CriminalSummary>> favoritesStream(FavoritesStreamRef ref) {
  return ref.watch(criminalRepositoryProvider).watchFavorites();
}

@riverpod
Future<void> removeFavorite(
  RemoveFavoriteRef ref,
  CriminalSummary criminal,
) async {
  await ref.read(toggleFavoriteUseCaseProvider).call(criminal);
}
