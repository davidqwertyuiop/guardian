import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:guardian/core/services/telemetry_service.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      debugPrint('Bloc Event: ${bloc.runtimeType} -> $event');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('Bloc Change: ${bloc.runtimeType} -> $change');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('Bloc Transition: ${bloc.runtimeType} -> $transition');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    unawaited(
      TelemetryService.recordError(
        error,
        stackTrace,
        reason: 'Bloc error in ${bloc.runtimeType}',
      ),
    );
    super.onError(bloc, error, stackTrace);
  }
}
