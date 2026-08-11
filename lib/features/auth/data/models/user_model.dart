import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.imageUrl,
    super.createdAt,
  });

  ///=========================================
  /// Entity -> Model
  ///=========================================
  factory UserModel.fromEntity(AppUser user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      imageUrl: user.imageUrl,
      createdAt: user.createdAt,
    );
  }

  ///=========================================
  /// Firestore -> Model
  ///=========================================
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final json = document.data()!;

    return UserModel(
      uid: document.id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'rider',
      imageUrl: json['imageUrl'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  ///=========================================
  /// Model -> Firestore
  ///=========================================
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'imageUrl': imageUrl,
      'createdAt':
          createdAt == null
              ? FieldValue.serverTimestamp()
              : Timestamp.fromDate(createdAt!),
    };
  }

  ///=========================================
  /// copyWith
  ///=========================================
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ///=========================================
  /// Model -> Entity
  ///=========================================
  AppUser toEntity() {
    return AppUser(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }
}
