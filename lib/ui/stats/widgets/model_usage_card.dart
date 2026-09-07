import 'package:fluent_ui/fluent_ui.dart';

import '../../../models/usage_stats.dart';
import '../../common/provider_colors.dart';

/// Uma linha do detalhamento por modelo: requisições, cache e tempo médio.
class ModelUsageCard extends StatelessWidget {
  const ModelUsageCard({super.key, required this.usage});

  final ModelUsage usage;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final averageSeconds = usage.averageResponseTime.inMilliseconds / 1000;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: colorForProviderLabel(usage.providerLabel),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${usage.providerLabel} (${usage.modelUsed ?? 'Padrão'})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${usage.requestCount} requisições',
                    style: TextStyle(
                      color: theme.resources.textFillColorSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (usage.cacheHitPercentage > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${usage.cacheHitPercentage.toStringAsFixed(0)}% dos '
                      'tokens vieram do cache',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${averageSeconds.toStringAsFixed(2)}s',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'tempo médio',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.resources.textFillColorSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
