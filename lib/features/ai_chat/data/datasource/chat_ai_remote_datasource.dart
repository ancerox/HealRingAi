import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_ring_ai/features/ai_chat/data/models/ai_chat_response.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ChatGptModel {
  gpt3_5Turbo('gpt-3.5-turbo'),
  gpt4('gpt-4'),
  gpt4Turbo('gpt-4-turbo');

  final String value;
  const ChatGptModel(this.value);
}

class ChatAiRemoteDatasource {
  final Dio _dio;
  final SharedPreferences _prefs;

  ChatAiRemoteDatasource(this._dio, this._prefs);

  Future<AiChatResponse> getAiMessage(String message) async {
    final apiKey = dotenv.env['chat_api_key'];

    final List<Map<String, dynamic>> summarizedDailyData = [];

    for (int i = 0; i < 7; i++) {
      final dayHealthData = Hive.box('bluetooth_cache').get('health_data_$i');
      final daySleepData = Hive.box('bluetooth_cache').get('sleep_data_$i');

      final daySummary = <String, dynamic>{
        'dayIndex': i,
        'averageHeartRate': null,
        'averageBloodOxygen': null,
        'totalSleepMinutes': null,
      };

      if (dayHealthData != null) {
        double totalHeartRate = 0;
        int heartRateCount = 0;

        double totalBloodOxygen = 0;
        int bloodOxygenCount = 0;

        // -- Summarize heart rate
        final heartRateDataList = dayHealthData['heartRateData'] as List?;
        if (heartRateDataList != null) {
          for (final hrItem in heartRateDataList) {
            final heartRates = hrItem['heartRates'] as List?;
            if (heartRates != null && heartRates.isNotEmpty) {
              for (final hr in heartRates) {
                if ((hr as int) > 0) {
                  totalHeartRate += hr.toDouble();
                  heartRateCount++;
                }
              }
            }
          }
        }

        // -- Summarize blood oxygen
        final bloodOxygenDataList = dayHealthData['bloodOxygenData'] as List?;
        if (bloodOxygenDataList != null) {
          for (final boItem in bloodOxygenDataList) {
            final bloodOxygenLevels = boItem['bloodOxygenLevels'] as List?;
            if (bloodOxygenLevels != null && bloodOxygenLevels.isNotEmpty) {
              for (final spO2 in bloodOxygenLevels) {
                if ((spO2 as double) > 0) {
                  totalBloodOxygen += spO2;
                  bloodOxygenCount++;
                }
              }
            }
          }
        }

        if (heartRateCount > 0) {
          daySummary['averageHeartRate'] =
              (totalHeartRate / heartRateCount).toStringAsFixed(1);
        }
        if (bloodOxygenCount > 0) {
          daySummary['averageBloodOxygen'] =
              (totalBloodOxygen / bloodOxygenCount).toStringAsFixed(1);
        }
      }

      if (daySleepData != null && daySleepData is List) {
        int totalSleepMinutes = 0;

        for (final item in daySleepData) {
          final duration = item.durationMinutes as int?;
          if (duration != null && duration > 0) {
            totalSleepMinutes += duration;
          }
        }

        if (totalSleepMinutes > 0) {
          daySummary['totalSleepMinutes'] = totalSleepMinutes;
        }
      }

      summarizedDailyData.add(daySummary);
    }

    final userName = _prefs.getString('user_name') ?? '';
    final userSex = _prefs.getString('user_sex') ?? '';
    final userBirthDate = _prefs.getString('user_birth_date') ?? '';
    final userHeight = _prefs.getInt('user_height') ?? 0;
    final userWeight = _prefs.getString('user_weight') ?? '';
    final usesMetric = _prefs.getBool('uses_metric_system') ?? false;

    final userDetails = '''
User Profile:
- Name: ${userName.isNotEmpty ? userName : 'Not provided'}
- Sex: ${userSex.isNotEmpty ? userSex : 'Not provided'}
- Birth Date: ${userBirthDate.isNotEmpty ? userBirthDate : 'Not provided'}
- Height: $userHeight ${usesMetric ? 'cm' : 'inches'}
- Weight: $userWeight ${usesMetric ? 'kg' : 'lbs'}
- Measurement System: ${usesMetric ? 'Metric' : 'Imperial'}
''';

    // Instead of sending the entire raw data, we only send our summarizedDailyData:
    final now = DateTime.now();
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
          {
            "role": "system",
            "content":
                "You are a friendly, knowledgeable AI assistant integrated with a wearable ring that tracks the user's vital health metrics such as sleep quality, sleep duration, heart rate, and resting heart rate. Your purpose is to help ${userName.isNotEmpty ? userName : 'the user'} understand these metrics, provide personalized insights based on their specific health profile (including their age, height, weight, and sex), and offer tailored suggestions on improving health habits. Always consider the user's unique characteristics when providing advice or analysis. You do not provide medical diagnoses or replace professional medical advice."
          },
          {"role": "system", "content": "Current date: $now"},
          {
            "role": "system",
            "content":
                "Here is a summarized view of the user's last 7 days of data (heart rate averages, blood oxygen averages, total sleep in minutes): $summarizedDailyData"
          },
          {"role": "system", "content": userDetails},
          {"role": "user", "content": message}
        ],
        "temperature": 0.7,
        // "model": "gpt-3.5-turbo", // or pass in as needed
      },
    );

    if (response.statusCode == 200) {
      return AiChatResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load AI response');
    }
  }
}
