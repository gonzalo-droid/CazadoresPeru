import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../shared/widgets/criminal_photo.dart';
import '../shared/widgets/reward_badge.dart';
import 'favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardados'),
      ),
      body: favAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Error cargando favoritos')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const Gap(16),
                  Text(
                    'Sin guardados',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(8),
                  Text(
                    'Guarda criminales desde el buscador\npara acceder offline.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final criminal = items[i];
              return Dismissible(
                key: Key(criminal.hashRequisitoriado),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(removeFavoriteProvider(criminal).future);
                },
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Quitar de guardados'),
                      content: const Text(
                        '¿Eliminar este criminal de tu lista de seguimiento?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                },
                child: ListTile(
                  leading: CriminalPhoto(
                    base64Photo: criminal.foto,
                    size: 52,
                  ),
                  title: Text(
                    '${criminal.apellidoPaterno} ${criminal.apellidoMaterno}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${criminal.departamento} — ${criminal.delitos.isNotEmpty ? criminal.delitos.first : ""}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: RewardBadge(amount: criminal.montoRecompensa),
                  onTap: () => context.push(
                    '${AppRoutes.detail}/${criminal.hashRequisitoriado}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
