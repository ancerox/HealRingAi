import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:health_ring_ai/features/ai_chat/data/chat_ai_repository_impl.dart';
import 'package:health_ring_ai/features/ai_chat/data/datasource/chat_ai_remote_datasource.dart';
import 'package:health_ring_ai/features/ai_chat/domain/repository/chat_ai_repository.dart';
import 'package:health_ring_ai/features/ai_chat/domain/usecases/get_ai_response_usecase.dart';
import 'package:health_ring_ai/features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Bloc
  getIt.registerFactory(() => AiChatBloc(getIt()));

  // Use cases
  getIt.registerLazySingleton(() => GetAiResponseUsecase(getIt()));

  // Repository
  getIt.registerLazySingleton<ChatAiRepository>(
    () => ChatAiRepositoryImpl(getIt()),
  );

  // Data sources
  getIt.registerLazySingleton<ChatAiRemoteDatasource>(
    () => ChatAiRemoteDatasource(getIt(), getIt()),
  );

  // External
  getIt.registerLazySingleton(() => Dio());
  getIt.registerSingletonAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance());
}
