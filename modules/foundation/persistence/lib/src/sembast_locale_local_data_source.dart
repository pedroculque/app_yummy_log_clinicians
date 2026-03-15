import 'dart:ui';

import 'package:persistence_foundation/src/locale_local_data_source.dart';
import 'package:sembast/sembast.dart';

const String _storeName = 'app_settings';
const String _localeKey = 'locale';

/// Implementação do [LocaleLocalDataSource] usando Sembast.
class SembastLocaleLocalDataSource implements LocaleLocalDataSource {
  SembastLocaleLocalDataSource(this._db);

  final Database _db;

  static final StoreRef<String, dynamic> _store =
      StoreRef<String, dynamic>(_storeName);

  @override
  Future<Locale?> getLocale() async {
    final value = await _store.record(_localeKey).get(_db);
    if (value == null) return null;
    return Locale(value as String);
  }

  @override
  Future<void> setLocale(Locale locale) async {
    await _store.record(_localeKey).put(_db, locale.languageCode);
  }
}
