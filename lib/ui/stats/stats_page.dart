import 'package:fluent_ui/fluent_ui.dart';

import '../../data/stats_repository.dart';
import '../../models/usage_stats.dart';
import '../common/app_info_bar.dart';
import '../common/confirm_dialog.dart';
import '../common/detail_page.dart';
import 'widgets/activity_chart.dart';
import 'widgets/kpi_card.dart';
import 'widgets/model_usage_card.dart';
import 'widgets/provider_pie_chart.dart';

/// Painel de uso: totais, atividade por dia e detalhamento por modelo.
///
/// Os dados vêm de `stats_log`, que guarda só métricas — nenhum texto — e
/// por isso continua íntegro mesmo depois de o histórico ser limpo.
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final StatsRepository _repository = StatsRepository();

  UsageSummary _summary = const UsageSummary();
  List<ModelUsage> _usageByModel = [];
  List<DailyUsage> _activity = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await _repository.summary();
    final usageByModel = await _repository.byModel();
    final activity = await _repository.dailyActivity();

    if (!mounted) return;
    setState(() {
      _summary = summary;
      _usageByModel = usageByModel;
      _activity = activity;
      _isLoading = false;
    });
  }

  Future<void> _clear() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Zerar Estatísticas',
      message:
          'Tem certeza que deseja apagar todas as estatísticas acumuladas? '
          'Isso não pode ser desfeito e não afeta o histórico de textos.',
      confirmLabel: 'Zerar Tudo',
    );
    if (!confirmed) return;

    await _repository.clear();
    await _load();
    if (mounted) showSuccessBar(context, 'Estatísticas zeradas com sucesso.');
  }

  @override
  Widget build(BuildContext context) {
    return DetailPage(
      title: 'Estatísticas',
      commands: [
        CommandBarButton(
          icon: const Icon(FluentIcons.delete),
          label: const Text('Zerar Estatísticas'),
          onPressed: _clear,
        ),
      ],
      child: _isLoading
          ? const Center(child: ProgressRing())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildKpiRow(),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ActivityChart(activity: _activity),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: ProviderPieChart(usageByModel: _usageByModel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildModelDetails(context),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiRow() {
    final cacheHit = _summary.cacheHitPercentage;
    final averageSeconds = _summary.averageResponseTime.inMilliseconds / 1000;

    final cards = [
      KpiCard(
        title: 'Requisições',
        value: '${_summary.requestCount}',
        icon: FluentIcons.number_symbol,
        accent: Colors.blue,
      ),
      KpiCard(
        title: 'Tempo Médio',
        value: '${averageSeconds.toStringAsFixed(1)}s',
        icon: FluentIcons.stopwatch,
        accent: Colors.orange,
      ),
      KpiCard(
        title: 'Tokens Gerados',
        value: '${_summary.totalTokens}',
        icon: FluentIcons.b_i_dashboard,
        accent: Colors.purple,
      ),
      KpiCard(
        title: 'Economia de Cache',
        value: cacheHit == null ? '--' : '${cacheHit.toStringAsFixed(0)}%',
        icon: FluentIcons.database,
        accent: Colors.teal,
      ),
    ];

    return Row(
      children: [
        for (final card in cards) ...[
          Expanded(child: card),
          if (card != cards.last) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _buildModelDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes por Modelo',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 12),
        if (_usageByModel.isEmpty)
          const Text('Nenhum processamento registrado ainda.')
        else
          for (final usage in _usageByModel) ModelUsageCard(usage: usage),
      ],
    );
  }
}
