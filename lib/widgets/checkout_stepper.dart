import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
          _buildStep(context, 1, 'Dirección', currentStep >= 1),
          _buildLine(currentStep >= 2),
          _buildStep(context, 2, 'Método de pago', currentStep >= 2),
          _buildLine(currentStep >= 3),
          _buildStep(context, 3, 'Confirmación', currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, int step, String label, bool isActive) {
    final theme = Theme.of(context);
    
    // Colores según el Figma
    final bgColor = isActive 
        ? AppColors.naranjaUnimet.withValues(alpha: 0.15) 
        : AppColors.sombras.withValues(alpha: 0.08);
    
    final textColor = isActive 
        ? AppColors.naranjaUnimet 
        : AppColors.sombras.withValues(alpha: 0.8);
        
    final labelColor = isActive
        ? AppColors.naranjaUnimet
        : AppColors.sombras;

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

  Widget _buildLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 24), // Compensar el texto inferior
        color: isCompleted ? AppColors.naranjaUnimet : AppColors.sombras.withValues(alpha: 0.3),
      ),
    );
  }
}
