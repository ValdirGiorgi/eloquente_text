import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../ai/provider_catalog.dart';
import '../models/model_config.dart';
import '../models/purpose.dart';
import '../models/tone.dart';
import 'app_database.dart';
import 'encryption_service.dart';

/// Configurações do app, guardadas na tabela chave/valor `settings`.
///
/// A tabela é genérica; os métodos abaixo são a única forma tipada de
/// acessá-la, para nenhuma tela precisar conhecer os nomes das chaves. API
/// keys passam sempre por [EncryptionService] antes de serem gravadas.
class SettingsRepository {
  SettingsRepository({AppDatabase? database, SecretCodec? encryption})
      : _database = database ?? AppDatabase.instance,
        _encryption = encryption ?? EncryptionService.instance;

  final AppDatabase _database;
  final SecretCodec _encryption;

  static const String _providerKey = 'current_provider';
  static const String _toneKey = 'last_tone';
  static const String _purposeKey = 'last_purpose';
  static const String _humanizeKey = 'last_humanize';
  static const String _apiKeyPrefix = 'apikey_';
  static const String _defaultModelPrefix = 'model_';
  static const String _modelListPrefix = 'models_list_';

  // --- Provedor selecionado ---

  Future<AiProviderKind> selectedProvider() async {
    return AiProviderKind.fromLabel(await _read(_providerKey)) ??
        AiProviderKind.fallback;
  }

  Future<void> saveSelectedProvider(AiProviderKind provider) =>
      _write(_providerKey, provider.label);

  // --- API keys ---

  /// `null` quando não há chave salva ou quando ela não pôde ser
  /// descriptografada (arquivo `security.key` trocado, por exemplo).
  Future<String?> apiKey(AiProviderKind provider) async {
    final encrypted = await _read('$_apiKeyPrefix${provider.label}');
    if (encrypted == null || encrypted.isEmpty) return null;
    try {
      return _encryption.decryptValue(encrypted);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveApiKey(AiProviderKind provider, String apiKey) => _write(
        '$_apiKeyPrefix${provider.label}',
        _encryption.encryptValue(apiKey),
      );

  // --- Modelos ---

  /// Modelo pré-selecionado nas telas para este provedor.
  Future<String?> defaultModel(AiProviderKind provider) =>
      _read('$_defaultModelPrefix${provider.label}');

  /// Grava o modelo padrão e garante que ele apareça na lista cadastrada.
  Future<void> saveDefaultModel(AiProviderKind provider, String model) async {
    await _write('$_defaultModelPrefix${provider.label}', model);
    if (model.isNotEmpty) {
      await upsertModel(provider, ModelConfig(name: model));
    }
  }

  Future<List<ModelConfig>> models(AiProviderKind provider) async {
    final raw = await _read('$_modelListPrefix${provider.label}');
    if (raw == null || raw.trim().isEmpty) return [];
    if (!raw.trim().startsWith('[')) return _parseLegacyModelList(raw);

    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(ModelConfig.fromJson)
          .toList();
    } on FormatException {
      return [];
    }
  }

  /// Versões antigas do app gravavam a lista como nomes separados por
  /// vírgula, sem temperatura. Interpreta esse formato em vez de descartar
  /// a lista de quem já usava o app.
  List<ModelConfig> _parseLegacyModelList(String raw) => raw
      .split(',')
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .map((name) => ModelConfig(name: name))
      .toList();

  Future<void> saveModels(
    AiProviderKind provider,
    List<ModelConfig> models,
  ) async {
    final json = jsonEncode(models.map((m) => m.toJson()).toList());
    await _write('$_modelListPrefix${provider.label}', json);
  }

  /// Adiciona o modelo, ou substitui o cadastro existente com o mesmo nome.
  Future<void> upsertModel(AiProviderKind provider, ModelConfig model) async {
    final current = await models(provider);
    final index = current.indexWhere((m) => m.name == model.name);
    if (index >= 0) {
      current[index] = model;
    } else {
      current.add(model);
    }
    await saveModels(provider, current);
  }

  Future<void> removeModel(AiProviderKind provider, String modelName) async {
    final current = await models(provider);
    current.removeWhere((m) => m.name == modelName);
    await saveModels(provider, current);
  }

  /// Temperatura fixada para um modelo, ou `null` para usar o padrão da API.
  Future<double?> temperatureFor(
    AiProviderKind provider,
    String modelName,
  ) async {
    for (final model in await models(provider)) {
      if (model.name == modelName) return model.temperature;
    }
    return null;
  }

  // --- Últimas escolhas da tela principal ---

  Future<Tone> lastTone() async =>
      Tone.fromLabel(await _read(_toneKey)) ?? Tone.formal;

  Future<void> saveLastTone(Tone tone) => _write(_toneKey, tone.label);

  Future<Purpose> lastPurpose() async =>
      Purpose.fromLabel(await _read(_purposeKey)) ?? Purpose.professionalEmail;

  Future<void> saveLastPurpose(Purpose purpose) =>
      _write(_purposeKey, purpose.label);

  Future<bool> humanizeEnabled() async => await _read(_humanizeKey) == 'true';

  Future<void> saveHumanizeEnabled(bool enabled) =>
      _write(_humanizeKey, enabled.toString());

  // --- Acesso bruto à tabela ---

  Future<String?> _read(String key) async {
    final db = await _database.database;
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> _write(String key, String value) async {
    final db = await _database.database;
    await db.insert(
        'settings',
        {
          'key': key,
          'value': value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
