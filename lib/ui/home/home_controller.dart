import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../ai/ai_provider.dart';
import '../../ai/ai_service.dart';
import '../../ai/enhance_request.dart';
import '../../ai/provider_catalog.dart';
import '../../data/history_repository.dart';
import '../../data/settings_repository.dart';
import '../../data/stats_repository.dart';
import '../../models/ai_response.dart';
import '../../models/purpose.dart';
import '../../models/tone.dart';

/// Estado e regras da tela principal, separados dos widgets.
///
/// Não conhece `BuildContext`: os métodos que podem falhar devolvem a
/// mensagem de erro (ou um `bool`) e é a tela que decide como mostrá-la.
class HomeController extends ChangeNotifier {
  HomeController({
    SettingsRepository? settings,
    HistoryRepository? history,
    StatsRepository? stats,
    AiService aiService = const AiService(),
  })  : _settings = settings ?? SettingsRepository(),
        _history = history ?? HistoryRepository(),
        _stats = stats ?? StatsRepository(),
        _aiService = aiService;

  final SettingsRepository _settings;
  final HistoryRepository _history;
  final StatsRepository _stats;
  final AiService _aiService;

  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController();

  Tone tone = Tone.formal;
  Purpose purpose = Purpose.professionalEmail;
  bool humanize = false;

  AiProviderKind provider = AiProviderKind.fallback;
  String selectedModel = '';
  List<String> availableModels = const [];

  bool isProcessing = false;

  /// Resposta da última chamada, para as métricas em tempo real abaixo do
  /// resultado (`null` antes do primeiro processamento).
  AiResponse? lastResponse;

  bool get hasResult => outputController.text.isNotEmpty;

  /// Recarrega as preferências salvas. Chamado ao abrir a tela e ao voltar
  /// das Configurações, onde provedor, modelos e API keys podem ter mudado.
  Future<void> loadSettings() async {
    tone = await _settings.lastTone();
    purpose = await _settings.lastPurpose();
    humanize = await _settings.humanizeEnabled();
    provider = await _settings.selectedProvider();
    await _loadModels();
  }

  Future<void> selectProvider(AiProviderKind newProvider) async {
    provider = newProvider;
    selectedModel = '';
    await _loadModels();
  }

  /// Lista os modelos cadastrados do provedor e escolhe qual fica
  /// selecionado — o padrão salvo, ou o primeiro da lista.
  Future<void> _loadModels() async {
    final configs = await _settings.models(provider);
    final defaultModel = await _settings.defaultModel(provider);

    availableModels = <String>{
      ...configs.map((config) => config.name),
      if (defaultModel != null && defaultModel.isNotEmpty) defaultModel,
    }.toList();

    if (!availableModels.contains(selectedModel)) {
      selectedModel = defaultModel?.isNotEmpty ?? false
          ? defaultModel!
          : (availableModels.isEmpty ? '' : availableModels.first);
    }
    notifyListeners();
  }

  void selectModel(String model) {
    selectedModel = model;
    notifyListeners();
  }

  Future<void> selectTone(Tone newTone) async {
    tone = newTone;
    notifyListeners();
    await _settings.saveLastTone(newTone);
  }

  Future<void> selectPurpose(Purpose newPurpose) async {
    purpose = newPurpose;
    notifyListeners();
    await _settings.saveLastPurpose(newPurpose);
  }

  Future<void> setHumanize(bool enabled) async {
    humanize = enabled;
    notifyListeners();
    await _settings.saveHumanizeEnabled(enabled);
  }

  /// Carrega no campo de entrada o texto da área de transferência (colocado
  /// lá pelo atalho global). Retorna `false` se não havia nada para colar.
  Future<bool> captureFromClipboard() async {
    final text = await FlutterClipboard.paste();
    if (text.isEmpty) return false;

    inputController.text = text;
    outputController.clear();
    lastResponse = null;
    notifyListeners();
    return true;
  }

  /// Processa o texto e registra o resultado no histórico e nas
  /// estatísticas. Retorna `null` em caso de sucesso, ou a mensagem de erro
  /// a ser exibida.
  Future<String?> enhanceText() async {
    final text = inputController.text.trim();
    if (text.isEmpty || isProcessing) return null;

    isProcessing = true;
    notifyListeners();

    try {
      final response = await _aiService.enhance(
        providerKind: provider,
        apiKey: await _settings.apiKey(provider) ?? '',
        model: selectedModel,
        request: EnhanceRequest(
          text: text,
          tone: tone,
          purpose: purpose,
          temperature: await _settings.temperatureFor(provider, selectedModel),
          humanize: humanize,
        ),
      );

      outputController.text = response.text;
      lastResponse = response;
      await _record(text, response);
      return null;
    } on AiProviderException catch (error) {
      return error.message;
    } catch (error) {
      return error.toString();
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  /// O histórico guarda os textos e pode ser limpo pelo usuário; o log de
  /// estatísticas guarda só as métricas e sobrevive a essa limpeza — por
  /// isso os dois recebem o mesmo processamento.
  Future<void> _record(String originalText, AiResponse response) async {
    final model = selectedModel.isEmpty ? null : selectedModel;
    await _history.save(
      originalText: originalText,
      response: response,
      tone: tone,
      purpose: purpose,
      providerLabel: provider.label,
      modelUsed: model,
    );
    await _stats.log(
      response: response,
      providerLabel: provider.label,
      modelUsed: model,
    );
  }

  /// Copia o resultado. Retorna `false` quando ainda não há nada copiar.
  Future<bool> copyResult() async {
    if (!hasResult) return false;
    await FlutterClipboard.copy(outputController.text);
    return true;
  }

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }
}
