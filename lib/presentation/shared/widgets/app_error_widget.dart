import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_colors.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  static _ErrorInfo _classify(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          return const _ErrorInfo(
            icon: Icons.wifi_off_rounded,
            title: 'Sin conexión',
            message: 'Verifica tu conexión a internet e intenta nuevamente.',
          );
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const _ErrorInfo(
            icon: Icons.timer_off_rounded,
            title: 'Tiempo agotado',
            message: 'El servidor tardó demasiado. Intenta en unos momentos.',
          );
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode ?? 0;
          if (code == 404) {
            return const _ErrorInfo(
              icon: Icons.search_off_rounded,
              title: 'No encontrado',
              message: 'El recurso solicitado no está disponible.',
            );
          }
          if (code >= 500) {
            return const _ErrorInfo(
              icon: Icons.cloud_off_rounded,
              title: 'Servicio no disponible',
              message: 'El servicio de MININTER presenta problemas. Intenta más tarde.',
            );
          }
          return const _ErrorInfo(
            icon: Icons.error_outline_rounded,
            title: 'Error del servidor',
            message: 'Ocurrió un error inesperado. Intenta nuevamente.',
          );
        case DioExceptionType.cancel:
          return const _ErrorInfo(
            icon: Icons.cancel_outlined,
            title: 'Solicitud cancelada',
            message: 'La operación fue cancelada.',
          );
        case DioExceptionType.badCertificate:
          return const _ErrorInfo(
            icon: Icons.lock_outline,
            title: 'Error de seguridad',
            message: 'No se pudo establecer conexión segura con el servidor.',
          );
      }
    }
    return const _ErrorInfo(
      icon: Icons.error_outline_rounded,
      title: 'Error inesperado',
      message: 'Algo salió mal. Por favor intenta nuevamente.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _classify(error);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 16, color: AppColors.error),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              info.title,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRetry,
              child: const Text(
                'Reintentar',
                style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, size: 48, color: AppColors.error),
            ),
            const Gap(16),
            Text(
              info.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              info.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const Gap(24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorInfo {
  const _ErrorInfo({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}
