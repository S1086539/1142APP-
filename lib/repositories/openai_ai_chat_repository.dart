import '../models/ai_trip_prompt_context.dart';
import 'ai_chat_repository.dart';

class OpenAIAIChatRepository implements AIChatRepository {
  final String apiKey;
  final String model;

  OpenAIAIChatRepository({
    required this.apiKey,
    required this.model,
  });

  @override
  Stream<String> streamReply({
    required String text,
    AITripPromptContext? promptContext,
  }) async* {
    if (apiKey.trim().isEmpty) {
      throw Exception('OpenAI API Key 尚未設定');
    }

    yield '''
OpenAIAIChatRepository 已建立，但目前尚未正式送出 API request。

之後如果你想從 Gemini 改成 OpenAI，只要切換 AIApiConfig.provider 即可。

目前收到的 prompt context：

${promptContext?.prompt ?? text}
''';
  }
}