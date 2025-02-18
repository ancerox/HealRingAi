import 'package:equatable/equatable.dart';

class AiMessageEntity extends Equatable {
  final String content;

  const AiMessageEntity({required this.content});

  @override
  // TODO: implement props
  List<Object?> get props => [content];
}
