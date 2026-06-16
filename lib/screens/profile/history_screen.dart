import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../theme/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/translate_status.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  List<Map<String, dynamic>> _groupOrders(List<OrderModel> orders) {
    final groups = <String, List<OrderModel>>{};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    for (var order in orders) {
      final date = order.createdAt;
      final orderDate = DateTime(date.year, date.month, date.day);

      String label;
      if (orderDate == today) {
        label = 'hoy'.tr();
      } else if (orderDate == yesterday) {
        label = 'ayer'.tr();
      } else {
        label =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }

      if (!groups.containsKey(label)) {
        groups[label] = [];
      }
      groups[label]!.add(order);
    }

    // Convert to list of maps maintaining the order
    return groups.entries
        .map((e) => {'dateLabel': e.key, 'orders': e.value})
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'historial_de_compras'.tr(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null,
        showActionIcon: false,
      ),
      body: ordersAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.of(context).naranjaUnimet),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Text(
                'an_no_tienes_historial_de_compras'.tr(),
                style: TextStyle(color: AppColors.of(context).sombras),
              ),
            );
          }

          final groupedOrders = _groupOrders(orders);

          return ListView.builder(
            padding: EdgeInsets.all(24),
            itemCount: groupedOrders.length,
            itemBuilder: (context, groupIndex) {
              final group = groupedOrders[groupIndex];
              final groupOrdersList = group['orders'] as List<OrderModel>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta de fecha
                  Row(
                    children: [
                      Text(
                        group['dateLabel'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.of(context).sombras,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Divider(
                          color: AppColors.of(context).sombras.withValues(alpha: 0.2),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...groupOrdersList.asMap().entries.map(
                    (entry) {
                      final isFirst = groupIndex == 0 && entry.key == 0;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _buildOrderCard(context, entry.value, isFirst: isFirst),
                      );
                    },
                  ),
                  SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Historial activo
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 1) context.push('/cart');
          if (idx == 2) context.push('/history');
          if (idx == 3) context.push('/support');
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, {bool isFirst = false}) {
    final theme = Theme.of(context);

    String statusColorKey = 'gray';
    final st = order.status.toLowerCase();

    if (st.contains('pago') || st.contains('confirmado')) {
      statusColorKey = 'green';
    } else if (st.contains('enviado'))
      statusColorKey = 'blue';
    else if (st.contains('entregado'))
      statusColorKey = 'green';
    else if (st.contains('preparación') || st.contains('preparando'))
      statusColorKey = 'orange';
    else
      statusColorKey = 'gray';

    final statusColor = _getStatusColor(context, statusColorKey);

    // Abreviar el id largo de firebase
    final shortId = order.id.length > 6
        ? order.id.substring(0, 6).toUpperCase()
        : order.id.toUpperCase();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.of(context).naranjaUnimet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: AppColors.of(context).naranjaUnimet,
                  size: 22,
                ),
              ),
              if (isFirst)
                GuideWrapper(
                  id: 'history_order_status',
                  title: 'visibilidad_del_estado_del_sistema'.tr(),
                  description:
                      'Mantener informado al usuario sobre el estado de su orden mediante colores semánticos (ej. verde para entregado) genera confianza y reduce la ansiedad posventa.',
                  child: _buildStatusBadge(context, theme, order, statusColor),
                )
              else
                _buildStatusBadge(context, theme, order, statusColor),
            ],
          ),
          SizedBox(height: 12),
          // Número de orden
          Text(
            '${'orden'.tr()} $shortId',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.of(context).sombras,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          // Total
          Text(
            '${'total'.tr()} \$${order.total.toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.of(context).textoPrincipal,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/receipt/${order.id}'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.of(context).naranjaUnimet, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'ver_detalles'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.of(context).naranjaUnimet,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String colorKey) {
    switch (colorKey) {
      case 'orange':
        return AppColors.of(context).naranjaUnimet;
      case 'blue':
        return AppColors.of(context).azulSistemas;
      case 'green':
        return AppColors.of(context).verdeSaman;
      default:
        return AppColors.of(context).sombras;
    }
  }

  Widget _buildStatusBadge(BuildContext context, ThemeData theme, OrderModel order, Color statusColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        translateStatus(order.status).toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
