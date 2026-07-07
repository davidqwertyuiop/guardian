import 'package:get_it/get_it.dart';
import 'package:guardian/core/services/radio_type_service.dart';
import 'package:guardian/features/family/data/family_repository.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_bloc.dart';

void initFamilyInjection(GetIt locator) {
  if (!locator.isRegistered<RadioTypeService>()) {
    locator.registerLazySingleton<RadioTypeService>(RadioTypeService.new);
  }
  if (!locator.isRegistered<FamilyRepository>()) {
    locator.registerLazySingleton<FamilyRepository>(FamilyRepository.new);
  }
  if (!locator.isRegistered<FamilyCircleBloc>()) {
    locator.registerFactory(
      () => FamilyCircleBloc(
        repository: locator<FamilyRepository>(),
        radioTypeService: locator<RadioTypeService>(),
      ),
    );
  }
}
