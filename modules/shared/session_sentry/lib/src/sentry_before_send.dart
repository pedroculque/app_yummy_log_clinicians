import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Descarta eventos esperados (ex.: utilizador cancelou a compra na loja).
SentryEvent? sentryBeforeSend(SentryEvent event, Hint hint) {
  if (_isPurchaseUserCancelled(event.throwable)) {
    return null;
  }
  return event;
}

bool _isPurchaseUserCancelled(Object? throwable) {
  if (throwable is! PlatformException) return false;
  final details = throwable.details;
  if (details is Map) {
    final code = details['readable_error_code'] ?? details['readableErrorCode'];
    if (code == 'PURCHASE_CANCELLED_ERROR') return true;
  }
  final msg = throwable.message ?? '';
  if (msg.contains('purchaseCancelledError')) return true;
  if (msg.contains('PurchaseCancelledError')) return true;
  return false;
}
