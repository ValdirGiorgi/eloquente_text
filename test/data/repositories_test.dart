// Testes das camadas de dados sobre um banco SQLite em memória
// (AppDatabase.inMemory), sem tocar em nenhum arquivo do usuário.

import 'package:eloquente_text/ai/provider_catalog.dart';
import 'package:eloquente_text/data/app_database.dart';
import 'package:eloquente_text/data/encryption_service.dart';
import 'package:eloquente_text/data/history_repository.dart';
import 'package:eloquente_text/data/settings_repository.dart';
import 'package:eloquente_text/data/stats_repository.dart';
import 'package:eloquente_text/models/ai_response.dart';
import 'package:eloquente_text/models/language.dart';
import 'package:eloquente_text/models/model_config.dart';
import 'package:eloquente_text/models/purpose.dart';
import 'package:eloquente_text/models/tone.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cifragem falsa: só prefixa o valor, para o teste conseguir verificar que
/// a chave passou pela camada de criptografia.
class _FakeCodec implements SecretCodec {
  static const String prefix = 'cifrado:';

  @override
  String encryptValue(String plainText) => '$prefix$plainText';

  @override
  String decryptValue(String encryptedValue) =>
      encryptedValue.substring(prefix.length);
}

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.inMemory());
  tearDown(() => database.close());

  group('SettingsRepository', () {
    late SettingsRepository settings;

    setUp(() {
      settings = SettingsRepository(
        database: database,
        encryption: _FakeCodec(),
      );
    });

    test('usa o provedor padrão enquanto nada foi escolhido', () async {
      expect(await settings.selectedProvider(), AiProviderKind.fallback);
    });

    test('grava e lê o provedor escolhido', () async {
      await settings.saveSelectedProvider(AiProviderKind.anthropic);
      expect(await settings.selectedProvider(), AiProviderKind.anthropic);
    });

    test('grava a API key criptografada e a devolve em claro', () async {
      await settings.saveApiKey(AiProviderKind.openAi, 'sk-secreta');

      expect(await settings.apiKey(AiProviderKind.openAi), 'sk-secreta');
      // Chave de outro provedor não é afetada.
      expect(await settings.apiKey(AiProviderKind.gemini), isNull);
    });

    test('cada provedor tem a própria lista de modelos', () async {
      await settings.upsertModel(
        AiProviderKind.openAi,
        const ModelConfig(name: 'gpt-4o', temperature: 0.3),
      );
      await settings.upsertModel(
        AiProviderKind.gemini,
        const ModelConfig(name: 'gemini-2.0-flash'),
      );

      final openAiModels = await settings.models(AiProviderKind.openAi);
      expect(openAiModels.single.name, 'gpt-4o');
      expect(
        await settings.temperatureFor(AiProviderKind.openAi, 'gpt-4o'),
        0.3,
      );
      expect((await settings.models(AiProviderKind.gemini)).single.name,
          'gemini-2.0-flash');
    });

    test('cadastrar de novo o mesmo modelo substitui a temperatura', () async {
      await settings.upsertModel(
        AiProviderKind.openAi,
        const ModelConfig(name: 'gpt-4o', temperature: 0.3),
      );
      await settings.upsertModel(
        AiProviderKind.openAi,
        const ModelConfig(name: 'gpt-4o'),
      );

      final models = await settings.models(AiProviderKind.openAi);
      expect(models, hasLength(1));
      expect(models.single.temperature, isNull);
    });

    test('remove um modelo da lista', () async {
      await settings.upsertModel(
        AiProviderKind.openAi,
        const ModelConfig(name: 'gpt-4o'),
      );
      await settings.removeModel(AiProviderKind.openAi, 'gpt-4o');

      expect(await settings.models(AiProviderKind.openAi), isEmpty);
    });

    test('o modelo padrão entra automaticamente na lista', () async {
      await settings.saveDefaultModel(AiProviderKind.openAi, 'gpt-4o-mini');

      expect(await settings.defaultModel(AiProviderKind.openAi), 'gpt-4o-mini');
      expect(
        (await settings.models(AiProviderKind.openAi)).single.name,
        'gpt-4o-mini',
      );
    });

    test('lê a lista no formato legado separado por vírgulas', () async {
      final db = await database.database;
      await db.insert('settings', {
        'key': 'models_list_OpenAI',
        'value': 'gpt-4o, gpt-4o-mini',
      });

      final models = await settings.models(AiProviderKind.openAi);
      expect(models.map((m) => m.name), ['gpt-4o', 'gpt-4o-mini']);
      expect(models.every((m) => m.temperature == null), isTrue);
    });

    test('guarda as últimas escolhas da tela principal', () async {
      await settings.saveLastTone(Tone.friendly);
      await settings.saveLastPurpose(Purpose.whatsApp);
      await settings.saveLastLanguage(Language.spanish);
      await settings.saveHumanizeEnabled(true);

      expect(await settings.lastTone(), Tone.friendly);
      expect(await settings.lastPurpose(), Purpose.whatsApp);
      expect(await settings.lastLanguage(), Language.spanish);
      expect(await settings.humanizeEnabled(), isTrue);
    });

    test('usa português como idioma padrão enquanto nada foi escolhido',
        () async {
      expect(await settings.lastLanguage(), Language.portuguese);
    });
  });

  group('HistoryRepository', () {
    late HistoryRepository history;

    setUp(() => history = HistoryRepository(database: database));

    Future<void> saveEntry(String original) => history.save(
          originalText: original,
          response: const AiResponse(
            text: 'Texto melhorado.',
            inputTokens: 100,
            outputTokens: 20,
            cachedInputTokens: 25,
            responseTime: Duration(milliseconds: 1500),
          ),
          tone: Tone.formal,
          purpose: Purpose.professionalEmail,
          providerLabel: AiProviderKind.openAi.label,
          modelUsed: 'gpt-4o',
        );

    test('grava e devolve o processamento com as métricas', () async {
      await saveEntry('texto original');

      final entry = (await history.recent()).single;
      expect(entry.originalText, 'texto original');
      expect(entry.enhancedText, 'Texto melhorado.');
      expect(entry.tone, 'Formal');
      expect(entry.purpose, 'E-mail Profissional');
      expect(entry.modelUsed, 'gpt-4o');
      expect(entry.responseTime, const Duration(milliseconds: 1500));
      expect(entry.cacheHitPercentage, 25);
    });

    test('a busca cobre o texto original e o melhorado', () async {
      await saveEntry('reunião de segunda');

      final entry = (await history.recent()).single;
      expect(entry.matches('REUNIÃO'), isTrue);
      expect(entry.matches('melhorado'), isTrue);
      expect(entry.matches('inexistente'), isFalse);
    });

    test('apaga um item e limpa tudo', () async {
      await saveEntry('primeiro');
      await saveEntry('segundo');

      final first = (await history.recent()).first;
      await history.delete(first.id);
      expect(await history.recent(), hasLength(1));

      await history.clear();
      expect(await history.recent(), isEmpty);
    });
  });

  group('StatsRepository', () {
    late StatsRepository stats;

    setUp(() => stats = StatsRepository(database: database));

    Future<void> log(AiProviderKind provider, String model, int input) {
      return stats.log(
        response: AiResponse(
          text: 'texto',
          inputTokens: input,
          outputTokens: 10,
          cachedInputTokens: input ~/ 2,
          responseTime: const Duration(seconds: 2),
        ),
        providerLabel: provider.label,
        modelUsed: model,
      );
    }

    test('soma tokens e calcula o tempo médio', () async {
      await log(AiProviderKind.openAi, 'gpt-4o', 100);
      await log(AiProviderKind.openAi, 'gpt-4o', 200);

      final summary = await stats.summary();
      expect(summary.requestCount, 2);
      expect(summary.inputTokens, 300);
      expect(summary.outputTokens, 20);
      expect(summary.totalTokens, 320);
      expect(summary.cacheHitPercentage, 50);
      expect(summary.averageResponseTime, const Duration(seconds: 2));
    });

    test('sem registros, o percentual de cache é indefinido', () async {
      expect((await stats.summary()).cacheHitPercentage, isNull);
    });

    test('agrupa por provedor e modelo, do mais usado para o menos', () async {
      await log(AiProviderKind.openAi, 'gpt-4o', 100);
      await log(AiProviderKind.openAi, 'gpt-4o', 100);
      await log(AiProviderKind.gemini, 'gemini-2.0-flash', 50);

      final usage = await stats.byModel();
      expect(usage.first.modelUsed, 'gpt-4o');
      expect(usage.first.requestCount, 2);
      expect(usage.last.providerLabel, AiProviderKind.gemini.label);
    });

    test('conta os processamentos do dia no gráfico de atividade', () async {
      await log(AiProviderKind.openAi, 'gpt-4o', 100);

      final activity = await stats.dailyActivity();
      expect(activity.single.requestCount, 1);
    });

    test('zerar as estatísticas não depende do histórico', () async {
      await log(AiProviderKind.openAi, 'gpt-4o', 100);
      await stats.clear();

      expect((await stats.summary()).requestCount, 0);
    });
  });
}
