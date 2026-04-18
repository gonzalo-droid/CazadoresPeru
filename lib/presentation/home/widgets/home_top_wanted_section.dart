import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/base64_utils.dart';
import '../../../domain/entities/criminal_summary.dart';
import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/reward_badge.dart';

class HomeTopWantedSection extends StatelessWidget {
  const HomeTopWantedSection({super.key, required this.topAsync});

  final AsyncValue<List<CriminalSummary>> topAsync;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: topAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => AppErrorWidget(error: e),
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
              if (bytes != null)
                Image.memory(bytes, fit: BoxFit.cover)
              else
                Container(
                  color: AppColors.primaryDark,
                  child: const Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.white24,
                  ),
                ),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 10,
                right: 10,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      criminal.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.3,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    RewardBadge(
                      amount: criminal.montoRecompensa,
                      style: RewardBadgeStyle.subtle,
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
