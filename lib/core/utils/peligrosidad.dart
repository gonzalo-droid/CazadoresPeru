import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

enum NivelPeligrosidad { extremo, muyAlto, alto }

class PeligrosidadHelper {
  PeligrosidadHelper._();

  static NivelPeligrosidad calcular(List<String> delitos) {
    final upper = delitos.map((d) => d.toUpperCase()).toList();

    for (final d in upper) {
      for (final extremo in AppConstants.delitosExtremos) {
        if (d.contains(extremo)) return NivelPeligrosidad.extremo;
      }
    }
    for (final d in upper) {
      for (final alto in AppConstants.delitosMuyAltos) {
        if (d.contains(alto)) return NivelPeligrosidad.muyAlto;
      }
    }
    return NivelPeligrosidad.alto;
  }

  static Color color(NivelPeligrosidad nivel) {
    switch (nivel) {
      case NivelPeligrosidad.extremo:
        return AppColors.peligroExtremo;
      case NivelPeligrosidad.muyAlto:
        return AppColors.peligroMuyAlto;
      case NivelPeligrosidad.alto:
        return AppColors.peligroAlto;
    }
  }

  static String label(NivelPeligrosidad nivel) {
    switch (nivel) {
      case NivelPeligrosidad.extremo:
        return 'EXTREMO';
      case NivelPeligrosidad.muyAlto:
        return 'MUY ALTO';
      case NivelPeligrosidad.alto:
        return 'ALTO';
    }
  }

  static IconData icon(NivelPeligrosidad nivel) {
    switch (nivel) {
      case NivelPeligrosidad.extremo:
        return Icons.warning_rounded;
      case NivelPeligrosidad.muyAlto:
        return Icons.report_problem_rounded;
      case NivelPeligrosidad.alto:
        return Icons.info_rounded;
    }
  }
}
