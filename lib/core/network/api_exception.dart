import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_exception.freezed.dart';

@freezed
class ApiException with _$ApiException implements Exception {
  const factory ApiException.network({required String message}) = NetworkException;
  const factory ApiException.server({
    required int statusCode,
    required String message,
  }) = ServerException;
  const factory ApiException.timeout() = TimeoutException;
  const factory ApiException.unauthorized() = UnauthorizedException;
  const factory ApiException.notFound() = NotFoundException;
  const factory ApiException.unknown({required String message}) = UnknownException;

  static ApiException fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException.timeout();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode == 401) return const ApiException.unauthorized();
        if (statusCode == 404) return const ApiException.notFound();
        return ApiException.server(
          statusCode: statusCode,
          message: e.response?.statusMessage ?? 'Error del servidor',
        );
      case DioExceptionType.connectionError:
        return ApiException.network(
          message: 'Sin conexión a internet',
        );
      default:
        return ApiException.unknown(message: e.message ?? 'Error desconocido');
    }
  }

  static String toUserMessage(ApiException exception) {
    return exception.when(
      network: (_) => 'Sin conexión a internet. Verifica tu red.',
      server: (code, msg) => 'Error del servidor ($code). Intenta más tarde.',
      timeout: () => 'La solicitud tardó demasiado. Intenta de nuevo.',
      unauthorized: () => 'Sin autorización para acceder.',
      notFound: () => 'Recurso no encontrado.',
      unknown: (msg) => 'Error inesperado: $msg',
    );
  }
}
