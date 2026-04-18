import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../home_provider.dart';
import '../../shared/widgets/app_error_widget.dart';

class HomeStatsSection extends StatelessWidget {
  const HomeStatsSection({super.key, required this.statsAsync});

  final AsyncValue<HomeStats> statsAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: statsAsync.when(
        loading: () => const Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total buscados',
                value: '---',
                icon: Icons.person_search,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Recompensa máxima',
                value: '---',
                icon: Icons.monetization_on,
                color: AppColors.rewardGreen,
              ),
            ),
          ],
        ),
        error: (e, __) => AppErrorWidget(error: e, compact: true),
        data: (stats) => Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total buscados',
                value: '${stats.totalBuscados}',
                icon: Icons.person_search,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Recompensa máxima',
                value: Formatters.formatReward(stats.recompensaMaxima),
                icon: Icons.monetization_on,
                color: AppColors.rewardGreen,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
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
    );
  }
}
