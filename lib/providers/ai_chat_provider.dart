import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../models/ai_chat_message.dart';
import '../models/ai_trip_prompt_context.dart';
import '../models/weather.dart';

import '../config/ai_api_config.dart';

import '../repositories/gemini_ai_chat_repository.dart';
import '../repositories/openai_ai_chat_repository.dart';
import '../repositories/ai_chat_repository.dart';

import '../services/ai_trip_prompt_builder.dart';
import '../services/trip_query_parser.dart';

import 'weather_provider.dart';

final aiChatRepositoryProvider = Provider<AIChatRepository>((ref) {
  debugPrint('目前 AI Provider: ${AIApiConfig.provider}');
  debugPrint(
    'Gemini API Key 是否存在: ${AIApiConfig.geminiApiKey.trim().isNotEmpty}',
  );
  debugPrint('Gemini Model: ${AIApiConfig.geminiModel}');

  switch (AIApiConfig.provider) {
    case AIProviderType.fake:
      debugPrint('使用 FakeAIChatRepository');
      return FakeAIChatRepository();

    case AIProviderType.gemini:
      debugPrint('使用 GeminiAIChatRepository');
      return GeminiAIChatRepository(
        apiKey: AIApiConfig.geminiApiKey,
        model: AIApiConfig.geminiModel,
      );

    case AIProviderType.openAI:
      debugPrint('使用 OpenAIAIChatRepository');
      return OpenAIAIChatRepository(
        apiKey: AIApiConfig.openAIApiKey,
        model: AIApiConfig.openAIModel,
      );
  }
});

final aiChatProvider =
NotifierProvider<AIChatNotifier, List<AIChatMessage>>(
  AIChatNotifier.new,
);

class AIChatNotifier extends Notifier<List<AIChatMessage>> {
  AIChatRepository get _repository => ref.read(aiChatRepositoryProvider);

  @override
  List<AIChatMessage> build() {
    return const [];
  }

  bool get isReplying {
    return state.any((message) => message.pending);
  }

  String? get latestUserText {
    final userMessages = state.where((m) => m.isUser).toList();

    if (userMessages.isEmpty) {
      return null;
    }

    return userMessages.last.text;
  }

  String? get latestAIReplyText {
    final aiMessages = state
        .where(
          (m) =>
      !m.isUser &&
          !m.pending &&
          !m.isError &&
          m.text.trim().isNotEmpty,
    )
        .toList();

    if (aiMessages.isEmpty) {
      return null;
    }

    return aiMessages.last.text;
  }

  Future<void> sendUserMessage(String text) async {
    final trimmed = text.trim();

    if (trimmed.isEmpty) return;
    if (isReplying) return;

    final userMessage = AIChatMessage(
      id: _createId('user'),
      text: trimmed,
      isUser: true,
      createdAt: DateTime.now(),
    );

    state = [
      ...state,
      userMessage,
    ];

    await _appendAIReplyForText(trimmed);
  }

  Future<void> retryLastFailedMessage() async {
    if (isReplying) return;

    final errorIndex = state.lastIndexWhere(
          (message) => !message.isUser && message.isError,
    );

    if (errorIndex == -1) return;

    final previousUserText = _findPreviousUserText(
      beforeIndex: errorIndex,
    );

    if (previousUserText == null) return;

    final updatedList = [...state];

    updatedList.removeAt(errorIndex);

    state = updatedList;

    await _appendAIReplyForText(previousUserText);
  }

  Future<void> _appendAIReplyForText(String text) async {
    final aiPendingMessage = AIChatMessage(
      id: _createId('ai'),
      text: '',
      isUser: false,
      createdAt: DateTime.now(),
      pending: true,
    );

    state = [
      ...state,
      aiPendingMessage,
    ];

    var fullReply = '';

    try {
      final promptContext = await _buildPromptContext(text);

      await for (final chunk in _repository.streamReply(
        text: text,
        promptContext: promptContext,
      )) {
        fullReply += chunk;

        _replaceMessage(
          aiPendingMessage.id,
          aiPendingMessage.copyWith(
            text: fullReply,
            pending: true,
          ),
        );
      }

      _replaceMessage(
        aiPendingMessage.id,
        aiPendingMessage.copyWith(
          text: fullReply,
          pending: false,
          isError: false,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('AI 回覆失敗: $e');
      debugPrint('AI 回覆失敗 stackTrace: $stackTrace');

      _replaceMessage(
        aiPendingMessage.id,
        aiPendingMessage.copyWith(
          text: 'AI 回覆失敗：$e',
          pending: false,
          isError: true,
        ),
      );
    }
  }

  Future<AITripPromptContext> _buildPromptContext(String text) async {
    final userTexts = state
        .where((message) => message.isUser)
        .map((message) => message.text);

    final destinationCity = TripQueryParser.parseDestinationCity(text) ??
        TripQueryParser.parseLatestDestinationCityFromTexts(userTexts);

    Weather? destinationWeather;

    if (destinationCity != null) {
      try {
        destinationWeather = await ref.read(
          weatherProvider(destinationCity).future,
        );
      } catch (e) {
        destinationWeather = null;
      }
    }

    final conversationHistoryText = _buildConversationHistoryText();

    return AITripPromptBuilder.build(
      userText: text,
      destinationCity: destinationCity,
      destinationWeather: destinationWeather,
      conversationHistoryText: conversationHistoryText,
    );
  }

  String _buildConversationHistoryText() {
    final validMessages = state
        .where(
          (message) =>
      !message.pending &&
          message.text.trim().isNotEmpty,
    )
        .toList();

    if (validMessages.isEmpty) {
      return '尚無過去對話。';
    }

    final recentMessages = validMessages.length > 8
        ? validMessages.sublist(validMessages.length - 8)
        : validMessages;

    return recentMessages.map((message) {
      final role = message.isUser ? '使用者' : 'AI';
      final text = _limitText(message.text);

      return '$role：$text';
    }).join('\n\n');
  }

  String _limitText(
      String text, {
        int maxLength = 1200,
      }) {
    final trimmed = text.trim();

    if (trimmed.length <= maxLength) {
      return trimmed;
    }

    return '${trimmed.substring(0, maxLength)}...';
  }

  String? _findPreviousUserText({
    required int beforeIndex,
  }) {
    for (int i = beforeIndex - 1; i >= 0; i--) {
      final message = state[i];

      if (message.isUser) {
        return message.text;
      }
    }

    return null;
  }

  void clearChat() {
    state = const [];
  }

  void _replaceMessage(
      String id,
      AIChatMessage updatedMessage,
      ) {
    final index = state.indexWhere((message) => message.id == id);

    if (index == -1) return;

    final updatedList = [...state];

    updatedList[index] = updatedMessage;

    state = updatedList;
  }

  String _createId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}