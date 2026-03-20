import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:patients_feature/src/data/patient.dart';

abstract class PatientsRepository {
  Future<List<Patient>> getPatients(String clinicianId);
  Stream<List<Patient>> watchPatients(String clinicianId);
  Future<String?> getInviteCode(String clinicianId);
  Future<String> generateInviteCode(String clinicianId, String? displayName);
  Future<void> removePatient(String clinicianId, String patientId);

  /// Remove dados do clínico no Firestore (antes de apagar o usuário no Auth).
  Future<void> deleteClinicianAccountData(String clinicianId);
}

class FirestorePatientsRepository implements PatientsRepository {
  FirestorePatientsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<Patient>> getPatients(String clinicianId) async {
    final snapshot = await _firestore
        .collection('clinicians')
        .doc(clinicianId)
        .collection('patients')
        .get();

    final patients = <Patient>[];
    for (final doc in snapshot.docs) {
      final patientId = doc.id;
      final linkData = doc.data();

      final patientDoc =
          await _firestore.collection('users').doc(patientId).get();

      final userData = patientDoc.exists
          ? patientDoc.data()!
          : <String, dynamic>{};

      debugPrint(
        '[PatientsRepo] getPatients patientId=$patientId '
        'link.photoUrl=${linkData['photoUrl']} '
        'link.photoURL=${linkData['photoURL']} '
        'user.photoUrl=${userData['photoUrl']} '
        'user.photoURL=${userData['photoURL']}',
      );

      patients.add(
        Patient.fromFirestore(
          {...userData, ...linkData},
          patientId,
        ),
      );
    }
    return patients;
  }

  @override
  Stream<List<Patient>> watchPatients(String clinicianId) {
    debugPrint(
      '[PatientsRepo] watchPatients: clinicianId=$clinicianId '
      '(path: clinicians/$clinicianId/patients)',
    );
    final stream = _firestore
        .collection('clinicians')
        .doc(clinicianId)
        .collection('patients')
        .snapshots()
        .asyncMap((snapshot) async {
      debugPrint(
        '[PatientsRepo] snapshot received: ${snapshot.docs.length} docs, '
        'metadata.fromCache=${snapshot.metadata.isFromCache}',
      );
      final patients = <Patient>[];
      for (final doc in snapshot.docs) {
        final patientId = doc.id;
        final linkData = doc.data();
        Map<String, dynamic> userData;
        try {
          final patientDoc =
              await _firestore.collection('users').doc(patientId).get();
          userData = patientDoc.exists
              ? patientDoc.data()!
              : <String, dynamic>{};

          debugPrint(
            '[PatientsRepo] watchPatients patientId=$patientId '
            'link.photoUrl=${linkData['photoUrl']} '
            'link.photoURL=${linkData['photoURL']} '
            'user.photoUrl=${userData['photoUrl']} '
            'user.photoURL=${userData['photoURL']}',
          );
        } catch (e, st) {
          debugPrint(
            '[PatientsRepo] permission-denied ou erro ao ler users/$patientId: $e',
          );
          debugPrint('[PatientsRepo] stack: $st');
          rethrow;
        }
        patients.add(
          Patient.fromFirestore(
            {...userData, ...linkData},
            patientId,
          ),
        );
      }
      return patients;
    });
    // Evita que permission-denied (ex.: revalidação ao trocar de aba)
    // propague como Unhandled Exception; o cubit mantém a lista em tela.
    return stream.handleError((Object e, StackTrace st) {
      if (e.toString().contains('permission-denied')) return;
      if (e is Exception) throw e;
      if (e is Error) throw e;
      throw Exception(e.toString());
    });
  }

  @override
  Future<String?> getInviteCode(String clinicianId) async {
    final snapshot = await _firestore
        .collection('clinician_codes')
        .where('clinicianUid', isEqualTo: clinicianId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  @override
  Future<String> generateInviteCode(
    String clinicianId,
    String? displayName,
  ) async {
    final existingCode = await getInviteCode(clinicianId);
    if (existingCode != null) {
      await _firestore.collection('clinician_codes').doc(existingCode).delete();
    }

    final code = _generateCode();
    await _firestore.collection('clinician_codes').doc(code).set({
      'clinicianUid': clinicianId,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return code;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    for (var i = 0; i < 6; i++) {
      buffer.write(chars[(random + i * 7) % chars.length]);
    }
    return buffer.toString();
  }

  @override
  Future<void> removePatient(String clinicianId, String patientId) async {
    await _firestore
        .collection('clinicians')
        .doc(clinicianId)
        .collection('patients')
        .doc(patientId)
        .delete();
  }

  @override
  Future<void> deleteClinicianAccountData(String clinicianId) async {
    final root = _firestore.collection('clinicians').doc(clinicianId);

    Future<void> drainCollection(
      CollectionReference<Map<String, dynamic>> col,
    ) async {
      while (true) {
        final snap = await col.limit(450).get();
        if (snap.docs.isEmpty) break;
        final batch = _firestore.batch();
        for (final d in snap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }
    }

    await drainCollection(root.collection('patients'));
    await drainCollection(root.collection('notification_tokens'));
    await drainCollection(root.collection('preferences'));

    final code = await getInviteCode(clinicianId);
    if (code != null) {
      await _firestore.collection('clinician_codes').doc(code).delete();
    }

    final userDoc = _firestore.collection('users').doc(clinicianId);
    final userSnap = await userDoc.get();
    if (userSnap.exists) {
      await userDoc.delete();
    }

    try {
      await root.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'not-found') rethrow;
    }
  }
}
