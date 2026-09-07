import '../../models/ai_response.dart';
import '../ai_provider.dart';
import '../enhance_request.dart';

/// Base dos provedores que falam o dialeto da OpenAI: endpoint
/// `/chat/completions`, mensagens `role`/`content` e uso em
/// `prompt_tokens`/`completion_tokens`.
///
/// OpenAI e DeepSeek usam exatamente esse formato — só mudam a URL base e o
/// modelo padrão —, então a chamada HTTP fica aqui uma única vez e cada
/// provedor declara apenas o que o diferencia.
abstract class OpenAiCompatibleProvider extends AiProvider {
  OpenAiCompatibleProvider({
    required super.apiKey,
    required super.model,
    super.client,
  });

  Uri get endpoint;

  @override
  Future<AiResponse> enhance(EnhanceRequest request) async {
    final body = <String, dynamic>{
      'model': effectiveModel,
      'messages': [
        {'role': 'system', 'content': request.systemPrompt},
        {'role': 'user', 'content': request.userPrompt},
      ],
      if (request.temperature != null) 'temperature': request.temperature,
    };

    final data = await postJson(
      url: endpoint,
      headers: {'Authorization': 'Bearer $apiKey'},
      body: body,
    );

    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw AiProviderException('$label: resposta sem nenhuma alternativa.');
    }

    final usage = data['usage'];
    return AiResponse(
      text: (choices.first['message']['content'] as String).trim(),
      inputTokens: AiProvider.readTokenCount(usage, ['prompt_tokens']),
      outputTokens: AiProvider.readTokenCount(usage, ['completion_tokens']),
      cachedInputTokens: _readCachedTokens(usage),
    );
  }

  /// Cache automático por prefixo repetido: a OpenAI relata em
  /// `prompt_tokens_details.cached_tokens` e a DeepSeek no campo próprio
  /// `prompt_cache_hit_tokens`. Nenhum dos dois exige nada na requisição —
  /// só a leitura da resposta muda de um para o outro.
  int _readCachedTokens(Object? usage) {
    if (usage is! Map) return 0;
    final details = usage['prompt_tokens_details'];
    final nested = AiProvider.readTokenCount(details, ['cached_tokens']);
    if (nested > 0) return nested;
    return AiProvider.readTokenCount(usage, ['prompt_cache_hit_tokens']);
  }
}
