import 'openai_compatible_provider.dart';

/// https://api-docs.deepseek.com — compatível com o formato da OpenAI.
class DeepSeekProvider extends OpenAiCompatibleProvider {
  DeepSeekProvider({required super.apiKey, required super.model, super.client});

  @override
  String get label => 'DeepSeek';

  @override
  String get defaultModel => 'deepseek-chat';

  @override
  Uri get endpoint => Uri.parse('https://api.deepseek.com/v1/chat/completions');
}
