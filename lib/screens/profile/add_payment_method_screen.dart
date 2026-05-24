import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/payment_method.dart';
import 'package:easy_localization/easy_localization.dart';
import '../checkout/payment_method_screen.dart'; // Import formatters

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends ConsumerState<AddPaymentMethodScreen> {
  bool _isSaving = false;

  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvcController = TextEditingController();
  final _aliasController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _saveMethod() async {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '').trim();
    final expiry = _expiryDateController.text.trim();
    final cvc = _cvcController.text.trim();
    final alias = _aliasController.text.trim();

    if (cardNumber.length < 15 || expiry.length < 5 || cvc.length < 3 || alias.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('por_favor_completa_todos_los'.tr())),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final isVisa = cardNumber.startsWith('4');
        final brand = isVisa ? 'VISA' : 'MASTERCARD';
        final labelColor = isVisa ? 'blue' : 'orange';

        final newMethod = PaymentMethod(
          id: '',
          brand: brand,
          last4Digits: cardNumber.substring(cardNumber.length - 4),
          expiryDate: expiry,
          labelColor: labelColor,
          alias: _aliasController.text.trim(),
        );
        await ref.read(paymentMethodRepositoryProvider).addPaymentMethod(user.uid, newMethod);
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: TopNavigationBar(
        titleWidget: Text(
          'Agregar método de pago',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textoPrincipal,
          ),
        ),
        leadingIcon: Icons.arrow_back,
        onLeadingPressed: () => context.pop(),
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
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nueva tarjeta',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Ingresa los datos de tu tarjeta de crédito o débito para guardarla en tu perfil.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.sombras,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 32),
                  
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
                  SizedBox(height: 16),
                  CustomTextField(
                    label: 'alias_del_método_de_pago'.tr(),
                    placeholder: 'Nombre para esta tarjeta',
                    controller: _aliasController,
                  ),
                  
                  SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: _isSaving
                        ? Center(child: CircularProgressIndicator(color: AppColors.naranjaUnimet))
                        : CustomButton(
                            text: 'Guardar tarjeta',
                            color: ButtonColor.naranja,
                            onPressed: _saveMethod,
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
}
