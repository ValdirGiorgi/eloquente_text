import 'package:fluent_ui/fluent_ui.dart';

/// Botão principal da tela: dispara o processamento e vira um indicador de
/// progresso enquanto a resposta não chega.
class EnhanceButton extends StatelessWidget {
  const EnhanceButton({
    super.key,
    required this.isProcessing,
    required this.onPressed,
  });

  final bool isProcessing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: isProcessing ? null : onPressed,
        child: isProcessing
            ? const ProgressRing(strokeWidth: 2.5)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FluentIcons.auto_enhance_on),
                  SizedBox(width: 8),
                  Text('Melhorar Texto', style: TextStyle(fontSize: 16)),
                ],
              ),
      ),
    );
  }
}
