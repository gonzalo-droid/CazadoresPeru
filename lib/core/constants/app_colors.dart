import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFCC0000);       // Rojo peruano
  static const Color primaryDark = Color(0xFF990000);
  static const Color primaryLight = Color(0xFFFF3333);
  static const Color secondary = Color(0xFFFFD700);     // Dorado/recompensa
  static const Color accent = Color(0xFF1E88E5);

  // Peligrosidad
  static const Color peligroExtremo = Color(0xFFD32F2F);
  static const Color peligroMuyAlto = Color(0xFFF57C00);
  static const Color peligroAlto = Color(0xFFFBC02D);

  // Reward
  static const Color rewardGreen = Color(0xFF2E7D32);
  static const Color rewardGreenLight = Color(0xFF4CAF50);

  // Background
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFEEEEEE);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Status
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);

  // Map cluster
  static const Color clusterLow = Color(0xFF4CAF50);
  static const Color clusterMed = Color(0xFFFFC107);
  static const Color clusterHigh = Color(0xFFE53935);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3C3C3C);
}
