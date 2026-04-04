import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/criminal_summary.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/usecases/search_criminals_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

part 'search_provider.g.dart';

// ─── Search state ─────────────────────────────────────────────────────────────

class SearchState {
  const SearchState({
    this.items = const [],
    this.filters = const SearchFilters(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.error,
    this.isOffline = false,
    this.totalElements = 0,
  });

  final List<CriminalSummary> items;
  final SearchFilters filters;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? error;
  final bool isOffline;
  final int totalElements;

  SearchState copyWith({
    List<CriminalSummary>? items,
    SearchFilters? filters,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? error,
    bool clearError = false,
    bool? isOffline,
    int? totalElements,
  }) {
    return SearchState(
      items: items ?? this.items,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      error: clearError ? null : error ?? this.error,
      isOffline: isOffline ?? this.isOffline,
      totalElements: totalElements ?? this.totalElements,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  SearchState build() => const SearchState();

  Future<void> search({SearchFilters? filters}) async {
    final newFilters = (filters ?? state.filters).resetPage();
    state = state.copyWith(
      isLoading: true,
      items: [],
      filters: newFilters,
      hasReachedEnd: false,
      clearError: true,
    );
    await _fetchPage(newFilters);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd || state.isLoading) return;
    final nextFilters = state.filters.nextPage();
    state = state.copyWith(isLoadingMore: true, filters: nextFilters);
    await _fetchPage(nextFilters, append: true);
  }

  Future<void> refresh() => search(filters: state.filters.resetPage());

  void updateFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
  }

  void clearFilters() {
    search(filters: const SearchFilters());
  }

  Future<void> _fetchPage(SearchFilters filters, {bool append = false}) async {
    final useCase = ref.read(searchCriminalsUseCaseProvider);
    final result = await useCase(filters);

    result.fold(
      (error) {
        final isOffline = error.when(
          network: (_) => true,
          server: (_, __) => false,
          timeout: () => false,
          unauthorized: () => false,
          notFound: () => false,
          unknown: (_) => false,
        );
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: _errorMessage(error),
          isOffline: isOffline,
        );
      },
      (paginated) {
        final newItems = append
            ? [...state.items, ...paginated.items]
            : paginated.items;
        state = state.copyWith(
          items: newItems,
          isLoading: false,
          isLoadingMore: false,
          hasReachedEnd: paginated.isLast,
          totalElements: paginated.totalElements,
          clearError: true,
          isOffline: false,
        );
      },
    );
  }

  String _errorMessage(dynamic error) {
    return error.toString();
  }
}

// ─── Favorite toggle ──────────────────────────────────────────────────────────

@riverpod
Future<void> toggleFavoriteSearch(
  ToggleFavoriteSearchRef ref,
  CriminalSummary criminal,
) async {
  await ref.read(toggleFavoriteUseCaseProvider).call(criminal);
}
