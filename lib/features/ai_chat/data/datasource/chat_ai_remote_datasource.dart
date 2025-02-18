import 'package:dio/dio.dart';
import 'package:health_ring_ai/features/ai_chat/data/models/ai_chat_response.dart';

enum ChatGptModel {
  gpt3_5Turbo('gpt-3.5-turbo'),
  gpt4('gpt-4'),
  gpt4Turbo('gpt-4-turbo');

  final String value;
  const ChatGptModel(this.value);
}

class ChatAiRemoteDatasource {
  final Dio _dio;

  ChatAiRemoteDatasource(this._dio);

  Future<AiChatResponse> getAiMessage(String message) async {
    const apiKey = '';

    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
      data: {
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": message}
        ],
        "temperature": 0.7
      },
    );

    if (response.statusCode == 200) {
      return AiChatResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load AI response');
    }
  }
}
