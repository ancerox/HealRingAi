part of 'ai_chat_bloc.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening
/// Start listening
class ListenSpeach extends AiChatEvent {
  final stt.SpeechToText speech;
  final bool isAlreadyListening;

  const ListenSpeach(
    this.speech,
    this.isAlreadyListening,
  );

  @override
  List<Object?> get props => [speech, isAlreadyListening];
}

/// Stop listening
class StopListeningSpeach extends AiChatEvent {
  const StopListeningSpeach();
}

/// Speech-to-text returned new recognized words
class AiChatSpeechResultReceived extends AiChatEvent {
  final String recognizedWords;

  const AiChatSpeechResultReceived(this.recognizedWords);

  @override
  List<Object?> get props => [recognizedWords];
}

/// New amplitude (mic level) received
class AiChatAmplitudeChanged extends AiChatEvent {
  final double amplitude;

  const AiChatAmplitudeChanged(this.amplitude);

  @override
  List<Object?> get props => [amplitude];
}

class SendMessageToAI extends AiChatEvent {
  final String message;

  const SendMessageToAI({required this.message});

  @override
  List<Object?> get props => [message];
}
