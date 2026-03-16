import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary_feature/diary_feature.dart';
import 'package:flutter/foundation.dart';

abstract class PatientMealsRepository {
  Future<List<MealEntry>> getMeals(String patientId, {Source? source});
  Stream<List<MealEntry>> watchMeals(String patientId);
}

class FirestorePatientMealsRepository implements PatientMealsRepository {
  FirestorePatientMealsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Converte Timestamp do Firestore para string ISO
  /// (MealEntry.fromJson espera string).
  Map<String, dynamic> _normalizeDocData(
    Map<String, dynamic> data,
    String docId,
  ) {
    final out = <String, dynamic>{...data, 'id': docId};
    for (final key in ['dateTime', 'updatedAt', 'deletedAt']) {
      final v = out[key];
      if (v == null) continue;
      if (v is Timestamp) {
        out[key] = v.toDate().toUtc().toIso8601String();
      }
    }
    return out;
  }

  @override
  Future<List<MealEntry>> getMeals(String patientId, {Source? source}) async {
    debugPrint(
      '[PatientMealsRepo] getMeals(patientId=$patientId, source=$source) path=users/$patientId/meals',
    );
    final getOpts = source == Source.server
        ? const GetOptions(source: Source.server)
        : null;
    final snapshot = await _firestore
        .collection('users')
        .doc(patientId)
        .collection('meals')
        .orderBy('dateTime', descending: true)
        .get(getOpts);

    final fromCache = snapshot.metadata.isFromCache;
    final hasPending = snapshot.metadata.hasPendingWrites;
    debugPrint(
      '[PatientMealsRepo] getMeals snapshot: ${snapshot.docs.length} docs '
      'fromCache=$fromCache hasPendingWrites=$hasPending',
    );

    var parseErrors = 0;
    var deletedCount = 0;
    final entries = snapshot.docs
        .map((doc) {
          try {
            final data = _normalizeDocData(doc.data(), doc.id);
            final entry = MealEntry.fromJson(data);
            if (entry.deletedAt != null) {
              deletedCount++;
              return null;
            }
            return entry;
          } on Object catch (e, st) {
            parseErrors++;
            debugPrint(
              '[PatientMealsRepo] getMeals parse error doc=${doc.id}: $e',
            );
            debugPrint('[PatientMealsRepo] $st');
            return null;
          }
        })
        .whereType<MealEntry>()
        .toList();

    debugPrint(
      '[PatientMealsRepo] getMeals: ${snapshot.docs.length} docs -> '
      '${entries.length} entries (deleted=$deletedCount, '
      'parseErrors=$parseErrors)',
    );
    return entries;
  }

  @override
  Stream<List<MealEntry>> watchMeals(String patientId) {
    debugPrint(
      '[PatientMealsRepo] watchMeals(patientId=$patientId) path=users/$patientId/meals',
    );
    return _firestore
        .collection('users')
        .doc(patientId)
        .collection('meals')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
          final fromCache = snapshot.metadata.isFromCache;
          final hasPending = snapshot.metadata.hasPendingWrites;
          debugPrint(
            '[PatientMealsRepo] watchMeals snapshot: '
            '${snapshot.docs.length} docs fromCache=$fromCache '
            'hasPendingWrites=$hasPending',
          );

          var parseErrors = 0;
          var deletedCount = 0;
          final entries = snapshot.docs
              .map((doc) {
                try {
                  final data = _normalizeDocData(doc.data(), doc.id);
                  final entry = MealEntry.fromJson(data);
                  if (entry.deletedAt != null) {
                    deletedCount++;
                    return null;
                  }
                  return entry;
                } on Object catch (e, st) {
                  parseErrors++;
                  debugPrint(
                    '[PatientMealsRepo] watchMeals parse error '
                    'doc=${doc.id}: $e',
                  );
                  debugPrint('[PatientMealsRepo] $st');
                  return null;
                }
              })
              .whereType<MealEntry>()
              .toList();

          debugPrint(
            '[PatientMealsRepo] watchMeals: ${snapshot.docs.length} docs -> '
            '${entries.length} entries (deleted=$deletedCount, '
            'parseErrors=$parseErrors)',
          );
          return entries;
        });
  }
}
