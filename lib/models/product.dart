import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final List<String> categories;
  final String category; // Para mantener compatibilidad con la UI actual
  final String imageUrl;
  final String? discount;
  final double discountPercentage;
  final bool isFeatured;
  final DateTime? createdAt;
  final String? description;

  final Map<String, String> specs;      // Especificaciones dinámicas
  final double ratingPromedio;          // Promedio de calificaciones
  final int totalResenas;               // Total de reseñas

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.categories,
    required this.category,
    required this.imageUrl,
    this.discount,
    this.discountPercentage = 0.0,
    this.isFeatured = false,
    this.createdAt,
    this.description,
    this.specs = const {},
    this.ratingPromedio = 0.0,
    this.totalResenas = 0,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    String? parsedDiscount;
    double parsedDiscountPercentage = 0.0;
    if (data['discount'] != null && data['discount'] != 0) {
      if (data['discount'] is num) {
        parsedDiscountPercentage = (data['discount'] as num).toDouble();
        parsedDiscount = '${parsedDiscountPercentage.toInt()}% OFF';
      } else {
        parsedDiscount = data['discount'].toString();
      }
    }

    final List<String> cats = List<String>.from(data['categories'] ?? []);
    final String mainCategory = cats.isNotEmpty ? cats.first : 'General';

    // Parsear specs: Firestore lo almacena como Map<String, dynamic>
    final Map<String, String> parsedSpecs = {};
    if (data['specs'] is Map) {
      (data['specs'] as Map).forEach((k, v) {
        parsedSpecs[k.toString()] = v?.toString() ?? '';
      });
    }

    return Product(
      id: documentId,
      title: data['title']?.toString() ?? '',
      price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
      categories: cats,
      category: mainCategory,
      imageUrl: data['imageUrl']?.toString() ?? '',
      discount: parsedDiscount,
      discountPercentage: parsedDiscountPercentage,
      isFeatured: data['isFeatured'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      description: data['description']?.toString(),
      specs: parsedSpecs,
      ratingPromedio: (data['ratingPromedio'] as num?)?.toDouble() ?? 0.0,
      totalResenas: (data['totalResenas'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'categories': categories,
      'imageUrl': imageUrl,
      'discount': discount,
      'isFeatured': isFeatured,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'description': description,
      'specs': specs,
      'ratingPromedio': ratingPromedio,
      'totalResenas': totalResenas,
    };
  }
}
