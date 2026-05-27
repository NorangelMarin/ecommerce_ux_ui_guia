import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address.dart';

class AddressRepository {
  final FirebaseFirestore _firestore;

  AddressRepository(this._firestore);

  // Obtener flujo en tiempo real de las direcciones
  Stream<List<Address>> getUserAddresses(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Address.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Agregar nueva dirección — retorna el ID del documento creado
  Future<String> addAddress(String uid, Address address) async {
    final collection = _firestore.collection('users').doc(uid).collection('addresses');
    
    // Si es default, quitamos el default a las demás
    if (address.isDefault) {
      await _removeOtherDefaults(uid);
    }

    final docRef = await collection.add(address.toMap());
    return docRef.id;
  }

  // Actualizar dirección
  Future<void> updateAddress(String uid, Address address) async {
    if (address.isDefault) {
      await _removeOtherDefaults(uid);
    }
    
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(address.id)
        .update(address.toMap());
  }

  // Eliminar dirección
  Future<void> deleteAddress(String uid, String addressId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  // Marcar una dirección como predeterminada (y quitarle el estado a las demás)
  Future<void> setDefaultAddress(String uid, String addressId) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('users').doc(uid).collection('addresses');

    // Buscar si hay alguna que sea default actualmente
    final currentDefaults = await collection.where('isDefault', isEqualTo: true).get();
    for (var doc in currentDefaults.docs) {
      if (doc.id != addressId) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }

    // Poner en true la seleccionada
    batch.update(collection.doc(addressId), {'isDefault': true});
    
    await batch.commit();
  }

  // Método auxiliar interno
  Future<void> _removeOtherDefaults(String uid) async {
    final collection = _firestore.collection('users').doc(uid).collection('addresses');
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
