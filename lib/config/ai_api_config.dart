import 'local_ai_secrets.dart';

enum AIProviderType {
  fake,
  gemini,
  openAI,
}

class AIApiConfig {
  static AIProviderType get provider {
    const value = String.fromEnvironment(
      'AI_PROVIDER',
      defaultValue: 'gemini',
    );

    switch (value) {
      case 'gemini':
        return AIProviderType.gemini;
      case 'openAI':
        return AIProviderType.openAI;
      case 'fake':
        return AIProviderType.fake;
      default:
        return AIProviderType.gemini;
    }
  }

  static String get geminiApiKey {
    const dartDefineKey = String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: '',
    );

    if (dartDefineKey.trim().isNotEmpty) {
      return dartDefineKey;
    }

    return LocalAISecrets.geminiApiKey;
  }

  static const String openAIApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-3-flash-preview',
  );

  static const String geminiImageModel = String.fromEnvironment(
    'GEMINI_IMAGE_MODEL',
    defaultValue: 'gemini-3.1-flash-image',
  );

  static const String openAIModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4.1-mini',
  );

  static bool get hasGeminiApiKey {
    return geminiApiKey.trim().isNotEmpty;
  }

  static bool get hasOpenAIApiKey {
    return openAIApiKey.trim().isNotEmpty;
  }
}