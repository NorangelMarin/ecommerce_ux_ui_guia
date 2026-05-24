import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

enum AlertType { exito, advertencia, error }

class CustomAlert extends StatelessWidget {
  final AlertType type;
  final String message;
  final VoidCallback? onConfirm;

  const CustomAlert({
    super.key,
    required this.type,
    required this.message,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color iconColor;
    IconData iconData;
    String defaultText;

    switch (type) {
      case AlertType.exito:
        backgroundColor = AppColors.exito.withOpacity(0.1);
        iconColor = AppColors.exito;
        iconData = Icons.check_circle;
        defaultText = '¡Buen Trabajo!';
        break;
      case AlertType.advertencia:
        backgroundColor = AppColors.advertencia.withOpacity(0.1);
        iconColor = AppColors.advertencia;
        iconData = Icons.warning_rounded;
        defaultText = '¡Ojo!';
        break;
      case AlertType.error:
        backgroundColor = AppColors.error.withOpacity(0.1);
        iconColor = AppColors.error;
        iconData = Icons.error;
        defaultText = 'Oops...';
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 48, color: iconColor),
            ),
            SizedBox(height: 16),
            Text(
              defaultText,
              style: theme.textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.sombras,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            CustomButton(
              text: 'Entendido',
              type: ButtonType.principal,
              color: ButtonColor.azul,
              onPressed: onConfirm ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
