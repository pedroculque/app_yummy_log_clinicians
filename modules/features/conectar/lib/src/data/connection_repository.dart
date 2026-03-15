import 'dart:async';

import 'package:conectar_feature/src/data/connected_clinician.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:sync_foundation/sync_foundation.dart';

/// Callbacks de sync para conexões.
typedef ConnectionSyncPushCallback = Future<void> Function(
  Map<String, dynamic> json,
);
typedef ConnectionSyncDeleteCallback = Future<void> Function(String id);

/// Dados opcionais do clínico já resolvidos pelo backend (código válido).
class ResolvedClinicianInfo {
  const ResolvedClinicianInfo({
    required this.clinicianUid,
    this.displayName,
  });
  final String clinicianUid;
  final String? displayName;
}

/// Repositório do vínculo com nutricionistas.
abstract class ConnectionRepository {
  Future<String?> getLinkedCode();
  /// [resolved] quando fornecido indica que o código foi validado e o
  /// clínico será preenchido (clinicianUid/displayName) no documento.
  Future<void> linkWithCode(
    String code, {
    ResolvedClinicianInfo? resolved,
  });
  Future<List<ConnectedClinician>> getConnections();
  Future<void> removeConnection(String id);
}

/// Implementação local usando Sembast via [ConnectionLocalDataSource].
class LocalConnectionRepository implements ConnectionRepository {
  LocalConnectionRepository(this._dataSource);

  final ConnectionLocalDataSource _dataSource;

  /// Callbacks de sync (injetados pelo app após configurar SyncService).
  ConnectionSyncPushCallback? onSyncPush;
  ConnectionSyncDeleteCallback? onSyncDelete;

  @override
  Future<String?> getLinkedCode() async {
    final connections = await getConnections();
    return connections.isNotEmpty ? connections.first.code : null;
  }

  @override
  Future<void> linkWithCode(
    String code, {
    ResolvedClinicianInfo? resolved,
  }) async {
    final stored = ClinicianInviteCode.toStored(code);
    if (stored.isEmpty) {
      return;
    }
    final list = await getConnections();
    if (list.any(
      (c) => ClinicianInviteCode.toStored(c.code) == stored,
    )) {
      return;
    }
    final now = DateTime.now();
    final newConnection = ConnectedClinician(
      id: '${stored.hashCode}_${now.millisecondsSinceEpoch}',
      code: stored,
      displayName: resolved?.displayName ?? 'Nutricionista',
      linkedAt: now,
      updatedAt: now,
      clinicianUid: resolved?.clinicianUid,
    );
    await _dataSource.save(newConnection.id, newConnection.toJson());

    unawaited(onSyncPush?.call(newConnection.toFirestoreJson()));
  }

  @override
  Future<List<ConnectedClinician>> getConnections() async {
    final list = await _dataSource.getAll();
    return list
        .map((e) => ConnectedClinician.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.status == 'active')
        .toList();
  }

  @override
  Future<void> removeConnection(String id) async {
    await _dataSource.delete(id);
    unawaited(onSyncDelete?.call(id));
  }
}
