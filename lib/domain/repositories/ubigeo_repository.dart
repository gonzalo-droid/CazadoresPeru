import '../entities/delito.dart';
import '../entities/ubigeo.dart';

abstract class UbigeoRepository {
  Future<List<Departamento>> getDepartamentos();

  Future<List<Provincia>> getProvincias(String departamentoCodigo);

  Future<List<Delito>> getDelitos();
}
