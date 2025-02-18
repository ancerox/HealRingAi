import 'package:dartz/dartz.dart';
import 'package:health_ring_ai/core/exception/network_excption.dart';
import 'package:health_ring_ai/features/ai_chat/domain/entity/ai_message.dart';

abstract class ChatAiRepository {
  Future<Either<NetworkException, AiMessageEntity>> getAiResponse(
      String message);
}
