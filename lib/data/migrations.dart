import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Versão atual do schema. Ao mudar o banco: incremente este número, ajuste
/// [createSchema] e acrescente um bloco novo em [upgradeSchema].
const int schemaVersion = 5;

/// Schema de uma instalação nova.
///
/// `history` guarda os textos processados e pode ser limpa pelo usuário;
/// `stats_log` guarda só as métricas e sobrevive a essa limpeza; `settings`
/// é um chave/valor genérico (veja `settings_repository.dart`).
Future<void> createSchema(Database db) async {
  await db.execute('''
    CREATE TABLE history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
      original_text TEXT NOT NULL,
      enhanced_text TEXT NOT NULL,
      tone TEXT NOT NULL,
      purpose TEXT NOT NULL,
      ai_provider TEXT NOT NULL,
      model_used TEXT,
      character_count INTEGER,
      input_tokens INTEGER DEFAULT 0,
      output_tokens INTEGER DEFAULT 0,
      response_time_ms INTEGER DEFAULT 0,
      cached_tokens INTEGER DEFAULT 0
    )
  ''');

  await db.execute('''
    CREATE TABLE stats_log (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
      ai_provider TEXT NOT NULL,
      model_used TEXT,
      input_tokens INTEGER DEFAULT 0,
      output_tokens INTEGER DEFAULT 0,
      response_time_ms INTEGER DEFAULT 0,
      cached_tokens INTEGER DEFAULT 0
    )
  ''');

  await db.execute('''
    CREATE TABLE settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');
}

/// Migrações incrementais.
///
/// Cada bloco é independente e cumulativo — uma instalação antiga passa por
/// todos os que se aplicam —, então nunca remova nem reescreva um bloco já
/// publicado: só acrescente novos ao final.
Future<void> upgradeSchema(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute(
      'ALTER TABLE history ADD COLUMN input_tokens INTEGER DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE history ADD COLUMN output_tokens INTEGER DEFAULT 0',
    );
  }
  if (oldVersion < 3) {
    await db.execute(
      'ALTER TABLE history ADD COLUMN response_time_ms INTEGER DEFAULT 0',
    );
  }
  if (oldVersion < 4) {
    await db.execute('''
      CREATE TABLE stats_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        ai_provider TEXT NOT NULL,
        model_used TEXT,
        input_tokens INTEGER DEFAULT 0,
        output_tokens INTEGER DEFAULT 0,
        response_time_ms INTEGER DEFAULT 0
      )
    ''');
    // stats_log nasceu para as estatísticas sobreviverem à limpeza do
    // histórico; ao criá-la, copia o que já existia em history.
    await db.execute('''
      INSERT INTO stats_log (
        timestamp, ai_provider, model_used,
        input_tokens, output_tokens, response_time_ms
      )
      SELECT timestamp, ai_provider, model_used,
             input_tokens, output_tokens, response_time_ms
      FROM history
    ''');
  }
  if (oldVersion < 5) {
    await db.execute(
      'ALTER TABLE history ADD COLUMN cached_tokens INTEGER DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE stats_log ADD COLUMN cached_tokens INTEGER DEFAULT 0',
    );
  }
}
