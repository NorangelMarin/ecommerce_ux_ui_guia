import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/checkout_stepper.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import '../../providers/address_provider.dart';
import '../../providers/payment_method_provider.dart';
import '../../models/address.dart';
import '../../models/payment_method.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import 'payment_method_screen.dart' show CheckoutData;
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  final CheckoutData? checkoutData;
  const ConfirmationScreen({super.key, this.checkoutData});

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'confirma_tu_pedido'.tr(),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.of(context).blanco,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.of(context).sombras.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckoutStepper(currentStep: 3),
                  SizedBox(height: 32),

                  // Bloque 1: Resumen de pago
                  _buildOrderSummaryBlock(context, ref),

                  SizedBox(height: 24),

                  // Bloque 2: Información de Envío
                  _buildShippingInfoBlock(context, ref),

                  SizedBox(height: 24),

                  // Bloque 3: Método de Pago
                  _buildPaymentMethodBlock(context, ref),

                  SizedBox(height: 32),

                  // Sello de seguridad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security,
                        color: AppColors.of(context).verdeSaman,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'transaccin_segura_y_encriptada_por_unime'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.of(context).sombras,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Botón
                  GuideWrapper(
                    title: 'prevención_de_errores_nielsen'.tr(),
                    description:
                        'Exigir un paso final de confirmación con un botón claro previene compras accidentales y da al usuario el control final sobre su transacción.',
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: CustomButton(
                        text: _isProcessing
                            ? 'procesando'.tr()
                            : 'confirmar_pago'.tr(),
                        color: ButtonColor.naranja,
                        icon: Icons.chevron_right,
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                final cartItems = ref.read(cartProvider);
                                if (cartItems.isEmpty) return;

                                final cd = widget.checkoutData;

                                // -- Resolver dirección --
                                Address? resolvedAddress;
                                if (cd?.addressData.newAddress != null) {
                                  resolvedAddress = cd!.addressData.newAddress;
                                } else if (cd?.addressData.addressId != null) {
                                  final addresses =
                                      ref.read(userAddressesProvider).value ??
                                      [];
                                  resolvedAddress = addresses
                                      .cast<Address?>()
                                      .firstWhere(
                                        (a) =>
                                            a?.id == cd!.addressData.addressId,
                                        orElse: () => null,
                                      );
                                }
                                resolvedAddress ??=
                                    (ref.read(userAddressesProvider).value ??
                                            [])
                                        .cast<Address?>()
                                        .isNotEmpty
                                    ? (ref.read(userAddressesProvider).value ??
                                              [])
                                          .first
                                    : null;

                                // -- Resolver método de pago --
                                PaymentMethod? resolvedPm;
                                if (cd?.paymentData.newMethod != null) {
                                  resolvedPm = cd!.paymentData.newMethod;
                                } else if (cd?.paymentData.savedMethodId !=
                                    null) {
                                  final pms =
                                      ref
                                          .read(userPaymentMethodsProvider)
                                          .value ??
                                      [];
                                  resolvedPm = pms
                                      .cast<PaymentMethod?>()
                                      .firstWhere(
                                        (pm) =>
                                            pm?.id ==
                                            cd!.paymentData.savedMethodId,
                                        orElse: () => null,
                                      );
                                }
                                // Fallback a métodos no basados en tarjeta
                                final nonCardTypes = {'pos', 'cash', 'mobile'};
                                final isNonCard = nonCardTypes.contains(
                                  cd?.paymentData.methodType,
                                );

                                if (resolvedAddress == null ||
                                    (resolvedPm == null && !isNonCard)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'revisa_tu_direccin_de_envo_y_mtodo_de_pa'
                                            .tr(),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isProcessing = true);
                                try {
                                  final user = ref
                                      .read(authStateProvider)
                                      .value;
                                  if (user != null) {
                                    final subtotal = ref.read(
                                      cartSubtotalProvider,
                                    );
                                    final discount = ref.read(
                                      cartDiscountProvider,
                                    );
                                    final total = ref.read(cartTotalProvider);

                                    final newOrder = OrderModel(
                                      id: '',
                                      userId: user.uid,
                                      items: cartItems,
                                      subtotal: subtotal,
                                      discount: discount,
                                      total: total,
                                      shippingAddressId:
                                          resolvedAddress.id,
                                      paymentMethodId:
                                          resolvedPm?.id ??
                                          cd?.paymentData.methodType ??
                                          'other',
                                      shippingAddressSnapshot: resolvedAddress
                                          .toMap(),
                                      paymentMethodSnapshot:
                                          resolvedPm?.toMap() ??
                                          {'type': cd?.paymentData.methodType},
                                      createdAt: DateTime.now(),
                                      status: 'pago_confirmado'.tr(),
                                    );

                                    final orderId = await ref
                                        .read(orderRepositoryProvider)
                                        .createOrder(user.uid, newOrder);
                                    await ref
                                        .read(cartProvider.notifier)
                                        .clear();

                                    if (!context.mounted) return;
                                    context.pushReplacement(
                                      '/receipt/$orderId',
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al procesar: $e'),
                                      ),
                                    );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isProcessing = false);
                                  }
                                }
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryBlock(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final discount = ref.watch(cartDiscountProvider);
    final total = ref.watch(cartTotalProvider);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'resumen_de_pago'.tr(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textoPrincipal,
                ),
              ),
              Text(
                '${cartItems.fold<int>(0, (sum, item) => sum + item.quantity)} ${'articulos'.tr()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.of(context).naranjaUnimet,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          if (cartItems.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'el_carrito_est_vaco'.tr(),
                  style: TextStyle(color: AppColors.of(context).sombras),
                ),
              ),
            )
          else
            ...cartItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: _buildMiniProductCard(
                  context,
                  title: item.title,
                  subtitle: '${'cantidad'.tr()} ${item.quantity}',
                  price:
                      '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                  imageUrl: item.imageUrl,
                ),
              ),
            ),

          SizedBox(height: 16),
          Divider(color: AppColors.of(context).verdeSaman, thickness: 1.5),
          SizedBox(height: 16),

          _buildSummaryRow(
            theme,
            'subtotal'.tr(),
            '\$ ${subtotal.toStringAsFixed(2)}',
            false,
          ),
          SizedBox(height: 12),
          _buildSummaryRow(
            theme,
            'descuentos'.tr(),
            '-\$ ${discount.toStringAsFixed(2)}',
            false,
            colorOverride: AppColors.of(context).naranjaUnimet,
          ),
          SizedBox(height: 16),
          Divider(color: AppColors.of(context).verdeSaman, thickness: 1.5),
          SizedBox(height: 16),
          _buildSummaryRow(
            theme,
            'total'.tr(),
            '\$ ${total.toStringAsFixed(2)}',
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
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        Text(
          amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : 14,
            color: colorOverride ?? AppColors.of(context).verdeSaman,
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
        color: AppColors.of(context).blanco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
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
                    color: AppColors.of(context).textoPrincipal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 9,
                    color: AppColors.of(context).sombras,
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
              color: AppColors.of(context).verdeSaman,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoBlock(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Prioridad: dirección nueva del flujo > dirección guardada por ID > default de Firestore
    Address? displayAddress = widget.checkoutData?.addressData.newAddress;

    if (displayAddress == null) {
      final addressesAsync = ref.watch(userAddressesProvider);
      final addresses = addressesAsync.value ?? [];
      final targetId = widget.checkoutData?.addressData.addressId;
      if (targetId != null) {
        displayAddress = addresses.cast<Address?>().firstWhere(
          (a) => a?.id == targetId,
          orElse: () => null,
        );
      }
      displayAddress ??=
          addresses.cast<Address?>().firstWhere(
            (a) => a?.isDefault == true,
            orElse: () => null,
          ) ??
          (addresses.isNotEmpty ? addresses.first : null);
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'entrega_en'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  color: AppColors.of(context).sombras,
                ),
              ),
              SizedBox(height: 4),
              Text(
                displayAddress?.label ?? 'sin_direccion_configurada'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.of(context).textoPrincipal,
                ),
              ),
              SizedBox(height: 8),
              Text(
                displayAddress != null
                    ? '${displayAddress.urbanizacion}, ${displayAddress.municipio}. ${displayAddress.ciudad}, ${displayAddress.estado}.'
                    : 'por_favor_aade_una_direccion_de_entrega_antes_de_confirmar_tu_pedido'
                          .tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: AppColors.of(context).sombras,
                  height: 1.4,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => context.push('/shipping'),
              child: Icon(Icons.edit, color: AppColors.of(context).naranjaUnimet, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodBlock(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Prioridad: método del flujo > guardado por ID > default de Firestore
    PaymentMethod? displayPm = widget.checkoutData?.paymentData.newMethod;
    final methodType = widget.checkoutData?.paymentData.methodType;

    if (displayPm == null && methodType == 'saved') {
      final pms = ref.watch(userPaymentMethodsProvider).value ?? [];
      final targetId = widget.checkoutData?.paymentData.savedMethodId;
      displayPm = pms.cast<PaymentMethod?>().firstWhere(
        (pm) => pm?.id == targetId,
        orElse: () => null,
      );
    }

    if (displayPm == null && (methodType == null || methodType == 'saved')) {
      final pms = ref.watch(userPaymentMethodsProvider).value ?? [];
      try {
        displayPm = pms.firstWhere((pm) => pm.isDefault);
      } catch (_) {
        displayPm = pms.isNotEmpty ? pms.first : null;
      }
    }

    // Label para métodos no-tarjeta
    String nonCardLabel = '';
    if (methodType == 'pos') nonCardLabel = 'pago_con_punto_de_venta'.tr();
    if (methodType == 'cash') nonCardLabel = 'efectivo_en_dolares'.tr();
    if (methodType == 'mobile') nonCardLabel = 'pago_movil'.tr();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'mtodo_de_pago'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  color: AppColors.of(context).sombras,
                ),
              ),
              SizedBox(height: 4),
              Text(
                displayPm != null
                    ? 'tarjeta'.tr()
                    : (nonCardLabel.isNotEmpty
                          ? nonCardLabel
                          : 'por_definir'.tr()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.of(context).textoPrincipal,
                ),
              ),
              SizedBox(height: 12),
              if (displayPm != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).blanco,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.of(context).sombras.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: AppColors.of(context).azulSistemas,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${displayPm.brand} •••• ${displayPm.last4Digits}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.of(context).textoPrincipal,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                )
              else if (nonCardLabel.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      methodType == 'pos'
                          ? Icons.point_of_sale
                          : methodType == 'cash'
                          ? Icons.attach_money
                          : Icons.account_balance,
                      color: AppColors.of(context).azulSistemas,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      nonCardLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppColors.of(context).textoPrincipal,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'por_favor_aade_un_mtodo_de_pago_antes_de'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.of(context).sombras,
                  ),
                ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => context.push('/payment_method'),
              child: Icon(Icons.edit, color: AppColors.of(context).naranjaUnimet, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
