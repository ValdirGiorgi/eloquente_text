import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

import '../../../models/usage_stats.dart';
import 'chart_card.dart';

/// Processamentos por dia, nos últimos dias em que houve uso — a consulta
/// pula dias sem nenhum registro (veja `StatsRepository.dailyActivity`).
class ActivityChart extends StatelessWidget {
  const ActivityChart({super.key, required this.activity});

  static final DateFormat _dayFormat = DateFormat('dd/MM');

  final List<DailyUsage> activity;

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Atividade por dia',
      isEmpty: activity.isEmpty,
      emptyMessage: 'Sem atividade recente',
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: _hiddenTitles,
            topTitles: _hiddenTitles,
            leftTitles: _hiddenTitles,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: _buildDayLabel,
              ),
            ),
          ),
          lineBarsData: [_buildLine(context)],
        ),
      ),
    );
  }

  static const AxisTitles _hiddenTitles = AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  );

  /// O eixo X é o índice do ponto; o rótulo mostra a data correspondente.
  Widget _buildDayLabel(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= activity.length) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _dayFormat.format(activity[index].day),
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  LineChartBarData _buildLine(BuildContext context) {
    final accent = FluentTheme.of(context).accentColor;
    return LineChartBarData(
      spots: [
        for (var i = 0; i < activity.length; i++)
          FlSpot(i.toDouble(), activity[i].requestCount.toDouble()),
      ],
      isCurved: true,
      color: accent,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: accent.withValues(alpha: 0.15),
      ),
    );
  }
}
