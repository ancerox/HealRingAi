import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  // final PreferencesRepository prefsRepository;
  AppBloc() : super(AppInitial());

  // Future<void> checkAuthStatus(AppEvent event, Emitter<AppState> emit) async {
  //   final isFirstLaunch = await prefsRepository.isFirstLaunch;
  //   final isUserConnected = await prefsRepository.isUserConnected;

  //   if (isFirstLaunch) {
  //     emit(AppFirstLaunch());
  //   } else if (isUserConnected) {
  //     emit(AppConnected());
  //   } else {
  //     emit(AppDisconnected());
  //   }
  // }
}
