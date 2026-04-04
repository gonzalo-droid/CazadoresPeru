import 'package:isar/isar.dart';

part 'cached_criminal_schema.g.dart';

@collection
class CachedCriminalSchema {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String hash;

  late int idRequisitoriado;
  late String apellidoPaterno;
  late String apellidoMaterno;
  late String nombres;
  late int sexo;
  late double montoRecompensa;
  late String montoRecompensaSpace;
  String? fotoBase64;
  late List<String> delitos;
  late String departamento;
  late String provincia;

  late DateTime cachedAt;
  late String searchKey; // Clave para agrupar por búsqueda
}
