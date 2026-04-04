import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/peligrosidad.dart';
import '../../domain/entities/criminal_summary.dart';
import '../report/report_bottom_sheet.dart';
import '../shared/widgets/criminal_photo.dart';
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
        error: (e, __) => _ErrorBody(error: e.toString()),
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

  Future<void> _call1818() async {
    final uri = Uri.parse(AppConstants.reportPhoneUri);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final nivel = PeligrosidadHelper.calcular(criminal.delitos);
    final peligroColor = PeligrosidadHelper.color(nivel);
    final fullName = Formatters.formatFullName(
      apellidoPaterno: criminal.apellidoPaterno,
      apellidoMaterno: criminal.apellidoMaterno,
      nombres: criminal.nombres,
    );

    return CustomScrollView(
      slivers: [
        // AppBar with hero photo
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: const BackButton(color: Colors.white),
          actions: [
            // Favorite
            IconButton(
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                color: Colors.white,
              ),
              onPressed: onToggleFavorite,
              tooltip: isFavorite ? 'Quitar guardado' : 'Guardar',
            ),
            // Share
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                Share.share(
                  'Persona requisitoriada: $fullName\n'
                  'Recompensa: ${Formatters.formatReward(criminal.montoRecompensa)}\n'
                  'Si tiene información, llame al 1818.\n'
                  'cazadores://criminal/${criminal.hashRequisitoriado}',
                );
              },
              tooltip: 'Compartir',
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Background gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                  ),
                ),
                // Photo centered
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(40),
                      Hero(
                        tag: heroTag,
                        child: CriminalPhoto(
                          base64Photo: criminal.foto,
                          size: 120,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reward card
                RewardBadge(amount: criminal.montoRecompensa, large: true),
                const Gap(16),

                // Peligrosidad card
                _PeligrosidadCard(nivel: nivel, color: peligroColor),
                const Gap(16),

                // Info card
                _InfoCard(criminal: criminal),
                const Gap(16),

                // Delitos
                _DelitosSection(delitos: criminal.delitos),
                const Gap(16),

                // How to report
                _ReportSection(onCall: _call1818),
                const Gap(16),

                // Report sighting button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ReportBottomSheet(
                          criminal: criminal,
                        ),
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

class _PeligrosidadCard extends StatelessWidget {
  const _PeligrosidadCard({required this.nivel, required this.color});

  final NivelPeligrosidad nivel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
                  color: color.withOpacity(0.7),
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
              label: 'Sexo',
              value: criminal.sexo == 1 ? 'Masculino' : 'Femenino',
            ),
            _InfoRow(
              label: 'Departamento',
              value: criminal.departamento,
            ),
            _InfoRow(
              label: 'Provincia',
              value: criminal.provincia,
            ),
            _InfoRow(
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
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
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
                  backgroundColor:
                      AppColors.peligroExtremo.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.peligroExtremo),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({required this.onCall});

  final VoidCallback onCall;

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
                onPressed: onCall,
                icon: const Icon(Icons.phone, color: AppColors.rewardGreen),
                label: const Text(
                  'Llamar al 1818',
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
  const _ErrorBody({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const Gap(16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
