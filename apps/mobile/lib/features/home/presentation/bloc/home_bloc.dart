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

    String name = localUsername;
    String avatar = '';
    String activeCircleName = '';
    String activeCircleId = '';
    List<dynamic> circleMembers = [];
    List<dynamic> sosBroadcasts = [];

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
      if (errMsg.contains('ExpiredSignature') || errMsg.contains('Invalid or expired token')) {
        log('Token signature expired or invalid. Clearing tokens and resetting auth state.');
        await TokenManager().clearTokens();
        await prefs.setBool('onboarding_completed', false);
        await prefs.remove('username');
        await prefs.remove('user_id');
        authBloc.add(const ResetAuth());
        return;
      }
    }

    // Try fetching circles and circle members from API
    try {
      final circles = await ApiService.getCircles();
      if (circles.isNotEmpty) {
        final firstCircle = circles.first as Map<String, dynamic>;
        activeCircleName = firstCircle['name'] as String? ?? '';
        activeCircleId = firstCircle['id'] as String? ?? '';

        if (activeCircleId.isNotEmpty) {
          circleMembers = await ApiService.getCircleMembers(activeCircleId);
          try {
            sosBroadcasts = await ApiService.getSosBroadcasts(activeCircleId);
          } catch (_) {
            // Ignore if sos broadcasts fail
          }
        }
      }
    } catch (e) {
      log('Failed to fetch circles/members from API: $e');
      final errMsg = e.toString();
      if (errMsg.contains('ExpiredSignature') || errMsg.contains('Invalid or expired token')) {
        log('Token signature expired or invalid on circle load. Clearing tokens and resetting auth state.');
        await TokenManager().clearTokens();
        await prefs.setBool('onboarding_completed', false);
        await prefs.remove('username');
        await prefs.remove('user_id');
        authBloc.add(const ResetAuth());
        return;
      }
    }

    // 2. Fetch dynamic weather greeting based on GPS coordinates
    String weatherGreeting = "Lovely weather we're having today...";
    double lat = 9.0578;
    double lon = 7.4951;
    try {
      final gps = GpsService();
      final loc = await gps.getCurrentLocation();
      lat = loc['latitude'] ?? 9.0578;
      lon = loc['longitude'] ?? 7.4951;
      weatherGreeting = await WeatherService.getWeatherGreeting(lat, lon);
    } catch (_) {}

    emit(
      state.copyWith(
        userName: name,
        avatarUrl: avatar,
        circleName: activeCircleName,
        circleId: activeCircleId,
        members: circleMembers,
        sosBroadcasts: sosBroadcasts,
        weatherGreeting: weatherGreeting,
        userLatitude: lat,
        userLongitude: lon,
        status: HomeStatus.success,
      ),
    );
  }
}
