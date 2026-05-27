import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/top_navigation_bar.dart';
import '../../widgets/custom_button.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/guide_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  final String? orderId;
  const SurveyScreen({super.key, this.orderId});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  // 0: Malo, 1: Normal, 2: Bueno, 3: Excelente
  int? _selectedRating;
  final _commentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitSurvey(String uid) async {
    if (_selectedRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('por_favor_selecciona_una_valoración'.tr())),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final surveyData = {
        'rating': _selectedRating,
        'comment': _commentController.text.trim(),
      };

      await ref.read(orderRepositoryProvider).saveSurvey(
            uid,
            widget.orderId!,
            surveyData,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('gracias_por_tu_opinión'.tr()),
            backgroundColor: AppColors.of(context).verdeSaman,
          ),
        );
        // Podríamos navegar al inicio o simplemente dejar que el stream actualice la UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.of(context).fondoPrincipal,
      drawer: CustomDrawer(),
      appBar: TopNavigationBar(
        titleWidget: Text('encuesta_de_satisfaccin'.tr(),
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
        data: (orders) {
          final order = widget.orderId != null
              ? orders.firstWhere((o) => o.id == widget.orderId, orElse: () => orders.first)
              : orders.first;
          
          final hasSubmitted = order.survey != null;
          if (hasSubmitted && _selectedRating == null) {
            // Cargar datos previos si ya fue enviado
            _selectedRating = order.survey!['rating'];
            _commentController.text = order.survey!['comment'] ?? '';
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildSuccessHeader(context),
                  SizedBox(height: 16),
                  _buildSurveyBlock(context, hasSubmitted, user?.uid),
                ],
              ),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('error_general'.tr(args: [e.toString()]))),
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

  Widget _buildSuccessHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.of(context).azulSistemas,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('entregado'.tr(),
                style: TextStyle(
                  color: AppColors.of(context).blanco,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('tu_pedido_ha_sidonentregado'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              color: AppColors.of(context).blanco,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16),
          Text('han_confirmado_la_recepcin_del_pedido'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.of(context).blanco.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSurveyBlock(BuildContext context, bool hasSubmitted, String? uid) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.of(context).fondoTarjetas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GuideWrapper(
            title: 'recolección_de_feedback'.tr(),
            description: 'Conocer la opinión del usuario permite iterar sobre el producto. El NPS (Net Promoter Score) es una métrica clave en e-commerce.',
            child: Text(
              hasSubmitted ? 'Tu valoración enviada:' : '¿Cómo valoras el servicio recibido?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.of(context).textoPrincipal,
              ),
            ),
          ),
          SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingButton(
                index: 0,
                label: 'malo'.tr(),
                icon: Icons.sentiment_very_dissatisfied,
                iconColor: Colors.red[600]!,
                disabled: hasSubmitted,
              ),
              _buildRatingButton(
                index: 1,
                label: 'normal'.tr(),
                icon: Icons.sentiment_neutral,
                iconColor: AppColors.of(context).azulSistemas,
                disabled: hasSubmitted,
              ),
              _buildRatingButton(
                index: 2,
                label: 'bueno'.tr(),
                icon: Icons.sentiment_satisfied,
                iconColor: Colors.amber[500]!,
                disabled: hasSubmitted,
              ),
              _buildRatingButton(
                index: 3,
                label: 'excelente'.tr(),
                icon: Icons.sentiment_very_satisfied,
                iconColor: Colors.green[600]!,
                disabled: hasSubmitted,
              ),
            ],
          ),
          
          SizedBox(height: 32),
          
          Text(
            hasSubmitted ? 'Tus observaciones:' : '¿Quieres añadir alguna observación?',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: AppColors.of(context).sombras,
            ),
          ),
          SizedBox(height: 16),
          
          GuideWrapper(
            title: 'prevención_de_errores'.tr(),
            description: 'Al deshabilitar el formulario después del envío, evitamos que el usuario sobrescriba su respuesta accidentalmente o genere datos duplicados.',
            child: Container(
              decoration: BoxDecoration(
                color: hasSubmitted ? AppColors.of(context).sombras.withValues(alpha: 0.05) : AppColors.of(context).blanco,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.of(context).sombras.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                enabled: !hasSubmitted,
                decoration: InputDecoration(
                  hintText: 'escribe_tus_comentarios_aquí'.tr(),
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.of(context).sombras.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: _isSaving 
                  ? 'Enviando...' 
                  : (hasSubmitted ? 'Volver al inicio' : 'Enviar'),
              color: ButtonColor.naranja,
              onPressed: _isSaving 
                  ? null 
                  : (hasSubmitted ? () => context.go('/home') : () => _submitSurvey(uid!)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton({
    required int index,
    required String label,
    required IconData icon,
    required Color iconColor,
    bool disabled = false,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedRating == index;
    
    return GestureDetector(
      onTap: disabled ? null : () {
        setState(() {
          _selectedRating = index;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.of(context).naranjaUnimet.withValues(alpha: 0.1) : AppColors.of(context).blanco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.of(context).naranjaUnimet : AppColors.of(context).sombras.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              icon,
              color: disabled && !isSelected ? AppColors.of(context).sombras.withValues(alpha: 0.3) : iconColor,
              size: 32,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.of(context).naranjaUnimet : AppColors.of(context).sombras,
            ),
          ),
        ],
      ),
    );
  }
}
