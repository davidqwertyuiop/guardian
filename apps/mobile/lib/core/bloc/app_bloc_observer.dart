import 'dart:developer';
import 'package:bloc/bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('🟢 Bloc Created: ${bloc.runtimeType}', name: 'BlocObserver');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log('⚡ Bloc Event: ${bloc.runtimeType} -> $event', name: 'BlocObserver');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log(
      '🔄 Bloc Change: ${bloc.runtimeType} -> currentState: ${change.currentState}, nextState: ${change.nextState}',
      name: 'BlocObserver'
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('⏭️ Bloc Transition: ${bloc.runtimeType} -> $transition', name: 'BlocObserver');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('🚨 Bloc Error: ${bloc.runtimeType} -> $error', name: 'BlocObserver', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('🔴 Bloc Closed: ${bloc.runtimeType}', name: 'BlocObserver');
  }
}
