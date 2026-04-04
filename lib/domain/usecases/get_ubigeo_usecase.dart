import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/ubigeo_repository_impl.dart';
import '../entities/delito.dart';
import '../entities/ubigeo.dart';
import '../repositories/ubigeo_repository.dart';

part 'get_ubigeo_usecase.g.dart';

class GetUbigeoUseCase {
  GetUbigeoUseCase(this._repository);

  final UbigeoRepository _repository;

  Future<List<Departamento>> getDepartamentos() =>
      _repository.getDepartamentos();

  Future<List<Provincia>> getProvincias(String departamentoCodigo) =>
      _repository.getProvincias(departamentoCodigo);

  Future<List<Delito>> getDelitos() => _repository.getDelitos();
}

@riverpod
GetUbigeoUseCase getUbigeoUseCase(GetUbigeoUseCaseRef ref) {
  return GetUbigeoUseCase(ref.watch(ubigeoRepositoryProvider));
}
