import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'auth_provider.dart';

final orderRepositoryProvider = Provider((ref) {
  return OrderRepository(FirebaseFirestore.instance);
});

final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  return ref.watch(orderRepositoryProvider).getUserOrders(user.uid);
});

class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository(this._firestore);

  Stream<List<OrderModel>> getUserOrders(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<String> createOrder(String uid, OrderModel order) async {
    final docRef = await _firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .add(order.toMap());
    return docRef.id;
  }

  Future<void> saveSurvey(String uid, String orderId, Map<String, dynamic> surveyData) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(orderId)
        .update({
      'survey': {
        ...surveyData,
        'submittedAt': FieldValue.serverTimestamp(),
      }
    });
  }
}
