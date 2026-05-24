import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.robotoTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.fondoPrincipal,
      primaryColor: AppColors.azulSistemas,
      colorScheme: ColorScheme.light(
        primary: AppColors.azulSistemas,
        secondary: AppColors.naranjaUnimet,
        tertiary: AppColors.verdeSaman,
        surface: AppColors.fondoTarjetas,
        error: AppColors.error,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.roboto(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: AppColors.textoPrincipal,
        ),
        displayMedium: GoogleFonts.roboto(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: AppColors.textoPrincipal,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: AppColors.textoPrincipal,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.textoSecundario,
        ),
        labelLarge: GoogleFonts.roboto(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.blanco,
        ),
      ),
    );
  }

  static ThemeData getTheme(bool isNightMode, bool isHighContrast) {
    ThemeData theme = lightTheme;
    
    if (isNightMode) {
      theme = theme.copyWith(
        scaffoldBackgroundColor: Color(0xFF121212), // Dark mode background
        colorScheme: theme.colorScheme.copyWith(
          brightness: Brightness.dark,
          surface: Color(0xFF1E1E1E),
        ),
        textTheme: theme.textTheme.apply(
          bodyColor: AppColors.blanco,
          displayColor: AppColors.blanco,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: AppColors.blanco,
        ),
      );
    }
    
    if (isHighContrast) {
      // Increase contrast by using pure black/white where applicable
      theme = theme.copyWith(
        primaryColor: isNightMode ? AppColors.naranjaUnimet : Color(0xFF0000FF), // Pure blue
        colorScheme: theme.colorScheme.copyWith(
          primary: isNightMode ? AppColors.naranjaUnimet : Color(0xFF0000FF),
        ),
      );
    }
    
    return theme;
  }
}
