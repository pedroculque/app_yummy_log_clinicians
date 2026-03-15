import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_foundation/src/connection_sync_remote.dart';

/// Implementação do [ConnectionSyncRemote] usando Cloud Firestore.
class FirestoreConnectionRemote implements ConnectionSyncRemote {
  FirestoreConnectionRemote({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _connectionsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('connections');

  @override
  Future<void> upsert(
    String userId,
    Map<String, dynamic> connection,
  ) async {
    final id = connection['id'] as String;
    await _connectionsRef(userId).doc(id).set(
          connection,
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> remove(String userId, String connectionId) async {
    await _connectionsRef(userId).doc(connectionId).delete();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchChanges(String userId) {
    return _connectionsRef(userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String userId) async {
    final snapshot = await _connectionsRef(userId).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
