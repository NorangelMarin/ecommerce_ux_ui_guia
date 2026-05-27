import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final String shippingAddressId; // Mantener por compatibilidad o búsqueda
  final String paymentMethodId;   // Mantener por compatibilidad o búsqueda
  final Map<String, dynamic>? shippingAddressSnapshot;
  final Map<String, dynamic>? paymentMethodSnapshot;
  final DateTime createdAt;
  final String status; // Ej: 'procesando', 'enviado', 'entregado'
  final Map<String, dynamic>? survey;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.shippingAddressId,
    required this.paymentMethodId,
    this.shippingAddressSnapshot,
    this.paymentMethodSnapshot,
    required this.createdAt,
    this.status = 'procesando',
    this.survey,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)?.map((item) => CartItem.fromMap(item as Map<String, dynamic>)).toList() ?? [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      shippingAddressId: map['shippingAddressId'] ?? '',
      paymentMethodId: map['paymentMethodId'] ?? '',
      shippingAddressSnapshot: map['shippingAddressSnapshot'],
      paymentMethodSnapshot: map['paymentMethodSnapshot'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'procesando',
      survey: map['survey'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'shippingAddressId': shippingAddressId,
      'paymentMethodId': paymentMethodId,
      'shippingAddressSnapshot': shippingAddressSnapshot,
      'paymentMethodSnapshot': paymentMethodSnapshot,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'survey': survey,
    };
  }
}
