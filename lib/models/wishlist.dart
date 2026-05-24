class Wishlist {
  final List<String> productIds;

  Wishlist({
    required this.productIds,
  });

  factory Wishlist.fromMap(Map<String, dynamic> data) {
    return Wishlist(
      productIds: List<String>.from(data['productIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productIds': productIds,
    };
  }
}
