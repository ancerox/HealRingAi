import 'package:dartz/dartz.dart';
import 'package:health_ring_ai/core/exception/network_excption.dart';
import 'package:health_ring_ai/features/ai_chat/domain/entity/ai_message.dart';
import 'package:health_ring_ai/features/ai_chat/domain/repository/chat_ai_repository.dart';

class GetAiResponseUsecase {
  final ChatAiRepository _chatAiRepository;

  const GetAiResponseUsecase(this._chatAiRepository);

  /// This method gets actor detail from the remote data source.
  Future<Either<NetworkException, AiMessageEntity>> getActorDetail(
      {required String message}) async {
    return _chatAiRepository.getAiResponse(message);
  }
}
