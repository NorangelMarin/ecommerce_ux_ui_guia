import 'package:flutter/material.dart';

enum ButtonType { principal, alternativo, inactivo }

enum ButtonColor { azul, naranja }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonColor color;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.principal,
    this.color = ButtonColor.azul,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAzul = color == ButtonColor.azul;
    final primaryColor = isAzul
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    Color backgroundColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (type) {
      case ButtonType.principal:
        backgroundColor = primaryColor;
        textColor = Colors.white;
        break;
      case ButtonType.alternativo:
        backgroundColor = Colors.transparent;
        textColor = primaryColor;
        borderSide = BorderSide(color: primaryColor, width: 2);
        break;
      case ButtonType.inactivo:
        backgroundColor = theme.disabledColor.withValues(alpha: 0.12);
        textColor = theme.disabledColor;
        break;
    }

    // Si es inactivo, ignorar onPressed
    final VoidCallback? action = type == ButtonType.inactivo ? null : onPressed;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (icon != null) ...[
          SizedBox(width: 8),
          Icon(icon, color: textColor, size: 20),
        ],
      ],
    );

    return Semantics(
      label: text,
      button: true,
      enabled: type != ButtonType.inactivo,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: type == ButtonType.alternativo
            ? OutlinedButton(
                onPressed: action,
                style: OutlinedButton.styleFrom(
                  side: borderSide,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: child,
              )
            : ElevatedButton(
                onPressed: action,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: child,
              ),
      ),
    );
  }
}
