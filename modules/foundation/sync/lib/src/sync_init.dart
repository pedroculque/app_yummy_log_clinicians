import 'package:auth_foundation/auth_foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:sync_foundation/src/clinician_link_service.dart';
import 'package:sync_foundation/src/connection_sync_remote.dart';
import 'package:sync_foundation/src/firestore_connection_remote.dart';
import 'package:sync_foundation/src/firestore_meal_remote.dart';
import 'package:sync_foundation/src/firestore_user_document_writer.dart';
import 'package:sync_foundation/src/firestore_user_profile_reader.dart';
import 'package:sync_foundation/src/meal_sync_remote.dart';
import 'package:sync_foundation/src/photo_upload_service.dart';
import 'package:sync_foundation/src/presentation/cubit/sync_cubit.dart';
import 'package:sync_foundation/src/sembast_sync_queue.dart';
import 'package:sync_foundation/src/sync_config.dart';
import 'package:sync_foundation/src/sync_queue.dart';
import 'package:sync_foundation/src/sync_service.dart';
import 'package:sync_foundation/src/user_document_writer.dart';
import 'package:sync_foundation/src/user_profile_reader.dart';

/// Registra o [SyncService] e suas dependências no [GetIt].
/// Chamar após initPersistence e initAuth.
/// [config]: use [SyncConfig] com `watchersEnabled: false` no app do clínico
/// para evitar permission-denied em users/{uid}/meals e users/{uid}/connections.
void initSync(GetIt getIt, {SyncConfig config = const SyncConfig()}) {
  final mealDs = getIt<MealEntryLocalDataSource>();
  final db = (mealDs as SembastMealEntryLocalDataSource).database;

  getIt
    ..registerSingleton<SyncQueue>(SembastSyncQueue(db))
    ..registerSingleton<MealSyncRemote>(FirestoreMealRemote())
    ..registerSingleton<ConnectionSyncRemote>(
      FirestoreConnectionRemote(),
    )
    ..registerSingleton<ClinicianLinkService>(FirestoreClinicianLinkService())
    ..registerSingleton<UserDocumentWriter>(FirestoreUserDocumentWriter())
    ..registerSingleton<UserProfileReader>(FirestoreUserProfileReader())
    ..registerSingleton<PhotoUploadService>(PhotoUploadService())
    ..registerSingleton<SyncService>(
      SyncService(
        authRepository: getIt<AuthRepository>(),
        mealLocalDataSource: getIt<MealEntryLocalDataSource>(),
        connectionLocalDataSource:
            getIt<ConnectionLocalDataSource>(),
        mealRemote: getIt<MealSyncRemote>(),
        connectionRemote: getIt<ConnectionSyncRemote>(),
        photoUploadService: getIt<PhotoUploadService>(),
        syncQueue: getIt<SyncQueue>(),
        userDocumentWriter: getIt<UserDocumentWriter>(),
        config: config,
      ),
    )
    ..registerSingleton<SyncCubit>(
      SyncCubit(syncService: getIt<SyncService>()),
    );

  getIt<SyncService>().start();
}
