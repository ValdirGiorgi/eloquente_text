import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../../models/usage_stats.dart';
import '../../common/provider_colors.dart';
import 'chart_card.dart';

/// Distribuição dos processamentos entre os provedores de IA.
class ProviderPieChart extends StatelessWidget {
  const ProviderPieChart({super.key, required this.usageByModel});

  /// Abaixo desta fatia do total, o rótulo não cabe dentro da seção.
  static const double _labelThreshold = 0.15;

  final List<ModelUsage> usageByModel;

  @override
  Widget build(BuildContext context) {
    final byProvider = _countByProvider();
    return ChartCard(
      title: 'Por Provedor',
      isEmpty: byProvider.isEmpty,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _buildSections(byProvider),
        ),
      ),
    );
  }

  Map<String, int> _countByProvider() {
    final counts = <String, int>{};
    for (final usage in usageByModel) {
      counts[usage.providerLabel] =
          (counts[usage.providerLabel] ?? 0) + usage.requestCount;
    }
    return counts;
  }

  List<PieChartSectionData> _buildSections(Map<String, int> byProvider) {
    final total = byProvider.values.fold(0, (sum, count) => sum + count);
    return [
      for (final entry in byProvider.entries)
        PieChartSectionData(
          color: colorForProviderLabel(entry.key),
          value: entry.value.toDouble(),
          title: entry.value / total > _labelThreshold
              ? '${entry.key}\n${entry.value}'
              : '',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];
  }
}
