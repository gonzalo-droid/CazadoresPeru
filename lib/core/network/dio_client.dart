import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';

part 'dio_client.g.dart';

@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json; charset=UTF-8',
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'es-PE,es;q=0.9,en;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'Origin': 'https://recompensas.pe',
        'Referer': 'https://recompensas.pe/',
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148',
        'Connection': 'keep-alive',
      },
    ),
  );

  // Android's BoringSSL rejects the MININTER server's incomplete cert chain.
  // Bypass certificate validation in debug builds only.
  if (!kIsWeb) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) {
        debugPrint('[SSL] Bad cert for $host:$port — ${cert.subject}');
        return kDebugMode; // allow in debug, reject in release
      };
      return client;
    };
  }

  dio.interceptors.addAll([
    _RetryInterceptor(dio),
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: false,
      maxWidth: 200,
    ),
  ]);

  return dio;
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this.dio);

  final Dio dio;
  static const int _maxRetries = 3;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Log the real underlying error for debugging
    final cause = err.error;
    if (cause != null) {
      debugPrint('[DIO] Underlying error type: ${cause.runtimeType}');
      debugPrint('[DIO] Underlying error: $cause');
      if (cause is SocketException) {
        debugPrint('[DIO] SocketException address: ${cause.address}');
        debugPrint('[DIO] SocketException osError: ${cause.osError}');
      } else if (cause is HandshakeException) {
        debugPrint('[DIO] HandshakeException message: ${cause.message}');
      } else if (cause is TlsException) {
        debugPrint('[DIO] TlsException message: ${cause.message}');
      }
    }

    final extra = err.requestOptions.extra;
    final retryCount = (extra['retryCount'] as int?) ?? 0;

    final shouldRetry = retryCount < _maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout);

    if (shouldRetry) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      await Future<void>.delayed(Duration(seconds: retryCount + 1));
      try {
        final response = await dio.fetch<dynamic>(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {}
    }

    handler.next(err);
  }
}
