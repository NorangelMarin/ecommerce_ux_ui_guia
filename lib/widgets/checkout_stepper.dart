import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class CheckoutStepper extends StatelessWidget {
  final int currentStep; // 1, 2, o 3

  const CheckoutStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStep(context, 1, 'direccion_stepper'.tr(), currentStep >= 1),
          _buildLine(context, currentStep >= 2),
          _buildStep(context, 2, 'metodo_de_pago_stepper'.tr(), currentStep >= 2),
          _buildLine(context, currentStep >= 3),
          _buildStep(context, 3, 'confirmacion_stepper'.tr(), currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, int step, String label, bool isActive) {
    final theme = Theme.of(context);
    
    // Colores según el Figma
    final bgColor = isActive 
        ? AppColors.of(context).naranjaUnimet.withValues(alpha: 0.15) 
        : AppColors.of(context).sombras.withValues(alpha: 0.08);
    
    final textColor = isActive 
        ? AppColors.of(context).naranjaUnimet 
        : AppColors.of(context).sombras.withValues(alpha: 0.8);
        
    final labelColor = isActive
        ? AppColors.of(context).naranjaUnimet
        : AppColors.of(context).sombras;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(BuildContext context, bool isCompleted) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 24), // Compensar el texto inferior
        color: isCompleted ? AppColors.of(context).naranjaUnimet : AppColors.of(context).sombras.withValues(alpha: 0.3),
      ),
    );
  }
}
