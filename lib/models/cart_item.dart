class CartItem {
  final String productId;
  final String title;
  final double unitPrice;
  final String imageUrl;
  final int quantity;
  final double discountValue;

  CartItem({
    required this.productId,
    required this.title,
    required this.unitPrice,
    required this.imageUrl,
    this.quantity = 1,
    this.discountValue = 0.0,
  });

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      productId: data['productId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      unitPrice: double.tryParse(data['unitPrice']?.toString() ?? '0') ?? 0.0,
      imageUrl: data['imageUrl']?.toString() ?? '',
      quantity: data['quantity'] as int? ?? 1,
      discountValue: double.tryParse(data['discountValue']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'unitPrice': unitPrice,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'discountValue': discountValue,
    };
  }

  CartItem copyWith({
    String? productId,
    String? title,
    double? unitPrice,
    String? imageUrl,
    int? quantity,
    double? discountValue,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      unitPrice: unitPrice ?? this.unitPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      discountValue: discountValue ?? this.discountValue,
    );
  }
}
