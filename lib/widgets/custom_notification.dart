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
        iconData = Icons.info;
        iconColor = Colors.blue.shade700;
        break;
    }

    final trimmedMessage = message.trim();
    final formattedMessage = trimmedMessage.isNotEmpty
        ? '${trimmedMessage[0].toUpperCase()}${trimmedMessage.substring(1)}'
        : trimmedMessage;

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          bottom: 20.0 + MediaQuery.of(ctx).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
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
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
