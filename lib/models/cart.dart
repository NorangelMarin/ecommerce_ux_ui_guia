import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class Cart {
  final DateTime updatedAt;
  final List<CartItem> items;

  Cart({
    required this.updatedAt,
    required this.items,
  });

  factory Cart.fromMap(Map<String, dynamic> data) {
    final itemsData = data['items'] as List<dynamic>? ?? [];
    return Cart(
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: itemsData.map((item) => CartItem.fromMap(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'updatedAt': FieldValue.serverTimestamp(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}
