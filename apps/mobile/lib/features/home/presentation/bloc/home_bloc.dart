import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/core/services/api_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<ChangeTab>(_onChangeTab);
    on<LoadHomeData>(_onLoadHomeData);
  }

  void _onChangeTab(ChangeTab event, Emitter<HomeState> emit) {
    emit(state.copyWith(currentIndex: event.index));
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      // 1. Fetch current profile details
      final profile = await ApiService.getMe();
      final name = profile['name'] as String? ?? 'User';
      final avatar = profile['avatar_url'] as String? ?? '';

      // 2. Fetch circles list
      final circles = await ApiService.getCircles();
      
      String activeCircleName = '';
      String activeCircleId = '';
      List<dynamic> circleMembers = [];

      if (circles.isNotEmpty) {
        final firstCircle = circles.first as Map<String, dynamic>;
        activeCircleName = firstCircle['name'] as String? ?? '';
        activeCircleId = firstCircle['id'] as String? ?? '';

        // 3. Fetch members of this active circle
        if (activeCircleId.isNotEmpty) {
          circleMembers = await ApiService.getCircleMembers(activeCircleId);
        }
      }

      emit(state.copyWith(
        userName: name,
        avatarUrl: avatar,
        circleName: activeCircleName,
        circleId: activeCircleId,
        members: circleMembers,
        status: HomeStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
