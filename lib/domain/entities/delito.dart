import 'package:freezed_annotation/freezed_annotation.dart';

part 'delito.freezed.dart';
part 'delito.g.dart';

@freezed
class Delito with _$Delito {
  const factory Delito({
    required int idDelito,
    required String descripcion,
  }) = _Delito;

  factory Delito.fromJson(Map<String, dynamic> json) =>
      _$DelitoFromJson(json);
}
