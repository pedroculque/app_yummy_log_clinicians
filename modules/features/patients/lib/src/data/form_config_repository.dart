import 'package:patients_feature/src/data/behavior_form_config.dart';

abstract class FormConfigRepository {
  /// Carrega a config do formulário de comportamento do paciente.
  /// Retorna [BehaviorFormConfig] vazia se o documento não existir.
  Future<BehaviorFormConfig> getFormConfig(String patientId);

  /// Observa a config em tempo real.
  Stream<BehaviorFormConfig> watchFormConfig(String patientId);

  /// Salva a config. [clinicianUid] e [clinicianDisplayName] são usados para
  /// updatedBy/updatedByDisplayName e nova entrada no changeLog.
  /// Mantém no máximo [changeLogMaxLength] entradas no changeLog.
  Future<void> saveFormConfig(
    String patientId,
    BehaviorFormConfig config, {
    required String clinicianUid,
    String? clinicianDisplayName,
    int changeLogMaxLength = 10,
  });
}
