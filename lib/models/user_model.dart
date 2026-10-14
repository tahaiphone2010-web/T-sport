import 'package:cloud_firestore/cloud_firestore.dart';

class TSportUser {
  final String uid;
  final String phoneNumber;
  final String? displayName;
  final String role; // 'player', 'venue_manager', 'admin'
  final DateTime createdAt;

  TSportUser({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.role = 'player',
    required this.createdAt,
  });

  factory TSportUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TSportUser(
      uid: doc.id,
      phoneNumber: data['phoneNumber'] ?? '',
      displayName: data['displayName'],
      role: data['role'] ?? 'player',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
