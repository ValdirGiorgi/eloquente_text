import 'package:fluent_ui/fluent_ui.dart';

import '../../common/request_metrics.dart';
import '../home_controller.dart';

/// Rodapé do campo de resultado: métricas da última chamada à esquerda e o
/// botão de copiar à direita.
class ResultFooter extends StatelessWidget {
  const ResultFooter({
    super.key,
    required this.controller,
    required this.onCopy,
  });

  final HomeController controller;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final response = controller.lastResponse;
    final showMetrics =
        response != null && controller.hasResult && !controller.isProcessing;

    return Row(
      children: [
        Expanded(
          child: showMetrics
              ? RequestMetrics(
                  characters: '${controller.inputController.text.length} → '
                      '${controller.outputController.text.length} caracteres',
                  inputTokens: response.inputTokens,
                  outputTokens: response.outputTokens,
                  cacheHitPercentage: response.cacheHitPercentage,
                  responseTime: response.responseTime,
                )
              : const SizedBox.shrink(),
        ),
        Button(
          onPressed: onCopy,
          child: const Row(
            children: [
              Icon(FluentIcons.copy),
              SizedBox(width: 8),
              Text('Copiar'),
            ],
          ),
        ),
      ],
    );
  }
}
