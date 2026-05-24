import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UnimetLogo extends StatelessWidget {
  final double size;

  const UnimetLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Cuadrado Naranja
          Positioned(
            top: 0,
            left: size * 0.1,
            child: Container(
              width: size * 0.5,
              height: size * 0.5,
              decoration: BoxDecoration(
                color: AppColors.naranjaUnimet.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          // Círculo Azul
          Positioned(
            bottom: size * 0.1,
            right: 0,
            child: Container(
              width: size * 0.55,
              height: size * 0.55,
              decoration: BoxDecoration(
                color: AppColors.azulSistemas.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Triángulo (o forma geométrica) Verde Samán
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: BoxDecoration(
                color: AppColors.verdeSaman.withValues(alpha: 0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.25),
                  bottomRight: Radius.circular(size * 0.25),
                  bottomLeft: Radius.circular(size * 0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
