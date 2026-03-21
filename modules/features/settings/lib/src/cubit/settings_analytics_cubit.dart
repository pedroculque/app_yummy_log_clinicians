import 'package:bloc/bloc.dart';
import 'package:feature_contract/clinicians_analytics.dart';

/// Estado vazio — o cubit só encaminha analytics.
class SettingsAnalyticsState {
  const SettingsAnalyticsState();
}

/// Eventos de analytics da feature Configurações (restore, notificações,
/// avaliar app).
///
/// O contrato de analytics é passado no construtor (mock em testes;
/// UI sem GetIt).
class SettingsAnalyticsCubit extends Cubit<SettingsAnalyticsState> {
  SettingsAnalyticsCubit(this._analytics)
      : super(const SettingsAnalyticsState());

  final CliniciansAnalytics? _analytics;

  void logRestoreOutcome({required String result}) {
    _analytics?.logRestoreOutcome(result: result);
  }

  void logRateAppOpen() {
    _analytics?.logRateAppOpen(source: 'settings');
  }

  void logNotifPrefUpdate({
    required bool pushEnabled,
    required String mode,
  }) {
    _analytics?.logNotifPrefUpdate(pushEnabled: pushEnabled, mode: mode);
  }
}
