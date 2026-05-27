import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/payment_method.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pmAsync = ref.watch(userPaymentMethodsProvider);

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text('mis_mtodos_de_pago'.tr(),
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
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('tus_mtodos_de_pago'.tr(),
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.of(context).textoPrincipal,
              ),
            ),
            SizedBox(height: 32),

            // Tarjetas de métodos de pago
            pmAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: AppColors.of(context).naranjaUnimet)),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (pms) {
                if (pms.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Text('no_tienes_mtodos_de_pago_guardados'.tr(), style: TextStyle(color: AppColors.of(context).sombras)),
                  );
                }
                return Column(
                  children: pms.map((pm) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: PaymentCardWidget(pm: pm, ref: ref),
                  )).toList(),
                );
              },
            ),
            
            SizedBox(height: 16),
            _buildAddNewCard(context),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 1) context.push('/cart');
          if (idx == 2) context.push('/history');
          if (idx == 3) context.push('/support');
        },
      ),
    );
  }

  Widget _buildAddNewCard(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        context.push('/add_payment_method');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.of(context).blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.of(context).naranjaUnimet.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.of(context).naranjaUnimet.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.of(context).naranjaUnimet, size: 18),
            ),
            SizedBox(width: 10),
            Text('agregar_nuevo_mtodo_de_pago'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).naranjaUnimet,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentCardWidget extends StatefulWidget {
  final PaymentMethod pm;
  final WidgetRef ref;

  const PaymentCardWidget({super.key, required this.pm, required this.ref});

  @override
  State<PaymentCardWidget> createState() => _PaymentCardWidgetState();
}

class _PaymentCardWidgetState extends State<PaymentCardWidget> {
  bool _isEditing = false;
  late TextEditingController _aliasController;
  late TextEditingController _numberController;
  late TextEditingController _expiryController;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.pm.alias);
    _numberController = TextEditingController(text: '**** **** **** ${widget.pm.last4Digits}');
    _expiryController = TextEditingController(text: widget.pm.expiryDate);
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pm = widget.pm;
    final labelColor = pm.labelColor == 'blue' ? AppColors.of(context).azulSistemas : AppColors.of(context).naranjaUnimet;
    final displayAlias = pm.alias.isNotEmpty ? pm.alias : '${pm.brand} ****${pm.last4Digits}';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).sombras.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.credit_card, color: AppColors.of(context).azulSistemas, size: 32),
                    SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: labelColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pm.brand.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Row(
                children: [
                  if (!_isEditing) ...[
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: AppColors.of(context).azulSistemas, size: 20),
                      onPressed: () => setState(() => _isEditing = true),
                      tooltip: 'Editar alias',
                    ),
                    SizedBox(width: 4),
                    if (pm.isDefault)
                      Icon(Icons.check_circle, color: AppColors.of(context).azulSistemas, size: 20)
                    else
                      IconButton(
                        icon: Icon(Icons.check_circle_outline, color: AppColors.of(context).sombras, size: 20),
                        onPressed: () async {
                          final user = widget.ref.read(authStateProvider).value;
                          if (user != null) {
                            await widget.ref.read(paymentMethodRepositoryProvider).setDefaultPaymentMethod(user.uid, pm.id);
                          }
                        },
                        tooltip: 'Marcar como principal',
                        constraints: BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    SizedBox(width: 12),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () async {
                        final user = widget.ref.read(authStateProvider).value;
                        if (user != null) {
                          await widget.ref.read(paymentMethodRepositoryProvider).deletePaymentMethod(user.uid, pm.id);
                        }
                      },
                      tooltip: 'Eliminar',
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ] else ...[
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _aliasController.text = pm.alias;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.check, color: AppColors.of(context).verdeSaman, size: 20),
                      onPressed: () async {
                        final user = widget.ref.read(authStateProvider).value;
                        if (user != null) {
                          final updatedPm = PaymentMethod(
                            id: pm.id,
                            brand: pm.brand,
                            last4Digits: pm.last4Digits,
                            expiryDate: pm.expiryDate,
                            labelColor: pm.labelColor,
                            isDefault: pm.isDefault,
                            alias: _aliasController.text.trim(),
                          );
                          await widget.ref.read(paymentMethodRepositoryProvider).updatePaymentMethod(user.uid, updatedPm);
                          if (mounted) setState(() => _isEditing = false);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          
          if (_isEditing)
            CustomTextField(
              label: 'alias'.tr(),
              placeholder: 'Ej. Mi Tarjeta Principal',
              controller: _aliasController,
            )
          else ...[
            Text(
              displayAlias,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.of(context).textoPrincipal,
                fontSize: 16,
              ),
            ),
            Text('tarjeta_de_crdito_o_dbito'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).sombras,
                fontSize: 13,
              ),
            ),
          ],
          
          SizedBox(height: 24),

          CustomTextField(
            label: 'número_de_la_tarjeta'.tr(),
            placeholder: '**** **** **** ****',
            controller: _numberController,
            readOnly: true,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'fecha_vencimiento'.tr(),
                  placeholder: 'MM/YY',
                  controller: _expiryController,
                  readOnly: true,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'código_de_seguridad'.tr(),
                  placeholder: 'CVC',
                  controller: TextEditingController(text: '***'),
                  readOnly: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
