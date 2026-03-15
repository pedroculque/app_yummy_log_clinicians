import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sync_foundation/src/meal_sync_remote.dart';

/// Implementação do [MealSyncRemote] usando Cloud Firestore.
class FirestoreMealRemote implements MealSyncRemote {
  FirestoreMealRemote({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _mealsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('meals');

  @override
  Future<void> upsert(String userId, Map<String, dynamic> entry) async {
    final id = entry['id'] as String;
    debugPrint('[FirestoreMealRemote] upsert userId=$userId, mealId=$id');
    await _mealsRef(userId).doc(id).set(entry, SetOptions(merge: true));
    debugPrint('[FirestoreMealRemote] upsert SUCCESS');
  }

  @override
  Future<void> softDelete(String userId, String mealId) async {
    await _mealsRef(userId).doc(mealId).update({
      'deletedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchChanges(
    String userId,
    DateTime since,
  ) {
    debugPrint(
      '[FirestoreMealRemote] watchChanges userId=$userId, since=$since',
    );
    debugPrint('[FirestoreMealRemote] Query path: users/$userId/meals');
    
    return _mealsRef(userId)
        .where('updatedAt', isGreaterThan: since.toIso8601String())
        .orderBy('updatedAt')
        .snapshots()
        .map((snapshot) {
          debugPrint(
            '[FirestoreMealRemote] snapshot: ${snapshot.docs.length} docs, '
            'fromCache=${snapshot.metadata.isFromCache}',
          );
          if (snapshot.docs.isEmpty) {
            debugPrint(
              '[FirestoreMealRemote] WARNING: No docs from Firestore!',
            );
          }
          for (final doc in snapshot.docs) {
            debugPrint(
              '[FirestoreMealRemote]   doc.id=${doc.id}, exists=${doc.exists}',
            );
          }
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String userId) async {
    debugPrint('[FirestoreMealRemote] fetchAll userId=$userId');
    final snapshot = await _mealsRef(userId).get();
    debugPrint(
      '[FirestoreMealRemote] fetchAll returned ${snapshot.docs.length} docs',
    );
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
