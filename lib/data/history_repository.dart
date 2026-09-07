import '../models/ai_response.dart';
import '../models/history_entry.dart';
import '../models/purpose.dart';
import '../models/tone.dart';
import 'app_database.dart';

/// Histórico de textos processados (tabela `history`).
///
/// Pode ser apagado pelo usuário a qualquer momento; as métricas de uso
/// ficam em `stats_log` justamente para sobreviverem a essa limpeza (veja
/// `stats_repository.dart`).
class HistoryRepository {
  HistoryRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Quantos itens a tela de histórico carrega de uma vez.
  static const int defaultLimit = 100;

  Future<List<HistoryEntry>> recent({int limit = defaultLimit}) async {
    final db = await _database.database;
    final rows = await db.query(
      'history',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(HistoryEntry.fromRow).toList();
  }

  Future<void> save({
    required String originalText,
    required AiResponse response,
    required Tone tone,
    required Purpose purpose,
    required String providerLabel,
    String? modelUsed,
  }) async {
    final db = await _database.database;
    await db.insert('history', {
      'original_text': originalText,
      'enhanced_text': response.text,
      'tone': tone.label,
      'purpose': purpose.label,
      'ai_provider': providerLabel,
      'model_used': modelUsed,
      'character_count': response.text.length,
      'input_tokens': response.inputTokens,
      'output_tokens': response.outputTokens,
      'response_time_ms': response.responseTime.inMilliseconds,
      'cached_tokens': response.cachedInputTokens,
    });
  }

  Future<void> delete(int id) async {
    final db = await _database.database;
    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _database.database;
    await db.delete('history');
  }
}
