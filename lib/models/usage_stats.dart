/// Totais acumulados de uso, calculados sobre a tabela `stats_log`.
class UsageSummary {
  const UsageSummary({
    this.requestCount = 0,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.cachedTokens = 0,
    this.averageResponseTime = Duration.zero,
  });

  final int requestCount;
  final int inputTokens;
  final int outputTokens;
  final int cachedTokens;
  final Duration averageResponseTime;

  int get totalTokens => inputTokens + outputTokens;

  /// `null` quando ainda não há tokens de entrada registrados — a tela
  /// mostra "--" nesse caso, em vez de 0%.
  double? get cacheHitPercentage =>
      inputTokens > 0 ? cachedTokens / inputTokens * 100 : null;
}

/// Uso agregado por par provedor + modelo.
class ModelUsage {
  const ModelUsage({
    required this.providerLabel,
    required this.modelUsed,
    required this.requestCount,
    required this.inputTokens,
    required this.outputTokens,
    required this.cachedTokens,
    required this.averageResponseTime,
  });

  factory ModelUsage.fromRow(Map<String, Object?> row) => ModelUsage(
        providerLabel: row['ai_provider'] as String,
        modelUsed: row['model_used'] as String?,
        requestCount: row['count'] as int? ?? 0,
        inputTokens: row['input_tokens'] as int? ?? 0,
        outputTokens: row['output_tokens'] as int? ?? 0,
        cachedTokens: row['cached_tokens'] as int? ?? 0,
        averageResponseTime: Duration(
          milliseconds: ((row['avg_time'] as num?) ?? 0).round(),
        ),
      );

  final String providerLabel;
  final String? modelUsed;
  final int requestCount;
  final int inputTokens;
  final int outputTokens;
  final int cachedTokens;
  final Duration averageResponseTime;

  double get cacheHitPercentage =>
      inputTokens > 0 ? cachedTokens / inputTokens * 100 : 0;
}

/// Quantidade de processamentos em um dia, usada no gráfico de atividade.
class DailyUsage {
  const DailyUsage({required this.day, required this.requestCount});

  factory DailyUsage.fromRow(Map<String, Object?> row) => DailyUsage(
        day: DateTime.parse(row['day'] as String),
        requestCount: row['count'] as int? ?? 0,
      );

  final DateTime day;
  final int requestCount;
}
