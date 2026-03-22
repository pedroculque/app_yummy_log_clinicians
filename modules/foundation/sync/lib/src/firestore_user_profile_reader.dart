import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:persistence_foundation/persistence_foundation.dart'
    show clinicianProfilePhotoUrlHint, logClinicianProfilePhoto;

import 'package:sync_foundation/src/user_profile_reader.dart';

/// Implementação do [UserProfileReader] usando Cloud Firestore.
class FirestoreUserProfileReader implements UserProfileReader {
  FirestoreUserProfileReader({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'users';

  static UserProfileSnapshot _snapshotFromData(Map<String, dynamic>? data) {
    if (data == null) {
      return const UserProfileSnapshot();
    }
    final rawUrl = data['photoUrl'];
    final url = rawUrl is String && rawUrl.isNotEmpty ? rawUrl : null;
    final token = _cacheTokenFromData(data);
    return UserProfileSnapshot(photoUrl: url, cacheToken: token);
  }

  static String? _cacheTokenFromData(Map<String, dynamic> data) {
    final v = data['updatedAt'];
    if (v == null) return null;
    if (v is Timestamp) return v.millisecondsSinceEpoch.toString();
    return v.toString();
  }

  @override
  Future<String?> getPhotoUrl(String userId) async {
    final s = await readSnapshot(userId);
    return s.photoUrl;
  }

  @override
  Future<UserProfileSnapshot> readSnapshot(String userId) async {
    try {
      final snapshot =
          await _firestore.collection(_collection).doc(userId).get();
      if (!snapshot.exists) {
        logClinicianProfilePhoto(
          'firestore.readSnapshot uid=$userId exists=false',
        );
        return const UserProfileSnapshot();
      }
      final s = _snapshotFromData(snapshot.data());
      logClinicianProfilePhoto(
        'firestore.readSnapshot uid=$userId '
        'fromCache=${snapshot.metadata.isFromCache} '
        'url=${clinicianProfilePhotoUrlHint(s.photoUrl)} '
        'token=${s.cacheToken ?? '(null)'}',
      );
      return s;
    } on Object catch (e) {
      debugPrint('[FirestoreUserProfileReader] readSnapshot: $e');
      return const UserProfileSnapshot();
    }
  }

  @override
  Stream<UserProfileSnapshot> watchSnapshot(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((snap) {
      if (!snap.exists) {
        logClinicianProfilePhoto(
          'firestore.watch uid=$userId exists=false '
          'fromCache=${snap.metadata.isFromCache}',
        );
        return const UserProfileSnapshot();
      }
      try {
        final s = _snapshotFromData(snap.data());
        logClinicianProfilePhoto(
          'firestore.watch uid=$userId '
          'fromCache=${snap.metadata.isFromCache} '
          'pendingWrites=${snap.metadata.hasPendingWrites} '
          'url=${clinicianProfilePhotoUrlHint(s.photoUrl)} '
          'token=${s.cacheToken ?? '(null)'}',
        );
        return s;
      } on Object catch (e) {
        debugPrint('[FirestoreUserProfileReader] watchSnapshot map: $e');
        return const UserProfileSnapshot();
      }
    });
  }
}
