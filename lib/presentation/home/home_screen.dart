import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/base64_utils.dart';
import '../../core/utils/formatters.dart';
import '../shared/widgets/disclaimer_banner.dart';
import '../shared/widgets/reward_badge.dart';
import '../../domain/entities/criminal_summary.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _callReportLine() async {
    final uri = Uri.parse(AppConstants.reportPhoneUri);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);
    final topAsync = ref.watch(topWantedProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(topWantedProvider);
          ref.invalidate(homeStatsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              pinned: true,
              expandedHeight: 160,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Cazadores Perú',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.go(AppRoutes.search),
                  tooltip: 'Buscar',
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(16),
                  const DisclaimerBanner(),
                  const Gap(16),

                  // Stats cards
                  _StatsSection(statsAsync: statsAsync),
                  const Gap(24),

                  // Top wanted
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Más Buscados',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.search),
                          child: const Text('Ver todos'),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  _TopWantedSection(topAsync: topAsync),
                  const Gap(24),

                  // Quick access
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Accesos Rápidos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const Gap(12),
                  _QuickAccessSection(),
                  const Gap(24),

                  // Official info
                  _ProgramInfo(),
                  const Gap(80), // FAB space
                ],
              ),
            ),
          ],
        ),
      ),

      // FAB — Report Line ${AppConstants.reportPhone}
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _callReportLine,
        backgroundColor: AppColors.rewardGreen,
        icon: const Icon(Icons.phone, color: Colors.white),
        label: const Text(
          'Denunciar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.statsAsync});

  final AsyncValue<HomeStats> statsAsync;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: statsAsync.when(
          loading: () => [
            _StatCard(
              label: 'Total buscados',
              value: '---',
              icon: Icons.person_search,
              color: AppColors.primary,
            ),
          const SizedBox(width: 12),
            _StatCard(
              label: 'Recompensa máxima',
              value: '---',
              icon: Icons.monetization_on,
              color: AppColors.rewardGreen,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Llame al',
              value: '${AppConstants.reportPhone}',
              icon: Icons.phone,
              color: AppColors.accent,
            ),
          ],
          error: (_, __) => [],
          data: (stats) => [
            _StatCard(
              label: 'Total buscados',
              value: '${stats.totalBuscados}',
              icon: Icons.person_search,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Recompensa máxima',
              value: Formatters.formatReward(stats.recompensaMaxima),
              icon: Icons.monetization_on,
              color: AppColors.rewardGreen,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Llame al',
              value: '${AppConstants.reportPhone}',
              icon: Icons.phone,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopWantedSection extends StatelessWidget {
  const _TopWantedSection({required this.topAsync});

  final AsyncValue<List<CriminalSummary>> topAsync;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: topAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error cargando datos')),
        data: (criminals) {
          if (criminals.isEmpty) {
            return const Center(child: Text('Sin datos disponibles'));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: criminals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _TopWantedCard(criminal: criminals[i]),
          );
        },
      ),
    );
  }
}

class _TopWantedCard extends StatelessWidget {
  const _TopWantedCard({required this.criminal});

  final CriminalSummary criminal;

  @override
  Widget build(BuildContext context) {
    final bytes = Base64Utils.decodePhoto(criminal.foto);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(
        '${AppRoutes.detail}/${criminal.hashRequisitoriado}',
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 148,
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background photo
              if (bytes != null)
                Image.memory(bytes, fit: BoxFit.cover)
              else
                Container(
                  color: AppColors.primaryDark,
                  child: const Icon(Icons.person, size: 64, color: Colors.white24),
                ),

              // Gradient overlay — top subtle, bottom dark
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.82),
                    ],
                  ),
                ),
              ),

              // Content pinned to bottom
              Positioned(
                left: 10,
                right: 10,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RewardBadge(amount: criminal.montoRecompensa),
                    const SizedBox(height: 6),
                    Text(
                      criminal.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

class _QuickAccessSection extends StatelessWidget {
  _QuickAccessSection();

  final _links = [
    _QuickLink(
      label: 'PNP',
      icon: Icons.local_police,
      color: AppColors.accent,
      url: AppConstants.pnpUrl,
    ),
    _QuickLink(
      label: 'MININTER',
      icon: Icons.account_balance,
      color: AppColors.primary,
      url: AppConstants.mininterUrl,
    ),
    _QuickLink(
      label: 'Recompensas.pe',
      icon: Icons.web,
      color: AppColors.rewardGreen,
      url: AppConstants.recompensasUrl,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < _links.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final uri = Uri.parse(_links[i].url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: _links[i].color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _links[i].color.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_links[i].icon, color: _links[i].color, size: 28),
                      const Gap(6),
                      Text(
                        _links[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _links[i].color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickLink {
  const _QuickLink({
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String url;
}

class _ProgramInfo extends StatelessWidget {
  _ProgramInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primaryDark.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              Gap(8),
              Text(
                'Programa de Recompensas',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            'El Programa de Recompensas del Estado Peruano ofrece incentivos '
            'económicos a ciudadanos que brinden información que conduzca a la '
            'captura de personas requisitoriadas por la justicia peruana.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(12),
          OutlinedButton.icon(
            onPressed: () async {
              final uri = Uri.parse(AppConstants.recompensasUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Más información'),
          ),
        ],
      ),
    );
  }
}
