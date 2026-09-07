import 'package:fluent_ui/fluent_ui.dart';

import 'metric_chip.dart';

/// Métricas de um processamento: contagem de caracteres (opcional), tokens,
/// tempo de resposta e percentual de cache.
///
/// Usada na tela principal (última chamada) e no histórico (por item), para
/// as duas mostrarem a mesma informação com a mesma aparência.
class RequestMetrics extends StatelessWidget {
  const RequestMetrics({
    super.key,
    required this.inputTokens,
    required this.outputTokens,
    required this.cacheHitPercentage,
    required this.responseTime,
    this.characters,
  });

  final int inputTokens;
  final int outputTokens;
  final double cacheHitPercentage;
  final Duration responseTime;

  /// Texto do primeiro item, quando a tela tem os dois textos em mãos
  /// (ex.: "320 → 280 caracteres").
  final String? characters;

  @override
  Widget build(BuildContext context) {
    final color = FluentTheme.of(context).resources.textFillColorSecondary;
    final seconds = (responseTime.inMilliseconds / 1000).toStringAsFixed(1);

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (characters != null)
          MetricChip(icon: FluentIcons.font, label: characters!, color: color),
        MetricChip(
          icon: FluentIcons.b_i_dashboard,
          label: '$inputTokens → $outputTokens tokens',
          color: color,
        ),
        MetricChip(
          icon: FluentIcons.stopwatch,
          label: '${seconds}s',
          color: color,
        ),
        if (cacheHitPercentage > 0)
          MetricChip(
            icon: FluentIcons.database,
            label: '${cacheHitPercentage.toStringAsFixed(0)}% cache',
            color: Colors.teal,
          ),
      ],
    );
  }
}
