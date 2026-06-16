import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/checkout_stepper.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/payment_method.dart';
import 'shipping_screen.dart' show CheckoutAddressData;
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/custom_notification.dart';

/// Contenedor con los datos del método de pago seleccionado en el flujo.
class CheckoutPaymentData {
  final String? savedMethodId; // ID si es guardado
  final PaymentMethod? newMethod; // Objeto si es nuevo
  final String methodType; // 'saved','card','pos','cash','mobile'
  CheckoutPaymentData({
    this.savedMethodId,
    this.newMethod,
    required this.methodType,
  });
}

/// Agrupación de datos completos del checkout para pasar a Confirmación.
class CheckoutData {
  final CheckoutAddressData addressData;
  final CheckoutPaymentData paymentData;
  CheckoutData({required this.addressData, required this.paymentData});
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 16) text = text.substring(0, 16);
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != text.length) buffer.write(' ');
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 4) text = text.substring(0, 4);
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) == 2 && (i + 1) != text.length) buffer.write('/');
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final CheckoutAddressData? addressData;
  const PaymentMethodScreen({super.key, this.addressData});

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  // 0: Guardado, 1: Tarjeta, 2: Punto de venta, 3: Dolares, 4: Pago móvil
  int _selectedMethod = 0;
  String? _selectedSavedMethodId;
  bool _saveMethod = false;
  bool _isSaving = false;

  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvcController = TextEditingController();
  final _aliasController = TextEditingController();
  final _pagoMovilRefController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    _aliasController.dispose();
    _pagoMovilRefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentMethodsAsync = ref.watch(userPaymentMethodsProvider);
    final paymentMethods = paymentMethodsAsync.value ?? [];

    if (paymentMethods.isNotEmpty && _selectedSavedMethodId == null) {
      _selectedSavedMethodId = paymentMethods
          .firstWhere((p) => p.isDefault, orElse: () => paymentMethods.first)
          .id;
    }

    // Si no hay métodos guardados y estaba seleccionado, pasar a 'Nueva Tarjeta'
    if (paymentMethods.isEmpty && _selectedMethod == 0) {
      _selectedMethod = 1;
    }

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'selecciona_el_medio_de_pago'.tr(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
          ),
        ),
        leadingIcon: Icons.menu,
        onLeadingPressed: null, // Abre nativamente el drawer
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
                  CheckoutStepper(currentStep: 2),
                  SizedBox(height: 32),

                  Text(
                    'selecciona_el_medio_de_pago'.tr(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'elige_la_opcin_que_mejor_se_adapte_a_tu'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).sombras,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Opciones de Pago
                  Column(
                    children: [
                        if (paymentMethods.isNotEmpty) ...[
                          _buildPaymentCard(
                            index: 0,
                            icon: Icons.account_balance_wallet,
                            title: 'método_de_pago_guardado'.tr(),
                            subtitle: 'usa_una_tarjeta_o_método'.tr(),
                            expandedContent: _buildSavedMethodForm(
                              paymentMethods,
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        _buildPaymentCard(
                          index: 1,
                          icon: Icons.credit_card,
                          title: 'nueva_tarjeta_de_crédito_o'.tr(),
                          subtitle: 'visa_mastercard'.tr(),
                          expandedContent: _buildCreditCardForm(),
                        ),
                        SizedBox(height: 16),
                        _buildPaymentCard(
                          index: 2,
                          icon: Icons.point_of_sale,
                          title: 'pago_con_punto_de_venta'.tr(),
                          subtitle: 'disponible_para_retiros_en_tienda'.tr(),
                        ),
                        SizedBox(height: 16),
                        _buildPaymentCard(
                          index: 3,
                          icon: Icons.attach_money,
                          title: 'pago_en_dolares_en_efectivo'.tr(),
                          subtitle: 'disponible_para_retiros_en_tienda'.tr(),
                        ),
                        SizedBox(height: 16),
                        _buildPaymentCard(
                          index: 4,
                          icon: Icons.account_balance,
                          title: 'pago_movil'.tr(),
                          subtitle: 'seleccione_para_vizualizar_los_datos'.tr(),
                          expandedContent: _buildPagoMovilForm(),
                        ),
                      ],
                    ),
                  SizedBox(height: 24),

                  SizedBox(height: 48),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CustomButton(
                      text: _isSaving
                          ? 'procesando'.tr()
                          : 'confirmar_pedido'.tr(),
                      color: ButtonColor.naranja,
                      icon: Icons.chevron_right,
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_selectedMethod == 0 &&
                                  _selectedSavedMethodId == null) {
                                CustomNotification.show(
                                  context,
                                  message:
                                      'por_favor_selecciona_una_tarjeta_guardad'
                                          .tr(),
                                  type: NotificationType.info,
                                );
                                return;
                              }

                              if (_selectedMethod == 1) {
                                if (_cardNumberController.text.trim().length <
                                        15 ||
                                    _expiryDateController.text.trim().length <
                                        5 ||
                                    _cvcController.text.trim().length < 3) {
                                  CustomNotification.show(
                                    context,
                                    message:
                                        'por_favor_completa_todos_los_datos_de_la'
                                            .tr(),
                                    type: NotificationType.error,
                                  );
                                  return;
                                }

                                String brand = 'VISA';
                                if (_cardNumberController.text.startsWith('5'))
                                  brand = 'MASTERCARD';
                                if (_cardNumberController.text.startsWith('3'))
                                  brand = 'AMEX';
                                String last4 =
                                    _cardNumberController.text.length >= 4
                                    ? _cardNumberController.text
                                          .replaceAll(' ', '')
                                          .substring(
                                            _cardNumberController.text
                                                    .replaceAll(' ', '')
                                                    .length -
                                                4,
                                          )
                                    : '';

                                final tempCard = PaymentMethod(
                                  id: '',
                                  brand: brand,
                                  last4Digits: last4,
                                  expiryDate: _expiryDateController.text,
                                  labelColor: 'blue',
                                  isDefault: false,
                                );

                                if (_saveMethod) {
                                  if (_aliasController.text.trim().isEmpty) {
                                    CustomNotification.show(
                                      context,
                                      message: 'por_favor_ingresa_un_alias'
                                          .tr(),
                                      type: NotificationType.info,
                                    );
                                    return;
                                  }
                                  setState(() => _isSaving = true);
                                  final user = ref
                                      .read(authStateProvider)
                                      .value;
                                  if (user != null) {
                                    final cardToSave = PaymentMethod(
                                      id: '',
                                      brand: brand,
                                      last4Digits: last4,
                                      expiryDate: _expiryDateController.text,
                                      labelColor: 'blue',
                                      isDefault: false,
                                      alias: _aliasController.text.trim(),
                                    );
                                    await ref
                                        .read(paymentMethodRepositoryProvider)
                                        .addPaymentMethod(user.uid, cardToSave);
                                  }
                                  if (mounted)
                                    setState(() => _isSaving = false);
                                }

                                if (mounted) {
                                  context.push(
                                    '/confirmation',
                                    extra: CheckoutData(
                                      addressData:
                                          widget.addressData ??
                                          CheckoutAddressData(),
                                      paymentData: CheckoutPaymentData(
                                        newMethod: tempCard,
                                        methodType: 'card',
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              // Método guardado
                              if (_selectedMethod == 0) {
                                if (mounted) {
                                  context.push(
                                    '/confirmation',
                                    extra: CheckoutData(
                                      addressData:
                                          widget.addressData ??
                                          CheckoutAddressData(),
                                      paymentData: CheckoutPaymentData(
                                        savedMethodId: _selectedSavedMethodId,
                                        methodType: 'saved',
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              // Otros métodos (punto de venta, efectivo, móvil)
                              if (_selectedMethod == 4 &&
                                  _pagoMovilRefController.text.trim().isEmpty) {
                                CustomNotification.show(
                                  context,
                                  message:
                                      'por_favor_ingresa_el_nmero_de_referencia'
                                          .tr(),
                                  type: NotificationType.info,
                                );
                                return;
                              }

                              final typeMap = {
                                2: 'pos',
                                3: 'cash',
                                4: 'mobile',
                              };
                              if (mounted) {
                                context.push(
                                  '/confirmation',
                                  extra: CheckoutData(
                                    addressData:
                                        widget.addressData ??
                                        CheckoutAddressData(),
                                    paymentData: CheckoutPaymentData(
                                      methodType:
                                          typeMap[_selectedMethod] ?? 'other',
                                    ),
                                  ),
                                );
                              }
                              return;
                            },
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

  Widget _buildPaymentCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? expandedContent,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedMethod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.of(context).fondoTarjetas, // Gris claro del figma
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.of(context).azulSistemas
                : AppColors.of(context).sombras.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.of(context).azulSistemas, size: 28),
                Spacer(),
                // Radio button custom
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.of(context).azulSistemas
                          : AppColors.of(context).azulSistemas,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.of(context).azulSistemas,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.of(context).textoPrincipal,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).sombras,
                fontSize: 13,
              ),
            ),

            // Contenido expandible
            if (isSelected && expandedContent != null) ...[
              SizedBox(height: 24),
              expandedContent,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSavedMethodForm(List<PaymentMethod> paymentMethods) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'selecciona_una_de_tus_tarjetas_guardadas'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.of(context).textoPrincipal,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        ...paymentMethods.map(
          (pm) => Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: _buildSavedCardItem(
              id: pm.id,
              title: pm.alias.isNotEmpty ? pm.alias : pm.brand,
              cardNumber: '**** **** **** ${pm.last4Digits}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedCardItem({
    required String id,
    required String title,
    required String cardNumber,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedSavedMethodId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSavedMethodId = id;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.of(context).blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.of(context).azulSistemas
                : AppColors.of(context).sombras.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.credit_card,
              color: isSelected
                  ? AppColors.of(context).azulSistemas
                  : AppColors.of(context).sombras,
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
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  Text(
                    cardNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.of(context).sombras,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.of(context).azulSistemas,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'número_de_la_tarjeta'.tr(),
          placeholder: '0000 0000 0000 0000',
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [CardNumberFormatter()],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'fecha_vencimiento'.tr(),
                placeholder: 'MM/YY',
                controller: _expiryDateController,
                keyboardType: TextInputType.number,
                inputFormatters: [ExpiryDateFormatter()],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'código_de_seguridad'.tr(),
                placeholder: 'CVC',
                controller: _cvcController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Theme(
                data: theme.copyWith(
                  checkboxTheme: theme.checkboxTheme.copyWith(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                child: Checkbox(
                  value: _saveMethod,
                  onChanged: (val) =>
                      setState(() => _saveMethod = val ?? false),
                  activeColor: AppColors.of(context).azulSistemas,
                  checkColor: Colors.white,
                  side: BorderSide.none,
                  fillColor: WidgetStateProperty.all(
                    AppColors.of(context).azulSistemas,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _saveMethod = !_saveMethod),
                child: Text(
                  'guardar_para_mis_futuros_pagos'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.of(context).sombras,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_saveMethod) ...[
          SizedBox(height: 24),
          CustomTextField(
            label: 'alias'.tr(),
            placeholder: 'Ej. Mi Visa Unimet, Tarjeta Azul, etc.',
            controller: _aliasController,
          ),
        ],
      ],
    );
  }

  Widget _buildPagoMovilForm() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.of(context).blanco,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.of(context).sombras.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              _buildInfoRow(theme, 'Banco', 'Banesco (0134)'),
              Divider(height: 24, color: AppColors.of(context).fondoPrincipal),
              _buildInfoRow(theme, 'Teléfono', '0414-1234567'),
              Divider(height: 24, color: AppColors.of(context).fondoPrincipal),
              _buildInfoRow(theme, 'Cédula', 'J-12345678-9'),
            ],
          ),
        ),
        SizedBox(height: 16),
        CustomTextField(
          label: 'número_de_referencia'.tr(),
          placeholder: 'Ej. 123456',
          controller: _pagoMovilRefController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.of(context).sombras,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.of(context).textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
