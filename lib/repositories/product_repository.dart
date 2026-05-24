import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addProduct(Product product) {
    return _firestore.collection('products').add(product.toMap());
  }
}
