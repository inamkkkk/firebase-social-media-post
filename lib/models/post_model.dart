import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String userId;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;

  Post({
    required this.userId,
    required this.text,
    this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}