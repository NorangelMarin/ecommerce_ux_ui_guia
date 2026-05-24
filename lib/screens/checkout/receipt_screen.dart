import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../providers/order_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/payment_method_provider.dart';
import '../../models/order.dart';
import '../../models/address.dart';
import '../../models/payment_method.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class ReceiptScreen extends ConsumerWidget {
  final String? orderId;
  const ReceiptScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(userOrdersProvider);

    // Utilizamos PopScope para interceptar el botón "Atrás" de Android
    // y redirigir al usuario al inicio, dado que el carrito ya está vacío.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.fondoPrincipal,
        drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'Comprobante de pago',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textoPrincipal,
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null,
        showActionIcon: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.blanco,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sombras.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '¡Pago Exitoso!',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Icono de Éxito
                  GuideWrapper(
                    title: 'retroalimentación_del_sistema'.tr(),
                    description:
                        'Proporcionar una respuesta visual clara y positiva tras una acción crítica (como un pago) confirma el éxito de la tarea, reduciendo la ansiedad y brindando tranquilidad al usuario.',
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.fondoPrincipal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.check,
                            color: AppColors.blanco,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  ordersAsync.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.naranjaUnimet,
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Error al cargar órdenes: $err',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    data: (orders) {
                      if (orders.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'No hay información de orden disponible.',
                            style: TextStyle(color: AppColors.sombras),
                          ),
                        );
                      }

                      // Buscar la orden específica si se proporcionó un ID
                      OrderModel? targetOrder;
                      if (orderId != null) {
                        try {
                          targetOrder = orders.firstWhere((o) => o.id == orderId);
                        } catch (_) {
                          // Si no se encuentra (aún), mostrar cargando
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(color: AppColors.naranjaUnimet),
                                  SizedBox(height: 16),
                                  Text(
                                    'Procesando información del pedido...',
                                    style: TextStyle(color: AppColors.sombras, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        targetOrder = orders.first;
                      }

                      final shortOrderId = targetOrder.id.length > 6
                          ? targetOrder.id.substring(0, 6).toUpperCase()
                          : targetOrder.id.toUpperCase();

                      return Column(
                        children: [
                          Text(
                            'Orden: $shortOrderId',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.sombras,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 32),

                          // Bloque 1: Resumen de pago
                          _buildOrderSummaryBlock(context, targetOrder),
                          SizedBox(height: 24),

                          // Bloque 2: Información de Envío
                          _buildShippingInfoBlock(context, ref, targetOrder),
                          SizedBox(height: 24),

                          // Bloque 3: Método de Pago
                          _buildPaymentMethodBlock(context, ref, targetOrder),
                          SizedBox(height: 32),
                          
                          // Botones de acción
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                CustomButton(
                                  text: 'Ver estado del pedido',
                                  color: ButtonColor.naranja,
                                  icon: Icons.chevron_right,
                                  onPressed: () => context.push('/order_status/${targetOrder!.id}'),
                                ),
                                SizedBox(height: 12),
                                CustomButton(
                                  text: 'Volver al inicio',
                                  type: ButtonType.alternativo,
                                  color: ButtonColor.naranja,
                                  onPressed: () => context.go('/home'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Por defecto Inicio
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 1) context.push('/cart');
          if (idx == 2) context.push('/history');
          if (idx == 3) context.push('/support');
        },
      ),
    ));
  }

  Widget _buildOrderSummaryBlock(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sombras.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumen de pago',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoPrincipal,
                ),
              ),
              Text(
                '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} artículos',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.naranjaUnimet,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          ...order.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: _buildMiniProductCard(
                context,
                title: item.title,
                subtitle: 'Cantidad: ${item.quantity}',
                price:
                    '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                imageUrl: item.imageUrl,
              ),
            ),
          ),

          SizedBox(height: 16),
          Divider(color: AppColors.verdeSaman, thickness: 1.5),
          SizedBox(height: 16),

          _buildSummaryRow(
            theme,
            'Subtotal:',
            '\$ ${order.subtotal.toStringAsFixed(2)}',
            false,
          ),
          SizedBox(height: 12),
          _buildSummaryRow(
            theme,
            'Descuentos:',
            '-\$ ${order.discount.toStringAsFixed(2)}',
            false,
            colorOverride: AppColors.naranjaUnimet,
          ),
          SizedBox(height: 16),
          Divider(color: AppColors.verdeSaman, thickness: 1.5),
          SizedBox(height: 16),
          _buildSummaryRow(
            theme,
            'Total:',
            '\$ ${order.total.toStringAsFixed(2)}',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String amount,
    bool isTotal, {
    Color? colorOverride,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : 14,
            color: AppColors.textoPrincipal,
          ),
        ),
        Text(
          amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : 14,
            color: colorOverride ?? AppColors.verdeSaman,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniProductCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String price,
    required String imageUrl,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.sombras.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.textoPrincipal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 9,
                    color: AppColors.sombras,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            price,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.verdeSaman,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoBlock(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    final theme = Theme.of(context);
    
    // Prioridad: Snapshot de la orden > Búsqueda en perfil (fallback)
    Address? targetAddress;
    if (order.shippingAddressSnapshot != null) {
      targetAddress = Address.fromMap(
        order.shippingAddressSnapshot!,
        order.shippingAddressId,
      );
    } else {
      final addresses = ref.watch(userAddressesProvider).value ?? [];
      try {
        targetAddress = addresses.firstWhere((a) => a.id == order.shippingAddressId);
      } catch (_) {
        targetAddress = addresses.isNotEmpty ? addresses.first : null;
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sombras.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrega en',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              color: AppColors.sombras,
            ),
          ),
          SizedBox(height: 4),
          Text(
            targetAddress?.label ?? 'Dirección de envío',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textoPrincipal,
            ),
          ),
          SizedBox(height: 8),
          Text(
            targetAddress != null
                ? '${targetAddress.urbanizacion}, ${targetAddress.municipio}. ${targetAddress.ciudad}, ${targetAddress.estado}.'
                : 'Información de dirección no disponible.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: AppColors.sombras,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodBlock(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    final theme = Theme.of(context);
    final pmId = order.paymentMethodId;
    
    PaymentMethod? targetPm;
    String methodLabel = 'Tarjeta guardada';
    IconData methodIcon = Icons.credit_card;

    // Prioridad 1: Snapshot de la orden
    if (order.paymentMethodSnapshot != null) {
      final snap = order.paymentMethodSnapshot!;
      if (snap.containsKey('brand')) {
        // Es una tarjeta
        targetPm = PaymentMethod.fromMap(snap, pmId);
      } else {
        // Es un método tipo 'pos', 'cash', 'mobile'
        final type = snap['type'] ?? pmId;
        if (type == 'pos') {
          methodLabel = 'Pago con punto de venta';
          methodIcon = Icons.point_of_sale;
        } else if (type == 'cash') {
          methodLabel = 'Efectivo en dólares';
          methodIcon = Icons.attach_money;
        } else if (type == 'mobile') {
          methodLabel = 'Pago móvil';
          methodIcon = Icons.account_balance;
        }
      }
    } else {
      // Prioridad 2: Búsqueda en perfil (fallback para órdenes viejas)
      if (pmId == 'pos') {
        methodLabel = 'Pago con punto de venta';
        methodIcon = Icons.point_of_sale;
      } else if (pmId == 'cash') {
        methodLabel = 'Efectivo en dólares';
        methodIcon = Icons.attach_money;
      } else if (pmId == 'mobile') {
        methodLabel = 'Pago móvil';
        methodIcon = Icons.account_balance;
      } else {
        final pms = ref.watch(userPaymentMethodsProvider).value ?? [];
        try {
          targetPm = pms.firstWhere((pm) => pm.id == pmId);
        } catch (_) {
          targetPm = pms.isNotEmpty ? pms.first : null;
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sombras.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Método de Pago',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              color: AppColors.sombras,
            ),
          ),
          SizedBox(height: 4),
          Text(
            methodLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textoPrincipal,
            ),
          ),
          SizedBox(height: 12),
          if (targetPm != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.blanco,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.sombras.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    methodIcon,
                    color: AppColors.azulSistemas,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${targetPm.brand} •••• ${targetPm.last4Digits}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: AppColors.textoPrincipal,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Icon(
                  methodIcon,
                  color: AppColors.azulSistemas,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  methodLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.textoPrincipal,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
