import 'package:flutter/widgets.dart';

import 'package:yummy_log_l10n/l10n/gen/app_localizations.dart';

export 'package:yummy_log_l10n/l10n/gen/app_localizations.dart';

extension YummyLogL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
