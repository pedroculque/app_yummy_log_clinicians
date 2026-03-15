import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary_feature/diary_feature.dart';

abstract class PatientMealsRepository {
  Future<List<MealEntry>> getMeals(String patientId);
  Stream<List<MealEntry>> watchMeals(String patientId);
}

class FirestorePatientMealsRepository implements PatientMealsRepository {
  FirestorePatientMealsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<MealEntry>> getMeals(String patientId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(patientId)
        .collection('meals')
        .orderBy('dateTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MealEntry.fromJson(doc.data()))
        .where((entry) => entry.deletedAt == null)
        .toList();
  }

  @override
  Stream<List<MealEntry>> watchMeals(String patientId) {
    return _firestore
        .collection('users')
        .doc(patientId)
        .collection('meals')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealEntry.fromJson(doc.data()))
            .where((entry) => entry.deletedAt == null)
            .toList());
  }
}
