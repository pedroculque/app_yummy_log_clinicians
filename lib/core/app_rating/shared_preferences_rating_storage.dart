import 'dart:convert';

import 'package:package_app_rating/package_app_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAppRatingStateKey = 'clinician_app_rating_state_v1';

/// [RatingStorage] com [SharedPreferences].
class SharedPreferencesRatingStorage implements RatingStorage {
  SharedPreferencesRatingStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> clear() async {
    await _prefs.remove(_kAppRatingStateKey);
  }

  @override
  Future<AppRatingState> load() async {
    final raw = _prefs.getString(_kAppRatingStateKey);
    if (raw == null || raw.isEmpty) {
      return AppRatingState.initial();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(map);
    } on Object {
      return AppRatingState.initial();
    }
  }

  @override
  Future<void> save(AppRatingState state) async {
    await _prefs.setString(_kAppRatingStateKey, jsonEncode(_toJson(state)));
  }

  Map<String, dynamic> _toJson(AppRatingState s) => {
        'status': s.status.name,
        'promptCount': s.promptCount,
        'lastPromptDate': s.lastPromptDate?.toIso8601String(),
        'ratedDate': s.ratedDate?.toIso8601String(),
        'lastRating': s.lastRating,
        'actionCount': s.actionCount,
        'sessionCount': s.sessionCount,
        'isPostponed': s.isPostponed,
        'currentOrigin': s.currentOrigin,
        'selectedRating': s.selectedRating,
      };

  AppRatingState _fromJson(Map<String, dynamic> m) {
    RatingStatus parseStatus(String? name) {
      if (name == null) return RatingStatus.idle;
      return RatingStatus.values.firstWhere(
        (e) => e.name == name,
        orElse: () => RatingStatus.idle,
      );
    }

    return AppRatingState(
      status: parseStatus(m['status'] as String?),
      promptCount: (m['promptCount'] as num?)?.toInt() ?? 0,
      lastPromptDate: _parseDate(m['lastPromptDate'] as String?),
      ratedDate: _parseDate(m['ratedDate'] as String?),
      lastRating: (m['lastRating'] as num?)?.toInt(),
      actionCount: (m['actionCount'] as num?)?.toInt() ?? 0,
      sessionCount: (m['sessionCount'] as num?)?.toInt() ?? 0,
      isPostponed: m['isPostponed'] as bool? ?? false,
      currentOrigin: m['currentOrigin'] as String?,
      selectedRating: (m['selectedRating'] as num?)?.toInt() ?? 0,
    );
  }

  DateTime? _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  }
}
