import 'package:fluent_ui/fluent_ui.dart';

/// Par ícone + texto para uma métrica compacta (tokens, tempo de resposta,
/// % de cache). Usado tanto na tela principal (última requisição) quanto
/// no histórico (por item), para os dois lugares terem a mesma cara.
class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
