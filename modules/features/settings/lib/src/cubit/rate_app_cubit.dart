import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:package_app_rating/package_app_rating.dart';

/// Estado mínimo — o fluxo de avaliação é modal e não altera estado aqui.
class RateAppState {
  const RateAppState();
}

/// Encapsula [AppRating] (mobile-foundation) para a UI não aceder ao GetIt.
class RateAppCubit extends Cubit<RateAppState> {
  RateAppCubit({required AppRating? appRating})
      : _appRating = appRating,
        super(const RateAppState());

  final AppRating? _appRating;

  /// Abre o pedido de avaliação a partir de Configurações.
  /// Retorna `false` se [AppRating] não estiver disponível ou em erro.
  Future<bool> openFromSettings(BuildContext context) async {
    final r = _appRating;
    if (r == null) return false;
    try {
      await r.forceRequest(
        context: context,
        origin: 'settings_rate_app',
      );
      return true;
    } on Object {
      return false;
    }
  }
}
