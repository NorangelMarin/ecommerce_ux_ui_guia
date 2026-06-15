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
import '../../widgets/custom_notification.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState
    extends ConsumerState<AddPaymentMethodScreen> {
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

    if (cardNumber.length < 15 ||
        expiry.length < 5 ||
        cvc.length < 3 ||
        alias.isEmpty) {
      if (mounted) {
        CustomNotification.show(context, message: 'por_favor_completa_todos_los'.tr(), type: NotificationType.info);
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
        await ref
            .read(paymentMethodRepositoryProvider)
            .addPaymentMethod(user.uid, newMethod);
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        CustomNotification.show(context, message: 'error_al_guardar'.tr(args: [e.toString()]), type: NotificationType.error);
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
      backgroundColor: AppColors.of(context).fondoPrincipal,
      appBar: TopNavigationBar(
        titleWidget: Text(
          'agregar_mtodo_de_pago'.tr(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textoPrincipal,
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
                  Text(
                    'nueva_tarjeta'.tr(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.of(context).textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ingresa_los_datos_de_tu_tarjeta_de_crdit'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).sombras,
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
                            LengthLimitingTextInputFormatter(3),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    label: 'alias_del_método_de_pago'.tr(),
                    placeholder: 'nombre_para_esta_tarjeta'.tr(),
                    controller: _aliasController,
                  ),

                  SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: _isSaving
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.of(context).naranjaUnimet,
                            ),
                          )
                        : CustomButton(
                            text: 'guardar_tarjeta'.tr(),
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
