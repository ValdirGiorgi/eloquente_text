import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

import '../../../models/history_entry.dart';
import '../../common/request_metrics.dart';

/// Um item do histórico: cabeçalho com finalidade, data e provedor, e o
/// conteúdo expandido com métricas, os dois textos e os botões de copiar.
class HistoryEntryTile extends StatelessWidget {
  const HistoryEntryTile({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  static final DateFormat _dateFormat = DateFormat('dd/MM HH:mm');

  final HistoryEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Expander(
        header: _buildHeader(context),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RequestMetrics(
              inputTokens: entry.inputTokens,
              outputTokens: entry.outputTokens,
              cacheHitPercentage: entry.cacheHitPercentage,
              responseTime: entry.responseTime,
            ),
            const SizedBox(height: 12),
            _buildTextBlock(context, 'Original:', entry.originalText),
            _buildTextBlock(
              context,
              'Melhorado:',
              entry.enhancedText,
              highlighted: true,
            ),
            _buildCopyButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final subtitle = '${_dateFormat.format(entry.timestamp)} • '
        '${entry.providerLabel} (${entry.modelUsed ?? 'Padrão'})';

    return Row(
      children: [
        Icon(FluentIcons.history, size: 16, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.purpose,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: FluentTheme.of(
                    context,
                  ).resources.textFillColorSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(FluentIcons.delete, size: 14),
          onPressed: onDelete,
        ),
      ],
    );
  }

  /// O texto melhorado ganha uma faixa na cor de destaque à esquerda, para
  /// diferenciá-lo do original em uma olhada.
  Widget _buildTextBlock(
    BuildContext context,
    String label,
    String text, {
    bool highlighted = false,
  }) {
    final theme = FluentTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          decoration: BoxDecoration(
            color: theme.micaBackgroundColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: highlighted
                ? Border(
                    left: BorderSide(color: theme.accentColor, width: 3),
                  )
                : null,
          ),
          child: Text(
            text,
            style: highlighted
                ? null
                : TextStyle(color: theme.resources.textFillColorSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Button(
          onPressed: () => FlutterClipboard.copy(entry.originalText),
          child: const _CopyLabel('Original'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => FlutterClipboard.copy(entry.enhancedText),
          child: const _CopyLabel('Melhorado'),
        ),
      ],
    );
  }
}

class _CopyLabel extends StatelessWidget {
  const _CopyLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(FluentIcons.copy, size: 16),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
