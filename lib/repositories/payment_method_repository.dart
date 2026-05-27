import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_method.dart';

class PaymentMethodRepository {
  final FirebaseFirestore _firestore;

  PaymentMethodRepository(this._firestore);

  Stream<List<PaymentMethod>> getUserPaymentMethods(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('payment_methods')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentMethod.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addPaymentMethod(String uid, PaymentMethod pm) async {
    final collection = _firestore.collection('users').doc(uid).collection('payment_methods');
    if (pm.isDefault) {
      await _removeOtherDefaults(uid);
    }
    await collection.add(pm.toMap());
  }

  Future<void> updatePaymentMethod(String uid, PaymentMethod pm) async {
    if (pm.isDefault) {
      await _removeOtherDefaults(uid);
    }
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('payment_methods')
        .doc(pm.id)
        .update(pm.toMap());
  }

  Future<void> deletePaymentMethod(String uid, String pmId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('payment_methods')
        .doc(pmId)
        .delete();
  }

  Future<void> setDefaultPaymentMethod(String uid, String pmId) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('users').doc(uid).collection('payment_methods');

    final currentDefaults = await collection.where('isDefault', isEqualTo: true).get();
    for (var doc in currentDefaults.docs) {
      if (doc.id != pmId) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }

    batch.update(collection.doc(pmId), {'isDefault': true});
    await batch.commit();
  }

  Future<void> _removeOtherDefaults(String uid) async {
    final collection = _firestore.collection('users').doc(uid).collection('payment_methods');
    final currentDefaults = await collection.where('isDefault', isEqualTo: true).get();
    if (currentDefaults.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in currentDefaults.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    }
  }
}
