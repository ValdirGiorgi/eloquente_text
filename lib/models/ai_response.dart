/// Resultado de uma chamada de IA, com as métricas mostradas na tela
/// principal e agregadas na tela de Estatísticas.
class AiResponse {
  const AiResponse({
    required this.text,
    required this.inputTokens,
    required this.outputTokens,
    this.cachedInputTokens = 0,
    this.responseTime = Duration.zero,
  });

  /// Texto reescrito pelo modelo.
  final String text;

  final int inputTokens;
  final int outputTokens;

  /// Tokens de entrada servidos pelo cache do provedor (mais baratos que um
  /// token processado do zero). Cada provedor relata isso em um campo
  /// diferente da resposta — veja as implementações em `lib/ai/providers/` —
  /// e o valor fica em 0 quando não houve acerto de cache.
  final int cachedInputTokens;

  /// Tempo total da chamada HTTP, medido por [AiService].
  final Duration responseTime;

  /// Fração dos tokens de entrada que veio do cache, de 0 a 100.
  double get cacheHitPercentage =>
      inputTokens > 0 ? cachedInputTokens / inputTokens * 100 : 0;

  AiResponse copyWith({Duration? responseTime}) => AiResponse(
        text: text,
        inputTokens: inputTokens,
        outputTokens: outputTokens,
        cachedInputTokens: cachedInputTokens,
        responseTime: responseTime ?? this.responseTime,
      );
}
