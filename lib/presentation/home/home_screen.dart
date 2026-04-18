import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/app_launcher.dart';
import '../shared/widgets/disclaimer_banner.dart';
import 'home_provider.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_program_info.dart';
import 'widgets/home_quick_access_section.dart';
import 'widgets/home_stats_section.dart';
import 'widgets/home_top_wanted_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
            const HomeAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(16),
                  const DisclaimerBanner(),
                  const Gap(16),
                  HomeStatsSection(statsAsync: statsAsync),
                  const Gap(24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Los más Buscados',
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
                  HomeTopWantedSection(topAsync: topAsync),
                  const Gap(24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Accesos Rápidos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const Gap(12),
                  const HomeQuickAccessSection(),
                  const Gap(24),
                  const HomeProgramInfo(),
                  const Gap(80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AppLauncher.call(AppConstants.reportPhoneUri),
        backgroundColor: AppColors.rewardGreen,
        icon: const Icon(Icons.phone, color: Colors.white),
        label: const Text(
          'Denunciar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
