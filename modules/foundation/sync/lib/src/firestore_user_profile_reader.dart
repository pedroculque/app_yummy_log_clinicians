import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:sync_foundation/src/user_profile_reader.dart';

/// Implementação do [UserProfileReader] usando Cloud Firestore.
class FirestoreUserProfileReader implements UserProfileReader {
  FirestoreUserProfileReader({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'users';

  @override
  Future<String?> getPhotoUrl(String userId) async {
    try {
      final snapshot =
          await _firestore.collection(_collection).doc(userId).get();
      if (!snapshot.exists) return null;
      final url = snapshot.data()?['photoUrl'];
      return url is String && url.isNotEmpty ? url : null;
    } on Object catch (e) {
      debugPrint('[FirestoreUserProfileReader] getPhotoUrl: $e');
      return null;
    }
  }
}
