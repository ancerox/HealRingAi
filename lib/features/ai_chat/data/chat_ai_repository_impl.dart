import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:health_ring_ai/core/exception/network_excption.dart';
import 'package:health_ring_ai/features/ai_chat/data/datasource/chat_ai_remote_datasource.dart';
import 'package:health_ring_ai/features/ai_chat/domain/entity/ai_message.dart';
import 'package:health_ring_ai/features/ai_chat/domain/repository/chat_ai_repository.dart';

class ChatAiRepositoryImpl extends ChatAiRepository {
  final ChatAiRemoteDatasource _chatAiRemoteDatasource;

  ChatAiRepositoryImpl(this._chatAiRemoteDatasource);

  @override
  Future<Either<NetworkException, AiMessageEntity>> getAiResponse(
      String message) async {
    try {
      final response = await _chatAiRemoteDatasource.getAiMessage(message);

      return Right(response);
    } on DioException catch (e) {
      return Left(NetworkException.fromDioError(e));
    }
  }
}
