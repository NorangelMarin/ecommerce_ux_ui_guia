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
      backgroundColor: AppColors.fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text(
          'Selecciona el medio de pago',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textoPrincipal,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckoutStepper(currentStep: 2),
                  SizedBox(height: 32),

                  Text(
                    'Selecciona el medio de pago',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Elige la opción que mejor se adapte a tu comodidad para completar tu pedido.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.sombras,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Opciones de Pago
                  GuideWrapper(
                    title: 'flexibilidad_y_contexto_local'.tr(),
                    description:
                        'Ofrecer múltiples opciones de pago (Tarjetas, Divisas, Pago Móvil) se adapta a la realidad económica del usuario venezolano, previniendo el abandono del carrito por falta de opciones.',
                    alignment: Alignment.topRight,
                    child: Column(
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
                          title: 'pago_móvil'.tr(),
                          subtitle: 'seleccione_para_vizualizar_los_datos'.tr(),
                          expandedContent: _buildPagoMovilForm(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  SizedBox(height: 48),

                  // Botón central reducido
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CustomButton(
                      text: _isSaving ? 'Procesando...' : 'Confirmar pedido',
                        color: ButtonColor.naranja,
                        icon: Icons.chevron_right,
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (_selectedMethod == 0 &&
                                    _selectedSavedMethodId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Por favor selecciona una tarjeta guardada',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (_selectedMethod == 1) {
                                  if (_cardNumberController.text.trim().length < 15 ||
                                      _expiryDateController.text.trim().length < 5 ||
                                      _cvcController.text.trim().length < 3) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Por favor completa todos los datos de la tarjeta correctamente',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  String brand = 'VISA';
                                  if (_cardNumberController.text.startsWith('5')) brand = 'MASTERCARD';
                                  if (_cardNumberController.text.startsWith('3')) brand = 'AMEX';
                                  String last4 = _cardNumberController.text.length >= 4
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('por_favor_ingresa_un_alias'.tr()),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() => _isSaving = true);
                                    final user = ref.read(authStateProvider).value;
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
                                    if (mounted) setState(() => _isSaving = false);
                                  }

                                  if (mounted) {
                                    context.push(
                                      '/confirmation',
                                      extra: CheckoutData(
                                        addressData: widget.addressData ??
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
                                        addressData: widget.addressData ??
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Por favor ingresa el número de referencia del Pago Móvil',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
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
                                      addressData: widget.addressData ??
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
          color: AppColors.fondoTarjetas, // Gris claro del figma
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.azulSistemas
                : AppColors.sombras.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.azulSistemas, size: 28),
                Spacer(),
                // Radio button custom
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.azulSistemas
                          : AppColors.azulSistemas,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.azulSistemas,
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
                color: AppColors.textoPrincipal,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.sombras,
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
          'Selecciona una de tus tarjetas guardadas:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textoPrincipal,
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
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.azulSistemas
                : AppColors.sombras.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.credit_card,
              color: isSelected ? AppColors.azulSistemas : AppColors.sombras,
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
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  Text(
                    cardNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.sombras,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.azulSistemas),
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
                  LengthLimitingTextInputFormatter(4),
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
                  activeColor: AppColors.azulSistemas,
                  checkColor: Colors.white,
                  side: BorderSide.none,
                  fillColor: WidgetStateProperty.all(AppColors.azulSistemas),
                ),
              ),
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _saveMethod = !_saveMethod),
              child: Text(
                'Guardar para mis futuros pagos',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.sombras,
                  fontSize: 13,
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
            color: AppColors.blanco,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.sombras.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildInfoRow(theme, 'Banco', 'Banesco (0134)'),
              Divider(height: 24, color: AppColors.fondoPrincipal),
              _buildInfoRow(theme, 'Teléfono', '0414-1234567'),
              Divider(height: 24, color: AppColors.fondoPrincipal),
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
            color: AppColors.sombras,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
