import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore;

  WishlistRepository(this._firestore);

  Stream<Wishlist?> getWishlistStream(String uid) {
    return _firestore.collection('wishlists').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Wishlist.fromMap(doc.data()!);
    });
  }

  Future<void> toggleProduct(String uid, String productId, bool isAdding) async {
    final docRef = _firestore.collection('wishlists').doc(uid);
    
    // Utilizamos arrayUnion y arrayRemove que son super eficientes en Firestore
    if (isAdding) {
      await docRef.set({
        'productIds': FieldValue.arrayUnion([productId])
      }, SetOptions(merge: true));
    } else {
      await docRef.set({
        'productIds': FieldValue.arrayRemove([productId])
      }, SetOptions(merge: true));
    }
  }
  
  Future<void> clearWishlist(String uid) async {
    await _firestore.collection('wishlists').doc(uid).delete();
  }
}
