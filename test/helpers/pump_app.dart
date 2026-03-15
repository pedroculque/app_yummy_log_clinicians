import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }
}
