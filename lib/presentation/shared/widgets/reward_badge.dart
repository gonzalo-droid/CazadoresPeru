import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';

enum RewardBadgeStyle {
  solid,  // fondo dorado sólido — para fondos claros/neutros
  subtle, // borde dorado translúcido — para superposición sobre fotos oscuras
}

class RewardBadge extends StatelessWidget {
  const RewardBadge({
    super.key,
    required this.amount,
    this.large = false,
    this.style = RewardBadgeStyle.solid,
  });

  final double amount;
  final bool large;
  final RewardBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final isSubtle = style == RewardBadgeStyle.subtle;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 8,
        vertical: large ? 8 : 3,
      ),
      decoration: BoxDecoration(
        color: isSubtle
            ? AppColors.rewardGold.withValues(alpha: 0.15)
            : AppColors.rewardGold,
        borderRadius: BorderRadius.circular(large ? 12 : 6),
        border: isSubtle
            ? Border.all(color: AppColors.rewardGold.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on_rounded,
            color: isSubtle ? AppColors.rewardGold : const Color(0xFF1A0A00),
            size: large ? 20 : 12,
          ),
          const SizedBox(width: 4),
          Text(
            Formatters.formatReward(amount),
            style: TextStyle(
              color: isSubtle ? AppColors.rewardGold : const Color(0xFF1A0A00),
              fontWeight: FontWeight.w800,
              fontSize: large ? 16 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
