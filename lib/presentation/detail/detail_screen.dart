import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_launcher.dart';
import '../../core/utils/base64_utils.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/peligrosidad.dart';
import '../../domain/entities/criminal_summary.dart';
import '../report/report_bottom_sheet.dart';
import '../shared/widgets/app_error_widget.dart';
import '../shared/widgets/disclaimer_banner.dart';
import '../shared/widgets/reward_badge.dart';
import 'detail_provider.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({
    super.key,
    required this.hash,
    this.heroTag,
  });

  final String hash;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(criminalDetailProvider(hash));
    final isFavAsync = ref.watch(isFavoriteDetailProvider(hash));
    final tag = heroTag ?? 'criminal_$hash';

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => _ErrorBody(error: e, hash: hash, ref: ref),
        data: (criminal) => _DetailBody(
          criminal: criminal,
          heroTag: tag,
          isFavorite: isFavAsync.valueOrNull ?? false,
          onToggleFavorite: () {
            ref
                .read(favoriteToggleNotifierProvider(hash).notifier)
                .toggle(criminal);
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.criminal,
    required this.heroTag,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final CriminalSummary criminal;
  final String heroTag;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final nivel = PeligrosidadHelper.calcular(criminal.allDelitos);
    final peligroColor = PeligrosidadHelper.color(nivel);
    final fullName = criminal.displayName;
    final bytes = Base64Utils.decodePhoto(criminal.foto);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppColors.primaryDark,
          leading: const BackButton(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                color: Colors.white,
              ),
              onPressed: onToggleFavorite,
              tooltip: isFavorite ? 'Quitar guardado' : 'Guardar',
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                Share.share(
                  'Persona requisitoriada: $fullName\n'
                  'Recompensa: ${Formatters.formatReward(criminal.montoRecompensa)}\n'
                  'Si tiene información, llame al ${AppConstants.reportPhone}.\n'
                  'cazadores://criminal/${criminal.hashRequisitoriado}',
                );
              },
              tooltip: 'Compartir',
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: _DetailHeader(
              bytes: bytes,
              heroTag: heroTag,
              fullName: fullName,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reward badge — prominent at top
                Row(
                  children: [
                    RewardBadge(
                      amount: criminal.montoRecompensa,
                      large: true,
                    ),
                  ],
                ),
                const Gap(16),

                // Danger level
                _PeligrosidadCard(nivel: nivel, color: peligroColor),
                const Gap(16),

                // Info
                _InfoCard(criminal: criminal),
                const Gap(16),

                // Crimes
                _DelitosSection(delitos: criminal.allDelitos),
                const Gap(16),

                // How to report
                _ReportSection(),
                const Gap(16),

                // Report sighting
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ReportBottomSheet(criminal: criminal),
                      );
                    },
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('Reportar avistamiento'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
                const Gap(16),

                const DisclaimerBanner(),
                const Gap(32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.bytes,
    required this.heroTag,
    required this.fullName,
  });

  final dynamic bytes;
  final String heroTag;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo or placeholder
        if (bytes != null)
          Hero(
            tag: heroTag,
            child: Image.memory(bytes, fit: BoxFit.cover),
          )
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, size: 96, color: Colors.white24),
            ),
          ),

        // Gradient overlay — darkens bottom for name legibility
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: 0.0),
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),

        // Name at bottom of header
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Text(
            fullName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              height: 1.25,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PeligrosidadCard extends StatelessWidget {
  const _PeligrosidadCard({required this.nivel, required this.color});

  final NivelPeligrosidad nivel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(PeligrosidadHelper.icon(nivel), color: color, size: 32),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NIVEL DE PELIGROSIDAD',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
              Text(
                PeligrosidadHelper.label(nivel),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.criminal});

  final CriminalSummary criminal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información General',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 20),
            _InfoRow(
              icon: Icons.wc_rounded,
              label: 'Sexo',
              value: criminal.sexo == 1 ? 'Masculino' : 'Femenino',
            ),
            _InfoRow(
              icon: Icons.location_city_rounded,
              label: 'Departamento',
              value: criminal.departamento,
            ),
            _InfoRow(
              icon: Icons.map_rounded,
              label: 'Provincia',
              value: criminal.provincia,
            ),
            _InfoRow(
              icon: Icons.badge_rounded,
              label: 'ID Requisitoriado',
              value: '${criminal.idRequisitoriado}',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DelitosSection extends StatelessWidget {
  const _DelitosSection({required this.delitos});

  final List<String> delitos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delitos Imputados', style: Theme.of(context).textTheme.titleMedium),
        const Gap(10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: delitos
              .map(
                (d) => Chip(
                  label: Text(d, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.peligroExtremo.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.peligroExtremo),
                  side: BorderSide(
                    color: AppColors.peligroExtremo.withValues(alpha: 0.3),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.phone_in_talk, color: AppColors.rewardGreen),
                Gap(8),
                Text(
                  '¿Cómo reportar?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Gap(12),
            const _StepItem(
              number: '1',
              text: 'Asegúrate de que la persona no te vea.',
            ),
            const _StepItem(
              number: '2',
              text: 'Toma nota del lugar, hora y características.',
            ),
            const _StepItem(
              number: '3',
              text: 'Llama a la línea de denuncias anónimas:',
            ),
            const Gap(8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => AppLauncher.call(AppConstants.reportPhoneUri),
                icon: const Icon(Icons.phone, color: AppColors.rewardGreen),
                label: const Text(
                  'Llamar al 0-800-40-007',
                  style: TextStyle(
                    color: AppColors.rewardGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.rewardGreen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.rewardGreen,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const Gap(10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error, required this.hash, required this.ref});

  final Object error;
  final String hash;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: AppErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(criminalDetailProvider(hash)),
      ),
    );
  }
}
