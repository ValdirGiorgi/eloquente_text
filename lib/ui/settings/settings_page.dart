import 'package:fluent_ui/fluent_ui.dart';

import '../../ai/provider_catalog.dart';
import '../../data/settings_repository.dart';
import '../../models/model_config.dart';
import '../common/app_info_bar.dart';
import '../common/detail_page.dart';
import '../common/labeled_combo_box.dart';
import 'widgets/api_key_field.dart';
import 'widgets/model_form.dart';
import 'widgets/model_list.dart';

/// Provedor de IA, API key e modelos cadastrados.
///
/// Cada provedor tem a própria chave e a própria lista de modelos: trocar o
/// provedor no seletor recarrega tudo daquele provedor.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsRepository _settings = SettingsRepository();

  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelNameController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();

  AiProviderKind _provider = AiProviderKind.fallback;
  List<ModelConfig> _models = [];
  String? _defaultModel;

  @override
  void initState() {
    super.initState();
    _loadSelectedProvider();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelNameController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedProvider() async {
    final provider = await _settings.selectedProvider();
    await _loadProvider(provider);
  }

  Future<void> _loadProvider(AiProviderKind provider) async {
    final apiKey = await _settings.apiKey(provider);
    final models = await _settings.models(provider);
    final defaultModel = await _settings.defaultModel(provider);

    // Um modelo salvo como padrão antes da lista existir pode não estar
    // cadastrado; mostra ele mesmo assim, para não sumir da tela.
    if (defaultModel != null &&
        defaultModel.isNotEmpty &&
        !models.any((model) => model.name == defaultModel)) {
      models.add(ModelConfig(name: defaultModel));
    }

    if (!mounted) return;
    setState(() {
      _provider = provider;
      _apiKeyController.text = apiKey ?? '';
      _models = models;
      _defaultModel = defaultModel?.isNotEmpty ?? false
          ? defaultModel
          : (models.isEmpty ? null : models.first.name);
    });
  }

  Future<void> _save() async {
    await _settings.saveSelectedProvider(_provider);
    if (_apiKeyController.text.isNotEmpty) {
      await _settings.saveApiKey(_provider, _apiKeyController.text);
    }
    final defaultModel = _defaultModel;
    if (defaultModel != null && defaultModel.isNotEmpty) {
      await _settings.saveDefaultModel(_provider, defaultModel);
    }
    if (mounted) showSuccessBar(context, 'Configurações salvas!');
  }

  Future<void> _addModel() async {
    final name = _modelNameController.text.trim();
    if (name.isEmpty) return;

    final model = ModelConfig(
      name: name,
      temperature: double.tryParse(
        _temperatureController.text.trim().replaceAll(',', '.'),
      ),
    );
    await _settings.upsertModel(_provider, model);

    setState(() {
      final index = _models.indexWhere((m) => m.name == name);
      if (index >= 0) {
        _models[index] = model;
      } else {
        _models.add(model);
      }
      _defaultModel ??= name;
      _modelNameController.clear();
      _temperatureController.clear();
    });
  }

  Future<void> _removeModel(ModelConfig model) async {
    await _settings.removeModel(_provider, model.name);
    setState(() {
      _models.removeWhere((m) => m.name == model.name);
      if (_defaultModel == model.name) {
        _defaultModel = _models.isEmpty ? null : _models.first.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DetailPage(
      title: 'Configurações',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledComboBox<AiProviderKind>(
              label: 'Provedor de IA',
              value: _provider,
              items: AiProviderKind.values,
              itemLabel: (provider) => provider.label,
              onChanged: _loadProvider,
            ),
            const SizedBox(height: 16),
            ApiKeyField(controller: _apiKeyController, provider: _provider),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Modelos para ${_provider.label}',
              style: FluentTheme.of(context).typography.subtitle,
            ),
            const SizedBox(height: 12),
            ModelForm(
              nameController: _modelNameController,
              temperatureController: _temperatureController,
              onAdd: _addModel,
            ),
            const SizedBox(height: 16),
            if (_models.isEmpty)
              const Text('Nenhum modelo cadastrado.')
            else ...[
              LabeledComboBox<String>(
                label: 'Modelo Padrão',
                value: _defaultModel,
                items: _models.map((model) => model.name).toList(),
                itemLabel: (name) => name,
                onChanged: (name) => setState(() => _defaultModel = name),
              ),
              const SizedBox(height: 16),
              ModelList(models: _models, onRemove: _removeModel),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _save,
                child: const Text(
                  'Salvar Tudo',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
