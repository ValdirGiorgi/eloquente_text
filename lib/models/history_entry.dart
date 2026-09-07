/// Um processamento já concluído, como gravado na tabela `history`.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.timestamp,
    required this.originalText,
    required this.enhancedText,
    required this.tone,
    required this.purpose,
    required this.providerLabel,
    required this.modelUsed,
    required this.inputTokens,
    required this.outputTokens,
    required this.cachedTokens,
    required this.responseTime,
  });

  /// Converte uma linha da tabela `history`.
  ///
  /// O SQLite grava `timestamp` em UTC sem sufixo de fuso (`CURRENT_TIMESTAMP`),
  /// então o `Z` é acrescentado antes de converter para o horário local.
  factory HistoryEntry.fromRow(Map<String, Object?> row) => HistoryEntry(
        id: row['id'] as int,
        timestamp: DateTime.parse('${row['timestamp']}Z').toLocal(),
        originalText: row['original_text'] as String,
        enhancedText: row['enhanced_text'] as String,
        tone: row['tone'] as String,
        purpose: row['purpose'] as String,
        providerLabel: row['ai_provider'] as String,
        modelUsed: row['model_used'] as String?,
        inputTokens: row['input_tokens'] as int? ?? 0,
        outputTokens: row['output_tokens'] as int? ?? 0,
        cachedTokens: row['cached_tokens'] as int? ?? 0,
        responseTime:
            Duration(milliseconds: row['response_time_ms'] as int? ?? 0),
      );

  final int id;
  final DateTime timestamp;
  final String originalText;
  final String enhancedText;
  final String tone;
  final String purpose;
  final String providerLabel;
  final String? modelUsed;
  final int inputTokens;
  final int outputTokens;
  final int cachedTokens;
  final Duration responseTime;

  double get cacheHitPercentage =>
      inputTokens > 0 ? cachedTokens / inputTokens * 100 : 0;

  /// Texto que casa com a busca do histórico.
  bool matches(String query) {
    if (query.isEmpty) return true;
    final normalized = query.toLowerCase();
    return originalText.toLowerCase().contains(normalized) ||
        enhancedText.toLowerCase().contains(normalized);
  }
}
