import 'package:equatable/equatable.dart';

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
