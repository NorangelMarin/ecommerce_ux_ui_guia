import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class BottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    return Padding(
      padding: EdgeInsets.all(16),
      child: GuideWrapper(
        title: 'navegación_inferior_flotante'.tr(),
        description: 'La navegación inferior flotante separa visualmente los controles del contenido (efecto isla), mejorando la ergonomía (pulgar) y modernizando la interfaz. Provee acceso rápido a las secciones clave de la app de comercio electrónico.',
        child: Container(
          decoration: BoxDecoration(
        color: AppColors.of(context).fondoTarjetas,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
          backgroundColor: AppColors.of(context).fondoTarjetas,
          selectedItemColor: AppColors.of(context).naranjaUnimet,
          unselectedItemColor: AppColors.of(context).naranjaUnimet.withValues(alpha: 0.5),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'inicio'.tr(),
            ),
            BottomNavigationBarItem(
              icon: cartCount > 0 
                  ? Badge(
                      label: Text(cartCount.toString()),
                      backgroundColor: Colors.red,
                      child: Icon(Icons.shopping_cart_outlined),
                    )
                  : Icon(Icons.shopping_cart_outlined),
              activeIcon: cartCount > 0
                  ? Badge(
                      label: Text(cartCount.toString()),
                      backgroundColor: Colors.red,
                      child: Icon(Icons.shopping_cart),
                    )
                  : Icon(Icons.shopping_cart),
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
    ),
    );
  }
}
