import '../../models/ai_response.dart';
import '../ai_provider.dart';
import '../enhance_request.dart';

/// https://ai.google.dev/api/generate-content
class GeminiProvider extends AiProvider {
  GeminiProvider({required super.apiKey, required super.model, super.client});

  @override
  String get label => 'Google Gemini';

  @override
  String get defaultModel => 'gemini-2.0-flash';

  @override
  Future<AiResponse> enhance(EnhanceRequest request) async {
    final body = <String, dynamic>{
      'systemInstruction': {
        'parts': [
          {'text': request.systemPrompt},
        ],
      },
      'contents': [
        {
          'parts': [
            {'text': request.userPrompt},
          ],
        },
      ],
      if (request.temperature != null)
        'generationConfig': {'temperature': request.temperature},
    };

    final data = await postJson(
      // A API do Gemini autentica por query string, não por cabeçalho —
      // diferente dos outros três provedores.
      url: Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$effectiveModel:generateContent?key=$apiKey',
      ),
      headers: const {},
      body: body,
    );

    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const AiProviderException(
        'Google Gemini: resposta sem nenhuma alternativa.',
      );
    }

    final usage = data['usageMetadata'];
    return AiResponse(
      text: (candidates.first['content']['parts'][0]['text'] as String).trim(),
      inputTokens: AiProvider.readTokenCount(usage, ['promptTokenCount']),
      outputTokens: AiProvider.readTokenCount(usage, ['candidatesTokenCount']),
      // Só é preenchido em modelos com cache automático de contexto: não
      // configuramos cache explícito aqui porque o prompt de sistema fica
      // abaixo do mínimo exigido pela API do Gemini.
      cachedInputTokens: AiProvider.readTokenCount(usage, [
        'cachedContentTokenCount',
      ]),
    );
  }
}
