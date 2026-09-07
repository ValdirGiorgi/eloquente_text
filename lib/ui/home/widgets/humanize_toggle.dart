import 'package:fluent_ui/fluent_ui.dart';

/// Liga o modo Humanizar, que anexa ao prompt as instruções contra marcas
/// típicas de texto gerado por IA (veja
/// `lib/ai/prompts/humanizer_instructions.dart`).
class HumanizeToggle extends StatelessWidget {
  const HumanizeToggle({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: 'Reescreve o texto evitando marcas típicas de IA '
              '(clichês, listas forçadas, travessões em excesso etc.), '
              'inspirado no projeto humanizer '
              '(github.com/blader/humanizer).',
          child: ToggleSwitch(
            checked: enabled,
            onChanged: onChanged,
            content: const Text('Humanizar'),
          ),
        ),
      ],
    );
  }
}
