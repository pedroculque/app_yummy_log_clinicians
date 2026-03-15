import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_foundation/src/clinician_invite_code.dart';

/// Resultado da resolução de um código de clínico (coleção clinician_codes).
class ResolvedClinicianCode {
  const ResolvedClinicianCode({
    required this.clinicianUid,
    this.displayName,
  });

  final String clinicianUid;
  final String? displayName;
}

/// Serviço de vínculo paciente–clínico no backend (Firestore).
///
/// Resolve códigos em clinician_codes e mantém a lista de pacientes
/// em clinicians/{clinicianId}/patients para o app do nutricionista.
abstract class ClinicianLinkService {
  /// Resolve o código e retorna o UID do clínico (e opcionalmente o nome).
  /// Retorna null se o código não existir ou estiver inválido.
  Future<ResolvedClinicianCode?> resolveCode(String code);

  /// Adiciona o paciente à lista do clínico (permite que o clínico leia
  /// meals/connections do paciente pelas regras do Firestore).
  Future<void> addPatientToClinician(String patientId, String clinicianUid);

  /// Remove o paciente da lista do clínico.
  Future<void> removePatientFromClinician(
    String patientId,
    String clinicianUid,
  );
}

/// Implementação usando Firestore.
class FirestoreClinicianLinkService implements ClinicianLinkService {
  FirestoreClinicianLinkService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _codesCollection = 'clinician_codes';

  DocumentReference<Map<String, dynamic>> _codeDoc(String code) =>
      _firestore.collection(_codesCollection).doc(code);

  DocumentReference<Map<String, dynamic>> _patientRef(
    String clinicianUid,
    String patientId,
  ) {
    return _firestore
        .collection('clinicians')
        .doc(clinicianUid)
        .collection('patients')
        .doc(patientId);
  }

  @override
  Future<ResolvedClinicianCode?> resolveCode(String code) async {
    final stored = ClinicianInviteCode.toStored(code);
    if (stored.length != ClinicianInviteCode.length) return null;
    final snapshot = await _codeDoc(stored).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    final uid = data['clinicianUid'] as String?;
    if (uid == null || uid.isEmpty) return null;
    return ResolvedClinicianCode(
      clinicianUid: uid,
      displayName: data['displayName'] as String?,
    );
  }

  @override
  Future<void> addPatientToClinician(
    String patientId,
    String clinicianUid,
  ) async {
    await _patientRef(clinicianUid, patientId).set({
      'linkedAt': FieldValue.serverTimestamp(),
      'patientId': patientId,
    });
  }

  @override
  Future<void> removePatientFromClinician(
    String patientId,
    String clinicianUid,
  ) async {
    await _patientRef(clinicianUid, patientId).delete();
  }
}
