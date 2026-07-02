import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_stylist_prompt_context.dart';
import '../models/ai_stylist_result.dart';

import '../config/ai_api_config.dart';

import '../repositories/gemini_ai_stylist_repository.dart';
import '../repositories/ai_stylist_repository.dart';

final aiStylistRepositoryProvider = Provider<AIStylistRepository>((ref) {
  switch (AIApiConfig.provider) {
    case AIProviderType.fake:
      return FakeAIStylistRepository();

    case AIProviderType.gemini:
      return GeminiAIStylistRepository(
        apiKey: AIApiConfig.geminiApiKey,
        model: AIApiConfig.geminiImageModel,
      );

    case AIProviderType.openAI:
      return FakeAIStylistRepository();
  }
});

final aiStylistProvider =
NotifierProvider<AIStylistNotifier, AIStylistState>(
  AIStylistNotifier.new,
);

class AIStylistState {
  final bool isGenerating;
  final AIStylistResult? result;
  final String? errorMessage;

  const AIStylistState({
    this.isGenerating = false,
    this.result,
    this.errorMessage,
  });
}

class AIStylistNotifier extends Notifier<AIStylistState> {
  AIStylistRepository get _repository {
    return ref.read(aiStylistRepositoryProvider);
  }

  @override
  AIStylistState build() {
    return const AIStylistState();
  }

  Future<void> generate(
      AIStylistPromptContext context,
      ) async {
    state = const AIStylistState(
      isGenerating: true,
    );

    try {
      final result = await _repository.generateStylingImage(
        context: context,
      );

      state = AIStylistState(
        isGenerating: false,
        result: result,
      );
    } catch (e) {
      state = AIStylistState(
        isGenerating: false,
        errorMessage: 'AI Stylist 產生失敗：$e',
      );
    }
  }

  void clear() {
    state = const AIStylistState();
  }
}