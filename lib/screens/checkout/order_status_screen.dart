import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderStatusScreen extends ConsumerWidget {
  final String? orderId;
  const OrderStatusScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'estado_del_pedido'.tr(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        leadingIcon: Icons.arrow_back_ios_new,
        onLeadingPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/history');
          }
        },
        showActionIcon: false,
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.of(context).sombras,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'no_tienes_pedidos_activos'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.of(context).sombras,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: CustomButton(
                      text: 'ir_a_comprar'.tr(),
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                ],
              ),
            );
          }

          final order = orderId != null
              ? orders.firstWhere(
                  (o) => o.id == orderId,
                  orElse: () => orders.first,
                )
              : orders.first;
          final itemQuantity = order.items.fold<int>(
            0,
            (prev, item) => prev + item.quantity,
          );

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.of(context).blanco,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.of(
                        context,
                      ).sombras.withValues(alpha: 0.05),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GuideWrapper(
                        title: 'reconocimiento_vs_recuerdo'.tr(),
                        description:
                            'Proveer un ID de orden claro y truncado cumple con la heurística de "Reconocimiento antes que recuerdo", dando al usuario control y confianza sobre su transacción.',
                        child: Text(
                          '${'orden'.tr()} ${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.of(context).textoPrincipal,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      _buildShortSummaryBlock(context, order, itemQuantity),

                      SizedBox(height: 24),

                      GuideWrapper(
                        title: 'visibilidad_del_estado_del_sistema'.tr(),
                        description:
                            'Mantener al usuario informado sobre lo que está ocurriendo a través de retroalimentación apropiada en tiempo razonable (Heurística de Nielsen #1).',
                        child: _buildTimelineBlock(context, order.status),
                      ),

                      SizedBox(height: 32),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            if (order.status.toLowerCase() == 'entregado')
                              Tooltip(
                                message:
                                    'Danos tu opinión sobre el servicio para seguir mejorando',
                                child: CustomButton(
                                  text: 'evaluar_mi_experiencia'.tr(),
                                  color: ButtonColor.naranja,
                                  icon: Icons.star_outline,
                                  onPressed: () =>
                                      context.push('/survey/${order.id}'),
                                ),
                              ),
                            if (order.status.toLowerCase() == 'entregado')
                              SizedBox(height: 12),
                            Tooltip(
                              message: 'Habla con nuestro equipo de soporte',
                              child: CustomButton(
                                text: 'contactar_con_soporte'.tr(),
                                type: ButtonType.alternativo,
                                color: ButtonColor.naranja,
                                icon: Icons.chat_bubble_outline,
                                onPressed: () => context.push('/support'),
                              ),
                            ),
                            SizedBox(height: 12),
                            Tooltip(
                              message:
                                  'Sigue el recorrido de tu pedido en tiempo real',
                              child: CustomButton(
                                text: 'ver_mapa'.tr(),
                                type: ButtonType.alternativo,
                                color: ButtonColor.naranja,
                                icon: Icons.location_on_outlined,
                                onPressed: () => _showMapModal(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error al cargar pedidos: $e')),
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
    );
  }

  Widget _buildShortSummaryBlock(
    BuildContext context,
    OrderModel order,
    int quantity,
  ) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'es_VE',
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final estimatedDate = dateFormat.format(
      order.createdAt.add(Duration(hours: 1)),
    );

    return GuideWrapper(
      title: 'agrupación_y_carga_cognitiva'.tr(),
      description:
          'Agrupar la información esencial (artículos, total, entrega) en una tarjeta reduce la carga cognitiva del usuario, aplicando la Ley de Miller y principios de Gestalt.',
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.of(context).fondoTarjetas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.of(context).sombras.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'resumen_de_orden'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textoPrincipal,
                  ),
                ),
                Text(
                  '$quantity artículos',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.of(context).naranjaUnimet,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: AppColors.of(context).verdeSaman, thickness: 1.5),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.of(context).textoPrincipal,
                  ),
                ),
                Text(
                  currencyFormat.format(order.total),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.of(context).verdeSaman,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Entrega estimada:\n$estimatedDate hr',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.of(context).sombras,
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineBlock(BuildContext context, String status) {
    final st = status.toLowerCase();

    // Mapeo lógico de estados
    // 1. Pago confirmado (siempre activo si llegamos aquí)
    // 2. En preparación (status: 'procesando' o 'preparando' o más adelante)
    // 3. Enviado (status: 'enviado' o más adelante)
    // 4. Entregado (status: 'entregado')

    final step1Active =
        st == 'pago confirmado' ||
        st == 'en preparación' ||
        st == 'en preparacion' ||
        st == 'enviado' ||
        st == 'entregado';
    final step2Active =
        st == 'en preparación' || st == 'en preparacion' || st == 'enviado' || st == 'entregado';
    final step3Active = st == 'enviado' || st == 'entregado';
    final step4Active = st == 'entregado';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.of(context).fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.of(context).sombras.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _buildTimelineStep(
            context,
            title: 'pago_confirmado'.tr(),
            subtitle: 'tu_pago_fue_verificado'.tr(),
            icon: Icons.check_circle,
            iconColor: Colors.green[700]!,
            isActive: step1Active,
          ),
          _buildTimelineStep(
            context,
            title: 'en_preparación'.tr(),
            subtitle: 'estamos_preparando_tu_pedido'.tr(),
            icon: Icons.shopping_bag,
            iconColor: step2Active
                ? AppColors.of(context).azulSistemas
                : AppColors.of(context).sombras.withValues(alpha: 0.4),
            isActive: step2Active,
          ),
          _buildTimelineStep(
            context,
            title: 'enviado'.tr(),
            subtitle: 'el_repartidor_va_en_camino'.tr(),
            icon: Icons.moped,
            iconColor: step3Active
                ? AppColors.of(context).naranjaUnimet
                : AppColors.of(context).sombras.withValues(alpha: 0.4),
            isActive: step3Active,
          ),
          _buildTimelineStep(
            context,
            title: 'entregado'.tr(),
            subtitle: 'recibiste_tu_pedido_con_éxito'.tr(),
            icon: Icons.home,
            iconColor: step4Active
                ? Colors.green[700]!
                : AppColors.of(context).sombras.withValues(alpha: 0.4),
            isActive: step4Active,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isActive,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    // Cuadro naranja si ya pasó por ahí o es el actual
    final bgColor = isActive
        ? AppColors.of(context).naranjaUnimet
        : AppColors.of(context).sombras.withValues(alpha: 0.1);
    final activeIconColor = isActive
        ? Colors.white
        : AppColors.of(context).sombras.withValues(alpha: 0.4);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: activeIconColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isActive
                        ? AppColors.of(context).textoPrincipal
                        : AppColors.of(context).sombras,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.of(context).sombras,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMapModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.of(context).fondoPrincipal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'ruta_de_entrega_chacao__altamira'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.of(context).textoPrincipal,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'el_repartidor_se_encuentra_en_la_av_fran'.tr(),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.of(context).sombras,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  // Obtenemos el brillo actual para decidir el estilo del mapa
                  Builder(builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    
                    // Matriz para invertir colores (Modo Oscuro)
                    const colorMatrixDark = <double>[
                      -1,  0,  0, 0, 255, // Red
                       0, -1,  0, 0, 255, // Green
                       0,  0, -1, 0, 255, // Blue
                       0,  0,  0, 1,   0, // Alpha
                    ];
                    
                    return ColorFiltered(
                      colorFilter: isDark 
                          ? const ColorFilter.matrix(colorMatrixDark)
                          // Modo monocromático (Escala de grises) para el tema claro
                          : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black : Colors.grey[200],
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/delivery_map_clean.png',
                              ),
                              fit: BoxFit.cover,
                              opacity: 0.8,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  // Marcador del repartidor animado (simulado)
                  Center(
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(seconds: 2),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, -20 * (1 - value)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.of(context).naranjaUnimet,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'tu_pedido'.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.location_on,
                                color: AppColors.of(context).naranjaUnimet,
                                size: 40,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: MediaQuery.of(context).padding.bottom + 24.0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.of(context).fondoPrincipal,
                        child: Icon(
                          Icons.person,
                          color: AppColors.of(context).naranjaUnimet,
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'carlos_repartidor'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).textoPrincipal,
                            ),
                          ),
                          Text(
                            'en_camino__honda_cargo'.tr(),
                            style: TextStyle(
                              color: AppColors.of(context).sombras,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.phone,
                          color: AppColors.of(context).verdeSaman,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomButton(
                    text: 'cerrar'.tr(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'en proceso':
        return 'en_proceso'.tr();
      case 'enviado':
        return 'enviado'.tr();
      case 'entregado':
        return 'entregado'.tr();
      case 'pago confirmado':
        return 'pago_confirmado'.tr();
      case 'en preparación':
      case 'en preparacion':
        return 'en_preparación'.tr();
      default:
        return status;
    }
  }
}
