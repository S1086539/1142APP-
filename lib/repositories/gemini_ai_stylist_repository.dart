import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/ai_stylist_prompt_context.dart';
import '../models/ai_stylist_result.dart';
import 'ai_stylist_repository.dart';

class GeminiAIStylistRepository implements AIStylistRepository {
  final String apiKey;
  final String model;
  final Dio _dio;

  GeminiAIStylistRepository({
    required this.apiKey,
    required this.model,
    Dio? dio,
  }) : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 20),
        ),
      );

  @override
  Future<AIStylistResult> generateStylingImage({
    required AIStylistPromptContext context,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Gemini API Key 尚未設定');
    }

    final response = await _generateImage(context.imagePrompt);
    final imageData = _extractImageData(response.data);

    return AIStylistResult(
      title: '${context.destinationCity} 旅行穿搭建議',
      description: _buildDescription(context),
      outfitItems: _buildOutfitItems(context),
      imagePrompt: context.imagePrompt,
      imageBytes: imageData.bytes,
      mimeType: imageData.mimeType,
      createdAt: DateTime.now(),
    );
  }

  Future<Response<dynamic>> _generateImage(String prompt) async {
    try {
      return await _dio.post(
        '/models/$model:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
          'generationConfig': {
            'responseModalities': [
              'TEXT',
              'IMAGE',
            ],
          },
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
        ),
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      throw Exception('Gemini 圖片生成失敗：$statusCode $data');
    } catch (e) {
      throw Exception('Gemini 圖片生成失敗：$e');
    }
  }

  _GeminiImageData _extractImageData(dynamic data) {
    final candidates = data['candidates'];

    if (candidates is! List || candidates.isEmpty) {
      throw Exception('Gemini 圖片回傳格式錯誤：找不到 candidates');
    }

    for (final candidate in candidates) {
      final content = candidate['content'];
      final parts = content?['parts'];

      if (parts is! List) {
        continue;
      }

      for (final part in parts) {
        final inlineData = part['inlineData'] ?? part['inline_data'];

        if (inlineData == null) {
          continue;
        }

        final dataText = inlineData['data'];
        final mimeType = inlineData['mimeType'] ??
            inlineData['mime_type'] ??
            'image/png';

        if (dataText == null || dataText.toString().trim().isEmpty) {
          continue;
        }

        return _GeminiImageData(
          bytes: base64Decode(dataText.toString()),
          mimeType: mimeType.toString(),
        );
      }
    }

    throw Exception('Gemini 圖片回傳格式錯誤：找不到 inlineData');
  }

  String _buildDescription(AIStylistPromptContext context) {
    return '根據你的 ${context.destinationCity} 行程、活動內容與天氣提醒，AI 已產生一套適合旅行、拍照與步行的穿搭圖。';
  }

  List<String> _buildOutfitItems(AIStylistPromptContext context) {
    final items = <String>[
      '舒適透氣上衣',
      '好走的休閒鞋',
      '小型斜背包',
    ];

    final text = [
      context.weatherNote,
      context.activitySummary,
      context.outfitSummary,
    ].join(' ');

    if (text.contains('雨') || text.contains('降雨')) {
      items.add('輕薄防水外套');
      items.add('摺疊傘');
    }

    if (text.contains('熱') || text.contains('高溫') || text.contains('曝曬')) {
      items.add('防曬外套或帽子');
      items.add('淺色透氣下身');
    }

    if (text.contains('冷') || text.contains('外套')) {
      items.add('薄外套或層次穿搭');
    }

    if (text.contains('夜市') || text.contains('小吃') || text.contains('美食')) {
      items.add('方便行走的輕便穿搭');
    }

    return items.toSet().toList();
  }
}

class _GeminiImageData {
  final Uint8List bytes;
  final String mimeType;

  const _GeminiImageData({
    required this.bytes,
    required this.mimeType,
  });
}