import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client.dart';
import 'dto/criminal_summary_dto.dart';
import 'dto/delito_dto.dart';
import 'dto/search_request_dto.dart';
import 'dto/search_response_dto.dart';
import 'dto/ubigeo_dto.dart';

part 'api_service.g.dart';

class ApiService {
  ApiService(this._dio);

  final Dio _dio;

  Future<List<DelitoDto>> getDelitos() async {
    final response = await _dio.get<List<dynamic>>('/delitos');
    return (response.data as List)
        .map((e) => DelitoDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DepartamentoDto>> getDepartamentos() async {
    final response = await _dio.get<List<dynamic>>('/ubigeo/departamentos');
    return (response.data as List)
        .map((e) => DepartamentoDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProvinciaDto>> getProvincias(String departamentoId) async {
    final response = await _dio
        .get<List<dynamic>>('/ubigeo/provincias/departamento/$departamentoId');
    return (response.data as List)
        .map((e) => ProvinciaDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Búsqueda paginada de requisitoriados.
  /// Endpoint real: POST /requisitoriados/search/pageandfilter
  Future<SearchResponseDto> buscarRequisitoriados(
    SearchRequestDto request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/requisitoriados/pageandfilter',
      data: request.toJson(),
    );
    return SearchResponseDto.fromJson(response.data!);
  }

  /// Top 5 más buscados por recompensa.
  /// Endpoint real: POST /requisitoriados/top5
  Future<List<CriminalSummaryDto>> getTop5() async {
    final response = await _dio.post<List<dynamic>>(
      '/requisitoriados/top5',
      data: <String, dynamic>{},
    );
    return (response.data as List)
        .map((e) => CriminalSummaryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Detalle completo de un criminal por hash.
  /// Endpoint real: GET /requisitoriados/{hash}
  Future<CriminalDetailDto> getRequisitoriadoByHash(String hash) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/requisitoriados/$hash');
    return CriminalDetailDto.fromJson(response.data!);
  }
}

@Riverpod(keepAlive: true)
ApiService apiService(ApiServiceRef ref) {
  final dio = ref.watch(dioClientProvider);
  return ApiService(dio);
}
