import 'package:easy_localization/easy_localization.dart';

String translateStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pago confirmado':
      return 'pago_confirmado'.tr();
    case 'en preparación':
    case 'en preparacion':
    case 'en proceso':
      return 'en_preparación'.tr();
    case 'enviado':
      return 'enviado'.tr();
    case 'entregado':
      return 'entregado'.tr();
    case 'cancelado':
      return 'cancelado'.tr();
    default:
      return status; // Fallback
  }
}
