import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/delito.dart';
import '../../domain/entities/ubigeo.dart';
import '../../domain/repositories/ubigeo_repository.dart';

part 'ubigeo_repository_impl.g.dart';

/// Lee datos desde los assets JSON locales.
/// No requiere red — datos pre-descargados en assets/data/.
class UbigeoRepositoryImpl implements UbigeoRepository {
  List<Departamento>? _departamentos;
  Map<String, List<Provincia>>? _provincias;
  List<Delito>? _delitos;

  @override
  Future<List<Departamento>> getDepartamentos() async {
    _departamentos ??= await _loadDepartamentos();
    return _departamentos!;
  }

  @override
  Future<List<Provincia>> getProvincias(String departamentoCodigo) async {
    _provincias ??= await _loadProvincias();
    return _provincias![departamentoCodigo] ?? [];
  }

  @override
  Future<List<Delito>> getDelitos() async {
    _delitos ??= await _loadDelitos();
    return _delitos!;
  }

  Future<List<Departamento>> _loadDepartamentos() async {
    final json = await rootBundle.loadString('assets/data/departamentos.json');
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map(
          (e) => Departamento(
            codigo: e['departamento'] as String,
            descripcion: e['descripcion'] as String,
          ),
        )
        .toList();
  }

  Future<Map<String, List<Provincia>>> _loadProvincias() async {
    final json = await rootBundle.loadString('assets/data/provincias.json');
    final list = jsonDecode(json) as List<dynamic>;
    final map = <String, List<Provincia>>{};
    for (final e in list) {
      final dep = e['departamento'] as String;
      map.putIfAbsent(dep, () => []).add(
            Provincia(
              departamentoCodigo: dep,
              codigo: e['provincia'] as String,
              descripcion: e['descripcion'] as String,
            ),
          );
    }
    return map;
  }

  Future<List<Delito>> _loadDelitos() async {
    final json = await rootBundle.loadString('assets/data/delitos.json');
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map(
          (e) => Delito(
            idDelito: e['idDelito'] as int,
            descripcion: e['descripcion'] as String,
          ),
        )
        .toList();
  }
}

@Riverpod(keepAlive: true)
UbigeoRepository ubigeoRepository(UbigeoRepositoryRef ref) {
  return UbigeoRepositoryImpl();
}
