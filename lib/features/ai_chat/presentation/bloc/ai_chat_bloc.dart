import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_ring_ai/features/ai_chat/domain/usecases/get_ai_response_usecase.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

part 'ai_chat_event.dart';
part 'ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  Future<dynamic>? _speechFuture;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final GetAiResponseUsecase _getAiResponseUsecase;

  AiChatBloc(this._getAiResponseUsecase) : super(AiChatInitial()) {
    on<ListenSpeach>(_listenSpeach);
    on<StopListeningSpeach>(_stopListeningSpeach);
    on<AiChatSpeechResultReceived>((event, emit) {
      emit(AiChatTextUpdated(event.recognizedWords));
    });

    on<SendMessageToAI>(_sendMessageToAi);
  }

  void _sendMessageToAi(
    SendMessageToAI event,
    Emitter<AiChatState> emit,
  ) async {
    emit(AiMessageLoading());

    final result =
        await _getAiResponseUsecase.getActorDetail(message: event.message);

    result.fold(
      (error) => emit(AiMessageError(message: error.message)),
      (success) => emit(AiMessageRecieved(message: success.content)),
    );
  }

  void _listenSpeach(
    ListenSpeach event,
    Emitter<AiChatState> emit,
  ) async {
    // _speech = event.speech;
    final available = await _speech.initialize();
    if (available) {
      emit(const AiChatListeningStarted());
      _speechFuture = _speech.listen(
        onResult: (result) {
          try {
            final recognizedWords = result.recognizedWords;
            add(AiChatSpeechResultReceived(recognizedWords));
          } catch (e, s) {}
        },
        listenFor: const Duration(minutes: 5),
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  void _stopListeningSpeach(
    StopListeningSpeach event,
    Emitter<AiChatState> emit,
  ) async {
    await _speechFuture;
    _speech.stop();
    emit(const AiChatListeningStopped());
  }

  @override
  Future<void> close() async {
    await _speechFuture;
    return super.close();
  }
}
