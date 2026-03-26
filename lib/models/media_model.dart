import 'package:cloud_firestore/cloud_firestore.dart';

class Media {
  final String id;
  final String title;
  final String type;
  final bool available;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Media({
    required this.id,
    required this.title,
    required this.type,
    required this.available,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'available': available,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firestore document
  factory Media.fromMap(String id, Map<String, dynamic> data) {
    return Media(
      id: id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      available: data['available'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create a copy with modified fields
  Media copyWith({
    String? id,
    String? title,
    String? type,
    bool? available,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Media(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      available: available ?? this.available,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Media(id: $id, title: $title, type: $type, available: $available)';
}