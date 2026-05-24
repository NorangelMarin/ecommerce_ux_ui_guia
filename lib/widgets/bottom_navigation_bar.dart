import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GuideWrapper(
      title: 'navegación_inferior_flotante'.tr(),
      description: 'La navegación inferior flotante separa visualmente los controles del contenido (efecto isla), mejorando la ergonomía (pulgar) y modernizando la interfaz. Provee acceso rápido a las secciones clave de la app de comercio electrónico.',
      alignment: Alignment.topRight,
      child: Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.naranjaUnimet,
          unselectedItemColor: AppColors.naranjaUnimet.withValues(alpha: 0.5),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'inicio'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'carrito'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'historial'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent_outlined),
              activeIcon: Icon(Icons.support_agent),
              label: 'soporte'.tr(),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
