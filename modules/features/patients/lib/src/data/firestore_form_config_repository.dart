import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:patients_feature/src/data/behavior_form_config.dart';
import 'package:patients_feature/src/data/form_config_repository.dart';

/// ID do documento único da config na subcoleção form_config.
const String _kFormConfigDocId = 'behavior';

class FirestoreFormConfigRepository implements FormConfigRepository {
  FirestoreFormConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _configRef(String patientId) =>
      _firestore
          .collection('users')
          .doc(patientId)
          .collection('form_config')
          .doc(_kFormConfigDocId);

  @override
  Future<BehaviorFormConfig> getFormConfig(String patientId) async {
    final snap = await _configRef(patientId).get();
    if (!snap.exists || snap.data() == null) {
      return const BehaviorFormConfig();
    }
    return BehaviorFormConfig.fromFirestore(snap.data());
  }

  @override
  Stream<BehaviorFormConfig> watchFormConfig(String patientId) {
    return _configRef(patientId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return const BehaviorFormConfig();
      }
      return BehaviorFormConfig.fromFirestore(snap.data());
    });
  }

  @override
  Future<void> saveFormConfig(
    String patientId,
    BehaviorFormConfig config, {
    required String clinicianUid,
    String? clinicianDisplayName,
    int changeLogMaxLength = 10,
  }) async {
    final now = DateTime.now().toUtc();
    final newEntry = FormConfigChangeLogEntry(
      at: now,
      by: clinicianUid,
      displayName: clinicianDisplayName,
    );
    final updatedLog = [newEntry, ...config.changeLog];
    final truncatedLog = updatedLog.take(changeLogMaxLength).toList();

    final updated = config.copyWith(
      updatedAt: now,
      updatedBy: clinicianUid,
      updatedByDisplayName: clinicianDisplayName,
      changeLog: truncatedLog,
    );

    final path = 'users/$patientId/form_config/$_kFormConfigDocId';
    debugPrint('[FormConfigRepo] Saving to $path');
    await _configRef(patientId).set(updated.toFirestore());
    debugPrint('[FormConfigRepo] Save completed successfully');
  }
}
