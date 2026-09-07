import 'package:http/http.dart' as http;

import 'ai_provider.dart';
import 'providers/anthropic_provider.dart';
import 'providers/deepseek_provider.dart';
import 'providers/gemini_provider.dart';
import 'providers/openai_provider.dart';

/// Catálogo dos provedores de IA suportados.
///
/// O [label] é ao mesmo tempo o texto mostrado nos seletores e a chave
/// gravada no banco (configurações, histórico e estatísticas) — por isso
/// renomear um rótulo quebra os dados já salvos de quem usa o app.
///
/// Para adicionar um provedor: implemente [AiProvider] em
/// `lib/ai/providers/` e acrescente um valor aqui. Nada mais precisa mudar
/// — as telas leem esta lista.
enum AiProviderKind {
  openAi('OpenAI', 'https://platform.openai.com/api-keys'),
  deepSeek('DeepSeek', 'https://platform.deepseek.com/api_keys'),
  anthropic('Anthropic Claude', 'https://console.anthropic.com/settings/keys'),
  gemini('Google Gemini', 'https://aistudio.google.com/app/apikey');

  const AiProviderKind(this.label, this.apiKeyUrl);

  /// Nome exibido na interface e usado como chave nos dados persistidos.
  final String label;

  /// Onde o usuário obtém a API key deste provedor.
  final String apiKeyUrl;

  /// Instancia o cliente HTTP deste provedor. O [client] existe para os
  /// testes injetarem um `MockClient`.
  AiProvider create({
    required String apiKey,
    required String model,
    http.Client? client,
  }) {
    return switch (this) {
      AiProviderKind.openAi => OpenAiProvider(
          apiKey: apiKey,
          model: model,
          client: client,
        ),
      AiProviderKind.deepSeek => DeepSeekProvider(
          apiKey: apiKey,
          model: model,
          client: client,
        ),
      AiProviderKind.anthropic => AnthropicProvider(
          apiKey: apiKey,
          model: model,
          client: client,
        ),
      AiProviderKind.gemini => GeminiProvider(
          apiKey: apiKey,
          model: model,
          client: client,
        ),
    };
  }

  /// Provedor correspondente ao rótulo gravado, ou `null` se o rótulo não
  /// existe mais.
  static AiProviderKind? fromLabel(String? label) {
    for (final kind in values) {
      if (kind.label == label) return kind;
    }
    return null;
  }

  /// Provedor usado quando ainda não há nada configurado.
  static const AiProviderKind fallback = AiProviderKind.openAi;
}
