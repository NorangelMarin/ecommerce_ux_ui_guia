import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartItems = ref.watch(cartProvider);
    final wishlistIds = ref.watch(wishlistProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final discount = ref.watch(cartDiscountProvider);
    final total = ref.watch(cartTotalProvider);
    final userData = ref.watch(userDataProvider).value;

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text('carrito_de_compra'.tr(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null,
        actionIcon: Icons.search,
        onActionPressed: () => context.push('/catalog'),
      ),
      body: Column(
        children: [
          // Lista de productos
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.of(context).sombras),
                        SizedBox(height: 16),
                        Text('tu_carrito_est_vaco'.tr(),
                          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.of(context).sombras),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (c, i) => SizedBox(height: 16),
                    itemBuilder: (c, i) {
                      final item = cartItems[i];
                      return ProductCard(
                        type: CardType.carrito,
                        title: item.title,
                        price: '\$ ${(item.unitPrice - item.discountValue).toStringAsFixed(2)}',
                        category: '',
                        imageUrl: item.imageUrl,
                        quantity: item.quantity,
                        discount: item.discountValue > 0 
                            ? '-${(item.discountValue / item.unitPrice * 100).toStringAsFixed(0)}% OFF'
                            : null,
                        originalPrice: item.discountValue > 0
                            ? '\$ ${item.unitPrice.toStringAsFixed(2)}'
                            : null,
                        onIncrement: () => ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity + 1),
                        onDecrement: () {
                          if (item.quantity > 1) {
                            ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity - 1);
                          }
                        },
                        isFavorite: wishlistIds.contains(item.productId),
                        onFavoritePressed: () => ref.read(wishlistProvider.notifier).toggleProduct(item.productId),
                        onDelete: () => ref.read(cartProvider.notifier).removeItem(item.productId),
                        onTap: () => context.push('/product_detail/${item.productId}'),
                      );
                    },
                  ),
          ),

          // Resumen de la Orden
          if (cartItems.isNotEmpty)
            GuideWrapper(
              title: 'transparencia_de_costos'.tr(),
              description: 'Mostrar claramente el subtotal, descuentos y el total antes de proceder al pago genera confianza en el usuario. Evitar costos ocultos reduce el abandono del carrito.',
              alignment: Alignment.topCenter,
              child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Divider(color: AppColors.of(context).verdeSaman, thickness: 1.5),
                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('subtotal'.tr(), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.of(context).textoPrincipal)),
                      Text('\$ ${subtotal.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.of(context).verdeSaman)),
                    ],
                  ),
                  SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('descuentos'.tr(), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.of(context).textoPrincipal)),
                      Text('-\$ ${discount.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.of(context).naranjaUnimet)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(color: AppColors.of(context).verdeSaman, thickness: 1.5),
                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('total'.tr(), style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.of(context).textoPrincipal)),
                      Text('\$ ${total.toStringAsFixed(2)}', style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.of(context).verdeSaman)),
                    ],
                  ),

                  SizedBox(height: 32),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: CustomButton(
                      text: 'proceder_al_pago'.tr(),
                      color: ButtonColor.naranja,
                      icon: Icons.shopping_cart_outlined,
                      onPressed: () {
                        final phone = userData?['phoneNumber'] as String?;
                        if (phone == null || phone.trim().isEmpty) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('telfono_requerido'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                              content: Text('por_seguridad_y_logística_es'.tr()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('cancelar'.tr(), style: TextStyle(color: AppColors.of(context).sombras)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.of(context).naranjaUnimet, foregroundColor: Colors.white),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.push('/profile');
                                  },
                                  child: Text('ir_a_mi_perfil'.tr()),
                                )
                              ],
                            )
                          );
                        } else {
                          context.push('/shipping');
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: CustomButton(
                      text: 'seguir_comprando'.tr(),
                      type: ButtonType.alternativo,
                      color: ButtonColor.naranja,
                      icon: Icons.shopping_bag_outlined,
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                ],
              ),
            ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 1) context.push('/cart');
          if (idx == 2) context.push('/history');
          if (idx == 3) context.push('/support');
        },
      ),
    );
  }
}
