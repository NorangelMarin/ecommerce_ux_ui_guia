class PaymentMethod {
  final String id;
  final String brand;
  final String last4Digits;
  final String expiryDate;
  final String labelColor;
  final bool isDefault;
  final String alias;

  PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4Digits,
    required this.expiryDate,
    required this.labelColor,
    this.isDefault = false,
    this.alias = '',
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> data, String documentId) {
    return PaymentMethod(
      id: documentId,
      brand: data['brand']?.toString() ?? '',
      last4Digits: data['last4Digits']?.toString() ?? '',
      expiryDate: data['expiryDate']?.toString() ?? '',
      labelColor: data['labelColor']?.toString() ?? 'blue',
      isDefault: data['isDefault'] as bool? ?? false,
      alias: data['alias']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'last4Digits': last4Digits,
      'expiryDate': expiryDate,
      'labelColor': labelColor,
      'isDefault': isDefault,
      'alias': alias,
    };
  }
}
