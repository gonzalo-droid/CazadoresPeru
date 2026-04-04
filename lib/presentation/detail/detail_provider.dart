import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/criminal_summary.dart';
import '../../domain/usecases/get_criminal_detail_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../../data/repositories/criminal_repository_impl.dart';

part 'detail_provider.g.dart';

@riverpod
Future<CriminalSummary> criminalDetail(
  CriminalDetailRef ref,
  String hash,
) async {
  final useCase = ref.watch(getCriminalDetailUseCaseProvider);
  final result = await useCase(hash);
  return result.fold(
    (error) => throw Exception(error.toString()),
    (criminal) => criminal,
  );
}

@riverpod
Stream<bool> isFavoriteDetail(IsFavoriteDetailRef ref, String hash) {
  return ref
      .watch(criminalRepositoryProvider)
      .watchFavorites()
      .map((favs) => favs.any((f) => f.hashRequisitoriado == hash));
}

@riverpod
class FavoriteToggleNotifier extends _$FavoriteToggleNotifier {
  @override
  AsyncValue<bool> build(String hash) => const AsyncValue.loading();

  Future<void> toggle(CriminalSummary criminal) async {
    state = const AsyncValue.loading();
    try {
      final newState =
          await ref.read(toggleFavoriteUseCaseProvider).call(criminal);
      state = AsyncValue.data(newState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
