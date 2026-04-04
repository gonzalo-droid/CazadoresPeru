import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/peligrosidad.dart';
import '../../../data/repositories/criminal_repository_impl.dart';
import '../../../domain/entities/criminal_summary.dart';
import '../../shared/widgets/criminal_photo.dart';
import '../../shared/widgets/reward_badge.dart';
import '../search_provider.dart';

class CriminalCard extends ConsumerWidget {
  const CriminalCard({
    super.key,
    required this.criminal,
    this.heroTag,
  });

  final CriminalSummary criminal;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nivel = PeligrosidadHelper.calcular(criminal.delitos);
    final tag = heroTag ?? 'criminal_${criminal.hashRequisitoriado}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          '${AppRoutes.detail}/${criminal.hashRequisitoriado}',
          extra: {'heroTag': tag},
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Photo
              Hero(
                tag: tag,
                child: CriminalPhoto(
                  base64Photo: criminal.foto,
                  size: 68,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      Formatters.formatFullName(
                        apellidoPaterno: criminal.apellidoPaterno,
                        apellidoMaterno: criminal.apellidoMaterno,
                        nombres: criminal.nombres,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${criminal.departamento} — ${criminal.provincia}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Chips row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Peligrosidad chip
                        _PeligrosidadChip(nivel: nivel),

                        // Delito chip
                        if (criminal.delitos.isNotEmpty)
                          _DelitoChip(
                            label: Formatters.firstDelito(criminal.delitos),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Reward + bookmark row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RewardBadge(amount: criminal.montoRecompensa),
                        _FavoriteButton(criminal: criminal),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeligrosidadChip extends StatelessWidget {
  const _PeligrosidadChip({required this.nivel});

  final NivelPeligrosidad nivel;

  @override
  Widget build(BuildContext context) {
    final color = PeligrosidadHelper.color(nivel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PeligrosidadHelper.icon(nivel), size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            PeligrosidadHelper.label(nivel),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DelitoChip extends StatelessWidget {
  const _DelitoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.criminal});

  final CriminalSummary criminal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real favorite state
    final favStream = ref.watch(
      StreamProvider(
        (sRef) => sRef
            .watch(criminalRepositoryProvider)
            .watchFavorites()
            .map(
              (list) => list.any(
                (c) => c.hashRequisitoriado == criminal.hashRequisitoriado,
              ),
            ),
      ),
    );

    final isCurrentlyFav = favStream.valueOrNull ?? false;

    return IconButton(
      icon: Icon(
        isCurrentlyFav ? Icons.bookmark : Icons.bookmark_outline,
        color: isCurrentlyFav
            ? Theme.of(context).colorScheme.primary
            : AppColors.textSecondaryLight,
      ),
      onPressed: () {
        ref.read(toggleFavoriteSearchProvider(criminal).future);
      },
      tooltip: isCurrentlyFav ? 'Quitar de guardados' : 'Guardar',
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
