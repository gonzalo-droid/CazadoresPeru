import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';

class RewardBadge extends StatelessWidget {
  const RewardBadge({
    super.key,
    required this.amount,
    this.large = false,
  });

  final double amount;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.rewardGreen,
        borderRadius: BorderRadius.circular(large ? 12 : 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on_rounded,
            color: Colors.white,
            size: large ? 20 : 14,
          ),
          const SizedBox(width: 4),
          Text(
            Formatters.formatReward(amount),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: large ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
