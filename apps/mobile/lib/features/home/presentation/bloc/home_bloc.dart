import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/security/token_manager.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:guardian/core/services/weather_service.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardian/features/location/services/gps_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthBloc authBloc;

  HomeBloc({required this.authBloc}) : super(const HomeState()) {
    on<ChangeTab>(_onChangeTab);
    on<LoadHomeData>(_onLoadHomeData);
    on<ChangeMapState>(_onChangeMapState);
    on<SelectCircle>(_onSelectCircle);
    on<LeaveCircle>(_onLeaveCircle);
    on<UpdateWeatherAndLocation>(_onUpdateWeatherAndLocation);
  }

  void _onChangeTab(ChangeTab event, Emitter<HomeState> emit) {
    emit(state.copyWith(currentIndex: event.index));
  }

  void _onChangeMapState(ChangeMapState event, Emitter<HomeState> emit) {
    emit(state.copyWith(mapDisplayState: event.mapState));
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    // 1. Get local fallback username first to ensure we display it immediately
    final prefs = locator<SharedPreferences>();
    final localUsername = prefs.getString('username') ?? 'User';

    String name = state.userName.isNotEmpty && state.userName != 'User'
        ? state.userName
        : localUsername;
    String avatar = state.avatarUrl;
    String activeCircleName = state.circleName;
    String activeCircleId = state.circleId;
    List<dynamic> circleMembers = state.members;
    List<dynamic> sosBroadcasts = state.sosBroadcasts;

    // Try fetching profile from API
    try {
      final profile = await ApiService.getMe();
      final apiName = profile['name'] as String?;
      if (apiName != null && apiName.trim().isNotEmpty) {
        name = apiName;
        await prefs.setString('username', name);
      } else {
        if (localUsername != 'User' && localUsername.trim().isNotEmpty) {
          try {
            await ApiService.updateProfile(localUsername);
            log('Synced local username "$localUsername" to backend.');
          } catch (e) {
            log('Failed to sync local username to backend: $e');
          }
        }
        name = localUsername;
      }
      avatar = profile['avatar_url'] as String? ?? '';
    } catch (e) {
      log('Failed to fetch profile from API, fallback to local username: $e');
      final errMsg = e.toString();
      if (errMsg.contains('ExpiredSignature') ||
          errMsg.contains('Invalid or expired token')) {
        log(
          'Token signature expired or invalid. Clearing tokens and resetting auth state.',
        );
        await TokenManager().clearTokens();
        await prefs.setBool('onboarding_completed', false);
        await prefs.remove('username');
        await prefs.remove('user_id');
        authBloc.add(const ResetAuth());
        return;
      }
    }

    // Try fetching circles and circle members from API
    List<dynamic> loadedCircles = [];
    try {
      loadedCircles = await ApiService.getCircles();
      if (loadedCircles.isNotEmpty) {
        // If current activeCircleId is not in the loaded circles list, reset it to the first circle
        final activeCircleExists = loadedCircles.any(
          (c) => c['id'] == activeCircleId,
        );
        if (!activeCircleExists) {
          final firstCircle = loadedCircles.first as Map<String, dynamic>;
          activeCircleName = firstCircle['name'] as String? ?? '';
          activeCircleId = firstCircle['id'] as String? ?? '';
        }

        if (activeCircleId.isNotEmpty) {
          circleMembers = await ApiService.getCircleMembers(activeCircleId);
          try {
            sosBroadcasts = await ApiService.getSosBroadcasts(activeCircleId);
          } catch (_) {
            // Ignore if sos broadcasts fail
          }
        }
      } else {
        // No circles
        activeCircleId = '';
        activeCircleName = '';
        circleMembers = [];
        sosBroadcasts = [];
      }
    } catch (e) {
      log('Failed to fetch circles/members from API: $e');
      final errMsg = e.toString();
      if (errMsg.contains('ExpiredSignature') ||
          errMsg.contains('Invalid or expired token')) {
        log(
          'Token signature expired or invalid on circle load. Clearing tokens and resetting auth state.',
        );
        await TokenManager().clearTokens();
        await prefs.setBool('onboarding_completed', false);
        await prefs.remove('username');
        await prefs.remove('user_id');
        authBloc.add(const ResetAuth());
        return;
      }
    }

    // Use current state values or defaults
    final double initialLat = state.userLatitude != 0.0
        ? state.userLatitude
        : 9.0578;
    final double initialLon = state.userLongitude != 0.0
        ? state.userLongitude
        : 7.4951;
    final String initialGreeting = state.weatherGreeting.isNotEmpty
        ? state.weatherGreeting
        : "Lovely weather we're having today...";

    emit(
      state.copyWith(
        userName: name,
        avatarUrl: avatar,
        circleName: activeCircleName,
        circleId: activeCircleId,
        members: circleMembers,
        sosBroadcasts: sosBroadcasts,
        weatherGreeting: initialGreeting,
        userLatitude: initialLat,
        userLongitude: initialLon,
        status: HomeStatus.success,
        circles: loadedCircles,
      ),
    );

    // Trigger background async load of weather and location without blocking
    GpsService()
        .getCurrentLocation()
        .then((loc) {
          final double lat = loc['latitude'] ?? 9.0578;
          final double lon = loc['longitude'] ?? 7.4951;
          WeatherService.getWeatherGreeting(lat, lon)
              .then((greeting) {
                if (!isClosed) {
                  add(
                    UpdateWeatherAndLocation(
                      latitude: lat,
                      longitude: lon,
                      weatherGreeting: greeting,
                    ),
                  );
                }
              })
              .catchError((_) {});
        })
        .catchError((_) {});
  }

  Future<void> _onSelectCircle(
    SelectCircle event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final circle = state.circles.firstWhere((c) => c['id'] == event.circleId);
      final members = await ApiService.getCircleMembers(event.circleId);
      List<dynamic> sosBroadcasts = [];
      try {
        sosBroadcasts = await ApiService.getSosBroadcasts(event.circleId);
      } catch (_) {}
      emit(
        state.copyWith(
          circleId: event.circleId,
          circleName: circle['name'] ?? '',
          members: members,
          sosBroadcasts: sosBroadcasts,
          status: HomeStatus.success,
        ),
      );
    } catch (e) {
      log('Failed to select circle: $e');
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLeaveCircle(
    LeaveCircle event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await ApiService.leaveCircle(event.circleId);
      // Reload home data after leaving circle
      add(const LoadHomeData());
    } catch (e) {
      log('Failed to leave circle: $e');
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void _onUpdateWeatherAndLocation(
    UpdateWeatherAndLocation event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        userLatitude: event.latitude,
        userLongitude: event.longitude,
        weatherGreeting: event.weatherGreeting,
      ),
    );
  }
}
