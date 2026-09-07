import 'openai_compatible_provider.dart';

/// https://platform.openai.com/docs/api-reference/chat
class OpenAiProvider extends OpenAiCompatibleProvider {
  OpenAiProvider({required super.apiKey, required super.model, super.client});

  @override
  String get label => 'OpenAI';

  @override
  String get defaultModel => 'gpt-4o-mini';

  @override
  Uri get endpoint => Uri.parse('https://api.openai.com/v1/chat/completions');
}
