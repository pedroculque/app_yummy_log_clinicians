import 'package:feature_contract/clinicians_analytics.dart';
import 'package:package_analytics/package_analytics.dart';

/// Implementação de [CliniciansAnalytics] sobre [AnalyticsLogger].
class CliniciansAnalyticsImpl implements CliniciansAnalytics {
  CliniciansAnalyticsImpl(this._logger);

  final AnalyticsLogger _logger;

  void _log(String name, [Map<String, Object?>? params]) {
    _logger.logEvent(name, params: params);
  }

  /// Propriedades de utilizador estáveis para segmentar o app clínico no GA4.
  static void applyDefaultUserProperties(AnalyticsLogger logger) {
    logger.setUserProperty(name: 'app_variant', value: 'clinicians');
  }

  @override
  void logPaywallView({required String source}) =>
      _log('cl_paywall_view', {'source': source});

  @override
  void logPurchaseSubmit({required String planPeriod}) =>
      _log('cl_purchase_submit', {'plan_period': planPeriod});

  @override
  void logPurchaseOutcome({required String result}) =>
      _log('cl_purchase_outcome', {'result': result});

  @override
  void logRestoreOutcome({required String result}) =>
      _log('cl_restore_outcome', {'result': result});

  @override
  void logInviteFlowOpen({String? patientCountBucket}) => _log(
        'cl_invite_flow_open',
        {
          'patient_count_bucket':? patientCountBucket,
        },
      );

  @override
  void logInviteShare({required String channel}) =>
      _log('cl_invite_share', {'channel': channel});

  @override
  void logPatientRemoveConfirm() => _log('cl_patient_remove_confirm');

  @override
  void logInsightsPeriodSet({required int days}) =>
      _log('cl_insights_period_set', {'days': days});

  @override
  void logInsightsPatientDrill({required String target}) =>
      _log('cl_insights_patient_drill', {'target': target});

  @override
  void logAuthStart({required String method}) =>
      _log('cl_auth_start', {'method': method});

  @override
  void logAuthResult({required String method, required bool success}) => _log(
        'cl_auth_result',
        {'method': method, 'success': success},
      );

  @override
  void logLogout() => _log('cl_logout');

  @override
  void logNotifPrefUpdate({required bool pushEnabled, required String mode}) =>
      _log(
        'cl_notif_pref_update',
        {'push_enabled': pushEnabled, 'mode': mode},
      );

  @override
  void logRateAppOpen({required String source}) =>
      _log('cl_rate_app_open', {'source': source});

  @override
  void logAccountDeleteComplete() => _log('cl_account_delete_complete');

  @override
  void logDiaryMealOpen({required String mealType}) =>
      _log('cl_diary_meal_open', {'meal_type': mealType});

  @override
  void logFormConfigSave() => _log('cl_form_config_save');
}
