import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary_feature/diary_feature.dart';
import 'package:insights_feature/src/domain/insights_calculator.dart';
import 'package:insights_feature/src/domain/insights_summary.dart';
import 'package:patients_feature/patients_feature.dart';

abstract interface class InsightsRepository {
  Future<InsightsSummary> getInsights(
    String clinicianId, {
    int periodDays = 7,
  });

  Stream<InsightsSummary> watchInsights(
    String clinicianId, {
    int periodDays = 7,
  });
}

class FirestoreInsightsRepository implements InsightsRepository {
  FirestoreInsightsRepository({
    FirebaseFirestore? firestore,
    PatientsRepository? patientsRepository,
    PatientMealsRepository? mealsRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _patientsRepository = patientsRepository,
        _mealsRepository = mealsRepository;

  final FirebaseFirestore _firestore;
  final PatientsRepository? _patientsRepository;
  final PatientMealsRepository? _mealsRepository;

  PatientsRepository get patientsRepository =>
      _patientsRepository ??
      FirestorePatientsRepository(firestore: _firestore);

  PatientMealsRepository get mealsRepository =>
      _mealsRepository ??
      FirestorePatientMealsRepository(firestore: _firestore);

  @override
  Future<InsightsSummary> getInsights(
    String clinicianId, {
    int periodDays = 7,
  }) async {
    final patients = await patientsRepository.getPatients(clinicianId);

    if (patients.isEmpty) {
      return const InsightsSummary.empty();
    }

    final mealsByPatient = <String, List<MealEntry>>{};
    for (final patient in patients) {
      final meals = await mealsRepository.getMeals(patient.id);
      mealsByPatient[patient.id] = meals;
    }

    return InsightsCalculator.calculate(
      patients: patients,
      mealsByPatient: mealsByPatient,
      periodDays: periodDays,
    );
  }

  @override
  Stream<InsightsSummary> watchInsights(
    String clinicianId, {
    int periodDays = 7,
  }) async* {
    yield await getInsights(clinicianId, periodDays: periodDays);
  }
}
