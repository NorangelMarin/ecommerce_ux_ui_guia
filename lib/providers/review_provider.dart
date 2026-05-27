import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import 'auth_provider.dart';
import 'order_provider.dart';

/// Stream de reseñas para un producto, ordenadas de más reciente a más antigua.
final reviewsProvider = StreamProvider.family<List<Review>, String>((
  ref,
  productId,
) {
  return FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .collection('reviews')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.data(), doc.id))
            .toList(),
      );
});

/// Verifica si el usuario autenticado ha comprado el producto dado.
final hasPurchasedProvider = Provider.family<bool, String>((ref, productId) {
  final orders = ref.watch(userOrdersProvider).value ?? [];
  return orders.any(
    (order) => order.items.any((item) => item.productId == productId),
  );
});

/// Verifica si el usuario ya dejó una reseña para este producto.
final hasReviewedProvider = StreamProvider.family<bool, String>((
  ref,
  productId,
) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .collection('reviews')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map((snap) => snap.docs.isNotEmpty);
});

/// Guarda una reseña en Firestore bajo products/{productId}/reviews.
Future<void> submitReview({
  required String productId,
  required String userId,
  required String userName,
  required String userPhotoUrl,
  required double rating,
  required String comment,
}) async {
  final db = FirebaseFirestore.instance;
  final productRef = db.collection('products').doc(productId);
  final newReviewRef = productRef.collection('reviews').doc();

  await db.runTransaction((transaction) async {
    final productDoc = await transaction.get(productRef);

    int totalResenas = 0;
    double ratingPromedio = 0.0;

    if (productDoc.exists) {
      final data = productDoc.data()!;
      totalResenas = (data['totalResenas'] as num?)?.toInt() ?? 0;
      ratingPromedio = (data['ratingPromedio'] as num?)?.toDouble() ?? 0.0;
    }

    // Calcular el nuevo promedio
    final nuevoTotal = totalResenas + 1;
    final nuevoPromedio =
        ((ratingPromedio * totalResenas) + rating) / nuevoTotal;

    // Actualizar producto
    transaction.update(productRef, {
      'totalResenas': nuevoTotal,
      'ratingPromedio': nuevoPromedio,
    });

    // Guardar la reseña
    transaction.set(newReviewRef, {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  });
}
