import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(bool isNightMode, bool isHighContrast) {
    AppColors appColors;
    
    if (isHighContrast) {
      appColors = isNightMode ? AppColors.hcDark : AppColors.hcLight;
    } else {
      appColors = isNightMode ? AppColors.dark : AppColors.light;
    }

    ThemeData theme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: appColors.fondoPrincipal,
      primaryColor: appColors.azulSistemas,
      extensions: [appColors],
      colorScheme: isNightMode
          ? ColorScheme.dark(
              primary: appColors.azulSistemas,
              secondary: appColors.naranjaUnimet,
              tertiary: appColors.verdeSaman,
              surface: appColors.fondoTarjetas,
              error: appColors.error,
            )
          : ColorScheme.light(
              primary: appColors.azulSistemas,
              secondary: appColors.naranjaUnimet,
              tertiary: appColors.verdeSaman,
              surface: appColors.fondoTarjetas,
              error: appColors.error,
            ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: appColors.textoPrincipal,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: appColors.textoPrincipal,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: appColors.textoPrincipal,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: appColors.textoSecundario,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: appColors.blanco,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.fondoTarjetas,
        foregroundColor: appColors.textoPrincipal,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appColors.textoPrincipal,
        contentTextStyle: TextStyle(color: appColors.fondoPrincipal),
      ),
    );

    return theme;
  }
}
