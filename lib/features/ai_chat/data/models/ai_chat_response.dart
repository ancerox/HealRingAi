import 'package:health_ring_ai/features/ai_chat/domain/entity/ai_message.dart';

class AiChatResponse extends AiMessageEntity {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<Choice> choices;
  final Usage usage;
  final String serviceTier;
  final dynamic systemFingerprint;

  AiChatResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
    required this.serviceTier,
    this.systemFingerprint,
  }) : super(content: choices.first.message.content);

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices:
          List<Choice>.from(json['choices'].map((x) => Choice.fromJson(x))),
      usage: Usage.fromJson(json['usage']),
      serviceTier: json['service_tier'],
      systemFingerprint: json['system_fingerprint'],
    );
  }
}

class Choice {
  final int index;
  final Message message;
  final dynamic logprobs;
  final String finishReason;

  Choice({
    required this.index,
    required this.message,
    this.logprobs,
    required this.finishReason,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      index: json['index'],
      message: Message.fromJson(json['message']),
      logprobs: json['logprobs'],
      finishReason: json['finish_reason'],
    );
  }
}

class Message {
  final String role;
  final String content;
  final dynamic refusal;

  Message({
    required this.role,
    required this.content,
    this.refusal,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
      refusal: json['refusal'],
    );
  }
}

class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final PromptTokensDetails promptTokensDetails;
  final CompletionTokensDetails completionTokensDetails;

  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.promptTokensDetails,
    required this.completionTokensDetails,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
      promptTokensDetails:
          PromptTokensDetails.fromJson(json['prompt_tokens_details']),
      completionTokensDetails:
          CompletionTokensDetails.fromJson(json['completion_tokens_details']),
    );
  }
}

class PromptTokensDetails {
  final int cachedTokens;
  final int audioTokens;

  PromptTokensDetails({
    required this.cachedTokens,
    required this.audioTokens,
  });

  factory PromptTokensDetails.fromJson(Map<String, dynamic> json) {
    return PromptTokensDetails(
      cachedTokens: json['cached_tokens'],
      audioTokens: json['audio_tokens'],
    );
  }
}

class CompletionTokensDetails {
  final int reasoningTokens;
  final int audioTokens;
  final int acceptedPredictionTokens;
  final int rejectedPredictionTokens;

  CompletionTokensDetails({
    required this.reasoningTokens,
    required this.audioTokens,
    required this.acceptedPredictionTokens,
    required this.rejectedPredictionTokens,
  });

  factory CompletionTokensDetails.fromJson(Map<String, dynamic> json) {
    return CompletionTokensDetails(
      reasoningTokens: json['reasoning_tokens'],
      audioTokens: json['audio_tokens'],
      acceptedPredictionTokens: json['accepted_prediction_tokens'],
      rejectedPredictionTokens: json['rejected_prediction_tokens'],
    );
  }
}
