part of 'ai_chat_bloc.dart';

abstract class AiChatState extends Equatable {
  final String text;

  const AiChatState({this.text = ''});

  @override
  List<Object> get props => [text];
}

class AiChatInitial extends AiChatState {}

class AiChatListeningStarted extends AiChatState {
  const AiChatListeningStarted() : super();
}

class AiChatListeningStopped extends AiChatState {
  const AiChatListeningStopped() : super();
}

class AiChatTextUpdated extends AiChatState {
  const AiChatTextUpdated(String text) : super(text: text);
}

class AiMessageLoading extends AiChatState {}

class AiMessageError extends AiChatState {
  final String message;
  const AiMessageError({required this.message});
}

class AiMessageRecieved extends AiChatState {
  final String message;

  const AiMessageRecieved({required this.message});
}
