/// Contrato de analytics do app **YummyLog Clinicians** (eventos `cl_*`).
///
/// A implementação concreta é registada no app (`GetIt`). **Não** a uses
/// diretamente em páginas/widgets: injeta-se como `CliniciansAnalytics?` no
/// construtor dos cubits (ou cubits dedicados por ecrã), e a UI chama métodos
/// no cubit. Em testes, passa-se um mock ou `null` sem `GetIt`.
abstract class CliniciansAnalytics {
  void logPaywallView({required String source});

  void logPurchaseSubmit({required String planPeriod});

  void logPurchaseOutcome({required String result});

  void logRestoreOutcome({required String result});

  void logInviteFlowOpen({String? patientCountBucket});

  void logInviteShare({required String channel});

  void logPatientRemoveConfirm();

  void logInsightsPeriodSet({required int days});

  void logInsightsPatientDrill({required String target});

  void logAuthStart({required String method});

  void logAuthResult({required String method, required bool success});

  void logLogout();

  void logNotifPrefUpdate({required bool pushEnabled, required String mode});

  void logRateAppOpen({required String source});

  void logAccountDeleteComplete();

  /// P2 — tap numa refeição no diário do paciente (detalhe em bottom sheet).
  void logDiaryMealOpen({required String mealType});

  /// P2 — gravação bem-sucedida do formulário de comportamento.
  void logFormConfigSave();
}
