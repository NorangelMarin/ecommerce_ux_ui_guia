import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color azulSistemas;
  final Color naranjaUnimet;
  final Color verdeSaman;
  final Color fondoPrincipal;
  final Color fondoTarjetas;
  final Color sombras;
  final Color exito;
  final Color error;
  final Color advertencia;
  final Color textoPrincipal;
  final Color textoSecundario;
  final Color blanco;

  const AppColors({
    required this.azulSistemas,
    required this.naranjaUnimet,
    required this.verdeSaman,
    required this.fondoPrincipal,
    required this.fondoTarjetas,
    required this.sombras,
    required this.exito,
    required this.error,
    required this.advertencia,
    required this.textoPrincipal,
    required this.textoSecundario,
    required this.blanco,
  });

  @override
  AppColors copyWith({
    Color? azulSistemas,
    Color? naranjaUnimet,
    Color? verdeSaman,
    Color? fondoPrincipal,
    Color? fondoTarjetas,
    Color? sombras,
    Color? exito,
    Color? error,
    Color? advertencia,
    Color? textoPrincipal,
    Color? textoSecundario,
    Color? blanco,
  }) {
    return AppColors(
      azulSistemas: azulSistemas ?? this.azulSistemas,
      naranjaUnimet: naranjaUnimet ?? this.naranjaUnimet,
      verdeSaman: verdeSaman ?? this.verdeSaman,
      fondoPrincipal: fondoPrincipal ?? this.fondoPrincipal,
      fondoTarjetas: fondoTarjetas ?? this.fondoTarjetas,
      sombras: sombras ?? this.sombras,
      exito: exito ?? this.exito,
      error: error ?? this.error,
      advertencia: advertencia ?? this.advertencia,
      textoPrincipal: textoPrincipal ?? this.textoPrincipal,
      textoSecundario: textoSecundario ?? this.textoSecundario,
      blanco: blanco ?? this.blanco,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      azulSistemas: Color.lerp(azulSistemas, other.azulSistemas, t)!,
      naranjaUnimet: Color.lerp(naranjaUnimet, other.naranjaUnimet, t)!,
      verdeSaman: Color.lerp(verdeSaman, other.verdeSaman, t)!,
      fondoPrincipal: Color.lerp(fondoPrincipal, other.fondoPrincipal, t)!,
      fondoTarjetas: Color.lerp(fondoTarjetas, other.fondoTarjetas, t)!,
      sombras: Color.lerp(sombras, other.sombras, t)!,
      exito: Color.lerp(exito, other.exito, t)!,
      error: Color.lerp(error, other.error, t)!,
      advertencia: Color.lerp(advertencia, other.advertencia, t)!,
      textoPrincipal: Color.lerp(textoPrincipal, other.textoPrincipal, t)!,
      textoSecundario: Color.lerp(textoSecundario, other.textoSecundario, t)!,
      blanco: Color.lerp(blanco, other.blanco, t)!,
    );
  }

  // Predefined pallets
  static const light = AppColors(
    azulSistemas: Color(0xFF003087),
    naranjaUnimet: Color(0xFFF37021),
    verdeSaman: Color(0xFF2E7D32),
    fondoPrincipal: Color(0xFFFAFAFA),
    fondoTarjetas: Color(0xFFF5F5F5),
    sombras: Color(0xFF666666),
    exito: Color(0xFF4CAF50),
    error: Color(0xFFD32F2F),
    advertencia: Color(0xFFFBC02D),
    textoPrincipal: Color(0xFF212121),
    textoSecundario: Color(0xFF666666),
    blanco: Colors.white,
  );

  static const dark = AppColors(
    azulSistemas: Color(0xFF003087),
    naranjaUnimet: Color(0xFFF37021),
    verdeSaman: Color(0xFF2E7D32),
    fondoPrincipal: Color(0xFF121212),
    fondoTarjetas: Color(0xFF1E1E1E),
    sombras: Color(0xFFAAAAAA),
    exito: Color(0xFF4CAF50),
    error: Color(0xFFD32F2F),
    advertencia: Color(0xFFFBC02D),
    textoPrincipal: Color(0xFFFFFFFF),
    textoSecundario: Color(0xFFCCCCCC),
    blanco: Color(0xFF1E1E1E),
  );

  static const hcLight = AppColors(
    azulSistemas: Color(0xFF0000FF),
    naranjaUnimet: Color(0xFFFF5500),
    verdeSaman: Color(0xFF00FF00),
    fondoPrincipal: Color(0xFFFAFAFA),
    fondoTarjetas: Color(0xFFF5F5F5),
    sombras: Color(0xFF000000),
    exito: Color(0xFF00FF00),
    error: Color(0xFFFF0000),
    advertencia: Color(0xFFFFCC00),
    textoPrincipal: Color(0xFF000000),
    textoSecundario: Color(0xFF000000),
    blanco: Colors.white,
  );

  static const hcDark = AppColors(
    azulSistemas: Color(0xFF0000FF),
    naranjaUnimet: Color(0xFFFF5500),
    verdeSaman: Color(0xFF00FF00),
    fondoPrincipal: Color(0xFF121212),
    fondoTarjetas: Color(0xFF1E1E1E),
    sombras: Color(0xFFFFFFFF),
    exito: Color(0xFF00FF00),
    error: Color(0xFFFF0000),
    advertencia: Color(0xFFFFCC00),
    textoPrincipal: Color(0xFFFFFFFF),
    textoSecundario: Color(0xFFFFFFFF),
    blanco: Color(0xFF1E1E1E),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? AppColors.light;
  }
}
