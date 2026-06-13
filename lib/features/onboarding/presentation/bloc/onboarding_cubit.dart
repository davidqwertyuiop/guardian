import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      emit(OnboardingState(
        username: prefs.getString('username') ?? '',
        locationGranted: prefs.getBool('location_granted') ?? false,
        notificationsGranted: prefs.getBool('notifications_granted') ?? false,
        circleName: prefs.getString('circle_name') ?? '',
        circleCode: prefs.getString('circle_code') ?? '',
        isCircleCreated: prefs.getBool('is_circle_created') ?? false,
      ));
    } catch (_) {}
  }

  Future<void> updateUsername(String name) async {
    emit(state.copyWith(username: name));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  Future<void> setLocationGranted(bool granted) async {
    emit(state.copyWith(locationGranted: granted));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_granted', granted);
  }

  Future<void> setNotificationsGranted(bool granted) async {
    emit(state.copyWith(notificationsGranted: granted));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_granted', granted);
  }

  Future<void> createCircle(String name) async {
    // Generate a random 6-character code (simulating API response)
    final code = _generateRandomCode();
    emit(state.copyWith(
      circleName: name,
      circleCode: code,
      isCircleCreated: true,
    ));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('circle_name', name);
    await prefs.setString('circle_code', code);
    await prefs.setBool('is_circle_created', true);
  }

  Future<void> joinCircle(String code) async {
    emit(state.copyWith(
      circleCode: code,
      isCircleCreated: false,
    ));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('circle_code', code);
    await prefs.setBool('is_circle_created', false);
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    return List.generate(4, (i) => chars[(rand + i * 7) % chars.length]).join();
  }
}
