import 'package:flutter/material.dart';

enum NotificationType { success, info, error, warning }

class CustomNotification {
  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
  }) {
    final theme = Theme.of(context);

    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.success:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case NotificationType.error:
        iconData = Icons.cancel;
        iconColor = Colors.red;
        break;
      case NotificationType.warning:
        iconData = Icons.warning_rounded;
        iconColor = Colors.amber;
        break;
      case NotificationType.info:
      default:
        iconData = Icons.info;
        iconColor = Colors.blue.shade700;
        break;
    }

    final trimmedMessage = message.trim();
    final formattedMessage = trimmedMessage.isNotEmpty 
        ? '${trimmedMessage[0].toUpperCase()}${trimmedMessage.substring(1)}' 
        : trimmedMessage;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: iconColor, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                formattedMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[100], // Fondo gris claro según diseño
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
