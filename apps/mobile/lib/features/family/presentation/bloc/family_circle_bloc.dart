import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/core/services/radio_type_service.dart';
import 'package:guardian/features/family/data/family_repository.dart';
import 'family_circle_event.dart';
import 'family_circle_state.dart';

part 'family_circle_load_handlers.dart';
part 'family_circle_mutation_handlers.dart';
part 'family_circle_action_handlers.dart';

class FamilyCircleBloc extends Bloc<FamilyCircleEvent, FamilyCircleState> {
  FamilyCircleBloc({required this.repository, required this.radioTypeService})
    : super(const FamilyCircleState()) {
    on<FamilyStarted>((event, emit) => _onStarted(event, emit));
    on<FamilyCircleSelected>((event, emit) => _onCircleSelected(event, emit));
    on<FamilyOverviewRequested>(
      (event, emit) => _onOverviewRequested(event, emit),
    );
    on<FamilyInviteRequested>((event, emit) => _onInviteRequested(event, emit));
    on<FamilyDetailsRequested>(
      (event, emit) => _onDetailsRequested(event, emit),
    );
    on<FamilyDetailsRefreshRequested>(
      (event, emit) => _onDetailsRefreshRequested(event, emit),
    );
    on<FamilyMemberExpanded>((event, emit) => _onMemberExpanded(event, emit));
    on<FamilyJoinSubmitted>((event, emit) => _onJoinSubmitted(event, emit));
    on<FamilyCreateSubmitted>((event, emit) => _onCreateSubmitted(event, emit));
    on<FamilyLeaveSubmitted>((event, emit) => _onLeaveSubmitted(event, emit));
    on<FamilyDeleteSubmitted>((event, emit) => _onDeleteSubmitted(event, emit));
    on<FamilyRemoveMemberSubmitted>(
      (event, emit) => _onRemoveMemberSubmitted(event, emit),
    );
    on<FamilyDeviceStatsChanged>(
      (event, emit) => _onDeviceStatsChanged(event, emit),
    );
  }

  final FamilyRepository repository;
  final RadioTypeService radioTypeService;
  final _battery = Battery();
  final _connectivity = Connectivity();
  StreamSubscription? _batterySubscription;
  StreamSubscription? _connectivitySubscription;
  Timer? _detailsTimer;

  Future<String> _connectivityLabel(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.wifi)) return 'WiFi';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (results.contains(ConnectivityResult.vpn)) return 'VPN';
    if (results.contains(ConnectivityResult.none)) return 'Offline';
    if (results.contains(ConnectivityResult.mobile)) {
      return radioTypeService.mobileRadioType();
    }
    return 'Cellular';
  }

  Future<void> _emitDeviceStats() async {
    final batteryLevel = await _battery.batteryLevel;
    final network = await _connectivityLabel(
      await _connectivity.checkConnectivity(),
    );
    add(FamilyDeviceStatsChanged(batteryLevel, network));
  }

  void _startDeviceStreams() {
    _batterySubscription ??= _battery.onBatteryStateChanged.listen((_) {
      _emitDeviceStats();
    });
    _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen((
      _,
    ) {
      _emitDeviceStats();
    });
  }

  void _startDetailsTimer() {
    _detailsTimer?.cancel();
    _detailsTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => add(const FamilyDetailsRefreshRequested()),
    );
  }

  @override
  Future<void> close() {
    _batterySubscription?.cancel();
    _connectivitySubscription?.cancel();
    _detailsTimer?.cancel();
    return super.close();
  }
}
