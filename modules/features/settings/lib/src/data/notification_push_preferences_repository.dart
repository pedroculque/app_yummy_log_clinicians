import 'package:cloud_firestore/cloud_firestore.dart';

/// Modo quando as notificações estão ligadas.
enum NotificationPushMode {
  /// Toda nova refeição (padrão).
  all,

  /// Só entrada com comportamento de risco (como Insights).
  criticalOnly,
}

/// Preferências de push do clínico.
class NotificationPushPrefs {
  const NotificationPushPrefs({
    required this.pushEnabled,
    required this.mode,
  });

  factory NotificationPushPrefs.fromData(Map<String, dynamic>? d) {
    final pushEnabled = switch (d?['pushEnabled']) {
      false => false,
      _ => true,
    };
    final modeStr = d?['pushMode'] as String?;
    final mode = modeStr == 'critical_only'
        ? NotificationPushMode.criticalOnly
        : NotificationPushMode.all;
    return NotificationPushPrefs(pushEnabled: pushEnabled, mode: mode);
  }

  /// `false` só quando gravado explicitamente no Firestore.
  final bool pushEnabled;
  final NotificationPushMode mode;
}

/// Persiste em `clinicians/{uid}/preferences/notification`.
class NotificationPushPreferencesRepository {
  NotificationPushPreferencesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'preferences';
  static const _docId = 'notification';

  Stream<NotificationPushPrefs> watchPrefs(String clinicianUid) {
    return _firestore
        .collection('clinicians')
        .doc(clinicianUid)
        .collection(_collection)
        .doc(_docId)
        .snapshots()
        .map((snap) => NotificationPushPrefs.fromData(snap.data()));
  }

  Future<void> setPushEnabled(
    String clinicianUid, {
    required bool enabled,
  }) async {
    await _firestore
        .collection('clinicians')
        .doc(clinicianUid)
        .collection(_collection)
        .doc(_docId)
        .set(
      {
        'pushEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setPushMode(
    String clinicianUid,
    NotificationPushMode mode,
  ) async {
    await _firestore
        .collection('clinicians')
        .doc(clinicianUid)
        .collection(_collection)
        .doc(_docId)
        .set(
      {
        'pushMode': mode == NotificationPushMode.criticalOnly
            ? 'critical_only'
            : 'all',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
