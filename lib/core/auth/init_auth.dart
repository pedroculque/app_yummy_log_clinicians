import 'package:auth_foundation/auth_foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

/// Inicializa Firebase (config nativa: google-services.json / plist),
/// registra [AuthRepository] e [AuthFlowCubit] no [getIt].
/// Em erro (ex.: Firebase não configurado), usa [StubAuthRepository].
Future<void> initAuth(GetIt getIt) async {
  try {
    await Firebase.initializeApp();
    getIt.registerSingleton<AuthRepository>(FirebaseAuthRepository());
  } on Object {
    getIt.registerSingleton<AuthRepository>(StubAuthRepository());
  }
  getIt.registerLazySingleton<AuthFlowCubit>(
    () => AuthFlowCubit(getIt<AuthRepository>()),
  );
}
