import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

class CartRepository {
  final FirebaseFirestore _firestore;

  CartRepository(this._firestore);

  Stream<Cart?> getCartStream(String uid) {
    return _firestore
        .collection('carts')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Cart.fromMap(doc.data()!);
    });
  }

  Future<void> updateCart(String uid, List<CartItem> items) async {
    // Si la lista de items está vacía, podríamos borrar el documento para ahorrar espacio
    if (items.isEmpty) {
      await _firestore.collection('carts').doc(uid).delete();
    } else {
      await _firestore.collection('carts').doc(uid).set(
        Cart(updatedAt: DateTime.now(), items: items).toMap(),
        SetOptions(merge: true),
      );
    }
  }

  Future<void> clearCart(String uid) async {
    await _firestore.collection('carts').doc(uid).delete();
  }
}
