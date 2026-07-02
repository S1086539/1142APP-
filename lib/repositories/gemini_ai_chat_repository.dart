import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/ai_trip_prompt_context.dart';
import 'ai_chat_repository.dart';

class GeminiAIChatRepository implements AIChatRepository {
  final String apiKey;
  final String model;
  final Dio _dio;

  GeminiAIChatRepository({
    required this.apiKey,
    required this.model,
    Dio? dio,
  }) : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 20),
        ),
      );

  @override
  Stream<String> streamReply({
    required String text,
    AITripPromptContext? promptContext,
  }) async* {
    if (apiKey.trim().isEmpty) {
      throw Exception('Gemini API Key 尚未設定');
    }

    final prompt = promptContext?.prompt ?? text;

    debugPrint('Gemini chat model: $model');
    debugPrint('Gemini 使用 generateContent 穩定模式');

    final responseText = await _generateContent(prompt);

    for (final chunk in _splitText(responseText, size: 6)) {
      await Future.delayed(
        const Duration(milliseconds: 24),
      );

      yield chunk;
    }
  }

  Future<String> _generateContent(String prompt) async {
    try {
      final response = await _dio.post(
        '/models/$model:generateContent',
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.65,
            'topP': 0.9,
            'maxOutputTokens': 4096,
          },
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
        ),
      );

      return _cleanGeminiText(
        _extractTextFromJson(response.data),
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      throw Exception(
        'Gemini generateContent 呼叫失敗：$statusCode $data',
      );
    } catch (e) {
      throw Exception('Gemini generateContent 解析失敗：$e');
    }
  }

  String _extractTextFromJson(dynamic data) {
    final candidates = data['candidates'];

    if (candidates is! List || candidates.isEmpty) {
      throw Exception('Gemini 回傳格式錯誤：找不到 candidates');
    }

    final buffer = StringBuffer();

    for (final candidate in candidates) {
      final content = candidate['content'];
      final parts = content?['parts'];

      if (parts is! List || parts.isEmpty) {
        continue;
      }

      for (final part in parts) {
        final text = part['text'];

        if (text != null) {
          buffer.write(text.toString());
        }
      }
    }

    final result = buffer.toString().trim();

    if (result.isEmpty) {
      throw Exception('Gemini 回覆文字為空');
    }

    return result;
  }

  String _cleanGeminiText(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('###', '')
        .replaceAll('##', '')
        .replaceAll('#', '')
        .trim();
  }

  List<String> _splitText(
      String text, {
        required int size,
      }) {
    final chars = text.runes
        .map((codePoint) => String.fromCharCode(codePoint))
        .toList();

    final chunks = <String>[];

    for (int i = 0; i < chars.length; i += size) {
      chunks.add(
        chars
            .sublist(
          i,
          min(i + size, chars.length),
        )
            .join(),
      );
    }

    return chunks;
  }
}