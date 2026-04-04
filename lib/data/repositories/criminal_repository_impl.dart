import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/api_exception.dart';
import '../../domain/entities/criminal_summary.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/repositories/criminal_repository.dart';
import '../local/isar_service.dart';
import '../local/schemas/cached_criminal_schema.dart';
import '../local/schemas/favorite_schema.dart';
import '../remote/api_service.dart';
import '../remote/dto/search_request_dto.dart';

part 'criminal_repository_impl.g.dart';

class CriminalRepositoryImpl implements CriminalRepository {
  CriminalRepositoryImpl({
    required this.apiService,
    required this.isarService,
    required this.connectivity,
  });

  final ApiService apiService;
  final IsarService isarService;
  final Connectivity connectivity;

  // ─── Search ───────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiException, PaginatedResult<CriminalSummary>>> searchCriminals(
    SearchFilters filters,
  ) async {
    final searchKey = _buildSearchKey(filters);
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (!isOnline) {
      return _getCachedResults(searchKey, filters);
    }

    try {
      final request = SearchRequestDto(
        pageInfo: PageInfoDto(
          page: filters.page,
          size: filters.size,
          sortBy: filters.sortBy,
          direction: filters.direction,
        ),
        search: SearchFiltersDto(
          nombreCompleto: filters.nombreCompleto,
          tipoFilter: filters.tipoFilter,
          alias: filters.alias,
          idDepartamento: filters.idDepartamento,
          idProvincia: filters.idProvincia,
          idDelito: filters.idDelito,
          delito: filters.delito,
          sexo: filters.sexo,
        ),
      );

      final response = await apiService.buscarRequisitoriados(request);
      final items = response.content
          .map(
            (dto) => CriminalSummary(
              idRequisitoriado: dto.idRequisitoriado,
              hashRequisitoriado: dto.hashRequisitoriado,
              apellidoPaterno: dto.apellidoPaterno,
              apellidoMaterno: dto.apellidoMaterno,
              nombres: dto.nombres,
              sexo: dto.sexo,
              montoRecompensa: dto.montoRecompensa,
              montoRecompensaSpace: dto.montoRecompensaSpace,
              foto: dto.foto,
              delitos: dto.delitos,
              departamento: dto.departamento,
              provincia: dto.provincia,
            ),
          )
          .toList();

      // Cache first page
      if (filters.page == 1) {
        unawaited(_cacheResults(items, searchKey));
      }

      return Right(
        PaginatedResult(
          items: items,
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          currentPage: response.number,
          isLast: response.last,
        ),
      );
    } on DioException catch (e) {
      return Left(ApiException.fromDioException(e));
    } catch (e) {
      return Left(ApiException.unknown(message: e.toString()));
    }
  }

  // ─── Detail ───────────────────────────────────────────────────────────────

  @override
  Future<Either<ApiException, CriminalSummary>> getCriminalByHash(
    String hash,
  ) async {
    try {
      final dto = await apiService.getRequisitoriadoByHash(hash);
      return Right(
        CriminalSummary(
          idRequisitoriado: dto.idRequisitoriado,
          hashRequisitoriado: dto.hashRequisitoriado,
          apellidoPaterno: dto.apellidoPaterno,
          apellidoMaterno: dto.apellidoMaterno,
          nombres: dto.nombres,
          sexo: dto.sexo,
          montoRecompensa: dto.montoRecompensa,
          montoRecompensaSpace: dto.montoRecompensaSpace,
          foto: dto.foto,
          delitos: dto.delitos,
          departamento: dto.departamento,
          provincia: dto.provincia,
        ),
      );
    } on DioException catch (e) {
      return Left(ApiException.fromDioException(e));
    } catch (e) {
      return Left(ApiException.unknown(message: e.toString()));
    }
  }

  // ─── Favorites ────────────────────────────────────────────────────────────

  @override
  Future<List<CriminalSummary>> getFavorites() async {
    final schemas = await isarService.getAllFavorites();
    return schemas.map(_favoriteToEntity).toList();
  }

  @override
  Stream<List<CriminalSummary>> watchFavorites() {
    return isarService.watchFavorites().map(
          (schemas) => schemas.map(_favoriteToEntity).toList(),
        );
  }

  @override
  Future<bool> isFavorite(String hash) => isarService.isFavorite(hash);

  @override
  Future<void> addFavorite(CriminalSummary criminal) async {
    final schema = FavoriteSchema()
      ..hash = criminal.hashRequisitoriado
      ..idRequisitoriado = criminal.idRequisitoriado
      ..apellidoPaterno = criminal.apellidoPaterno
      ..apellidoMaterno = criminal.apellidoMaterno
      ..nombres = criminal.nombres
      ..sexo = criminal.sexo
      ..montoRecompensa = criminal.montoRecompensa
      ..montoRecompensaSpace = criminal.montoRecompensaSpace
      ..fotoBase64 = criminal.foto
      ..delitos = criminal.delitos
      ..departamento = criminal.departamento
      ..provincia = criminal.provincia
      ..savedAt = DateTime.now();
    await isarService.addFavorite(schema);
  }

  @override
  Future<void> removeFavorite(String hash) => isarService.removeFavorite(hash);

  // ─── Private helpers ──────────────────────────────────────────────────────

  String _buildSearchKey(SearchFilters filters) {
    return [
      filters.nombreCompleto ?? '',
      filters.alias ?? '',
      filters.idDepartamento ?? '',
      filters.idProvincia ?? '',
      filters.idDelito ?? '',
      filters.sexo ?? '',
      filters.sortBy,
      filters.direction,
    ].join('|');
  }

  Future<Either<ApiException, PaginatedResult<CriminalSummary>>>
      _getCachedResults(String searchKey, SearchFilters filters) async {
    final cached = await isarService.getCachedBySearchKey(
      searchKey,
      filters.page,
      filters.size,
    );
    if (cached.isEmpty) {
      return Left(
        const ApiException.network(
          message: 'Sin conexión y sin datos en caché.',
        ),
      );
    }
    return Right(
      PaginatedResult(
        items: cached.map(_cachedToEntity).toList(),
        totalElements: cached.length,
        totalPages: 1,
        currentPage: 1,
        isLast: true,
      ),
    );
  }

  Future<void> _cacheResults(
    List<CriminalSummary> items,
    String searchKey,
  ) async {
    final schemas = items
        .map(
          (c) => CachedCriminalSchema()
            ..hash = c.hashRequisitoriado
            ..idRequisitoriado = c.idRequisitoriado
            ..apellidoPaterno = c.apellidoPaterno
            ..apellidoMaterno = c.apellidoMaterno
            ..nombres = c.nombres
            ..sexo = c.sexo
            ..montoRecompensa = c.montoRecompensa
            ..montoRecompensaSpace = c.montoRecompensaSpace
            ..fotoBase64 = c.foto
            ..delitos = c.delitos
            ..departamento = c.departamento
            ..provincia = c.provincia
            ..cachedAt = DateTime.now()
            ..searchKey = searchKey,
        )
        .toList();
    await isarService.cacheResults(schemas, searchKey);
  }

  CriminalSummary _favoriteToEntity(FavoriteSchema s) => CriminalSummary(
        idRequisitoriado: s.idRequisitoriado,
        hashRequisitoriado: s.hash,
        apellidoPaterno: s.apellidoPaterno,
        apellidoMaterno: s.apellidoMaterno,
        nombres: s.nombres,
        sexo: s.sexo,
        montoRecompensa: s.montoRecompensa,
        montoRecompensaSpace: s.montoRecompensaSpace,
        foto: s.fotoBase64,
        delitos: s.delitos,
        departamento: s.departamento,
        provincia: s.provincia,
      );

  CriminalSummary _cachedToEntity(CachedCriminalSchema s) => CriminalSummary(
        idRequisitoriado: s.idRequisitoriado,
        hashRequisitoriado: s.hash,
        apellidoPaterno: s.apellidoPaterno,
        apellidoMaterno: s.apellidoMaterno,
        nombres: s.nombres,
        sexo: s.sexo,
        montoRecompensa: s.montoRecompensa,
        montoRecompensaSpace: s.montoRecompensaSpace,
        foto: s.fotoBase64,
        delitos: s.delitos,
        departamento: s.departamento,
        provincia: s.provincia,
      );
}

void unawaited(Future<void> future) {}

@Riverpod(keepAlive: true)
CriminalRepository criminalRepository(CriminalRepositoryRef ref) {
  return CriminalRepositoryImpl(
    apiService: ref.watch(apiServiceProvider),
    isarService: ref.watch(isarServiceProvider).requireValue,
    connectivity: Connectivity(),
  );
}
