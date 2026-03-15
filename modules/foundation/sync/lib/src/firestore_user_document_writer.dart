import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_foundation/src/user_document_writer.dart';

/// Implementação do [UserDocumentWriter] usando Cloud Firestore.
class FirestoreUserDocumentWriter implements UserDocumentWriter {
  FirestoreUserDocumentWriter({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'users';

  @override
  Future<void> ensureExists(
    String userId, {
    String? email,
    String? displayName,
  }) async {
    final now = DateTime.now().toIso8601String();
    final data = <String, dynamic>{
      'updatedAt': now,
      if (email != null && email.isNotEmpty) 'email': email,
      if (displayName != null && displayName.isNotEmpty)
        'displayName': displayName,
    };
    final docRef = _firestore.collection(_collection).doc(userId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      data['createdAt'] = now;
    }
    await docRef.set(data, SetOptions(merge: true));
  }
}
