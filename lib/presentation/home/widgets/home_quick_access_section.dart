import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_launcher.dart';

class HomeQuickAccessSection extends StatelessWidget {
  const HomeQuickAccessSection({super.key});

  static const _links = [
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
        children: [
          for (int i = 0; i < _links.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: _QuickLinkCard(link: _links[i])),
          ],
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({required this.link});

  final _QuickLink link;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => AppLauncher.openUrl(link.url),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: link.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: link.color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(link.icon, color: link.color, size: 28),
            const Gap(6),
            Text(
              link.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: link.color,
              ),
            ),
          ],
        ),
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
