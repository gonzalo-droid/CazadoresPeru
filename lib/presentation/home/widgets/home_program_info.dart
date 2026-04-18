import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_launcher.dart';

class HomeProgramInfo extends StatelessWidget {
  const HomeProgramInfo({super.key});

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
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primaryDark.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
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
            onPressed: () => AppLauncher.openUrl(AppConstants.recompensasUrl),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Más información'),
          ),
        ],
      ),
    );
  }
}
