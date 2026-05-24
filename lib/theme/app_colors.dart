import 'package:flutter/material.dart';

class AppColors {
  static bool isHighContrast = false;
  static bool isNightMode = false;

  // Colores de Marca
  static Color get azulSistemas => isHighContrast ? Color(0xFF0000FF) : Color(0xFF003087);
  static Color get naranjaUnimet => isHighContrast ? Color(0xFFFF5500) : Color(0xFFF37021);
  static Color get verdeSaman => isHighContrast ? Color(0xFF00FF00) : Color(0xFF2E7D32);

  // Colores de Fondo
  static Color get fondoPrincipal => isNightMode ? Color(0xFF121212) : Color(0xFFFAFAFA);
  static Color get fondoTarjetas => isNightMode ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5);
  static Color get sombras => isHighContrast ? Color(0xFF000000) : (isNightMode ? Color(0xFFAAAAAA) : Color(0xFF666666));

  // Colores de Retroalimentación
  static Color get exito => isHighContrast ? Color(0xFF00FF00) : Color(0xFF4CAF50);
  static Color get error => isHighContrast ? Color(0xFFFF0000) : Color(0xFFD32F2F);
  static Color get advertencia => isHighContrast ? Color(0xFFFFCC00) : Color(0xFFFBC02D);
  
  // Colores Extra para UI
  static Color get textoPrincipal => isNightMode ? Color(0xFFFFFFFF) : (isHighContrast ? Color(0xFF000000) : Color(0xFF212121));
  static Color get textoSecundario => isNightMode ? Color(0xFFCCCCCC) : sombras;
  static Color get blanco => isNightMode ? Color(0xFF1E1E1E) : Colors.white;
}
