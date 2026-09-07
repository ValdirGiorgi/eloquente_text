import '../../models/ai_response.dart';
import '../ai_provider.dart';
import '../enhance_request.dart';

/// https://docs.anthropic.com/en/api/messages
class AnthropicProvider extends AiProvider {
  AnthropicProvider({
    required super.apiKey,
    required super.model,
    super.client,
  });

  static const int _maxTokens = 4096;

  @override
  String get label => 'Anthropic Claude';

  @override
  String get defaultModel => 'claude-sonnet-5';

  @override
  Future<AiResponse> enhance(EnhanceRequest request) async {
    final body = <String, dynamic>{
      'model': effectiveModel,
      'max_tokens': _maxTokens,
      // O prompt de sistema é idêntico em toda chamada com o mesmo estado do
      // toggle Humanizar (só a mensagem do usuário muda). Marcá-lo com
      // cache_control deixa a Anthropic reaproveitar o bloco entre chamadas
      // próximas por uma fração do preço — o que pesa bastante com o
      // Humanizar ativo, já que as 35 categorias formam um bloco grande.
      // Abaixo do tamanho mínimo cacheável a API ignora a marcação, sem erro.
      // Os outros provedores fazem cache de prefixo automaticamente; só a
      // Anthropic exige esse opt-in.
      'system': [
        {
          'type': 'text',
          'text': request.systemPrompt,
          'cache_control': {'type': 'ephemeral'},
        },
      ],
      'messages': [
        {'role': 'user', 'content': request.userPrompt},
      ],
      if (request.temperature != null) 'temperature': request.temperature,
    };

    final data = await postJson(
      url: Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {'x-api-key': apiKey, 'anthropic-version': '2023-06-01'},
      body: body,
    );

    final content = data['content'];
    if (content is! List || content.isEmpty) {
      throw const AiProviderException(
        'Anthropic Claude: resposta sem conteúdo.',
      );
    }

    final usage = data['usage'];
    return AiResponse(
      text: (content.first['text'] as String).trim(),
      inputTokens: AiProvider.readTokenCount(usage, ['input_tokens']),
      outputTokens: AiProvider.readTokenCount(usage, ['output_tokens']),
      // Tokens servidos do cache criado pelo cache_control acima. Fica em 0
      // quando não houve acerto — inclusive na primeira chamada de cada
      // janela, que grava o cache mas ainda não lê dele.
      cachedInputTokens: AiProvider.readTokenCount(usage, [
        'cache_read_input_tokens',
      ]),
    );
  }
}
