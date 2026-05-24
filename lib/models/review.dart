import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> data, String documentId) {
    return Review(
      id: documentId,
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? 'Usuario',
      userPhotoUrl: data['userPhotoUrl']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
