import '../models/ai_response.dart';
import '../models/usage_stats.dart';
import 'app_database.dart';

/// Métricas de uso (tabela `stats_log`).
///
/// Guarda só números — nenhum texto do usuário — e por isso continua
/// intacta quando o histórico é limpo.
class StatsRepository {
  StatsRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Quantos dias o gráfico de atividade mostra.
  static const int activityDays = 7;

  Future<void> log({
    required AiResponse response,
    required String providerLabel,
    String? modelUsed,
  }) async {
    final db = await _database.database;
    await db.insert('stats_log', {
      'ai_provider': providerLabel,
      'model_used': modelUsed,
      'input_tokens': response.inputTokens,
      'output_tokens': response.outputTokens,
      'response_time_ms': response.responseTime.inMilliseconds,
      'cached_tokens': response.cachedInputTokens,
    });
  }

  Future<UsageSummary> summary() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT
        COUNT(*) AS count,
        SUM(input_tokens) AS input_tokens,
        SUM(output_tokens) AS output_tokens,
        SUM(cached_tokens) AS cached_tokens,
        AVG(response_time_ms) AS avg_time
      FROM stats_log
    ''');

    if (rows.isEmpty) return const UsageSummary();
    final row = rows.first;
    return UsageSummary(
      requestCount: row['count'] as int? ?? 0,
      inputTokens: row['input_tokens'] as int? ?? 0,
      outputTokens: row['output_tokens'] as int? ?? 0,
      cachedTokens: row['cached_tokens'] as int? ?? 0,
      averageResponseTime: Duration(
        milliseconds: ((row['avg_time'] as num?) ?? 0).round(),
      ),
    );
  }

  Future<List<ModelUsage>> byModel() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT
        ai_provider,
        model_used,
        COUNT(*) AS count,
        SUM(input_tokens) AS input_tokens,
        SUM(output_tokens) AS output_tokens,
        SUM(cached_tokens) AS cached_tokens,
        AVG(response_time_ms) AS avg_time
      FROM stats_log
      GROUP BY ai_provider, model_used
      ORDER BY count DESC
    ''');
    return rows.map(ModelUsage.fromRow).toList();
  }

  /// Processamentos por dia, do mais antigo para o mais recente (a ordem
  /// que o gráfico de linha espera).
  Future<List<DailyUsage>> dailyActivity({int days = activityDays}) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      '''
      SELECT date(timestamp) AS day, COUNT(*) AS count
      FROM stats_log
      GROUP BY date(timestamp)
      ORDER BY day DESC
      LIMIT ?
    ''',
      [days],
    );
    return rows.reversed.map(DailyUsage.fromRow).toList();
  }

  Future<void> clear() async {
    final db = await _database.database;
    await db.delete('stats_log');
  }
}
