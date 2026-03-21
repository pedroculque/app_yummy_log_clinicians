import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:app_yummy_log_clinicians/core/di/injection.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:package_session_logger/package_session_logger.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    if (getIt.isRegistered<SessionLogger>()) {
      getIt<SessionLogger>().error(
        error,
        stackTrace,
        context: 'Bloc:${bloc.runtimeType}',
      );
    }
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  final previousFlutterError = FlutterError.onError;
  FlutterError.onError = (details) {
    previousFlutterError?.call(details);
    log(details.exceptionAsString(), stackTrace: details.stack);
    if (getIt.isRegistered<SessionLogger>()) {
      getIt<SessionLogger>().error(
        details.exception,
        details.stack,
        context: 'FlutterError',
      );
    }
  };

  final previousPlatformError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    final handled = previousPlatformError?.call(error, stack) ?? false;
    if (getIt.isRegistered<SessionLogger>()) {
      getIt<SessionLogger>().error(
        error,
        stack,
        context: 'PlatformDispatcher',
      );
    }
    return handled;
  };

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here

  runApp(await builder());
}
