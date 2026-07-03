import 'package:equatable/equatable.dart';
import 'home_state.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class ChangeTab extends HomeEvent {
  final int index;
  const ChangeTab(this.index);

  @override
  List<Object?> get props => [index];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class ChangeMapState extends HomeEvent {
  final MapDisplayState mapState;
  const ChangeMapState(this.mapState);

  @override
  List<Object?> get props => [mapState];
}
